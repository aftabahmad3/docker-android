# Docker Android
This repoistory contains a Dockerfile which will allow an Android project to run inside the Docker container.

The Docker image that is generated installed the latest Android SDK tools, Android API 27 and Builds Tools 27.0.3 by default. To install additional versions, modify the command under: Install Platform Tools. The image also contains version 2.4.0 of Ruby and Gradle version 4.1 by default.

This Docker image helps with the complete CI and CD flow for an Android project. It contains all the Android dependencies needed to perform tests and run linting or checkstyle tasks. It achieves this using Ruby and the Fastlane tool which helps orchestrate all the CI and CD scripts.  

This repo also contains a docker-compose.yml file which helps build and run the docker image easier. Connects with Buildkite to allow for automatic deployment to DockerHub when new changes are made.
