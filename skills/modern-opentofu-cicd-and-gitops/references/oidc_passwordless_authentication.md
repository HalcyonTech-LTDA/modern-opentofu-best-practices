# Passwordless OIDC Authentication Blueprint

OpenID Connect (OIDC) enables GitHub Actions and GitLab CI runners to request short-lived cloud security credentials dynamically without storing static, long-lived API keys in repository secret stores.

---

## 1. AWS IAM OIDC Federation

### Step 1: Create the OpenID Connect Provider
- Provider URL: `https://token.actions.githubusercontent.com`
- Audience: `sts.amazonaws.com`

### Step 2: Define the IAM Role Trust Policy
Scope trust strictly to your GitHub organization, repository, and branch:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:HalcyonTech-LTDA/my-opentofu-repo:*"
        }
      }
    }
  ]
}
```

### Step 3: Consume in GitHub Actions Workflow

```yaml
permissions:
  id-token: write # Required for requesting the JWT OIDC token
  contents: read

jobs:
  opentofu:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Configure AWS Credentials via OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-opentofu-role
          aws-region: us-east-1
          audience: sts.amazonaws.com
```

---

## 2. Azure Federated Identity Credentials

For Azure, configure a User-Assigned Managed Identity and assign a Federated Identity Credential targeting the branch or pull request entity:

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: actions/checkout@v4
  - uses: azure/login@v2
    with:
      client-id: ${{ secrets.AZURE_CLIENT_ID }}
      tenant-id: ${{ secrets.AZURE_TENANT_ID }}
      subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```
