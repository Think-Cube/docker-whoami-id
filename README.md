# docker-whoami-id

Tiny HTTP server that answers every request with the hostname of the container it runs in. By default Docker sets that to the short container ID, which makes it handy for checking load balancing, service discovery and ingress routing.

Images are built for `linux/amd64` and `linux/arm64`, run as a non-root user and ship with an SBOM, build provenance and a keyless signature.

## Images

Images are published to GitHub Container Registry as `ghcr.io/think-cube/whoami-id`.

| Tag | Meaning | Changes? |
|---|---|---|
| `2.0.0` | Exact release | Never |
| `2.0`, `2`, `latest` | Newest matching release | With each release |
| `edge` | Newest build of `main` | With each merge and weekly rebuild |
| `edge-YYYYMMDD` | Weekly rebuild of `main` | Never |
| `sha-<commit>` | Build of one `main` commit | Never |

For production, pin by digest: `ghcr.io/think-cube/whoami-id:2.0.0@sha256:...`.

## Usage

```bash
docker run --rm -p 8000:8000 ghcr.io/think-cube/whoami-id:2
curl http://localhost:8000/
# I'm 3f2a1b9c8d7e
```

Every path returns the same answer. Set `PORT` to listen on another port:

```bash
docker run --rm -e PORT=9000 -p 9000:9000 ghcr.io/think-cube/whoami-id:2
```

The image contains only a static binary, runs as UID/GID `10001` and works with a read-only root filesystem and all capabilities dropped:

```bash
docker run --rm --read-only --cap-drop ALL --security-opt no-new-privileges -p 8000:8000 ghcr.io/think-cube/whoami-id:2
```

## Run as a systemd service

`whoami@.service` is a template unit that runs one container per instance, each on a random host port:

```bash
sudo cp whoami@.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now whoami@1 whoami@2
docker port whoami-1 8000
```

## Verify an image

Check the signature:

```bash
cosign verify ghcr.io/think-cube/whoami-id:2.0.0 \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github\.com/Think-Cube/workflows/\.github/workflows/container-image\.yml@refs/tags/v.+$'
```

Read the SBOM and provenance:

```bash
docker buildx imagetools inspect ghcr.io/think-cube/whoami-id:2.0.0 --format '{{ json .SBOM }}'
docker buildx imagetools inspect ghcr.io/think-cube/whoami-id:2.0.0 --format '{{ json .Provenance }}'
```

## Build and test locally

```bash
docker build -t whoami-id:local .
bash tests/smoke.sh whoami-id:local
```

The build runs `go vet` and the unit tests before compiling. The smoke test starts the container with the same hardening as the systemd unit and checks the answer and the `PORT` setting.

## Support

Only the newest release receives fixes. `main` is rebuilt every week, and images with fixable critical vulnerabilities are not published. Report security issues through [GitHub private vulnerability reporting](https://github.com/Think-Cube/docker-whoami-id/security/advisories/new).

## License

This project is licensed under the [MIT License](LICENSE).

## Contribution

Feel free to contribute by opening issues or pull requests. Your feedback and improvements are highly appreciated!
