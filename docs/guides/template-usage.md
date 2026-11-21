# Template Usage

Use this base as the starting files for a new repository or as the foundation of a derived template. It supplies conventions that work independently of a language, build system, or repository layout.

## Adopt the Base

1. Create the new repository from this one, either as a hosted template repository or by copying its files, including hidden files, into the new repository's root. Do not copy this repository's `.git` directory or history.
2. Replace the root README's template introduction with the project's name, purpose, and intended users.
3. Describe the actual repository layout and add setup, build, run, and verification commands as those capabilities are introduced. State the working directory and prerequisites for each command.
4. Review the contribution and documentation conventions. Document any project-specific exceptions explicitly.
5. Add language rules in [Coding Style](../coding-style.md) and toolchains in the [dev container](../../.devcontainer/README.md#customizing-the-container) as languages are introduced. Rename the container in `devcontainer.json` after the project.
6. Extend `.gitignore` for the project's real tools and generated outputs. Keep shared example configuration tracked and use placeholders for secrets. Add language settings to `.editorconfig` and any special line-ending rules to `.gitattributes`.
7. Set the image name in `compose.yaml` to the repository's GitHub path in lowercase. Add the service's build to the `build` stage of the Dockerfile and its start command to the `runtime` stage, and list its settings in `.env.example` and in the `environment` section of `compose.yaml`. After the first publish, check the package's visibility as [Releasing](releasing.md#after-the-first-publish) describes.
8. Adapt `.github/pull_request_template.md` to the project's review needs. Move or remove it if the repository is not hosted on GitHub.
9. Choose an appropriate license and add its text and any necessary notices before distributing the project. This template does not select a license for you.
10. Update the [Documentation Map](../README.md), guide index, and glossary to match the repository.
11. Check that local links resolve and that every documented command or capability is available.

## Choose a Layout

A single-project repository can document its setup and verification in the root README, with source and tests arranged for its language and tools.

A monorepo can group its components in directories suited to the project. Give each component a README when it has its own commands or prerequisites. Explain shared dependencies, cross-component verification, and how to work on one component from the root README. Root conventions apply throughout, with explicit local exceptions where needed.

The base requires no application, package, service, or product directories. Create them when the project needs them.

## Build a Derived Template

* Start with the base files and add the capabilities the derived template provides.
* Add language conventions to the expansion area in [Coding Style](../coding-style.md), or link from it to longer language-specific documents.
* Include the actual configuration, scripts, dependencies, and version requirements for added tooling.
* Document installation, common commands, and verification alongside each addition.
* Add the project's toolchains to the [dev container](../../.devcontainer/README.md#customizing-the-container) and document its build, test, and run commands in the root README.
* Add glossary or documentation-check commands when those checks are supplied. State which files they check and how to correct failures.
* Update shared guidance when a new capability changes the contribution workflow. Keep each rule in one place and link to it elsewhere.
* Preserve provider-neutral instructions in [AGENTS.md](../../AGENTS.md), including the `AI:` prefix for AI-generated pull request comments and replies.

Copying these files does not establish automatic inheritance or updates. Review and incorporate future base changes into derived templates as needed.
