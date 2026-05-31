# GitHub Actions CD — IAM inline policy

Role: `github-actions-infra-study-cd`

## Policy

- **Name:** `infra-study-github-actions-cd-inline`
- **JSON:** [github-actions-infra-study-cd-inline.json](./github-actions-infra-study-cd-inline.json)

기존 inline policy가 여러 개면 삭제 후 위 JSON **하나만** 연결하세요.

## 적용 후 구조

| 구성요소 | 담당 |
|----------|------|
| `choesuna-terraform-state` | Terraform state (CD에서 없으면 생성) |
| `choesuna-terraform-s3-bucket` | 프론트 버킷 + `index.html` + `assets/` (Terraform만) |
| CloudFront / ALB data | Terraform |

`FRONTEND_S3_BUCKET` GitHub secret은 CD에서 더 이상 사용하지 않습니다. (삭제해도 됨)

## Trust policy (별도)

**Trust relationships**에서 OIDC:

- Provider: `token.actions.githubusercontent.com`
- `sub`: `repo:sonah5009/infra_study:ref:refs/heads/main`

## 버킷이 이미 수동으로 있을 때

프론트 버킷이 AWS에만 있고 state에 없으면 `terraform import`가 필요합니다.

```bash
terraform import aws_s3_bucket.static_site choesuna-terraform-s3-bucket
```

버킷을 비우고 삭제한 뒤라면 import 없이 `apply`만 하면 됩니다.
