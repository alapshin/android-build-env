FROM openjdk:11.0.15-jdk-bullseye

ARG PACKAGES="file git make curl libarchive-tools"
ARG ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip"
ARG ANDROID_PACKAGES="tools platform-tools build-tools;30.0.3 platforms;android-30 extras;google;m2repository extras;android;m2repository"

ENV BUILD_HOME /var/cache/build
# Set environment variables for Android SDK
ENV ANDROID_SDK_HOME /opt/android-sdk
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV ANDROID_NDK_HOME ${ANDROID_SDK_ROOT}/ndk-bundle
ENV ANDROID_SDK_TOOLS_ROOT /opt/android-sdk/cmdline-tools/latest

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
    && cd ${ANDROID_SDK_TOOLS_ROOT} \
    && curl --silent --output commandline-tools.zip ${ANDROID_SDK_URL} \
    && bsdtar --strip-components=1 -xvf commandline-tools.zip \
    && rm --force commandline-tools.zip \
    # Accept all licenses
    && yes | ${ANDROID_SDK_TOOLS_ROOT}/bin/sdkmanager --licenses \
    # Install sdk packages
    && ${ANDROID_SDK_TOOLS_ROOT}/bin/sdkmanager --verbose ${ANDROID_PACKAGES} \
    # Make directory with sdk writeable for other users
    # This way missing sdk packages could be installed by android gradle plugin
    # during build
    && chmod --recursive 777 ${ANDROID_SDK_ROOT}
