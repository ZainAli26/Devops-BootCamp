# DevOps BootCamp — Beginner-Friendly Deployment Guide

This repository demonstrates a real-world DevOps workflow using **FastAPI**, **Streamlit**, **CI/CD**, and **Google Cloud Platform (GCP)**. You will learn how to run the project locally, containerize services with Docker, deploy to the cloud using **Cloud Run + Cloud Functions**, and automate everything using **Terraform & GitHub Actions**.

This project contains three main services:

| Component          | Tech      | Deployment      | Purpose                            |
| ------------------ | --------- | --------------- | ---------------------------------- |
| **API**            | FastAPI   | Cloud Run       | Backend service exposing endpoints |
| **Web App**        | Streamlit | Cloud Run       | UI that communicates with the API  |
| **Cloud Function** | Python    | Cloud Functions | Sends Slack notifications          |

Once deployed, the Cloud Function is triggered and posts messages to Slack while the frontend calls the backend over an exposed URL.

## Required Tools

Before you begin, install:

* Python 3 - [https://www.python.org/downloads/](https://www.python.org/downloads/)
* Docker - [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)
* Terraform - [https://developer.hashicorp.com/terraform/tutorials](https://developer.hashicorp.com/terraform/tutorials)
* Google Cloud CLI - [https://cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)
* Git - [https://git-scm.com/download](https://git-scm.com/download)

## Step 1 — Create and Configure a GCP Project

### Create a new Google Cloud project

Go to:

[https://console.cloud.google.com/projectcreate](https://console.cloud.google.com/projectcreate)


### Enable Billing

Required to use GCP services.

[https://console.cloud.google.com/billing](https://console.cloud.google.com/billing)


### Enable required Google APIs

Ideally, all of these services should be enabled through Terraform, but for simplicity and to keep this guide beginner-friendly, we are enabling them manually.

### Google Cloud API Enable Links

| Service                                                                | Console Link                                                                                                                                                           |
| ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Cloud Run API** (`run.googleapis.com`)                               | [https://console.cloud.google.com/apis/library/run.googleapis.com](https://console.cloud.google.com/apis/library/run.googleapis.com)                                   |
| **Firestore API** (`firestore.googleapis.com`)                         | [https://console.cloud.google.com/apis/library/firestore.googleapis.com](https://console.cloud.google.com/apis/library/firestore.googleapis.com)                       |
| **Cloud Functions API** (`cloudfunctions.googleapis.com`)              | [https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com](https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com)             |
| **Artifact Registry API** (`artifactregistry.googleapis.com`)          | [https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com](https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com)         |
| **IAM Service Account API** (`iam.googleapis.com`)                     | [https://console.cloud.google.com/apis/library/iam.googleapis.com](https://console.cloud.google.com/apis/library/iam.googleapis.com)                                   |
| **Secret Manager API** (`secretmanager.googleapis.com`)                | [https://console.cloud.google.com/apis/library/secretmanager.googleapis.com](https://console.cloud.google.com/apis/library/secretmanager.googleapis.com)               |
| **Admin SDK API** (`admin.googleapis.com`)                             | [https://console.cloud.google.com/apis/library/admin.googleapis.com](https://console.cloud.google.com/apis/library/admin.googleapis.com)                               |
| **Service Usage API** (`serviceusage.googleapis.com`)                  | [https://console.cloud.google.com/apis/library/serviceusage.googleapis.com](https://console.cloud.google.com/apis/library/serviceusage.googleapis.com)                 |
| **Cloud Resource Manager API** (`cloudresourcemanager.googleapis.com`) | [https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com](https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com) |
| **Cloud Storage API** (`storage.googleapis.com`)                       | [https://console.cloud.google.com/apis/library/storage.googleapis.com](https://console.cloud.google.com/apis/library/storage.googleapis.com)                           |
| **Cloud Scheduler API** (`cloudscheduler.googleapis.com`) | [Enable Cloud Scheduler](https://console.cloud.google.com/apis/library/cloudscheduler.googleapis.com) |
| **Cloud Pub/Sub API** (`pubsub.googleapis.com`)           | [Enable Cloud Pub/Sub](https://console.cloud.google.com/apis/library/pubsub.googleapis.com)           |


---

**OR**

Run the following command:

```sh
gcloud services enable \
run.googleapis.com \
firestore.googleapis.com \
cloudfunctions.googleapis.com \
artifactregistry.googleapis.com \
iam.googleapis.com \
secretmanager.googleapis.com \
admin.googleapis.com \
serviceusage.googleapis.com \
cloudresourcemanager.googleapis.com \
storage.googleapis.com \
cloudscheduler.googleapis.com \
pubsub.googleapis.com
```



### Create a Service Account

[https://console.cloud.google.com/iam-admin/serviceaccounts](https://console.cloud.google.com/iam-admin/serviceaccounts)

Name: `devops-bootcamp-sa`

Assign roles:

| Required Role            | Reason                                |
| ------------------------ | ------------------------------------- |
| Editor                   | General required access               |
| Cloud Run Admin          | Deploy workloads                      |
| Artifact Registry Writer | Push Docker images                    |
| Cloud Functions Admin    | Deploy Cloud Functions                |
| Service Account User     | Allow workloads to impersonate the SA |

Note: From a security standpoint, granting **Editor** access to a service account is not recommended. However, for the purposes of this beginner-friendly guide, we will start by assigning **Editor** permissions to simplify the setup.

### Create & Download Service Account Key

Store it locally: `~/gcp/key.json`

Authenticate:

```sh
gcloud auth activate-service-account --key-file=~/gcp/key.json
```

Login Docker to GCP:

```sh
gcloud auth configure-docker us-east1-docker.pkg.dev
```

OR

cat `~/gcp/key.json` | docker login -u "_json_key" --password-stdin "https://us-east1-docker.pkg.dev"

```sh

```

---

## Step 2 — Run Application Locally (Optional but Recommended)

Set environment variables:

Create a Webhook URL follow the officail instructions of slack to generate the webhook.

```sh
export GOOGLE_APPLICATION_CREDENTIALS=~/gcp/key.json
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/<token>"
export API_URL="http://127.0.0.1:8000"
```

---

### Run FastAPI Backend

```sh
uvicorn api:app --reload
```

---

### Run Web App

```sh
python3 -m streamlit run app.py
```

Visit: [http://localhost:8501](http://localhost:8501)

---

## Step 3 — Build & Run Docker Containers

### Build Images

#### API:

```sh
docker build --network=host -t us-east1-docker.pkg.dev/<PROJECT_ID>/cloud-bootcamp/api -f api.Dockerfile .
```
`<PROJECT_ID>` here is the project Id of your GCP project.

#### Web App:

```sh
docker build --network=host -t us-east1-docker.pkg.dev/<PROJECT_ID>/cloud-bootcamp/app -f app.Dockerfile .
```
`<PROJECT_ID>` here is the project Id of your GCP project.

### Push Images to Artifact Registry

```sh
docker push us-east1-docker.pkg.dev/<PROJECT_ID>/cloud-bootcamp/api:latest
docker push us-east1-docker.pkg.dev/<PROJECT_ID>/cloud-bootcamp/app:latest
```

---

### Test Containers Locally

#### Run API container:

```sh
docker run -it -p 8000:8080 \
-v ~/gcp/key.json:/workspace/key.json \
-e GOOGLE_APPLICATION_CREDENTIALS=/workspace/key.json \
us-east1-docker.pkg.dev/<PROJECT_ID>/cloud-bootcamp/api
```

This command runs a Docker container interactively, maps container port **8080** to host port **8000**, mounts a local Google Cloud service account key into the container, sets the environment variable so Google SDK uses that key for authentication, and runs the image stored in **Artifact Registry** under your Google Cloud project.

#### Run Web App container:

```sh
docker run -it --net host us-east1-docker.pkg.dev/<PROJECT_ID>/cloud-bootcamp/app:latest
```
This command runs the latest version of the Docker image stored in Artifact Registry using interactive mode and maps the container to the host's network stack (`--net host`), meaning it will use the host machine's network directly without port mapping.


---

## Deploy to Cloud using Terraform

These commands initialize Terraform, validate the configuration, create an execution plan with a dummy Slack webhook, and then apply the plan automatically to deploy the infrastructure.

```sh
terraform init
terraform validate
terraform plan -var="slack_webhook_url=dummy"
terraform apply -var="slack_webhook_url=dummy" --auto-approve
```

### Destroy Cloud Resources:

```sh
terraform destroy -var="slack_webhook_url=dummy" --auto-approve
```

---

## Step 5 — Enable GitHub CI/CD

### Store secrets in GitHub Repo → Settings → Secrets → Actions

| Secret Name          | Value                                    |
| -------------------- | ---------------------------------------- |
| `GOOGLE_CREDENTIALS` | Content of the service account JSON file |
| `SLACK_WEBHOOK_URL`  | Slack webhook URL                        |

Once set, any push will automatically:

✔ Build Docker images
✔ Push them to Artifact Registry
✔ Deploy updates using Terraform

Here’s a clear explanation of how GitHub Actions work with the `.github/workflows/*.yml` files in your repo:

### **GitHub Actions Overview**

1. **Location:** All workflow files are stored in `.github/workflows/` and have a `.yml` or `.yaml` extension.
2. **Triggering:** Each workflow defines **events** that trigger it, for example:

   * `push` → runs whenever code is pushed to a branch
   * `pull_request` → runs when a PR is created or updated
   * `workflow_dispatch` → allows manual triggering from GitHub
3. **Jobs and Steps:** Each workflow contains **jobs**, which run on specific **runners** (Ubuntu, Windows, macOS). Jobs consist of **steps**:

   * Steps can run shell commands (`run:`)
   * Steps can use prebuilt **actions** (`uses:`), like `actions/checkout@v3` to clone your repo.
4. **Secrets & Environment Variables:** Workflows can access secrets stored in the repo (e.g., `GOOGLE_CREDENTIALS`, `SLACK_WEBHOOK`) via `${{ secrets.SECRET_NAME }}`.

### **How to Run and Test GitHub Actions**

1. **Automatic Trigger:**
   When you push a commit to the branch configured in the workflow, GitHub will automatically start the workflow.

2. **Manual Trigger:**
   If `workflow_dispatch` is enabled, go to **Actions → Select Workflow → Run workflow**, choose the branch, and click **Run workflow**.

3. **Check Logs:**

   * Click on the workflow run in GitHub Actions to see logs for each job and step.
   * You can debug failures or confirm that Docker builds, Terraform applies, or Slack notifications ran successfully.


## Step 6 — Testing Deployed Services

After Terraform completes you will receive:

- Open Cloud Run in the Google Cloud Console, search for the service named demo-app, and open it. Copy or click the service URL to run and test the deployed application in your browser.
- Finally, check your Slack channel to verify that notifications are being received successfully.


**Note:** If you have any questions or run into issues, please join our Slack workspace using this link: [Cloud DevOps Bootcamp Slack](https://join.slack.com/t/cloud-devops-bootcamp/shared_invite/zt-3jmuw3yat-AAnr1FboftINtCghTDU8Nw). You can use the channel to discuss setup problems or any other concerns.