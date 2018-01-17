(defproject tests "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url  "http://www.eclipse.org/legal/epl-v10.html"}
  :repl-options {:host "0.0.0.0"
                 :port 47480}
  :dependencies [[org.clojure/clojure "1.9.0"]

                 [org.clojure/tools.logging "0.3.1"]
                 [ch.qos.logback/logback-classic "1.1.7"]
                 [org.slf4j/jcl-over-slf4j "1.7.14"]
                 [org.slf4j/jul-to-slf4j "1.7.14"]
                 [org.slf4j/log4j-over-slf4j "1.7.14"]

                 [listora/again "0.1.0"]

                 [http.async.client "1.2.0"]
                 [cheshire "5.8.0"]

                 [mysql/mysql-connector-java "5.1.45"]
                 [org.clojure/java.jdbc "0.7.4"]

                 [com.github.docker-java/docker-java "3.0.14"]
                 [org.clojure/java.data "0.1.1"]])
