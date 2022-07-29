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
RUN flutter config --enable-web
RUN flutter doctor

# Copy files to container and build
WORKDIR /app
COPY . .

# Build the client
WORKDIR /app/packages/shimmer2_client
RUN flutter pub get
RUN flutter build web

# Compile websocket server.
WORKDIR /app/packages/shimmer2_server
RUN dart pub get
RUN dart compile exe bin/serve.dart -o /app/backend

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.

FROM nginx:1.21.1-alpine
COPY --from=build /app/packages/shimmer2_client/build /usr/share/nginx/html
COPY --from=build /app/docker_serve.sh /app/docker_serve.sh
COPY --from=build /app/backend /app/

# COPY --from=build /runtime/ /
# COPY --from=build /app/packages/shimmer2_client/build /app/frontend

# Start server.
EXPOSE 3000
EXPOSE 80

CMD ["/app/docker_serve.sh"]