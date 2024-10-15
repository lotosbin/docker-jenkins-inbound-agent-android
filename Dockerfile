FROM jenkins/inbound-agent:latest-jdk17
LABEL MAINTAINER="liubinbin <lotosbin@gmail.com>"


USER root
RUN apt-get update && apt-get install -y  wget unzip

USER jenkins
ENV HOME=/home/jenkins

# Install gradle
ENV GRADLE_VERSION=7.6.4
ENV GRADLE_ZIP=gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_ZIP_URL=https://services.gradle.org/distributions/$GRADLE_ZIP
ENV PATH=$PATH:$HOME/gradle-${GRADLE_VERSION}/bin
RUN cd $HOME && \
      wget -q ${GRADLE_ZIP_URL} && \
      unzip $HOME/$GRADLE_ZIP -d $HOME/ && \
      rm $HOME/$GRADLE_ZIP


# Install Android SDK
ENV ANDROID_SDK_VERSION=11076708
#ENV ANDROID_SDK_ZIP_URL=https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}_latest.zip
#ENV ANDROID_SDK_ZIP=sdk-tools-linux-${ANDROID_SDK_VERSION}_latest.zip
ENV ANDROID_HOME=${HOME}/android-sdk-linux
ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV ANDROID_SDK_ZIP_URL=https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip
ENV ANDROID_SDK_ZIP=commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip
ENV PATH=${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
RUN mkdir -p ${ANDROID_HOME} && \
      cd ${ANDROID_HOME}

RUN wget -q ${ANDROID_SDK_ZIP_URL} && \
      unzip -q ${ANDROID_SDK_ZIP} -d . && \
      rm ${ANDROID_SDK_ZIP} && \
      yes | cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses && \
      cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install "cmdline-tools;latest"


# Accept Licenses
RUN yes | sdkmanager --licenses

# Install 32-bit compatibility for 64-bit environments
#RUN apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 -y


# Install Android NDK
ENV ANDROID_NDK_VERSION=r15c
ENV ANDROID_NDK_HOME=$HOME/android-ndk-${ANDROID_NDK_VERSION}
ENV ANDROID_NDK_ZIP=android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip

RUN cd $HOME && \
   wget -q https://dl.google.com/android/repository/${ANDROID_NDK_ZIP} && \
   unzip -q ${ANDROID_NDK_ZIP} && \
   rm -rf $HOME/${ANDROID_NDK_ZIP}
#RUN echo "y" | android update sdk -u -a --filter ndk-bundle
#RUN echo "y" | android update sdk -u -a --filter ndk;16.1.4479499

# Set the locale
#RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    #locale-gen
#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US:en
#ENV LC_ALL en_US.UTF-8
USER root
#RUN apt-get update && apt-get install git -y && git --version
RUN mkdir -p /home/jenkins/data/jenkins-data \
&& mkdir -p /home/jenkins/data/.gradle \
&& chown -R jenkins:jenkins /home/jenkins/data/
RUN mkdir -p /home/jenkins/.gradle && chown -R jenkins:jenkins /home/jenkins/.gradle
RUN mkdir -p /home/jenkins/workspace && chown -R jenkins:jenkins /home/jenkins/workspace

ENV TINI_VERSION=v0.3.4
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

USER jenkins
#ENTRYPOINT ["/tini", "--", "/usr/local/bin/jenkins.sh"]
ENTRYPOINT ["/tini", "--", "jenkins-slave"]

RUN mkdir -p /home/jenkins/tools && chown -R jenkins:jenkins /home/jenkins/tools
