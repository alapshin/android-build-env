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
    --volume=$PWD:$PWD --workspace=$PWD \
    --volume=android-sdk:/opt/android-sdk \
    username/android-build-env /bin/sh -c "./gradlew build"
```

## Usage of volumes to store Android SDK
During image build minimal Android SDK is installed in directory `/opt/android-sdk`.
Also during image build licences for other SDK components are accepted. This way
Android Gradle Plugin could automatically install additional components later.
To have these components persist between container launches we use named volume.

Also since we don't know ahead of time which user will be used to launch docker
container we have to make `/opt/android-sdk` directory open to the world using `chmod -R 777`.
