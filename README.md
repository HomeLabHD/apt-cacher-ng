# 📦 apt-cacher-ng

A caching proxy for Debian-based package downloads (e.g., APT). This image is ideal for improving speed and reducing bandwidth in CI pipelines or homelab networks that frequently install packages from Debian, Ubuntu, or other APT-based distributions. Includes built-in logging support for monitoring usage and troubleshooting caching behavior.

<!-- sf:project:start -->
[![GitHub](https://img.shields.io/badge/GitHub-mirror-181717?logo=github)](https://github.com/HomeLabHD/apt-cacher-ng) [![GitLab](https://img.shields.io/badge/GitLab-source-FC6D26?logo=gitlab)](https://gitlab.prplanit.com/HomeLabHD/apt-cacher-ng) [![license](https://raw.githubusercontent.com/HomeLabHD/apt-cacher-ng/main/.stagefreight/scribe/license.svg)](https://github.com/HomeLabHD/apt-cacher-ng/blob/main/LICENSE) [![Open Issues](https://img.shields.io/github/issues/HomeLabHD/apt-cacher-ng)](https://github.com/HomeLabHD/apt-cacher-ng/issues) [![Open PRs](https://img.shields.io/github/issues-pr/HomeLabHD/apt-cacher-ng)](https://github.com/HomeLabHD/apt-cacher-ng/pulls) [![Contributors](https://img.shields.io/github/contributors/HomeLabHD/apt-cacher-ng)](https://github.com/HomeLabHD/apt-cacher-ng/graphs/contributors) [![donate](https://img.shields.io/badge/donate-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/T6T41IT163) [![sponsor](https://img.shields.io/badge/sponsor-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/HomeLabHD)
<!-- sf:project:end -->
<!-- sf:badges:start -->
[![release](https://raw.githubusercontent.com/HomeLabHD/apt-cacher-ng/main/.stagefreight/scribe/release.svg)](https://github.com/HomeLabHD/apt-cacher-ng/releases) [![build](https://raw.githubusercontent.com/HomeLabHD/apt-cacher-ng/main/.stagefreight/scribe/build.svg)](https://gitlab.prplanit.com/HomeLabHD/apt-cacher-ng/-/pipelines) [![Last Commit](https://img.shields.io/github/last-commit/HomeLabHD/apt-cacher-ng)](https://github.com/HomeLabHD/apt-cacher-ng/commits) [![StageFreight](https://img.shields.io/badge/StageFreight-0.9.2--dev+ef726e4-310937?logo=readthedocs&logoColor=white)](https://stagefreight.prplanit.com)
<!-- sf:badges:end -->
<!-- sf:image:start -->
[![GHCR](https://img.shields.io/badge/GHCR-homelabhd%2Fapt--cacher--ng-181717?logo=github&logoColor=white)](https://github.com/HomeLabHD/apt-cacher-ng/pkgs/container/apt-cacher-ng) [![Docker](https://img.shields.io/badge/Docker-hlhd%2Fapt--cacher--ng-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/hlhd/apt-cacher-ng) [![pulls](https://raw.githubusercontent.com/HomeLabHD/apt-cacher-ng/main/.stagefreight/scribe/pulls.svg)](https://hub.docker.com/r/hlhd/apt-cacher-ng) [![Harbor](https://img.shields.io/badge/Harbor-hlhd%2Fapt--cacher--ng-60b932)](https://cr.pcfae.com/harbor/projects)

[![latest](https://raw.githubusercontent.com/HomeLabHD/apt-cacher-ng/main/.stagefreight/scribe/release-latest.svg)](https://github.com/HomeLabHD/apt-cacher-ng/pkgs/container/apt-cacher-ng) ![updated](https://raw.githubusercontent.com/HomeLabHD/apt-cacher-ng/main/.stagefreight/scribe/release-updated.svg) [![size](https://raw.githubusercontent.com/HomeLabHD/apt-cacher-ng/main/.stagefreight/scribe/release-size.svg)](https://github.com/HomeLabHD/apt-cacher-ng/pkgs/container/apt-cacher-ng) [![latest-dev](https://raw.githubusercontent.com/HomeLabHD/apt-cacher-ng/main/.stagefreight/scribe/dev-latest.svg)](https://github.com/HomeLabHD/apt-cacher-ng/pkgs/container/apt-cacher-ng) ![updated](https://raw.githubusercontent.com/HomeLabHD/apt-cacher-ng/main/.stagefreight/scribe/dev-updated.svg) [![size](https://raw.githubusercontent.com/HomeLabHD/apt-cacher-ng/main/.stagefreight/scribe/dev-size.svg)](https://github.com/HomeLabHD/apt-cacher-ng/pkgs/container/apt-cacher-ng)
<!-- sf:image:end -->

### Features

|                          |                                                                    |
| ------------------------ | ------------------------------------------------------------------ |
| **Log Streaming**        | Functional container log streaming via `tail -F` to stdout         |
| **Runtime Overrides**    | Configure PassThroughPattern, concurrency, and timeouts at runtime |
| **Secure Volumes**       | Init-based ownership management for cache and log directories      |
| **Health Checks**        | Built-in HTTP health check against the report page                 |
| **Tini Init**            | Proper signal handling and zombie reaping via tini                  |

### Documentation

| Topic | |
|-------|-|
| [Usage](docs/README.md) | Running the image, client configuration, and maintenance |
| [Docker](docs/docker/) | [docker-compose.yaml](docs/docker/docker-compose.yaml) |
| [Kubernetes](docs/k8s/) | [pod.yaml](docs/k8s/pod.yaml) · [service.yaml](docs/k8s/service.yaml) |

---

## Installation

Pull the image from [Docker Hub](https://hub.docker.com/r/hlhd/apt-cacher-ng) or build it yourself:

```bash
docker pull docker.io/hlhd/apt-cacher-ng:latest
```

```bash
git clone https://github.com/HomeLabHD/apt-cacher-ng
cd apt-cacher-ng
docker build -t hlhd/apt-cacher-ng .
```

## Contributing

- Fork the repository
- Submit Pull Requests / Merge Requests
- [File issues](../../issues/new) with Docker version, run/compose command, and environment details

## Credits

* Based on [Apt-Cacher NG](https://www.unix-ag.uni-kl.de/~bloch/acng/) by Eduard Bloch, the caching proxy for Linux package archives — [source](https://salsa.debian.org/blade/apt-cacher-ng) · [BSD-4-Clause](LICENSE)
* Inspired by [sameersbn/docker-apt-cacher-ng](https://github.com/sameersbn/docker-apt-cacher-ng) — I struggled to find an image with working logs, so I made one

## Disclaimer

> The Software provided hereunder ("Software") is licensed "as-is," without warranties of any kind—express, implied, or telepathically transmitted. The Softwarer (yes, that's totally a word now) makes no promises about functionality, performance, compatibility, security, or availability—and absolutely no warranty of any sort. The developer shall not be held responsible, even if the software is clearly the reason your dog ran off to join a circus, or your mom scored five tickets to Hawaii but you missed out because you were knee-deep in a gaming bender.

> If using this caching proxy leads you down a rabbit hole of obsessive network optimizations, breaks your fragile grasp of version pinning, or causes an uprising among your offline-first containers—sorry, still not liable. Also not liable if your repo mirror syncs so fast it rips a hole in the space-time continuum. The developer likewise claims no credit for anything that actually goes right either. Any positive experiences are owed entirely to the brilliant folks behind the original tools, their forks, and the unstoppable force that is the Open Source community.

> It's never been a better time to be a PC user—just don't blame me when it inevitably eats your weekend.

## License

Apt-Cacher NG is distributed under the [BSD-4-Clause](https://metadata.ftp-master.debian.org/changelogs//main/a/apt-cacher-ng/apt-cacher-ng_3.7.5-1.1_copyright) license.
