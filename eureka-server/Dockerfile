#Pull base image
#-----------------
FROM azul/zulu-openjdk:17

#Author
#-------
LABEL org.opencontainers.image.authors="Jennifer Reif,jennifer@thehecklers.org,@JMHReif"

#Copy jar and expose entrypoints
#--------------------------------
COPY target/eureka-server-*.jar goodreads-eureka.jar
ENTRYPOINT ["java","-jar","/goodreads-eureka.jar"]