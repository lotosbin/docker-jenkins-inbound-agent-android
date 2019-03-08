FROM jenkins/jnlp-slave:3.26-1
LABEL MAINTAINER="liubinbin <lotosbin@gmail.com>"

USER jenkins

# Install gradle
ENV GRADLE_VERSION 4.10.2
ENV GRADLE_ZIP gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_ZIP_URL https://services.gradle.org/distributions/$GRADLE_ZIP
ENV PATH $PATH:$HOME/gradle-${GRADLE_VERSION}/bin
RUN cd $HOME && \
    wget -q ${GRADLE_ZIP_URL} && \
    unzip $HOME/$GRADLE_ZIP -d $HOME/ && \
	rm $HOME/$GRADLE_ZIP


# Install Android SDK
ENV ANDROID_SDK_ZIP_URL https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
ENV ANDROID_SDK_ZIP sdk-tools-linux-4333796.zip
ENV ANDROID_HOME $HOME/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

RUN mkdir -p ${ANDROID_HOME} && \
    cd ${ANDROID_HOME} && \
    wget -q ${ANDROID_SDK_ZIP_URL} && \
    unzip -q ${ANDROID_SDK_ZIP} && \
    rm ${ANDROID_SDK_ZIP}

# Accept Licenses
RUN yes | sdkmanager --licenses

# Install 32-bit compatibility for 64-bit environments
#RUN apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 -y


# Install Android NDK
ENV ANDROID_NDK_VERSION r15c
ENV ANDROID_NDK_HOME $HOME/android-ndk-${ANDROID_NDK_VERSION}
ENV ANDROID_NDK_ZIP android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip

RUN cd $HOME && \
   wget -q https://dl.google.com/android/repository/${ANDROID_NDK_ZIP} && \
   unzip -q ${ANDROID_NDK_ZIP} && \
   rm -rf $HOME/${ANDROID_NDK_ZIP}
RUN echo "y" | android update sdk --no-ui --all
# RUN echo "y" | android update sdk -u -a --filter platforms;android-28
# RUN echo "y" | android update sdk -u -a --filter build-tools;28.0.3
