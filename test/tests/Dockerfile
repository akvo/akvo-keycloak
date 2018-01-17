FROM clojure:lein-2.7.1
MAINTAINER Akvo Foundation <devops@akvo.org>

WORKDIR /tests
COPY import-and-run.sh /tests
RUN chmod 777 /tests/import-and-run.sh
CMD ./import-and-run.sh
