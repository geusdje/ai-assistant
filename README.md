# ai-assistant

## Local development

```bash
python -m venv .venv
.venv/Scripts/pip install -r requirements-dev.txt   # Linux/macOS: .venv/bin/pip
python -m pytest -q
uvicorn app.main:app --reload
```

## CI/CD

`.github/workflows/deploy.yml` runs on every push to `main`:

1. **test** – installs `requirements-dev.txt` and runs `pytest`.
2. **deploy** – uploads the commit to the EC2 host over SSH and runs `deploy/deploy.sh`,
   which builds the Docker image and restarts the container on port 80.

Required repository secrets (Settings → Secrets and variables → Actions):

| Secret        | Value                                   |
|---------------|-----------------------------------------|
| `EC2_HOST`    | Public IP or DNS of the instance        |
| `EC2_USER`    | `ec2-user` (Amazon Linux)               |
| `EC2_SSH_KEY` | Full contents of the instance's `.pem`  |

The instance has no Elastic IP, so its public IP changes after a stop/start — update `EC2_HOST` when that happens.

SSH keys live in `.secrets/` (git-ignored).
