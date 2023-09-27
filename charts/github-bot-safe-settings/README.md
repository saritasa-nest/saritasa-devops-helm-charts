# safe-settings

## `chart.deprecationWarning`

## `chart.name`

safe-settings

## `chart.version`

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.0.0](https://img.shields.io/badge/AppVersion-2.0.0-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa | <nospam@saritasa.com> |  |

## `chart.description`

A GitHub App built with [Probot](https://github.com/probot/probot) to manage policy-as-code and apply repository settings to repositories across an organization.

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| appEnv.NODE_EXTRA_CA_CERTS | string | `""` |  |
| appEnv.annotations | object | `{}` |  |
| appEnv.create | bool | `false` |  |
| appEnv.enabled | bool | `true` |  |
| appEnv.name | string | `"controller-manager"` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `5` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| deploymentConfig.configvalidators[0].error | string | `"`Admin cannot be assigned to collaborators`\n"` |  |
| deploymentConfig.configvalidators[0].plugin | string | `"collaborators"` |  |
| deploymentConfig.configvalidators[0].script | string | `"console.log(`baseConfig ${JSON.stringify(baseconfig)}`)\nreturn baseconfig.permission != 'admin'\n"` |  |
| deploymentConfig.overridevalidators[0].error | string | `"`Branch protection required_approving_review_count cannot be overidden to a lower value`\n"` |  |
| deploymentConfig.overridevalidators[0].plugin | string | `"branches"` |  |
| deploymentConfig.overridevalidators[0].script | string | `"console.log(`baseConfig ${JSON.stringify(baseconfig)}`)\nconsole.log(`overrideConfig ${JSON.stringify(overrideconfig)}`)\nif (baseconfig.protection.required_pull_request_reviews.required_approving_review_count && overrideconfig.protection.required_pull_request_reviews.required_approving_review_count ) {\n  return overrideconfig.protection.required_pull_request_reviews.required_approving_review_count >= baseconfig.protection.required_pull_request_reviews.required_approving_review_count\n}\nreturn true\n"` |  |
| deploymentConfig.overridevalidators[1].error | string | `"Some error\n"` |  |
| deploymentConfig.overridevalidators[1].plugin | string | `"labels"` |  |
| deploymentConfig.overridevalidators[1].script | string | `"return true\n"` |  |
| deploymentConfig.restrictedRepos.exclude[0] | string | `"^admin$"` |  |
| deploymentConfig.restrictedRepos.exclude[1] | string | `"^\\.github$"` |  |
| deploymentConfig.restrictedRepos.exclude[2] | string | `"^safe-settings$"` |  |
| deploymentConfig.restrictedRepos.exclude[3] | string | `".*-test"` |  |
| deploymentConfig.restrictedRepos.include[0] | string | `"^test$"` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"yadhav/safe-settings"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeExtraCaCerts | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
