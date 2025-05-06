FROM tomcat:latest
RUN rm -rf /usr/local/tomcat/webapps/*
COPY webapp/target/*.war /usr/local/tomcat/webapps/
