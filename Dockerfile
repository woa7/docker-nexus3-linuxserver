FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG NEXUS_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
#LABEL maintainer="thelamer"
LABEL maintainer="TESTING"

# copy prebuild files
COPY prebuilds/ /prebuilds/

# environment settings
####ENV BOOKSONIC_OPT_PREFIX="subsonic" \
LANG="C.UTF-8"

# package settings
ARG JETTY_VER="9.4.24.v20191120"

RUN \
 echo "**** install runtime packages ****" && \
 apt-get update && \
 apt-get install -y \
	--no-install-recommends \
	ca-certificates \
	ffmpeg \
	flac \
	fontconfig \
	jq \
	lame \
	openjdk-8-jre-headless \
	ttf-dejavu && \
 echo "**** fix XXXsonic status page ****" && \
 find /etc -name "accessibility.properties" -exec rm -fv '{}' + && \
 find /usr -name "accessibility.properties" -exec rm -fv '{}' + && \
 echo "**** install jetty-runner ****" && \
 mkdir -p \
	/tmp/jetty && \
 cp /prebuilds/* /tmp/jetty/ && \
 curl -o \
 /tmp/jetty/"jetty-runner-$JETTY_VER".jar -L \
	"https://repo.maven.apache.org/maven2/org/eclipse/jetty/jetty-runner/${JETTY_VER}/jetty-runner-{$JETTY_VER}.jar" && \
 cd /tmp/jetty && \
 install -m644 -D "jetty-runner-$JETTY_VER.jar" \
	/usr/share/java/jetty-runner.jar && \
 install -m755 -D jetty-runner /usr/bin/jetty-runner && \
# echo "**** install booksonic ****" && \
# if [ -z ${BOOKSONIC_RELEASE+x} ]; then \
#	BOOKSONIC_RELEASE=$(curl -sX GET "https://api.github.com/repos/popeen/Popeens-Subsonic/releases/latest" \
#	| jq -r '. | .tag_name'); \
# fi && \
# mkdir -p \
#	/app/booksonic && \
# curl -o \
# /app/booksonic/booksonic.war -L \
#	"https://github.com/popeen/Popeens-Subsonic/releases/download/${BOOKSONIC_RELEASE}/booksonic.war" && \

 echo "**** install nexus ****" && \
ARG NEXUS_VERSION=3.20.1-01
ARG NEXUS_RELEASE=${NEXUS_VERSION}
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz
ARG NEXUS_DOWNLOAD_SHA256_HASH=fba9953e70e2d53262d2bd953e5fbab3e44cf2965467df14a665b0752de30e51 

 echo "**** install NEXUS ****" && \
 if [ -z ${NEXUS_RELEASE+x} ]; then \
	NEXUS_RELEASE=$(curl -sX GET "https://api.github.com/repos/popeen/Popeens-Subsonic/releases/latest" \
	| jq -r '. | .tag_name'); \
 fi && \
 mkdir -p \
	/app/nexus && \
 curl -o \
 /app/nexus/nexus.tar.gz -L \
	"${NEXUS_DOWNLOAD_URL}" && \

echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
#EXPOSE 4040
EXPOSE 8081
VOLUME /config
