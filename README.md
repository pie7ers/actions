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
act -W .github/workflows/test-check-resource.yml
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

## Deprecated Actions

### `wait-for-api`

> [!IMPORTANT]
> ⚠️ **Deprecated:** `wait-for-api` is deprecated and will be removed in `v2.0.0`.

Use `check-resource` instead.

---

### Node – Basic Setup

Assumes the repository has already been checked out.

```yaml
name: Run tests
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
        uses: pie7ers/actions/node/basic-setup@v2
```

---


### Check Resource

Polls a resource until it becomes available or retries are exhausted.

```yaml
name: Run tests
on:
  push:
    branches: [main]

jobs:
  check-resource:
    runs-on: ubuntu-latest
    steps:
      - name: Check Resource
        uses: pie7ers/actions/check-resource@v2
        with:
          url: "https://my-resource.com"
          #url: "https://my-api.com/health"
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
        uses: pie7ers/actions/trigger-repo-dispatch@v2
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
* Use semantic version tags:
  - `v1.0.0` — exact version
  - `v1` — latest compatible release within major version 1
  - `v2.0.0` — exact version
  - `v2` — latest compatible release within major version 2

---

## 📄 License

MIT


## TAG STEPS

```sh
git tag v1.0.0
git push origin v1.0.0
#alias v1.0.0 -> v1
git tag -f v1
git push origin v1 --force
#git log --decorate --oneline
```