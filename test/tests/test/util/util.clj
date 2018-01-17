(ns util.util
  (:require [clojure.test :refer :all]
            [clojure.java.data :as java]))

(defmethod java/from-java java.util.Map [instance]
  (into {} (map (fn [[k v]]
                  [(java/from-java k)
                   (java/from-java v)]) instance)))
(prefer-method java/from-java java.util.Map Iterable)

(defmethod java/from-java Boolean [instance] (boolean instance))

(defmacro try-for [msg how-long & body]
  `(let [start-time# (System/currentTimeMillis)]
     (loop []
       (let [[status# return#] (try
                                 (let [result# (do ~@body)]
                                   [(if result# ::ok ::fail) result#])
                                 (catch Throwable e# [::error e#]))
             more-time# (> (* ~how-long 1000)
                           (- (System/currentTimeMillis) start-time#))]
         (cond
           (= status# ::ok) return#
           more-time# (do (Thread/sleep 1000) (recur))
           (= status# ::fail) (throw (ex-info (str "Failed: " ~msg) {:last-result return#}))
           (= status# ::error) (throw (ex-info (str "Failed: " ~msg) {:last-result return#})))))))