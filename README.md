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

The site is served at the load balancer's address (`WebsiteUrl` stack output), not an instance IP.

## Infrastructure (`infra/template.yml`)

All AWS resources are one CloudFormation stack: VPC, load balancer, launch template,
Auto Scaling Group (1–4 instances, scales on 70% average CPU), ECR, CodeDeploy, CodeBuild,
CodePipeline and the IAM roles they use.

Create or update it from AWS CloudShell in us-east-2:

```bash
git clone https://github.com/geusdje/ai-assistant && cd ai-assistant   # or: git pull
aws cloudformation deploy --stack-name ai-assistant \
  --template-file infra/template.yml --capabilities CAPABILITY_IAM
```

After the first create, approve the GitHub connection once
(Developer Tools → Settings → Connections → `ai-assistant-github` → Update pending connection),
then click **Release change** on the pipeline.

To delete everything: empty the stack's S3 artifact bucket, then
`aws cloudformation delete-stack --stack-name ai-assistant`.
