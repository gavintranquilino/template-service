# Releasing

The [publish workflow](../../.github/workflows/publish.yml) builds the runtime image and publishes it to the GitHub container registry (GHCR) for 64-bit Intel or AMD and 64-bit ARM processors. Servers then run it as [Self-Hosting](self-hosting.md) describes.

## What Gets Published

| Event | Image tags | Purpose |
| --- | --- | --- |
| Merge to `main` | `main` | The newest code, for testing |
| Release `v1.2.3` | `1.2.3`, `1.2`, `1`, `latest` | A version servers can run and pin |
| Release `v0.4.2` | `0.4.2`, `0.4`, `latest` | Before 1.0, no major-only tag is published |
| Pre-release `v1.3.0-rc.1` | `1.3.0-rc.1` | A release candidate. `latest` does not change |

Pull requests publish nothing. Releases happen only when a maintainer creates one. Every image is built from a commit on `main`, and no release branches are needed.

To run the workflow by hand, open the repository's **Actions** tab, choose **publish**, and select **Run workflow**. Running it on `main` republishes the `main` tag.

## Version Numbers

Releases use [Semantic Versioning](https://semver.org/), written as `MAJOR.MINOR.PATCH`. Choose the next version by the biggest change since the last release, as seen by the people who run or use the service.

| Part | Increase it when | Examples | Reset |
| --- | --- | --- | --- |
| **Major** | An upgrade requires the user to change something, or something they rely on stops working | Renaming or removing a setting in `.env`, changing the data format without migrating it, removing a command or API endpoint | Minor and patch to 0, so `1.4.2` becomes `2.0.0` |
| **Minor** | Something new is added and existing setups keep working | A new optional setting, a new command or feature, a new endpoint | Patch to 0, so `1.4.2` becomes `1.5.0` |
| **Patch** | Something is fixed and nothing is added or removed | A bug fix, a security update, a performance improvement | Nothing, so `1.4.2` becomes `1.4.3` |

* **Before 1.0:** Versions such as `0.4.2` mean the service is still taking shape. Any minor release can include breaking changes. Release `1.0.0` when others start to rely on the service.
* **Pre-releases:** Add a suffix such as `-rc.1` to try a release on a server before announcing it.
* **Each version is permanent:** Never move or reuse a version tag. If a release is broken, publish a new patch.

## Create a Release

Releases are created by hand.

1. Make sure `main` contains everything for the release and its checks pass.
2. On GitHub, open **Releases** and select **Draft a new release**.
3. Under **Choose a tag**, type the new version with a `v` prefix, such as `v1.2.0`, and create it on `main`.
4. Write release notes for the people who run the service. List breaking changes and any steps needed to upgrade first.
5. For a pre-release, also select **Set as a pre-release**.
6. Select **Publish release**. The publish workflow starts and takes a few minutes.

To release from the command line instead, tag the commit and push the tag.

```sh
git switch main && git pull
git tag -a v1.2.0 -m "v1.2.0"
git push origin v1.2.0
```

## After the First Publish

GHCR creates the package on the first publish. Check its visibility once.

1. Open the repository on GitHub and select the package under **Packages**.
2. In **Package settings**, under **Danger Zone**, set the visibility to **Public** if it is not already.

Public images can be pulled by any server without logging in. To keep the image private, follow [Private Images](self-hosting.md#private-images) on each server.

## Verify a Release

Check that the workflow succeeded in the **Actions** tab, then confirm that both processor types were published.

```sh
docker buildx imagetools inspect ghcr.io/<owner>/<repository>:1.2.0
```

The output lists `linux/amd64` and `linux/arm64`. Then update a server as [Self-Hosting](self-hosting.md#everyday-tasks) describes.
