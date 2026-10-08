# Gerard Almenares — Secure DigitalOcean Deployment

**Production:** https://gerardalmenares.com  
**QA:** https://qa.gerardalmenares.com

## Infrastructure

My own DigitalOcean Droplet runs Docker and Traefik.
Traefik routes the main domain and QA subdomain to separate containers
and manages HTTPS certificates.

Administration and deployment use the non-root account `gerard`.
SSH public-key authentication is enabled. Direct root SSH login,
password authentication, and keyboard-interactive authentication are disabled.
The administrator has sudo access and Docker group membership.
The website container itself runs as a non-root user.

## CI/CD and promotion rule

Pushes to `qa` automatically deploy only QA.
After checking QA, I promote the change by merging `qa` into `main`.
Pushes to `main` automatically deploy production.

GitHub Actions validates the HTML and deployment script, validates Compose,
builds a Docker image, and starts a temporary container to test its HTTP
response, deployed revision, and non-root user.
Only after these checks pass does it push the image to GitHub Container
Registry and deploy it over SSH to DigitalOcean.

Every image is tagged with the full Git commit SHA. The deployed revision
is also available at `/revision.txt`.
QA and production use separate Compose projects and containers.
A QA deployment does not update production.

SSH credentials are stored in GitHub Actions secrets.
The workflow verifies the server's SSH host key.
Registry authentication uses GitHub's automatic workflow token.

## Test Evidence

Evidence links and screenshots are added below after the deployments
and QA-to-production demonstration have completed.

### Successful workflow runs

| Environment | Workflow run | Deployed commit / image tag |
|---|---|---|
| QA | [Successful run](https://github.com/GerardA8/secure-deployment/actions/runs/37820619067) | `5e9b191e0220fc2bd889c357bc27be11bf0355b1` |
| Production | [Successful run](https://github.com/GerardA8/secure-deployment/actions/runs/37820939026) | `694aa1bf97e33f8b1e481b1b7a4aaa99e3ab2c4c` |

### Image registry

[Container package](https://github.com/users/GerardA8/packages/container/package/secure-deployment)

Image names use `ghcr.io/gerarda8/secure-deployment:<commit SHA>`.

### Demonstration screenshots

QA shows Release 2 while production still shows Release 1:

![QA before promotion](evidence/qa-before-promotion.png)

Production shows Release 2 after promotion:

![Production after promotion](evidence/production-after-promotion.png)

Successful SSH-key login as the non-root administrator:

![SSH key login](evidence/ssh-key-login.png)

Effective SSH settings and sudo access:

![SSH settings](evidence/ssh-settings.png)

Rejected direct root and password-only SSH logins:

![Rejected SSH logins](evidence/ssh-rejected.png)
