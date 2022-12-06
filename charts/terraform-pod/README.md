
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

![Version: 0.0.3](https://img.shields.io/badge/Version-0.0.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.3.5](https://img.shields.io/badge/AppVersion-1.3.5-informational?style=flat-square)

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

## Run the chart

```sh
helm upgrade --install CLIENT saritasa/terraform-pod \
  --namespace terraform \
  --set image.tag=1.3.5 \
  --set github.repository=saritasa-nest/CLIENT-infra-dev-aws \
  --set github.branch=feature/branch \
  --set github.username=YOUR-GITHUB-USERNAME \
  --set github.email=YOUR-GITHUB-EMAIL \
  --set gitCryptKey=$(base64 git-crypt-key | tr -d \\n) \
  --wait
```

## Get in the pod

```sh
k exec -ti $(kgpo -l app.kubernetes.io/name=terraform-pod --no-headers -o="custom-columns=NAME:.metadata.name") -c terraform -- bash
klo $(kgpo -l app.kubernetes.io/name=terraform-pod --no-headers -o="custom-columns=NAME:.metadata.name") --all-containers
make _dev apply
```

## Terminate

```sh
helm delete CLIENT
````

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | affinity |
| argocd | object | `{"cloud":{"secret":"saritasa-cloud-argocd","terraformEnvVarName":"TF_VAR_cloud_argocd_password"},"rocks":{"secret":"saritasa-rocks-argocd","terraformEnvVarName":"TF_VAR_rocks_argocd_password"}}` | where to obtain argo-cd credentials to be used |
| argocd.cloud.secret | string | `"saritasa-cloud-argocd"` | secret with "username/password" values |
| argocd.rocks.secret | string | `"saritasa-rocks-argocd"` | secret with "username/password" values |
| aws | object | `{"iamCredentialsSecret":"terraform-user-infra-v2-iam-credentials","output":"json","region":"us-west-2"}` | aws configuration |
| aws.iamCredentialsSecret | string | `"terraform-user-infra-v2-iam-credentials"` | aws iam user (for older terraform infra-dev-aws solutions) |
| aws.output | string | `"json"` | default aws output of CLI |
| aws.region | string | `"us-west-2"` | default aws region |
| databases | object | `{"mysql":{"secret":"saritasa-rocks-mysql","terraformEnvVarName":"TF_VAR_rds_mysql_password"},"postgres":{"secret":"saritasa-rocks-postgres","terraformEnvVarName":"TF_VAR_rds_postgress_password"}}` | where to obtain database credentials to be used |
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
| github.appAuthSecret | string | `"terraform-cicd-app.2022-11-18.private-key.pem"` | github app auth pem file used for terraform github provider authentication |
| github.branch | string | `""` | github branch to clone inside terraform pod |
| github.email | string | `""` | github email (who runs this terraform code) |
| github.repository | string | `""` | github repository containing terraform infra-dev-aws code |
| github.tokenSecret | string | `"github-cli-token"` | github gh cli secret containing token for authentication of the github CLI |
| github.username | string | `""` | github username (who runs this terraform code) |
| image.pullPolicy | string | `"IfNotPresent"` | pull policy |
| image.repository | string | `"public.ecr.aws/saritasa/terraform"` | default docker registry |
| image.tag | string | `"1.3.5"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | docker pull secret |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` | node selector |
| podAnnotations | object | `{}` | pod annotations |
| podSecurityContext | object | `{"fsGroup":1000}` | security options for the running pod |
| resources | object | `{"limits":{"cpu":"1000m","memory":"4Gi"},"requests":{"cpu":"250m","memory":"64Mi"}}` | resources allocated for the terraform podu |
| securityContext | object | `{"capabilities":{"drop":["ALL"]},"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | security options for the running container |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | service account details |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| slack | object | `{"urlSecret":"slack-alarm-webhook"}` | slack configuration |
| slack.urlSecret | string | `"slack-alarm-webhook"` | secret containing slack webhook url |
| terraform.client | string | `"fbmm"` | terraform client name (used to decide what workspace in the org to use) |
| terraform.initCommand | string | `"make _dev init"` | makefile target in the Makefile of  the repository to run during initialization phase (can be any valid bash one-liner if you want to skip the makefile targets of the repository) |
| terraform.organization | string | `"saritasa-team"` | terraform org |
| terraform.tokenSecret | string | `"terraform-cli-token-saritasa-team"` | terraform team API token name |
| tolerations | list | `[]` | tolerations |

