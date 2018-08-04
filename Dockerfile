FROM ubuntu:14.04

RUN locale-gen en_US.UTF-8
ENV LANG "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"

ENV DEBIAN_FRONTEND noninteractive
ENV DOCKER_ANDROID_DISPLAY_NAME mobileci-docker

ENV ANDROID_HOME /android-sdk
ENV RBENV_ROOT /usr/local/rbenv
ENV PATH ${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin:/bin:${RBENV_ROOT}/bin:$RBENV_ROOT/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

ARG GRADLE_VERSION="4.1"
ARG RUBY_VERSION="2.4.0"
ARG ANDROID_SDK_TOOLS_URL="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
ARG GRADLE_DISTRIBUTION_URL="https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip"

# Installing packages
RUN apt-get update \
 && apt-get install -y software-properties-common --no-install-recommends \
 && apt-add-repository ppa:openjdk-r/ppa \
 && apt-get update \
 && apt-get install -y \
  build-essential \
  curl \
  git \
  unzip \
  zip \
  openjdk-8-jdk \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  --no-install-recommends \
 && update-ca-certificates -f \
 && rm -rf /var/lib/apt/lists/*

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
    "platforms;android-27" \
    "build-tools;27.0.3" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"

# Install Gradle
RUN cd /usr/lib \
 && curl -fl ${GRADLE_DISTRIBUTION_URL} -o gradle-bin.zip \
 && unzip "gradle-bin.zip" \
 && ln -s "/usr/lib/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle \
 && rm "gradle-bin.zip"

# Install rbenv
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv \
 && echo '# rbenv setup' > /etc/profile.d/rbenv.sh \
 && echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
 && echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh \
 && echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh \
 && chmod +x /etc/profile.d/rbenv.sh

# Install Ruby and Fastlane
RUN mkdir /usr/local/rbenv/plugins \
 && git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
 && rbenv install ${RUBY_VERSION} \
 && rbenv global ${RUBY_VERSION} \
 && gem install bundler \
 && gem install fastlane --no-document
