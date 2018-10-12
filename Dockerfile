FROM jenkins/jnlp-slave:3.23-1
LABEL MAINTAINER="liubinbin <lotosbin@gmail.com>"

USER jenkins

# Set desired Android Linux SDK version
ENV ANDROID_SDK_VERSION 24.4.1

ENV ANDROID_SDK_ZIP android_tools.zip
ENV ANDROID_SDK_ZIP_URL https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
ENV ANDROID_HOME $HOME/android-sdk-linux

ENV GRADLE_ZIP gradle-3.0-bin.zip
ENV GRADLE_ZIP_URL https://services.gradle.org/distributions/$GRADLE_ZIP

ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools
ENV PATH $PATH:$HOME/gradle-3.0/bin

# Install gradle
ADD $GRADLE_ZIP_URL $HOME/
RUN unzip $HOME/$GRADLE_ZIP -d $HOME/ && \
	rm $HOME/$GRADLE_ZIP

# Install Android SDK
RUN mkdir -p ${ANDROID_HOME} && \
    cd ${ANDROID_HOME} && \
    wget -q ${ANDROID_SDK_ZIP_URL} -O android_tools.zip && \
    unzip android_tools.zip && \
    rm android_tools.zip
# ADD $ANDROID_SDK_ZIP_URL /opt/
# RUN tar xzvf /opt/$ANDROID_SDK_ZIP -C /opt/ && \
# 	rm /opt/$ANDROID_SDK_ZIP
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Accept Licenses
RUN yes | sdkmanager --licenses

# Install 32-bit compatibility for 64-bit environments
#RUN apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 -y



ENV ANDROID_NDK_HOME $HOME/android-ndk
ENV ANDROID_NDK_VERSION r15c

RUN mkdir $HOME/android-ndk-tmp && \
   cd $HOME/android-ndk-tmp && \
   wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
   unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
   mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME} && \
   cd ${ANDROID_NDK_HOME} && \
   rm -rf $HOME/android-ndk-tmp
