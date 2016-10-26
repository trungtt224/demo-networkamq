FROM java:8

RUN curl http://archive.apache.org/dist/activemq/5.11.1/apache-activemq-5.11.1-bin.tar.gz | tar xvz
EXPOSE 61616 1883 8161 

WORKDIR /apache-activemq-5.11.1/conf
RUN rm -f startup.sh
ADD activemq-cluster-config.sh /apache-activemq-5.11.1/conf/startup.sh

CMD ./startup.sh



