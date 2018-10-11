FROM jenkins/jnlp-slave:3.23-1
LABEL MAINTAINER="liubinbin <lotosbin@gmail.com>"

USER root
# Set desired Android Linux SDK version
ENV ANDROID_SDK_VERSION 24.4.1

ENV ANDROID_SDK_ZIP android-sdk_r$ANDROID_SDK_VERSION-linux.tgz
ENV ANDROID_SDK_ZIP_URL https://dl.google.com/android/$ANDROID_SDK_ZIP
ENV ANDROID_HOME /opt/android-sdk-linux

ENV GRADLE_ZIP gradle-3.0-bin.zip
ENV GRADLE_ZIP_URL https://services.gradle.org/distributions/$GRADLE_ZIP

ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools
ENV PATH $PATH:/opt/gradle-3.0/bin

# Install gradle
ADD $GRADLE_ZIP_URL /opt/
RUN unzip /opt/$GRADLE_ZIP -d /opt/ && \
	rm /opt/$GRADLE_ZIP

# Install Android SDK
ADD $ANDROID_SDK_ZIP_URL /opt/
RUN tar xzvf /opt/$ANDROID_SDK_ZIP -C /opt/ && \
	rm /opt/$ANDROID_SDK_ZIP
# Accept Licenses
RUN mkdir -p $ANDROID_HOME/licenses/ && \
    echo 8933bad161af4178b1185d1a37fbf41ea5269c55 >> $ANDROID_HOME/licenses/android-sdk-license && \
    echo 84831b9409646a918e30573bab4c9c91346d8abd >> $ANDROID_HOME/licenses/android-sdk-preview-license && \
    echo d975f751698a77b662f1254ddbeed3901e976f5a >> $ANDROID_HOME/licenses/intel-android-extra-license


# Install required build-tools
RUN	echo "y" | android update sdk -u -a --filter platform-tools,android-25,build-tools-25.0.2,extra-android-m2repository,extra-android-support,extra-google-m2repository
RUN	echo "y" | android update sdk -u -a --filter platform-tools,android-26,build-tools-26.0.0
#RUN	echo "y" | android update sdk -u -a --filter platform-tools,android-23,build-tools-23.0.3 && \
#	chmod -R 755 $ANDROID_HOME

#RUN	echo "y" | android update sdk -u -a --filter platform-tools,android-24,build-tools-24.0.1 && \
#	chmod -R 755 $ANDROID_HOME

RUN	echo "y" | android update sdk -u -a --filter platform-tools,android-26,build-tools-26.0.2,extra-android-m2repository,extra-android-support,extra-google-m2repository
RUN	echo "y" | android update sdk -u -a --filter build-tools-26.0.1
RUN	echo "y" | android update sdk -u -a --filter android-23,build-tools-25.0.0
RUN	echo "y" | android update sdk -u -a --filter android-21,android-22
RUN	echo "y" | android update sdk -u -a --filter android-27,build-tools-27.0.3
RUN	echo "y" | android update sdk -u -a --filter android-28,build-tools-28.0.2

# Install 32-bit compatibility for 64-bit environments
#RUN apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 -y

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# fix permission issue
# RUN chown -R jenkins:jenkins $ANDROID_HOME



ENV ANDROID_NDK_HOME /opt/android-ndk
ENV ANDROID_NDK_VERSION r15c

RUN mkdir /opt/android-ndk-tmp && \
   cd /opt/android-ndk-tmp && \
   wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
   unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
   mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME} && \
   cd ${ANDROID_NDK_HOME} && \
   rm -rf /opt/android-ndk-tmp

ENV PATH ${PATH}:${ANDROID_NDK_HOME}
RUN echo "y" | android update sdk -u -a --filter android-28,build-tools-28.0.3
RUN chown -R jenkins:jenkins $ANDROID_HOME

USER jenkins
