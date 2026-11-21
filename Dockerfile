# Images for developing and running the service.
#
#   dev      The shared development environment. The dev container uses it.
#   build    Builds the service with the dev stage's tools.
#   runtime  The image published for servers. It contains only what the
#            service needs to run.
#
# See .devcontainer/README.md and docs/guides/self-hosting.md.

ARG UBUNTU_VERSION=26.04

# ---------------------------------------------------------------------------
# dev
# ---------------------------------------------------------------------------
FROM ubuntu:${UBUNTU_VERSION} AS dev

ARG USERNAME=dev

ENV LANG=C.UTF-8

# General tools for working in any repository. Python 3 runs the repository
# checks in tools/scripts/.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bash-completion \
        ca-certificates \
        curl \
        git \
        less \
        nano \
        openssh-client \
        python3 \
        sudo \
        unzip \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Add the project's toolchains here, in their own RUN instructions, and pin
# their versions so every contributor and CI use the same ones.

# Ubuntu images include a user named ubuntu with ID 1000, the usual ID of the
# first user on a Linux host. Rename it so the container user owns files in
# the mounted workspace the same way the host user does. The user can run sudo
# without a password, to try out packages before adding them to this file.
RUN usermod --login "${USERNAME}" --move-home --home "/home/${USERNAME}" ubuntu \
    && groupmod --new-name "${USERNAME}" ubuntu \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

USER ${USERNAME}

# ---------------------------------------------------------------------------
# build
# ---------------------------------------------------------------------------
FROM dev AS build

WORKDIR /home/dev/src
COPY --chown=dev:dev . .

# Replace this with the project's build command. Write everything the service
# needs at run time to /home/dev/src/out, such as a compiled program, a
# bundled website, or source files with their installed dependencies.
RUN mkdir -p out

# ---------------------------------------------------------------------------
# runtime
# ---------------------------------------------------------------------------
# Use the same base as the dev stage, so that programs built there run here.
FROM ubuntu:${UBUNTU_VERSION} AS runtime

# Install only what the service needs at run time. CA certificates let it
# make HTTPS connections.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Run as an unprivileged user. /data holds files that must survive updates,
# and compose.yaml mounts a volume there.
RUN useradd --system --uid 10001 --user-group --no-create-home --shell /usr/sbin/nologin app \
    && mkdir -p /app /data \
    && chown app:app /data

WORKDIR /app

# Copy the built service from the build stage. Until this line is enabled,
# image builds skip the dev and build stages, which keeps them fast.
# COPY --from=build /home/dev/src/out/ /app/

USER app

# Placeholder that keeps the container running, so the release and deployment
# steps can be tested before the service exists. Replace it with the command
# that starts the service, for example CMD ["/app/my-service"].
CMD ["sh", "-c", "echo 'Placeholder service is running. Replace CMD in the Dockerfile.' && exec sleep infinity"]
