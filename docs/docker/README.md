# Docker Deployment

## Installation

Pull the image from [Docker Hub](https://hub.docker.com/r/hlhd/apt-cacher-ng):

```bash
docker pull docker.io/hlhd/apt-cacher-ng:latest
```

or build it yourself (see [Building from Source](#building-from-source)).

## Quick Start

```bash
docker run --name apt-cacher-ng -d --restart=always \
  -p 3142:3142 \
  -v /srv/apt-cacher-ng/cache:/var/cache/apt-cacher-ng \
  -v /srv/apt-cacher-ng/log:/var/log/apt-cacher-ng \
  --cap-drop=ALL \
  --cap-add=CHOWN --cap-add=SETUID --cap-add=SETGID --cap-add=DAC_OVERRIDE \
  --security-opt=no-new-privileges:true \
  docker.io/hlhd/apt-cacher-ng:latest
```

### Command-line Arguments

Custom arguments are passed directly to apt-cacher-ng:

```bash
docker run --rm -it docker.io/hlhd/apt-cacher-ng:latest -h
```

## Docker Compose

Copy or reference the [docker-compose.yaml](docker-compose.yaml) in this directory:

```bash
docker compose up -d
```

## Building from Source

```bash
git clone https://github.com/HomeLabHD/apt-cacher-ng && cd apt-cacher-ng
docker build -t hlhd/apt-cacher-ng .
```
