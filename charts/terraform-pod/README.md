
# terraform-pod

## `license`
```
          ,-.
 ,     ,-.   ,-.
/ \   (   )-(   )
\ |  ,.>-(   )-<
 \|,' (   )-(   )
  Y ___`-'   `-'
  |/__/   `-'
  |
  |
  |    -hi-
__|_____________

/* Copyright (C) Saritasa,LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Saritasa Devops Team, April 2022
 */

```

## `chart.deprecationWarning`

## `chart.name`

terraform-pod

## `chart.version`

![Version: 0.0.18](https://img.shields.io/badge/Version-0.0.18-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.6.1](https://img.shields.io/badge/AppVersion-1.6.1-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa |  | <https://www.saritasa.com/> |

## `chart.description`

A Helm chart for running infra-dev-aws solutions

## Install the chart

Install the chart:

```
helm repo add saritasa https://saritasa-nest.github.io/saritasa-devops-helm-charts/
```

## Use

### Simple case (infra-dev-aws)

```sh
helm upgrade --install CLIENT saritasa/terraform-pod \
  --namespace terraform \
  --set terraform.client=CLIENT \
  --set image.tag=1.5.0 \
  --set github.repository=saritasa-nest/CLIENT-infra-dev-aws \
  --set github.branch=feature/branch \
  --set github.username=YOUR-GITHUB-USERNAME \
  --set github.email=YOUR-GITHUB-EMAIL \
  --set gitCryptKey=$(base64 -w 0 git-crypt-key) \
  --wait
```

### Passing aws-vault short-term credentials (infra-aws)

For infra-aws repos you may want to pass short-term TTL AWS credentials from the aws-vault
```sh
(
  unset AWS_VAULT && creds=$(aws-vault exec saritasa/v2/administrators --json) && \
  helm upgrade --install CLIENT saritasa/terraform-pod \
    --namespace terraform \
    --set terraform.client=CLIENT \
    --set image.tag=1.5.0 \
    --set github.repository=saritasa-nest/CLIENT-infra-aws \
    --set github.branch=feature/branch \
    --set github.username=YOUR-GITHUB-USERNAME \
    --set github.email=YOUR-GITHUB-EMAIL \
    --set gitCryptKey=$(base64 -w 0 path/to/git-crypt-key) \
    --set terraform.token=xxx \
    --set aws.accessKeyId=$(echo $creds | jq -r ".AccessKeyId") \
    --set aws.secretAccessKey=$(echo $creds | jq -r ".SecretAccessKey") \
    --set aws.sessionToken="$(echo $creds | jq -r ".SessionToken")" \
    --set infracost.enabled=true \
    --set terraform.initCommand="make _staging init" \
    --wait && \
  unset creds
)
```

Run command as shown in `()`` so that creds are not exported in your local shell.

## Terminate

```sh
helm delete CLIENT
````

## Debug

If you want to debug the helm chart (after the improvements) you can perform the following

```sh
(
unset AWS_VAULT && creds=$(aws-vault exec saritasa/v2/administrators --json) && \
helm template --release-name debug-tfpod \
    --namespace terraform \
    --set terraform.client=saritasa \
    --set image.tag=1.5.0 \
    --set github.repository=saritasa-nest/some-repo-infra-aws \
    --set github.branch=feature/branch-name \
    --set github.username=your-username \
    --set github.email=your-email \
    --set gitCryptKey=$(base64 -w 0 git-crypt-key) \
    --set aws.accessKeyId="$(echo $creds | jq -r ".AccessKeyId")" \
    --set aws.secretAccessKey="$(echo $creds | jq -r ".SecretAccessKey")" \
    --set aws.sessionToken="$(echo $creds | jq -r ".SessionToken")" \
    --set infracost.enabled=true \
    --set terraform.initCommand="make _staging init" \
    . | k apply -f- && \
unset creds
)
```

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/arch","operator":"In","values":["amd64"]}]}]}}}` | affinity |
| argocd | object | `{"cloud":{"secret":"saritasa-cloud-argocd","terraformEnvVarName":"TF_VAR_cloud_argocd_password"},"rocks":{"secret":"saritasa-rocks-argocd","terraformEnvVarName":"TF_VAR_rocks_argocd_password"}}` | where to obtain argo-cd credentials to be used |
| argocd.cloud.secret | string | `"saritasa-cloud-argocd"` | secret with "username/password" values |
| argocd.rocks.secret | string | `"saritasa-rocks-argocd"` | secret with "username/password" values |
| aws | object | `{"accessKeyId":"","iamCredentialsSecret":"terraform-user-infra-v2-iam-credentials","output":"json","region":"us-west-2","secretAccessKey":"","sessionToken":""}` | aws configuration |
| aws.accessKeyId | string | `""` | aws access key (optional, should be always a short-term aws cred you get by using aws-vault) if defined takes precedence over iamCredentialsSecret |
| aws.iamCredentialsSecret | string | `"terraform-user-infra-v2-iam-credentials"` | name of the secret containing aws iam user creds (optional) they secret should contain 2 keys: - aws_access_key_id - aws_secret_access_key |
| aws.output | string | `"json"` | default aws output of CLI |
| aws.region | string | `"us-west-2"` | default aws region |
| aws.secretAccessKey | string | `""` | aws secret access key (optional, should be always a short-term aws cred you get by using aws-vault) if defined takes precedence over iamCredentialsSecret |
| aws.sessionToken | string | `""` | aws session token for short term creds obtained with aws-vault https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html |
| databases | object | `{"mssql":{"secret":"saritasa-rocks-mssql","terraformEnvVarName":"TF_VAR_rds_mssql_password"},"mysql":{"secret":"saritasa-rocks-mysql","terraformEnvVarName":"TF_VAR_rds_mysql_password"},"postgres":{"secret":"saritasa-rocks-postgres","terraformEnvVarName":"TF_VAR_rds_postgress_password"}}` | where to obtain database credentials to be used |
| databases.mssql | object | `{"secret":"saritasa-rocks-mssql","terraformEnvVarName":"TF_VAR_rds_mssql_password"}` | rocks mssql |
| databases.mssql.secret | string | `"saritasa-rocks-mssql"` | secret with "password" value |
| databases.mssql.terraformEnvVarName | string | `"TF_VAR_rds_mssql_password"` | name of the TF_VAR env variable to be used by the terraform as the password for the database |
| databases.mysql | object | `{"secret":"saritasa-rocks-mysql","terraformEnvVarName":"TF_VAR_rds_mysql_password"}` | rocks mysql |
| databases.mysql.secret | string | `"saritasa-rocks-mysql"` | secret with "password" value |
| databases.mysql.terraformEnvVarName | string | `"TF_VAR_rds_mysql_password"` | name of the TF_VAR env variable to be used by the terraform as the password for the database |
| databases.postgres | object | `{"secret":"saritasa-rocks-postgres","terraformEnvVarName":"TF_VAR_rds_postgress_password"}` | rocks postgres |
| databases.postgres.secret | string | `"saritasa-rocks-postgres"` | secret with "password" value |
| databases.postgres.terraformEnvVarName | string | `"TF_VAR_rds_postgress_password"` | name of the TF_VAR env variable to be used by the terraform as the password for the database |
| extraEnvVars | list | `[]` | evta env vars |
| extraVolumeMounts | list | `[]` | extra volume mounts |
| extraVolumes | list | `[]` | extra volumes |
| fullnameOverride | string | `""` |  |
| gitCryptKey | string | `""` | content of the git-crypt-key encoded in base64 format |
| github.appAuthSecret | string | `"terraform-cicd-app.2023-07-12.private-key.pem"` | github app auth pem file used for terraform github provider authentication |
| github.branch | string | `""` | github branch to clone inside terraform pod |
| github.email | string | `""` | github email (who runs this terraform code) |
| github.repository | string | `""` | github repository containing terraform infra-dev-aws code |
| github.tokenSecret | string | `"github-cli-token"` | github gh cli secret containing token for authentication of the github CLI |
| github.username | string | `""` | github username (who runs this terraform code) |
| image.pullPolicy | string | `"Always"` | pull policy |
| image.repository | string | `"public.ecr.aws/saritasa/terraform"` | default docker registry |
| image.tag | string | `"1.6.1"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | docker pull secret |
| infracost.apiKey | string | `""` | infracost api token value (optional, if passed - takes precedence over apiKeySecret) |
| infracost.apiKeySecret | string | `"infracost-api-key"` | infracost api key secret (should contain a single attr: token=) |
| infracost.enabled | bool | `true` | should we enable infracost (if enabled we will post cost diff as the PR github comment) |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` | node selector |
| podAnnotations | object | `{}` | pod annotations |
| podSecurityContext | object | `{"fsGroup":1000}` | security options for the running pod |
| resources | object | `{"limits":{"cpu":"1000m","memory":"4Gi"},"requests":{"cpu":"250m","memory":"64Mi"}}` | resources allocated for the terraform pod |
| securityContext | object | `{"capabilities":{"drop":["ALL"]},"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | security options for the running container |
| sentry | object | `{"secret":"saritasa-rocks-sentry","terraformEnvVarName":"TF_VAR_sentry_auth_token"}` | sentry configuration |
| sentry.secret | string | `"saritasa-rocks-sentry"` | secret with "token" value |
| sentry.terraformEnvVarName | string | `"TF_VAR_sentry_auth_token"` | name of the TF_VAR env variable to be used by the terraform as the token for sentry |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | service account details |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| slack | object | `{"urlSecret":"slack-alarm-webhook"}` | slack configuration |
| slack.urlSecret | string | `"slack-alarm-webhook"` | secret containing slack webhook url |
| terraform.client | string | `""` | terraform client name (used to decide what workspace in the org to use) |
| terraform.initCommand | string | `"make _dev init"` | makefile target in the Makefile of  the repository to run during initialization phase (can be any valid bash one-liner if you want to skip the makefile targets of the repository) |
| terraform.organization | string | `"saritasa-team"` | terraform org |
| terraform.token | string | `""` | terraform api token value (optional, if passed - takes precedence over tokenSecret) |
| terraform.tokenSecret | string | `"terraform-cli-token-saritasa-team"` | secret name containing terraform team API token name (optional) |
| tolerations | list | `[]` | tolerations |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)
