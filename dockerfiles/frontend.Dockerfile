# I'm not aware of an official flutter build image, so building our own.
FROM ubuntu:20.04 as build
# Make apt-get not prompt for "geographic area"
ARG DEBIAN_FRONTEND=noninteractive

# Install Dart and Flutter
RUN apt-get update 
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3
RUN apt-get clean

# download Flutter SDK from Flutter Github repo
RUN git clone --depth 1 https://github.com/flutter/flutter.git /usr/local/flutter --branch stable

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Setup Flutter
RUN flutter channel stable
# config --enable-web may not be needed anymore?
RUN flutter config --enable-web
RUN flutter doctor

# Copy files to container and build
WORKDIR /app
COPY . .

# Build the client
WORKDIR /app/packages/shimmer2_client
# pubspec.lock should ensure get pulls the same as locally.
RUN flutter pub get
RUN flutter build web

FROM nginx:1.21.1-alpine
COPY --from=build /app/packages/shimmer2_client/build/web /usr/share/nginx/html

EXPOSE 80
