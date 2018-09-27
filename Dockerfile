FROM anapsix/alpine-java:8_jdk

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive
ENV DOCKER_ANDROID_DISPLAY_NAME mobileci-docker

ENV ANDROID_HOME /android-sdk
ENV PATH ${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin:/bin:$PATH

ARG GRADLE_VERSION="4.6"
ARG ANDROID_SDK_TOOLS_URL="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
ARG GRADLE_DISTRIBUTION_URL="https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip"

# Installing packages
RUN apk update && \
    apk add --no-cache \
        git \
        bash \
        curl \
        ca-certificates \
        zip \
        unzip \
        ruby \
        ruby-rdoc \
        ruby-irb \
        ruby-dev \
        openssh \
        g++ \
        make \
    && rm -rf /tmp/* /var/tmp/* \
    && gem install bundler \
    && gem install fastlane --no-document

# Download Android SDK tools into $ANDROID_HOME
RUN cd /opt \
    && curl ${ANDROID_SDK_TOOLS_URL} -o android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} \
    && rm android-sdk-tools.zip

# Accept licenses before installing components
RUN mkdir ~/.android \
 && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg \
 && yes | sdkmanager --licenses && sdkmanager --update

# Install Platform Tools
RUN sdkmanager "tools" "platform-tools" \
 && yes | sdkmanager \
    "platforms;android-28" \
    "build-tools;28.0.2" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"

# Install Gradle
RUN cd /usr/lib \
 && curl -fl ${GRADLE_DISTRIBUTION_URL} -o gradle-bin.zip \
 && unzip "gradle-bin.zip" \
 && ln -s "/usr/lib/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle \
 && rm "gradle-bin.zip"
