## Build image

```bash
docker build -t username/android-build-env:latest .
```

## Push image to docker registry

```bash
docker push username/android-build-env
```

## Use image to build Android project
Change directory to your project directory and then run:

```bash
docker run --interactive --tty --rm \
    --volume=$PWD:$PWD --workdir=$PWD \
    --volume=android-sdk:/opt/android-sdk \
    username/android-build-env /bin/sh -c "./gradlew build"
```

## Use volume to allow installation of missing Android SDK components
During image build minimal Android SDK is installed in directory
`/opt/android-sdk`. Also during image build licences for other SDK components
are accepted. This way Android Gradle Plugin could automatically install
additional components later. To have these components persist between container
launches  `/opt/android-sdk` could be mounted using volume.
