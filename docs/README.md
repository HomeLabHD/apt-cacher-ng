# Documentation

| Guide | Description |
|-------|-------------|
| [Docker](docker/) | Docker run, Compose, and building from source |
| [Kubernetes](k8s/) | Pod and Service manifests |

## Client Configuration

Configure APT on Debian-based systems to use the proxy:

```bash
# /etc/apt/apt.conf.d/01proxy
Acquire::HTTP::Proxy "http://<host-ip>:3142";
Acquire::HTTPS::Proxy "false";
```

### Dockerfile Snippet

```dockerfile
RUN echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy \
 && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `APT_CACHER_NG_CACHE_DIR` | `/var/cache/apt-cacher-ng` | Cache directory path |
| `APT_CACHER_NG_LOG_DIR` | `/var/log/apt-cacher-ng` | Log directory path |
| `APT_CACHER_NG_USER` | `apt-cacher-ng` | Service user |
| `PASS_THROUGH_PATTERN` | `.*` | Regex for pass-through requests |
| `MAX_THREADS` | `20` | Max standby connection threads |
| `NETWORK_TIMEOUT` | `60` | Network timeout in seconds |
| `PRECACHE_FOR` | `` | Array of references in {} separated by , |
| `USER_AGENT` | `` | Use a custom agent response |
| `EX_THRESHOLD` | `4` | Num of days to keep unreferenced files |
| `ADMIN_AUTH_USER` | `` | Admin Username |
| `ADMIN_AUTH_PASS` | `` | Admin Password |

## Volumes

| Mount Point | Purpose |
|-------------|---------|
| `/var/cache/apt-cacher-ng` | Package cache |
| `/var/log/apt-cacher-ng` | Access and error logs |

Cache and logs should persist across restarts:

```bash
mkdir -p /srv/apt-cacher-ng/{cache,log}
```

## Logs

This image streams logs to stdout:

```bash
docker logs -f apt-cacher-ng
```

Or tail the log files directly:

```bash
docker exec -it apt-cacher-ng tail -f /var/log/apt-cacher-ng/apt-cacher.log
```

## Maintenance

### Cache Expiry

Run with the `-e` flag:

```bash
docker run --rm -it \
  -v /srv/apt-cacher-ng/cache:/var/cache/apt-cacher-ng \
  docker.io/hlhd/apt-cacher-ng:latest -e
```

Or via the web UI at `http://localhost:3142/acng-report.html`.

### Upgrading

```bash
docker pull docker.io/hlhd/apt-cacher-ng:latest
docker stop apt-cacher-ng && docker rm apt-cacher-ng
```

Then restart using your run or compose setup.

### Shell Access

```bash
docker exec -it apt-cacher-ng bash
```

## Notes

- This image is a caching proxy only — it does not serve packages directly.
- `ENTRYPOINT` uses tini for proper signal handling and zombie reaping.
- Health checks run every 10s against the report page on port 3142.
