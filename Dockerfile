# Build stage
FROM dart:stable AS build

WORKDIR /app

# Copy common package
COPY packages/common /app/packages/common

# Copy server
COPY apps/server /app/apps/server

# Get dependencies and compile to native binary
WORKDIR /app/apps/server
RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server_exe

# Runtime stage - minimal image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /app/apps/server/bin/server_exe /app/server

# Create data directory for SQLite
RUN mkdir -p /app/data

EXPOSE 8080

# Use shell form so $PORT environment variable is expanded at runtime by Railway
CMD ["/bin/sh", "-c", "/app/server --port ${PORT:-8080} --db /app/data/nutritrack.db"]
