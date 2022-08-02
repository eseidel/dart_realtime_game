FROM dart:stable AS build

# Copy files to container and build
WORKDIR /app
COPY . .

# Compile websocket server.
WORKDIR /app/packages/server

# pubspec.lock should ensure this pulls the same as locally.
# Would be nice to have a mechanism to ensure that with checksums, etc.
RUN dart pub get
RUN dart compile exe bin/serve.dart -o /app/serve

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/serve /app/backend/

EXPOSE 3000
CMD ["/app/backend/serve"]