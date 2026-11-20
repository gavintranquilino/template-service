# Shared development environment. See README.md in this directory.
#
# This stage is named "dev" so that a derived template can add build and
# runtime stages to the same file without changing devcontainer.json.

ARG UBUNTU_VERSION=26.04
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
