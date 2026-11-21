# template-service

A foundation for services that run on your own machines, such as a chat bot on a Raspberry Pi or a website on a home server. It builds on [template-devcontainer](https://github.com/gavintranquilino/template-devcontainer), which provides shared conventions, pull request checks, and a dev container. This template adds a published container image and a Docker Compose setup, so that any machine with Docker can run the service with two files and one command.

## Start Here

* **Adopting or extending the template:** Follow [Template Usage](docs/guides/template-usage.md).
* **Setting up development:** Follow [Dev Container](.devcontainer/README.md) to open a shell in the shared environment.
* **Running the service on a server:** Follow [Self-Hosting](docs/guides/self-hosting.md).
* **Publishing a release:** Follow [Releasing](docs/guides/releasing.md).
* **Contributing:** Read [Contributing](CONTRIBUTING.md) for the branch, review, and verification workflow.
* **Writing code:** Follow [Coding Style](docs/coding-style.md).
* **Writing documentation:** Follow [Documentation](docs/documentation.md). The [Documentation Map](docs/README.md) lists the included documents.
* **AI assistants:** Read [AGENTS.md](AGENTS.md) for repository instructions.

## Included Files

```text
.
├── README.md                     Repository introduction
├── CONTRIBUTING.md               Contribution and review workflow
├── AGENTS.md                     Instructions for AI assistants
├── .gitignore                    Local files to exclude from version control
├── .gitattributes                Line-ending normalization
├── .editorconfig                 Shared editor settings
├── Dockerfile                    Development, build, and runtime images
├── .dockerignore                 Files kept out of image builds
├── compose.yaml                  How servers run the service
├── compose.override.yaml         Local image builds from a clone
├── .env.example                  Settings and secrets the service needs, with placeholders
├── .devcontainer/
│   ├── README.md                 Dev container setup and customization
│   ├── devcontainer.json         Dev container configuration
│   └── post-create.sh            Setup that runs when the container is created
├── .github/
│   ├── pull_request_template.md  Pull request description template
│   └── workflows/
│       ├── checks.yml            Checks that run on pull requests
│       └── publish.yml           Publishes the runtime image
├── tools/
│   ├── README.md                 Tool descriptions and local usage
│   └── scripts/                  Check scripts and their configuration
└── docs/
    ├── README.md                 Documentation map
    ├── coding-style.md           Shared style and an area for language rules
    ├── documentation.md          Documentation placement and conventions
    ├── glossary.md               Shared terms and acronyms
    └── guides/
        ├── README.md             Guide index
        ├── releasing.md          Versions, releases, and image tags
        ├── self-hosting.md       Running the service on a server
        └── template-usage.md     Adoption and extension checklist
```

## Repository Structure

Choose a source layout that fits the project. A single-project repository can keep its source and tests at the root. A monorepo can organize applications, packages, or services in separate directories, each with its own setup and verification instructions.

Root conventions apply throughout the repository. Local guidance can extend them for a component and must explicitly identify any exceptions. Explain component boundaries and shared workflows in the root README as the repository grows.

## How It Works

```text
Develop in the dev container ──► merge to main ──► image :main
                                 create release ──► image :1.2.3 and :latest
Server: compose.yaml + .env ──► docker compose up -d --pull always
```

The [Dockerfile](Dockerfile) has three stages. The `dev` stage is the dev container. The `build` stage builds the service with the same tools. The `runtime` stage is the small image that servers run. The [publish workflow](.github/workflows/publish.yml) builds it for 64-bit Intel or AMD and ARM processors and publishes it to the GitHub container registry.

Until the project adds its service, the runtime image runs a placeholder that only keeps the container running. This lets you test releases and deployment before writing the service.

To run the service locally exactly as a server would, copy `.env.example` to `.env` and run `docker compose up -d --build` from the repository root.

## Included Checks

Pull requests run the checks described in [Tools](tools/README.md). They need only Python 3 and Git, and you can run them locally with the same commands, inside or outside the dev container.

## Extending the Base

This template builds on template-devcontainer and adds a runtime image, Docker Compose configuration, and image publishing. It includes no language toolchains or service code. Projects add their toolchains to the `dev` stage, their build to the `build` stage, and their start command to the `runtime` stage. Add language rules, toolchains, command-line tools, and automated checks in derived templates or individual repositories. Each addition must include the files and instructions needed to use it.

When adopting the template, replace this introduction with the project's purpose, layout, and setup instructions. Keep the shared conventions and adapt them where needed, as [Template Usage](docs/guides/template-usage.md) describes.
