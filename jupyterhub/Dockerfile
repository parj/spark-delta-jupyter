# syntax=docker/dockerfile:1
FROM azul/zulu-openjdk:17-latest as java

FROM spark:3.11 as spark

FROM debian:11 as node

ENV NODE_VERSION 14.21.2
ENV NPM_VERSION 9.2.0

RUN apt update && apt install -y --install-recommends gpg curl

RUN gpg --batch --keyserver keyserver.ubuntu.com --recv-keys B9E2F5981AA6E0CD28160D9FF13993A75599653C C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
 	&& curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
	&& curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt" \
	&& curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
	&& curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.sig" \
	&& gpg --verify SHASUMS256.txt.sig SHASUMS256.txt \
	&& grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && mkdir /node \
	&& tar xvzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /node --strip-components=1

FROM python:3.11.1

ARG USER=spark
ARG GROUP=tools
ARG UID=1001
ENV NPM_VERSION 9.2.0
ARG JAVA_HOME="/usr/lib/jvm/zulu17"

COPY --from=java ["/usr/lib/jvm/zulu17/", "${JAVA_HOME}"]
COPY --from=node ["/node", "/node/"]
COPY ["requirements.txt", "/"]

ENV JAVA_HOME="${JAVA_HOME}"
ENV PATH="$JAVA_HOME/bin:$PATH:/node/bin"

RUN addgroup ${GROUP} --gid ${UID} && useradd --uid ${UID} --gid ${UID} --create-home --shell /bin/bash ${USER} \
&& pip3 install -r /requirements.txt \
&& pip cache purge

RUN npm install -g npm@"$NPM_VERSION" \
  && npm install -g configurable-http-proxy \
	&& npm cache clear --force

COPY --from=spark ["/opt/spark/jars/*delta*.jar", "/usr/local/lib/python3.11/site-packages/pyspark/jars/"]

# RUN jupyter labextension install @telamonian/theme-darcula @oriolmirosa/jupyterlab_materialdarker \ 
# && jupyter lab clean \
# && rm -rf /usr/local/share/.cache

USER root

COPY jupyterhub_config.py /

ENTRYPOINT [ "jupyterhub", "-f", "/jupyterhub_config.py" ]