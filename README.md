# template-devcontainer

A foundation for new repositories that adds a shared Linux development environment to [template-CI](https://github.com/gavintranquilino/template-CI). It provides coding, documentation, and contribution conventions, lightweight pull request checks, and a dev container that gives every contributor the same tools. Projects add their own languages and toolchains to the container.

## Start Here

* **Adopting or extending the template:** Follow [Template Usage](docs/guides/template-usage.md).
* **Setting up development:** Follow [Dev Container](.devcontainer/README.md) to open a shell in the shared environment.
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
├── .devcontainer/
│   ├── README.md                 Dev container setup and customization
│   ├── devcontainer.json         Dev container configuration
│   ├── Dockerfile                Development image
│   └── post-create.sh            Setup that runs when the container is created
├── .github/
│   ├── pull_request_template.md  Pull request description template
│   └── workflows/
│       └── checks.yml            Checks that run on pull requests
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
        └── template-usage.md     Adoption and extension checklist
```

## Repository Structure

Choose a source layout that fits the project. A single-project repository can keep its source and tests at the root. A monorepo can organize applications, packages, or services in separate directories, each with its own setup and verification instructions.

Root conventions apply throughout the repository. Local guidance can extend them for a component and must explicitly identify any exceptions. Explain component boundaries and shared workflows in the root README as the repository grows.

## Included Checks

Pull requests run the checks described in [Tools](tools/README.md). They need only Python 3 and Git, and you can run them locally with the same commands, inside or outside the dev container.

## Extending the Base

This template builds on template-CI and adds a dev container. Contributors need a container engine and the dev container CLI, and no particular editor. The container includes no language toolchains. Add language rules, toolchains, command-line tools, and automated checks in derived templates or individual repositories. Each addition must include the files and instructions needed to use it.

When adopting the template, replace this introduction with the project's purpose, layout, and setup instructions. Keep the shared conventions and adapt them where needed, as [Template Usage](docs/guides/template-usage.md) describes.
