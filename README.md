# ai-assistant

## Local development

```bash
python -m venv .venv
.venv/Scripts/pip install -r requirements-dev.txt   # Linux/macOS: .venv/bin/pip
python -m pytest -q
uvicorn app.main:app --reload
```

## CI/CD (AWS CodePipeline, us-east-2)

Every push to `main` runs the `ai-assistant-pipeline` pipeline:

1. **Source** – pulls the commit from GitHub through a CodeConnections connection.
2. **Build** – CodeBuild runs `buildspec.yml`: installs dependencies, runs `pytest`,
   builds the Docker image and pushes it to ECR as `ai-assistant:<commit>`.
3. **Deploy** – CodeDeploy runs `appspec.yml` on the Auto Scaling Group, one instance at a time:
   `scripts/stop.sh` → `scripts/start.sh` (pull and run the image) → `scripts/validate.sh`
   (health check; a failure rolls the deployment back).

Instances come from a launch template whose user data is `infra/user-data.sh`
(installs Docker and the CodeDeploy agent). Instances the Auto Scaling Group adds later
receive the latest revision automatically.

The site is served at the Application Load Balancer's DNS name, not an instance IP.
