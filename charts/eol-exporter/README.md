
# eol-prometheus-exporter

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.2](https://img.shields.io/badge/AppVersion-0.1.2-informational?style=flat-square)

End of life prometheus exporter.

A Kubernetes's helm chart for a exporter that get information about end of life/support of products in order to be scrapped by Prometheus

You must supply a valid configmap with a list of products with its versions:

```yaml
# Get available products from:
# https://endoflife.date/api/all.json
# and find available cycles in:
# https://endoflife.date/api/{product}.json
eks:
  product: eks
  current: '1.30'
  comment: EKS
django:
  product: django
  current: '5.1'
  comment: backend
php:
  product: php
  current: '8.3'
  comment: dashboard application
  dockerfile: https://hub.docker.com/_/php
  notes: backend does not support a major version higher than 8
python-allstar-elevator:
  product: python
  current: '3.12'
  dockerfile: https://github.com/saritasa-nest/allstar-elevator-backend/blob/develop/Dockerfile
python-allstar-elevator-we:
  product: python
  current: '3.11'
  dockerfile: https://github.com/saritasa-nest/allstar-elevator-we-backend/blob/develop/Dockerfile
```

Check https://github.com/saritasa-nest/saritasa-devops-tools-eol-exporter/blob/main/config.yaml.example
for more example values.

- Each product must have a field `current` with valid version as defined in: https://endoflife.date/api/{product}.json.
- Each product must have a field `product` with valid product as defined in: https://endoflife.date/api/{product}.json.

Optionally, you can add any extra field and it will be added as a label in the metrics

A Prometheus extra scrape config must be configured in order to be able to watch the metrics in Prometheus.

The service name will be defined as: `$CHART_NAME.$NAMESPACE:$PORT`.
By default this is: `eol-exporter.prometheus:8080`:

```yaml
extraScrapeConfigs: |
- job_name: prometheus-eol-exporter
  metrics_path: /metrics
  scrape_interval: 5m
  scrape_timeout: 30s
  static_configs:
    - targets:
      - eol-exporter.prometheus:8080
```

Check https://github.com/saritasa-nest/saritasa-devops-tools-eol-exporter/blob/main/README.md#prometheus-server-config for more information

The exporter provides three metrics:
- `endoflife_expiration_timestamp_seconds`: Information about end of life (EOL) of products. Metric value is the UNIX timestamp of the eolDate label
- `endoflife_expired`: Information about end of life (EOL) of products. Boolean value of 1 for expired products.
- `endoflife_failed_configs`: Information about end of life (EOL) of products. Boolean value of 1 for products that failed to be fetched.

Sample query to get if EKS EOL is less than 30 days:

```sh
(endoflife_expiration_timestamp_seconds{name="eks"} - time()) > ((60*60*24) * 10) and (endoflife_expiration_timestamp_seconds{name="eks"} - time()) <= ((60*60*24) * 30)
```

Sample query to get if EKS EOL has already happened:

```sh
endoflife_expired{name="eks"} == 1
```

Sample query to check if any product failed be fetched:

```bash
endoflife_failed_configs{} == 1
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://stakater.github.io/stakater-charts/ | exporter(application) | 5.2.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| exporter.additionalContainers | list | `[]` |  |
| exporter.applicationName | string | `"eol-exporter"` |  |
| exporter.configMap | object | `{}` |  |
| exporter.deployment.additionalLabels | object | `{}` |  |
| exporter.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/arch"` |  |
| exporter.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"In"` |  |
| exporter.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"amd64"` |  |
| exporter.deployment.args | list | `[]` |  |
| exporter.deployment.command | string | `""` |  |
| exporter.deployment.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| exporter.deployment.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| exporter.deployment.containerSecurityContext.privileged | bool | `false` |  |
| exporter.deployment.containerSecurityContext.readOnlyRootFilesystem | bool | `false` |  |
| exporter.deployment.containerSecurityContext.runAsGroup | int | `1000` |  |
| exporter.deployment.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| exporter.deployment.containerSecurityContext.runAsUser | int | `1002` |  |
| exporter.deployment.enabled | bool | `true` |  |
| exporter.deployment.env.CONFIG_YAML_PATH.value | string | `"config.yaml"` |  |
| exporter.deployment.env.EOL_API_ENDPOINT.value | string | `"https://endoflife.date/api"` |  |
| exporter.deployment.env.JOB_INTERVAL_HOURS.value | string | `"24"` |  |
| exporter.deployment.env.PORT.value | string | `"8080"` |  |
| exporter.deployment.envFrom | object | `{}` |  |
| exporter.deployment.image.digest | string | `""` |  |
| exporter.deployment.image.pullPolicy | string | `"IfNotPresent"` |  |
| exporter.deployment.image.repository | string | `"saritasallc/eol-exporter"` |  |
| exporter.deployment.image.tag | string | `"0.1.2"` |  |
| exporter.deployment.initContainers | list | `[]` |  |
| exporter.deployment.livenessProbe.enabled | bool | `true` |  |
| exporter.deployment.livenessProbe.exec | object | `{}` |  |
| exporter.deployment.livenessProbe.failureThreshold | int | `3` |  |
| exporter.deployment.livenessProbe.httpGet.path | string | `"/metrics"` |  |
| exporter.deployment.livenessProbe.httpGet.port | int | `8080` |  |
| exporter.deployment.livenessProbe.initialDelaySeconds | int | `10` |  |
| exporter.deployment.livenessProbe.periodSeconds | int | `10` |  |
| exporter.deployment.livenessProbe.successThreshold | int | `1` |  |
| exporter.deployment.livenessProbe.tcpSocket | object | `{}` |  |
| exporter.deployment.livenessProbe.timeoutSeconds | int | `1` |  |
| exporter.deployment.nodeSelector | object | `{}` |  |
| exporter.deployment.ports[0].containerPort | int | `8080` |  |
| exporter.deployment.ports[0].name | string | `"http"` |  |
| exporter.deployment.ports[0].protocol | string | `"TCP"` |  |
| exporter.deployment.readinessProbe.enabled | bool | `true` |  |
| exporter.deployment.readinessProbe.exec | object | `{}` |  |
| exporter.deployment.readinessProbe.failureThreshold | int | `3` |  |
| exporter.deployment.readinessProbe.httpGet.path | string | `"/metrics"` |  |
| exporter.deployment.readinessProbe.httpGet.port | int | `8080` |  |
| exporter.deployment.readinessProbe.initialDelaySeconds | int | `10` |  |
| exporter.deployment.readinessProbe.periodSeconds | int | `10` |  |
| exporter.deployment.readinessProbe.successThreshold | int | `1` |  |
| exporter.deployment.readinessProbe.tcpSocket | object | `{}` |  |
| exporter.deployment.readinessProbe.timeoutSeconds | int | `1` |  |
| exporter.deployment.resources.limits.cpu | string | `"500m"` |  |
| exporter.deployment.resources.limits.memory | string | `"256Mi"` |  |
| exporter.deployment.resources.requests.cpu | string | `"100m"` |  |
| exporter.deployment.resources.requests.memory | string | `"128Mi"` |  |
| exporter.deployment.revisionHistoryLimit | int | `5` |  |
| exporter.deployment.securityContext.fsGroup | int | `1000` |  |
| exporter.deployment.securityContext.runAsGroup | int | `1000` |  |
| exporter.deployment.securityContext.runAsNonRoot | bool | `true` |  |
| exporter.deployment.securityContext.runAsUser | int | `1002` |  |
| exporter.deployment.startupProbe.enabled | bool | `false` |  |
| exporter.deployment.startupProbe.exec | object | `{}` |  |
| exporter.deployment.startupProbe.failureThreshold | int | `30` |  |
| exporter.deployment.startupProbe.httpGet | object | `{}` |  |
| exporter.deployment.startupProbe.periodSeconds | int | `10` |  |
| exporter.deployment.startupProbe.tcpSocket | object | `{}` |  |
| exporter.deployment.strategy.rollingUpdate.maxSurge | string | `"25%"` |  |
| exporter.deployment.strategy.rollingUpdate.maxUnavailable | string | `"25%"` |  |
| exporter.deployment.strategy.type | string | `"RollingUpdate"` |  |
| exporter.deployment.tolerations | list | `[]` |  |
| exporter.deployment.topologySpreadConstraints | object | `{}` |  |
| exporter.deployment.volumeMounts.config.mountPath | string | `"/workspace/app/config.yaml"` |  |
| exporter.deployment.volumeMounts.config.subPath | string | `"config.yaml"` |  |
| exporter.deployment.volumes.config.configMap.name | string | `"eol-exporter-config"` |  |
| exporter.enabled | bool | `true` |  |
| exporter.externalSecrets.enabled | bool | `false` |  |
| exporter.namespaceOverride | string | `""` |  |
| exporter.pdb.enabled | bool | `false` |  |
| exporter.pdb.minAvailable | int | `1` |  |
| exporter.service.annotations | object | `{}` |  |
| exporter.service.enabled | bool | `true` |  |
| exporter.service.ports[0].name | string | `"http"` |  |
| exporter.service.ports[0].port | int | `8080` |  |
| exporter.service.ports[0].protocol | string | `"TCP"` |  |
| exporter.service.ports[0].targetPort | int | `8080` |  |
| exporter.service.type | string | `"ClusterIP"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
