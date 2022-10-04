#Pull base image
#-----------------
FROM azul/zulu-openjdk:17

#Author
#-------
LABEL org.opencontainers.image.authors="Jennifer Reif,jennifer@thehecklers.org,@JMHReif"

#Copy jar and expose entrypoints
#--------------------------------
COPY target/service3-*.jar goodreads-svc3.jar
ENTRYPOINT ["java","-jar","/goodreads-svc3.jar"]