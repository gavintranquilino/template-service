# Self-Hosting

This guide runs the service on a machine you control, such as a Raspberry Pi, a spare laptop, or a home server. The steps are the same on each. The machine downloads the published image and runs it with Docker Compose.

## How It Works

* **The image** contains the service and everything it needs to run. [Releasing](releasing.md) explains how GitHub Actions publishes it to the GitHub container registry (GHCR).
* **`compose.yaml`** describes how to run the image: which version, which settings, where data is kept, and to restart it automatically.
* **`.env`** holds the settings and secrets for one machine. It is never committed or built into the image.

A server needs only Docker and these two files. It does not need the source code, a programming language, or any build tools.

## Prepare the Machine

### Raspberry Pi

1. Flash **Raspberry Pi OS Lite (64-bit)** with [Raspberry Pi Imager](https://www.raspberrypi.com/software/). The 64-bit system is required, because the image is built for 64-bit ARM. In the Imager settings, set the hostname and user, and enable SSH with your public key.
2. Start the Pi and connect to it from your computer.

   ```sh
   ssh <user>@<hostname>.local
   ```

3. Install Docker, then log out and back in so your user can run it.

   ```sh
   curl -fsSL https://get.docker.com | sh
   sudo usermod -aG docker "$USER"
   ```

For a service that writes a lot of data, consider booting from a USB SSD instead of an SD card, which wears out under heavy writing.

### Other Machines

* **Linux server or laptop:** Install [Docker Engine](https://docs.docker.com/engine/install/) and add your user to the `docker` group as above.
* **Windows or macOS:** Install [Docker Desktop](https://docs.docker.com/get-docker/) and enable **Start Docker Desktop when you sign in**. Keep the machine from sleeping while it serves.
* **Unraid or Portainer:** See [Homelab Tools](#homelab-tools).

Docker downloads the right image for the machine's processor automatically.

## Deploy

Create a folder for the service and download its configuration. Replace `<owner>/<repository>` with the repository's GitHub path.

```sh
mkdir -p ~/services/<repository> && cd ~/services/<repository>
curl -fsSLO https://raw.githubusercontent.com/<owner>/<repository>/main/compose.yaml
curl -fsSL https://raw.githubusercontent.com/<owner>/<repository>/main/.env.example -o .env
chmod 600 .env
```

Edit `.env` to set the version and fill in the settings and secrets the service needs.

```sh
nano .env
```

`APP_VERSION` selects the image to run.

| Value | Runs | Use it for |
| --- | --- | --- |
| `1.2.3` | That exact release | Production, with deliberate updates and easy rollback |
| `latest` | The newest release | Production that follows each release |
| `main` | The newest merge to `main` | Testing changes before a release, or a personal service under active development |

Before the first release, only `main` exists.

Start the service.

```sh
docker compose up -d
```

The service now runs in the background and starts again after a crash or a restart of the machine.

## Everyday Tasks

Run these from the service's folder.

| Task | Command |
| --- | --- |
| Start | `docker compose up -d` |
| Stop | `docker compose down` |
| Update to the version in `.env` | `docker compose up -d --pull always` |
| Apply changes to `.env` | `docker compose up -d` |
| Check status | `docker compose ps` |
| Follow the logs | `docker compose logs -f` |
| Restart | `docker compose restart` |
| Open a shell in the running container | `docker compose exec app sh` |

Updates are manual. To update, change `APP_VERSION` if it is pinned, then run the update command. To roll back, set `APP_VERSION` to the previous release and run the update command again. If the requested version does not exist, the command stops with an error and the running service is left alone.

To clean up old images after updates, run `docker image prune`.

## Settings and Secrets

Each setting the service needs is listed in two places in the repository. `.env.example` documents it with a placeholder, and the `environment` section of `compose.yaml` passes it into the container. On a server, Docker Compose reads the values from `.env` in the same folder, or from the variables entered in a tool such as Portainer.

* Keep secrets only on the machines that need them. `.env.example` in the repository lists the names, with placeholders.
* Use separate secrets for development and production, such as a separate test account or token on your own computer. Then nothing you run while developing can affect production.
* Restrict who can read `.env` with `chmod 600 .env`.
* Anyone who can run Docker on the machine can read the service's environment variables. Treat Docker access as administrator access.
* Share secrets with other maintainers through a password manager, never through Git or chat.

A required setting written as `${NAME:?message}` in `compose.yaml` stops the start with that message when its value is missing.

## Running More Than One Service

A project can run several services from one repository, such as a chat bot and the website that manages it. Add a service to `compose.yaml` for each one. Services can share one image and run different commands, and they can share the `data` volume.

```yaml
services:
  bot:
    image: ghcr.io/<owner>/<repository>:${APP_VERSION:-latest}
    command: ["/app/bot"]
    # environment, restart, volumes, and logging as in the app service
  web:
    image: ghcr.io/<owner>/<repository>:${APP_VERSION:-latest}
    command: ["/app/web"]
    ports:
      - "8080:8080"
    # environment, restart, volumes, and logging as in the app service
```

Add a matching `build` section for each service to `compose.override.yaml`. Every Compose command accepts service names, so you can manage one service without affecting the others.

| Task | Command |
| --- | --- |
| Stop one service and keep the others running | `docker compose stop bot` |
| Start it again | `docker compose start bot` |
| Follow one service's logs | `docker compose logs -f bot` |

Run only one copy of a service that logs in to an outside account, such as a chat bot. Two copies with the same token both respond to every event. When moving a service to another machine, stop it on the old machine first.

## Data and Backups

The service stores files that must survive updates in the `data` volume, mounted at `/data` in the container. `docker compose down` keeps the volume. `docker compose down -v` deletes it.

To back up the volume to a file in the service's folder, stop the service and archive the volume with a temporary container.

```sh
docker compose down
docker compose run --rm --no-deps -u root -v "$PWD:/backup" app \
  tar czf /backup/data-backup.tar.gz -C /data .
docker compose up -d
```

To restore, stop the service, empty the volume, and extract the archive into it. Emptying the volume first removes files that were created after the backup.

```sh
docker compose down
docker compose run --rm --no-deps -u root -v "$PWD:/backup" app \
  sh -c 'find /data -mindepth 1 -delete && tar xzf /backup/data-backup.tar.gz -C /data'
docker compose up -d
```

These commands use `tar` from the runtime image. If the project switches to a minimal base image without `tar`, update them. Store backups on another machine.

To move the service to another machine, back up the volume, stop the service on the old machine, deploy it on the new machine, and restore the backup there.

## Run From Source

To run unreleased code, such as when trying a change on the Pi itself, clone the repository and build the image on the machine.

```sh
git clone https://github.com/<owner>/<repository>.git
cd <repository>
cp .env.example .env    # then fill it in
docker compose up -d --build
```

In a clone, `compose.override.yaml` adds the build settings, and Docker Compose loads it automatically. After pulling new commits, run `docker compose up -d --build` again. Building on a Raspberry Pi can be slow for compiled languages, and published images are usually faster to deploy.

A folder that contains only `compose.yaml` has no build settings, so updates there always use a published image and never build unreleased code by accident.

Do not edit files inside a running container. Containers are replaced on every update, which discards those changes. Change the code in the repository and rebuild or release it.

## Homelab Tools

A machine can run many self-hosted applications, such as a file server, a media server, and this service. Each application is a separate **stack**, with its own `compose.yaml`, its own volumes, and its own network. Stacks do not affect each other, and each one is updated or stopped on its own.

```text
server
├── reverse proxy     The only stack using ports 80 and 443
├── files/            compose.yaml
├── media/            compose.yaml
└── <repository>/     compose.yaml
```

### Portainer

[Portainer](https://www.portainer.io/) manages stacks through a web interface.

1. Open **Stacks** and select **Add stack**.
2. Choose **Repository** to read `compose.yaml` from GitHub, or **Web editor** to paste it.
3. Under **Environment variables**, add each setting from `.env.example` with its real value.
4. Deploy the stack.

To update, open the stack, select **Pull and redeploy**, and turn on re-pulling the image. To change the version, edit `APP_VERSION` in the stack's environment variables.

### Unraid

Unraid's built-in templates run one container each. For a stack with several services, install the **Docker Compose Manager** plugin from Community Applications, create a stack, paste `compose.yaml`, and enter the settings in the stack's environment file. Alternatively, run Portainer on Unraid and follow the steps above.

### Reverse Proxy

When more than one stack serves a website, run a reverse proxy, such as [Caddy](https://caddyserver.com/) or [Nginx Proxy Manager](https://nginxproxymanager.com/), as its own stack. It receives all web traffic on ports 80 and 443 and forwards each request by hostname, for example `bot.home.example` to this service. It can also provide HTTPS. The service then joins the proxy's network instead of publishing its own port. Document the chosen approach in the project's README.

## Private Images

Images are public by default in this template, so servers need no login. If the package is private, create a GitHub personal access token with only the `read:packages` scope and log in once on each server.

```sh
docker login ghcr.io -u <github-username>
```

Paste the token when asked for a password. In Portainer, add the registry under **Registries** instead.

## Remote Access

This template does not expose the service to the internet. A service that only makes outgoing connections, such as a chat bot, needs no open ports. For a website, choose how to reach it, such as on your local network, through a private network service, or through a [reverse proxy](#reverse-proxy) with HTTPS.

## Troubleshooting

* **`exec format error`:** The image does not match the machine's processor. On a Raspberry Pi, check that the system is 64-bit with `uname -m`, which should print `aarch64`.
* **`denied` or `unauthorized` when pulling:** The package is private, the image name in `compose.yaml` is wrong, or nothing has been published yet. See [Private Images](#private-images).
* **`manifest unknown`:** The tag in `APP_VERSION` has not been published. Use `main` before the first release.
* **`required variable ... is missing a value`:** Add the named setting to `.env`, or to the stack's environment variables in Portainer or Unraid.
* **The service keeps restarting:** Read the reason with `docker compose logs`. A missing or wrong setting is the most common cause.
