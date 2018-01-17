(ns tests.end-to-end-test
  {:integration true}
  (:require
    [util.util :as util]
    [util.http-client :as http]
    [clojure.tools.logging :refer [info debug]]
    [clojure.test :refer :all]
    [clojure.java.data :as java])
  (:import
    (com.github.dockerjava.api DockerClient)
    (com.github.dockerjava.core DockerClientBuilder)
    (com.github.dockerjava.api.exception NotModifiedException)))

(defonce ^DockerClient docker-client (.build (DockerClientBuilder/getInstance)))

(defonce http-client (http/create-client {:connection-timeout 10000
                                          :request-timeout    30000
                                          :max-connections    10}))

(defn containers []
  (-> docker-client
      .listContainersCmd
      (.withShowAll true)
      (.withLabelFilter {"com.docker.compose.project" "akvokeycloak"})
      .exec
      java/from-java))

(defn keycloak-container-id []
  (->> (containers)
       (filter (fn [{labels :labels}]
                 (= "keycloak1" (get labels "com.docker.compose.service"))))
       first
       :id))

(defn kill []
  (info "Killing Keycloak container")
  (try
    (.exec (.killContainerCmd docker-client (keycloak-container-id)))
    (catch Exception _)))

(defn start []
  (info "Starting Keycloak container")
  (.exec (.startContainerCmd docker-client (keycloak-container-id))))

(defn restart []
  (info "Restarting Keycloak container")
  (.exec (.restartContainerCmd docker-client (keycloak-container-id))))

(defn access-token [{:keys [url user password]}]
  (-> (http/json-request
        http-client
        {:method  :post
         :url     (str url "/realms/akvo/protocol/openid-connect/token")
         :headers {"content-type" "application/x-www-form-urlencoded"}
         :auth    {:type       :basic
                   :user       user
                   :password   password
                   :preemptive true}
         :body    {:grant_type "client_credentials"}})
      :body
      :access_token))

(defn keycloak-works []
  (util/try-for "Keycloak not working" 60
                (access-token {:url      "http://keycloak1:8080/auth"
                               :user     "akvo-flow"
                               :password "3918fbb4-3bc3-445a-8445-76826603b227"})))

(defn make-sure-keycloak-is-initialized []
  (try
    (start)
    (catch NotModifiedException _))
  (try
    ;; it is possible than Keycloak starts before the DB, in which case JBoss starts but not Keycloak
    ;; We give Keycloak some time and if it doesnt become available, we restart the process
    (keycloak-works)
    (catch Exception _
      (restart)
      (keycloak-works))))

(use-fixtures :once (fn [f]
                      (make-sure-keycloak-is-initialized)
                      (f)))

(deftest starts-in-a-reasonble-amount-of-time
  (dotimes [_ 4]
    (keycloak-works)
    (kill)
    (start)))