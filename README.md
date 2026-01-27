# ACTIONS

Collection of reusable **GitHub Composite Actions** intended to standardize and simplify common CI/CD tasks across repositories.

---

## 🚀 Local Testing with `act`

You can test most workflows locally using [`act`](https://github.com/nektos/act).

### Requirements

```bash
brew install act
```

### Secrets & Environment

* Ensure required secrets and variables are available before running `act`.
* Some actions behave differently when running locally (see compatibility notes below).

### Basic Example

```bash
act -j test -s ACT=true
```

The `ACT=true` flag is useful for conditionally bypassing steps that are not compatible with `act`.

---

## 🧪 Test Workflows

Each action is validated through a dedicated workflow under `.github/workflows`.

### Run tests locally

```bash
act -W .github/workflows/test-wait-for-api.yml
act -W .github/workflows/test-node-basic-setup.yml
```

⚠️ **Trigger Repo Dispatch**

```bash
act -W .github/workflows/test-trigger-dispatch.yml
```

Notes:

* Requires GitHub App secrets
* Target repositories must be installed on the GitHub App
* This workflow triggers an external repository workflow, for example:

  * [https://github.com/pie7ers/tau-github-actions-practice-tests/blob/main/.github/workflows/test-own-trigger-action.yml](https://github.com/pie7ers/tau-github-actions-practice-tests/blob/main/.github/workflows/test-own-trigger-action.yml)
* Due to `act` limitations, this action is **fully supported only on GitHub-hosted runners**

---

## 📦 Usage

### Node – Basic Setup

Assumes the repository has already been checked out.

```yaml
name: Run tests on staging
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: pie7ers/actions/node/basic-setup@v1
```

---

### Wait for API

Polls a health endpoint until it becomes available or retries are exhausted.

```yaml
name: Run tests on staging
on:
  push:
    branches: [main]

jobs:
  wait-api:
    runs-on: ubuntu-latest
    steps:
      - name: Check API
        uses: pie7ers/actions/wait-for-api@v1
        with:
          url-health: "https://my-api.com/health"
          retries: 20        # default: 30
          interval: 5        # default: 5 (seconds)
```

---

### Trigger Repository Dispatch

Triggers a `repository_dispatch` event in another repository using a **GitHub App**.

#### Prerequisites

* Create a GitHub App
* Install the app on both:

  * the actions repository
  * the target repository
* Store the following secrets:

  * `GH_APP_ID`
  * `GH_PRIVATE_KEY`

```yaml
name: Run tests on staging
on:
  push:
    branches: [main]

jobs:
  trigger-event:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger repository dispatch
        uses: pie7ers/actions/trigger-repo-dispatch@v1
        with:
          app-id: ${{ secrets.GH_APP_ID }}
          private-key: ${{ secrets.GH_PRIVATE_KEY }}
          owner: my-org
          repository: repo-b
          event-type: event-type
          client-payload: |
            {
              "env": "test",
              "system": "Render",
              "version": "1.2.3",
              "trigger_by": "${{ github.actor }}"
            }
```

⚠️ **Compatibility Note**

This action relies on `actions/create-github-app-token@v2`, which uses Web APIs not fully supported by `act`.

* ✅ Works on GitHub-hosted runners
* ⚠️ Limited or unsupported on `act`

---

## 📌 Notes & Best Practices

* Composite actions **must not perform repository checkout** unless explicitly required
* Prefer passing configuration via inputs instead of environment variables
* Always test actions on GitHub-hosted runners before releasing
* Use semantic version tags (`v1`, `v1.1`, etc.) for consumers

---

## 📄 License

MIT
