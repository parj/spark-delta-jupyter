# syntax=docker/dockerfile:1
ARG SPARK_VERSION=3.3.1
ARG DELTA_VERSION=2.2.0

FROM azul/zulu-openjdk:17-latest as java

FROM debian as curl

ARG SPARK_VERSION
ARG DELTA_VERSION

#Purposely split to ensure runs is cached
RUN apt update && apt install -y curl unzip

RUN curl -SL "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" -o /tmp/spark.tgz

RUN tar xvzf /tmp/spark.tgz -C /tmp/ && mv /tmp/spark-3.3.1-bin-hadoop3 /tmp/spark

#Delta jars
RUN curl -SL "https://repo1.maven.org/maven2/io/delta/delta-core_2.12/${DELTA_VERSION}/delta-core_2.12-${DELTA_VERSION}.jar" -o /tmp/spark/jars/delta-core_2.12-2.2.0.jar && \
curl -SL "https://repo1.maven.org/maven2/io/delta/delta-storage/${DELTA_VERSION}/delta-storage-${DELTA_VERSION}.jar" -o /tmp/spark/jars/delta-storage-2.2.0.jar

#Explode snappy
RUN ls -1  /tmp/spark/jars/*snappy* | xargs -I % unzip % -d /tmp/snappy && \
ls -1  /tmp/spark/jars/*zstd* | xargs -I % unzip % -d /tmp/zstd

FROM python:3.11.1

ARG SPARK=spark
ARG GROUP=tools
ARG UID=1001
ARG SPARK_HOME="/opt/spark"
ARG JAVA_HOME="/usr/lib/jvm/zulu17"

USER root

RUN addgroup ${GROUP} --gid ${UID} && useradd --uid ${UID} --gid ${UID} --create-home --shell /bin/bash ${SPARK} && \
mkdir -p /opt/spark && \ 
chown -R ${SPARK}:${GROUP} ${SPARK_HOME}

USER spark

COPY --from=java ["/usr/lib/jvm/zulu17/", "${JAVA_HOME}"]

COPY --from=curl --chown=${SPARK}:${GROUP} ["/tmp/spark/", "${SPARK_HOME}"]

COPY --from=curl ["/tmp/zstd/linux/amd64/libzstd-jni-*.so", "/usr/local/lib/"]

COPY --from=curl ["/tmp/snappy/org/xerial/snappy/native/Linux/x86_64/libsnappyjava.so", "/usr/local/lib/"]

COPY --chown=${SPARK}:${GROUP} ["rootfs", "/"]

WORKDIR ${SPARK_HOME}

ENV JAVA_HOME="${JAVA_HOME}"
ENV SPARK_HOME="${SPARK_HOME}"
ENV PATH="$JAVA_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH"
ENV SPARK_NO_DAEMONIZE="true"

ENTRYPOINT [ "/opt/spark/start.sh" ]
