
# eol-exporter

![Version: 0.1.0-dev-11](https://img.shields.io/badge/Version-0.1.0--dev--11-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: prod-843dabc](https://img.shields.io/badge/AppVersion-prod--843dabc-informational?style=flat-square)

End of life exporter.
A Kubernetes's helm chart for a exporter that get information about end of life/support of products in order to be scrapped by Prometheus

You must supply a valid configmap with a list of products with its versions. Check https://github.com/saritasa-nest/saritasa-devops-tools-eol-exporter/blob/main/config.yaml.example
for example values.
Each product must have a field `current` with valid version as defined in: https://endoflife.date/api/{product}.json
A `comment` field is optional, and it will be added as a label in the metrics.

A Prometheus extra scrape config must be configured in order to be able to watch the metrics in Prometheus.
The service name will be defined as: $CHART_NAME.$NAMESPACE:$PORT
By default this is: eol-exporter.prometheus:8080
An example extraScrapeConfigs is available in: https://github.com/saritasa-nest/saritasa-devops-tools-eol-exporter/blob/main/README.md#prometheus-server-config

The exporter provides two metrics:
- endoflife_expiration_timestamp_seconds: Information about end of life (EOL) of products. Metric value is the UNIX timestamp of the eolDate label
- endoflife_expired: Information about end of life (EOL) of products. Boolean value of 1 for expired products.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://stakater.github.io/stakater-charts/ | eol-exporter(application) | 5.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| eol-exporter.additionalContainers | list | `[]` |  |
| eol-exporter.applicationName | string | `"eol-exporter"` |  |
| eol-exporter.configMap | object | `{}` |  |
| eol-exporter.deployment.additionalLabels | object | `{}` |  |
| eol-exporter.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/arch"` |  |
| eol-exporter.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"In"` |  |
| eol-exporter.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"amd64"` |  |
| eol-exporter.deployment.args | list | `[]` |  |
| eol-exporter.deployment.command | string | `""` |  |
| eol-exporter.deployment.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| eol-exporter.deployment.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| eol-exporter.deployment.containerSecurityContext.privileged | bool | `false` |  |
| eol-exporter.deployment.containerSecurityContext.readOnlyRootFilesystem | bool | `false` |  |
| eol-exporter.deployment.containerSecurityContext.runAsGroup | int | `1000` |  |
| eol-exporter.deployment.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| eol-exporter.deployment.containerSecurityContext.runAsUser | int | `1002` |  |
| eol-exporter.deployment.enabled | bool | `true` |  |
| eol-exporter.deployment.env.CONFIG_YAML_PATH.value | string | `"config.yaml"` |  |
| eol-exporter.deployment.env.EOL_API_ENDPOINT.value | string | `"https://endoflife.date/api"` |  |
| eol-exporter.deployment.env.JOB_INTERVAL_HOURS.value | string | `"24"` |  |
| eol-exporter.deployment.env.PORT.value | string | `"8080"` |  |
| eol-exporter.deployment.envFrom | object | `{}` |  |
| eol-exporter.deployment.image.digest | string | `""` |  |
| eol-exporter.deployment.image.pullPolicy | string | `"IfNotPresent"` |  |
| eol-exporter.deployment.image.repository | string | `"saritasallc/eol-exporter"` |  |
| eol-exporter.deployment.image.tag | string | `"prod-843dabc"` |  |
| eol-exporter.deployment.initContainers | list | `[]` |  |
| eol-exporter.deployment.livenessProbe.enabled | bool | `true` |  |
| eol-exporter.deployment.livenessProbe.exec | object | `{}` |  |
| eol-exporter.deployment.livenessProbe.failureThreshold | int | `3` |  |
| eol-exporter.deployment.livenessProbe.httpGet.path | string | `"/metrics"` |  |
| eol-exporter.deployment.livenessProbe.httpGet.port | int | `8080` |  |
| eol-exporter.deployment.livenessProbe.initialDelaySeconds | int | `10` |  |
| eol-exporter.deployment.livenessProbe.periodSeconds | int | `10` |  |
| eol-exporter.deployment.livenessProbe.successThreshold | int | `1` |  |
| eol-exporter.deployment.livenessProbe.tcpSocket | object | `{}` |  |
| eol-exporter.deployment.livenessProbe.timeoutSeconds | int | `1` |  |
| eol-exporter.deployment.nodeSelector | object | `{}` |  |
| eol-exporter.deployment.ports[0].containerPort | int | `8080` |  |
| eol-exporter.deployment.ports[0].name | string | `"http"` |  |
| eol-exporter.deployment.ports[0].protocol | string | `"TCP"` |  |
| eol-exporter.deployment.readinessProbe.enabled | bool | `true` |  |
| eol-exporter.deployment.readinessProbe.exec | object | `{}` |  |
| eol-exporter.deployment.readinessProbe.failureThreshold | int | `3` |  |
| eol-exporter.deployment.readinessProbe.httpGet.path | string | `"/metrics"` |  |
| eol-exporter.deployment.readinessProbe.httpGet.port | int | `8080` |  |
| eol-exporter.deployment.readinessProbe.initialDelaySeconds | int | `10` |  |
| eol-exporter.deployment.readinessProbe.periodSeconds | int | `10` |  |
| eol-exporter.deployment.readinessProbe.successThreshold | int | `1` |  |
| eol-exporter.deployment.readinessProbe.tcpSocket | object | `{}` |  |
| eol-exporter.deployment.readinessProbe.timeoutSeconds | int | `1` |  |
| eol-exporter.deployment.resources.limits.cpu | string | `"500m"` |  |
| eol-exporter.deployment.resources.limits.memory | string | `"256Mi"` |  |
| eol-exporter.deployment.resources.requests.cpu | string | `"100m"` |  |
| eol-exporter.deployment.resources.requests.memory | string | `"128Mi"` |  |
| eol-exporter.deployment.revisionHistoryLimit | int | `5` |  |
| eol-exporter.deployment.securityContext.fsGroup | int | `1000` |  |
| eol-exporter.deployment.securityContext.runAsGroup | int | `1000` |  |
| eol-exporter.deployment.securityContext.runAsNonRoot | bool | `true` |  |
| eol-exporter.deployment.securityContext.runAsUser | int | `1002` |  |
| eol-exporter.deployment.startupProbe.enabled | bool | `false` |  |
| eol-exporter.deployment.startupProbe.exec | object | `{}` |  |
| eol-exporter.deployment.startupProbe.failureThreshold | int | `30` |  |
| eol-exporter.deployment.startupProbe.httpGet | object | `{}` |  |
| eol-exporter.deployment.startupProbe.periodSeconds | int | `10` |  |
| eol-exporter.deployment.startupProbe.tcpSocket | object | `{}` |  |
| eol-exporter.deployment.strategy.rollingUpdate.maxSurge | string | `"25%"` |  |
| eol-exporter.deployment.strategy.rollingUpdate.maxUnavailable | string | `"25%"` |  |
| eol-exporter.deployment.strategy.type | string | `"RollingUpdate"` |  |
| eol-exporter.deployment.tolerations | list | `[]` |  |
| eol-exporter.deployment.topologySpreadConstraints | object | `{}` |  |
| eol-exporter.deployment.volumeMounts.config.mountPath | string | `"/workspace/app/config.yaml"` |  |
| eol-exporter.deployment.volumeMounts.config.subPath | string | `"config.yaml"` |  |
| eol-exporter.deployment.volumes.config.configMap.name | string | `"eol-exporter-config"` |  |
| eol-exporter.enabled | bool | `true` |  |
| eol-exporter.externalSecrets.enabled | bool | `false` |  |
| eol-exporter.namespaceOverride | string | `""` |  |
| eol-exporter.pdb.enabled | bool | `false` |  |
| eol-exporter.pdb.minAvailable | int | `1` |  |
| eol-exporter.service.annotations | object | `{}` |  |
| eol-exporter.service.enabled | bool | `true` |  |
| eol-exporter.service.ports[0].name | string | `"http"` |  |
| eol-exporter.service.ports[0].port | int | `8080` |  |
| eol-exporter.service.ports[0].protocol | string | `"TCP"` |  |
| eol-exporter.service.ports[0].targetPort | int | `8080` |  |
| eol-exporter.service.type | string | `"ClusterIP"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
