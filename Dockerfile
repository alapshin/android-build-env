FROM openjdk:11.0.15-jdk-bullseye

ARG PACKAGES="file git make curl unzip"
ARG ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip"
ARG ANDROID_PACKAGES="build-tools;33.0.0 platform-tools platforms;android-30 extras;google;m2repository extras;android;m2repository"

ENV BUILD_HOME /var/cache/build
# Set environment variables for Android SDK
# See https://developer.android.com/studio/command-line/variables
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_SDK_HOME /opt/android-sdk
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV ANDROID_NDK_HOME ${ANDROID_HOME}/ndk-bundle
ENV ANDROID_SDK_TOOLS_ROOT ${ANDROID_HOME}/cmdline-tools/latest

# Install required packages
RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests ${PACKAGES} \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

# Create directory that is used as user home during build
RUN mkdir --parents ${BUILD_HOME} && chmod --recursive 777 ${BUILD_HOME}

# Create directory for Android SDK
# Download and install Android SDK and its components
RUN mkdir --parents ${ANDROID_SDK_TOOLS_ROOT} \
    && curl --silent --output cmdline-tools.zip ${ANDROID_SDK_URL} \
    && unzip cmdline-tools.zip \
    && mv cmdline-tools/* ${ANDROID_SDK_TOOLS_ROOT} \
    && rm --force --recursive cmdline-tools/ commandline-tools.zip \
    # Accept all licenses
    && yes | ${ANDROID_SDK_TOOLS_ROOT}/bin/sdkmanager --licenses \
    # Install sdk packages
    && ${ANDROID_SDK_TOOLS_ROOT}/bin/sdkmanager --verbose ${ANDROID_PACKAGES} \
    # Make directory with sdk writeable for other users
    # This way missing sdk packages could be installed by android gradle plugin
    # during build
    && chmod --recursive 777 ${ANDROID_SDK_ROOT}
