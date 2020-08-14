FROM centos as infra
# installing java
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk \
   PATH=$PATH:$JAVA_HOME
RUN yum install java-1.8.0-openjdk-devel -y

#installing maven

ENV Mvn_Version=3.6.3
ENV M2_HOME=/usr/local/apache-maven/apache-maven-${Mvn_Version}
ENV M2="${M2_HOME}/bin"
ENV PATH=$PATH:$M2
RUN yum install wget -y \
    && wget https://downloads.apache.org/maven/maven-3/${Mvn_Version}/binaries/apache-maven-${Mvn_Version}-bin.tar.gz \
    && tar xvfz apache-maven-${Mvn_Version}-bin.tar.gz \
    && mkdir /usr/local/apache-maven/apache-maven-${Mvn_Version} /opt/myapp -p \
    && mv apache-maven-${Mvn_Version}/* /usr/local/apache-maven/apache-maven-${Mvn_Version}/
COPY ./docker-dev/ /opt/myapp/
WORKDIR /opt/myapp/
RUN mvn clean install

# installing tomcat
FROM centos
# installing java
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk \
   PATH=$PATH:$JAVA_HOME
RUN yum install java-1.8.0-openjdk-devel -y

EXPOSE 8080
ENV Tomcat_Version=8.5.56
RUN mkdir /opt/tomcat/ -p \
   && yum install wget -y && wget http://www-eu.apache.org/dist/tomcat/tomcat-8/v${Tomcat_Version}/bin/apache-tomcat-${Tomcat_Version}.tar.gz \
   && tar xvfz apache-tomcat-${Tomcat_Version}.tar.gz \
   && rm -f apache-tomcat-${Tomcat_Version}.tar.gz \
   && mv apache-tomcat-${Tomcat_Version}/* /opt/tomcat/.
COPY ./context.xml /opt/tomcat/webapps/manager/META-INF/
COPY ./tomcat-users.xml /opt/tomcat/conf
COPY --from=infra /opt/myapp/target/*.war /opt/tomcat/webapps/appli.war
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
 
 
