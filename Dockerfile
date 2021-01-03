FROM gradle:6.3.0-jdk11 AS assemble
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp

USER root
RUN chown -R gradle /usr/src/myapp
USER gradle
RUN ./gradlew clean assemble
# RUN ./gradlew build


FROM tomcat:9.0.30-jdk11-openjdk
WORKDIR /app
COPY --from=assemble /usr/src/myapp/build/libs/ /app

RUN mv AppsServices.war  /usr/local/tomcat/webapps/

ADD resources/docker/tomcat.keystore /usr/local/tomcat
COPY resources/docker/server.xml  /usr/local/tomcat/conf
COPY resources/docker/context.xml  /usr/local/tomcat/conf
COPY resources/docker/web.xml  /usr/local/tomcat/conf
RUN mkdir -p /root/.aws
COPY resources/docker/.aws /root/.aws
RUN mkdir -p /fop
COPY resources/docker/fop /fop

EXPOSE 8080