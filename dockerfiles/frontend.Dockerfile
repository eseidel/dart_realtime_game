FROM dart:stable AS build

# Copy files to container and build
WORKDIR /app
COPY . .

# Setup webdev.
RUN mkdir /pub-cache
ENV PUB_CACHE=/pub-cache \
    PATH="${PATH}:/pub-cache/bin"
RUN dart pub global activate webdev

# Compile frontend.
WORKDIR /app/packages/client

# pubspec.lock should ensure this pulls the same as locally.
# Would be nice to have a mechanism to ensure that with checksums, etc.
RUN dart pub get
RUN webdev build

# Build the final serving image with the compiled frontend.
FROM nginx:1.21.1-alpine
# FIXME: build seems too broad a directory to copy?
COPY --from=build /app/packages/client/build /usr/share/nginx/html

EXPOSE 80