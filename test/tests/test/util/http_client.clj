(ns util.http-client
  (:require [http.async.client :as http]
            [http.async.client.request :as http-req]
            [cheshire.core :as json])
  (:import (com.ning.http.client Request)
           (com.fasterxml.jackson.core JsonParseException)))

(defn make-request [client {:keys [method url] :as req}]
  (let [request ^Request (apply http-req/prepare-request method url (apply concat (dissoc req :method :url)))
        response (http/await (http-req/execute-request client request))]
    (assoc response
      :status (http/status response)
      :body (http/string response)
      :error (http/error response)
      :headers (http/headers response))))

(defn create-client [{:keys [connection-timeout request-timeout max-connections] :as config}]
  {:pre [connection-timeout request-timeout max-connections]}
  (let [cfg (merge {:connection-timeout   connection-timeout
                    :request-timeout      request-timeout
                    :read-timeout         request-timeout
                    :max-conns-per-host   max-connections
                    :max-conns-total      max-connections
                    :idle-in-pool-timeout 60000} config)]
    (apply http/create-client (apply concat cfg))))

(defn destroy [client]
  (http/close client))

(defn json-request [http-client req]
  (let [res (-> (make-request http-client
                              (update req :headers (fn [req-headers]
                                                      (merge {"content-type" "application/json"} req-headers))))
                (update :status :code)
                (update :body (fn [body]
                                (try
                                  (json/parse-string body true)
                                  (catch JsonParseException _ (throw
                                                                (RuntimeException. (str "expecting json response, was:'" body "'"))))))))]
    (when (:error res)
      (throw (:error res)))
    res))