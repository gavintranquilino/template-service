# Dev Container

The dev container gives every contributor the same Linux development environment, whatever their operating system or editor. Build, test, and run the project inside it, so that each contributor needs only a few tools on their own machine.

## What Is Included

The image is the `dev` stage of the root [Dockerfile](../Dockerfile) and is configured by [devcontainer.json](devcontainer.json). The same file defines the runtime image that servers run.

* **Operating system:** Ubuntu 26.04 LTS.
* **Tools:** Git, Python 3 for the [repository checks](../tools/README.md), curl, `sudo`, and common command-line utilities.
* **User:** A non-root user named `dev`, which can run `sudo` without a password.
* **Workspace:** The repository is mounted at `/workspaces/<repository-folder-name>`. Changes made inside the container are changes to your local files.
* **Setup script:** [post-create.sh](post-create.sh) runs once after the container is created.

The template includes no language toolchains. Each project adds the ones it needs, as [Customizing the Container](#customizing-the-container) describes.

## Prerequisites

Install these on your machine once.

* **A container engine:** [Docker Desktop](https://docs.docker.com/get-docker/) on Windows or macOS, or Docker Engine or [Podman](https://podman.io/) on Linux.
* **The dev container CLI:** Install [Node.js](https://nodejs.org/), then run `npm install -g @devcontainers/cli`.
* **uv (optional):** [uv](https://docs.astral.sh/uv/) runs the repository's Python tools on your machine without a separate Python installation, as [Working Outside the Container](#working-outside-the-container) shows.

No editor is required. Any editor can work on the mounted files while you run commands in a shell inside the container.

On Windows, use Docker Desktop with the WSL 2 backend, and clone the repository inside your WSL distribution rather than on a Windows drive. Files on a Windows drive are much slower inside the container.

## Quick Start

Run these commands from the repository root.

```sh
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash
```

`devcontainer up` builds the image and starts the container. The first build takes a few minutes, and later runs reuse the existing container. `devcontainer exec` opens a shell in the container, in the repository folder. Run `exit` to leave the shell. The container keeps running in the background.

To run a single command without opening a shell, pass it to `devcontainer exec`.

```sh
devcontainer exec --workspace-folder . python3 tools/scripts/run_checks.py
```

To shorten these commands, add a shell alias on your machine.

```sh
alias dcx='devcontainer exec --workspace-folder .'
```

With Podman, add `--docker-path podman` to each `devcontainer` command, and use `podman` in place of `docker` in other commands.

## Everyday Tasks

| Task | Command, from the repository root |
| --- | --- |
| Start the container | `devcontainer up --workspace-folder .` |
| Open a shell | `devcontainer exec --workspace-folder . bash` |
| Rebuild after changing the dev container files | `devcontainer up --workspace-folder . --remove-existing-container` |
| Stop and remove the container | `docker rm -f $(docker ps -aq --filter "label=devcontainer.local_folder=$PWD")` |

Removing the container discards anything installed outside the workspace, such as packages installed with `sudo apt-get`. Add tools you want to keep to the `dev` stage of the Dockerfile.

## Using an Editor

Editors with dev container support can open the same container. This is optional, and every task works from a shell.

* **VS Code:** Install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension, open the repository, and run **Dev Containers: Reopen in Container** from the Command Palette.
* **JetBrains IDEs:** Open the repository's `devcontainer.json` and choose to create a dev container from it.
* **Other editors:** Edit the files on your machine and run commands in a container shell.

## Working Outside the Container

The [repository checks](../tools/README.md) need only Python 3 and Git, so you can also run them on your machine. With uv, which provides Python automatically, run the following.

```sh
uv run --no-project tools/scripts/run_checks.py
```

## Customizing the Container

Change the shared dev container files in a pull request, so that every contributor and CI get the same environment.

* **Toolchains and system packages:** Add them to the `dev` stage of the Dockerfile in their own `RUN` instruction, and pin their versions. For example, install a compiler with `apt-get`, or copy a language's version manager or package manager from its official image.
* **Project setup:** Add steps to `post-create.sh` that need the mounted workspace, such as installing dependencies. Keep each step safe to run again.
* **Environment variables:** Add them to `containerEnv` in `devcontainer.json`. Keep secrets out of the repository and out of the image.
* **Ports:** List ports that the project serves, such as a local web server, in `forwardPorts` in `devcontainer.json`.
* **Editor settings:** Add extensions and settings under `customizations` in `devcontainer.json`. Keep the container usable without them.
* **Hardware access:** Some projects need a device such as a USB debug probe. Docker fails to start a container when a listed device is missing, so do not add devices to the shared `devcontainer.json`. On Linux, pass the device when starting the container, for example by adding `--device /dev/bus/usb` to `runArgs` in an uncommitted copy of the configuration. On Windows, attach the device to WSL 2 with [usbipd-win](https://github.com/dorssel/usbipd-win) first. Docker Desktop on macOS cannot pass USB devices through. It is often simpler to build in the container and flash or run the result from the host.

Document the project's build, test, and run commands in the root README, and state that they run in the dev container.

The `build` stage starts from `dev`, so the service is built with the same tools you develop with. [Self-Hosting](../docs/guides/self-hosting.md) explains how the `runtime` stage is run on servers.

## Troubleshooting

* **Changes to the Dockerfile have no effect:** Rebuild with `--remove-existing-container`, as shown in [Everyday Tasks](#everyday-tasks).
* **Git reports dubious ownership:** `post-create.sh` marks the workspace as safe. If you created the container before this step existed, rebuild it.
* **Files created in the container belong to another user:** The CLI matches the `dev` user's ID to yours on Linux. If you start the image another way, run it with your user ID, for example with `--user "$(id -u):$(id -g)"`.
* **Paths break in Git Bash on Windows:** Git Bash rewrites path arguments before Docker sees them. Run the commands in WSL, or set `MSYS_NO_PATHCONV=1`.
