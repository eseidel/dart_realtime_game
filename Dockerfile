# Use latest stable channel SDK.
FROM dart:stable AS build

WORKDIR /app
COPY . .

# Compile websocket server.
WORKDIR /app/packages/shimmer2_shared
RUN dart pub get
WORKDIR /app/packages/shimmer2_server
RUN dart pub get

RUN dart compile exe bin/serve.dart -o /app/server

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/server /app/

# Start server.
EXPOSE 3000
CMD ["/app/server"]
