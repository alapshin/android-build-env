FROM openjdk:11

ARG PACKAGES="file git make wget unzip libtinfo5"
ARG ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
ARG ANDROID_PACKAGES="tools platform-tools build-tools;28.0.3 platforms;android-28 extras;google;m2repository extras;android;m2repository"

# Set environment variables for Android SDK
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV ANDROID_SDK_HOME /opt/android-sdk
ENV ANDROID_NDK_HOME ${ANDROID_SDK_ROOT}/ndk-bundle

# Install required packages
RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests ${PACKAGES} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download JAXB libraries used by sdkmanager because they are not available out of the box in JDK 11
ENV SDKMANAGER_LIB_PATH ${ANDROID_SDK_ROOT}/tools/lib
RUN mkdir -p ${SDKMANAGER_LIB_PATH} \ 
    && wget --quiet --directory-prefix=${SDKMANAGER_LIB_PATH} \ 
    https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar \
    https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-jxc/2.3.2/jaxb-jxc-2.3.2.jar \
    https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.2/jaxb-impl-2.3.2.jar \
    https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar \
    https://repo1.maven.org/maven2/javax/activation/activation/1.1.1/activation-1.1.1.jar

# Create directory for Android SDK
# Download and install Android SDK and its components
RUN mkdir -p ${ANDROID_SDK_ROOT} \
    && wget --quiet --output-document=${ANDROID_SDK_ROOT}/sdk-tools.zip ${ANDROID_SDK_URL} \
    && unzip -d ${ANDROID_SDK_ROOT} ${ANDROID_SDK_ROOT}/sdk-tools.zip \
    && rm --force ${ANDROID_SDK_ROOT}/sdk-tools.zip \
    # Patch sdkmanager script to add JAXB libraries to classpath
    && sed -i 's|CLASSPATH=.*|&:${APP_HOME}/lib/jaxb-impl-2.3.2.jar:${APP_HOME}/lib/jaxb-api-2.3.1.jar:${APP_HOME}/lib/jaxb-jxc-2.3.2.jar:${APP_HOME}/lib/jaxb-core-2.3.0.1.jar:${APP_HOME}/lib/activation-1.1.1.jar|' ${ANDROID_SDK_ROOT}/tools/bin/sdkmanager \
    # Accept all licenses
    && yes | ${ANDROID_SDK_ROOT}/tools/bin/sdkmanager --licenses \
    # Install specified packages
    && ${ANDROID_SDK_ROOT}/tools/bin/sdkmanager --verbose ${ANDROID_PACKAGES}
