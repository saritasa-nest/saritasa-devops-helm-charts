
# eol-exporter

![Version: 0.1.0-dev-4](https://img.shields.io/badge/Version-0.1.0--dev--4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: prod-d0d3488](https://img.shields.io/badge/AppVersion-prod--d0d3488-informational?style=flat-square)

End of life exporter.
A Kubernetes's helm chart for a exporter that get information about end of life/support of products in order to be scrapped by Prometheus

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://stakater.github.io/stakater-charts/ | eol-exporter(application) | 5.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| eol-exporter.additionalContainers | list | `[]` |  |
| eol-exporter.applicationName | string | `"eol-exporter"` |  |
| eol-exporter.autoscaling.behavior.scaleDown.policies[0].periodSeconds | int | `100` |  |
| eol-exporter.autoscaling.behavior.scaleDown.policies[0].type | string | `"Pods"` |  |
| eol-exporter.autoscaling.behavior.scaleDown.policies[0].value | int | `1` |  |
| eol-exporter.autoscaling.behavior.scaleDown.policies[1].periodSeconds | int | `100` |  |
| eol-exporter.autoscaling.behavior.scaleDown.policies[1].type | string | `"Percent"` |  |
| eol-exporter.autoscaling.behavior.scaleDown.policies[1].value | int | `10` |  |
| eol-exporter.autoscaling.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| eol-exporter.autoscaling.behavior.scaleUp.policies[0].periodSeconds | int | `30` |  |
| eol-exporter.autoscaling.behavior.scaleUp.policies[0].type | string | `"Pods"` |  |
| eol-exporter.autoscaling.behavior.scaleUp.policies[0].value | int | `1` |  |
| eol-exporter.autoscaling.behavior.scaleUp.policies[1].periodSeconds | int | `60` |  |
| eol-exporter.autoscaling.behavior.scaleUp.policies[1].type | string | `"Percent"` |  |
| eol-exporter.autoscaling.behavior.scaleUp.policies[1].value | int | `10` |  |
| eol-exporter.autoscaling.behavior.scaleUp.selectPolicy | string | `"Max"` |  |
| eol-exporter.autoscaling.behavior.scaleUp.stabilizationWindowSeconds | int | `180` |  |
| eol-exporter.autoscaling.enabled | bool | `false` |  |
| eol-exporter.autoscaling.maxReplicas | int | `2` |  |
| eol-exporter.autoscaling.metrics[0].resource.name | string | `"cpu"` |  |
| eol-exporter.autoscaling.metrics[0].resource.target.averageUtilization | int | `70` |  |
| eol-exporter.autoscaling.metrics[0].resource.target.type | string | `"Utilization"` |  |
| eol-exporter.autoscaling.metrics[0].type | string | `"Resource"` |  |
| eol-exporter.autoscaling.metrics[1].resource.name | string | `"memory"` |  |
| eol-exporter.autoscaling.metrics[1].resource.target.averageUtilization | int | `70` |  |
| eol-exporter.autoscaling.metrics[1].resource.target.type | string | `"Utilization"` |  |
| eol-exporter.autoscaling.metrics[1].type | string | `"Resource"` |  |
| eol-exporter.autoscaling.minReplicas | int | `1` |  |
| eol-exporter.configmap.enabled | bool | `true` |  |
| eol-exporter.configmap.files."config.yaml" | string | `"eol:\n  # Get available products from:\n  # https://endoflife.date/api/all.json\n  # and find available cycles in:\n  # https://endoflife.date/api/{product}.json\n  eks:\n    current: '1.30'\n    comment: EKS\n  django:\n    current: '5.1'\n    comment: backend\n"` |  |
| eol-exporter.deployment.additionalLabels | object | `{}` |  |
| eol-exporter.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"kubernetes.io/arch"` |  |
| eol-exporter.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"In"` |  |
| eol-exporter.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"amd64"` |  |
| eol-exporter.deployment.args | list | `[]` |  |
| eol-exporter.deployment.command | string | `""` |  |
| eol-exporter.deployment.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| eol-exporter.deployment.containerSecurityContext.privileged | bool | `false` |  |
| eol-exporter.deployment.containerSecurityContext.readOnlyRootFilesystem | bool | `false` |  |
| eol-exporter.deployment.containerSecurityContext.runAsGroup | int | `1000` |  |
| eol-exporter.deployment.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| eol-exporter.deployment.containerSecurityContext.runAsUser | int | `1002` |  |
| eol-exporter.deployment.enabled | bool | `true` |  |
| eol-exporter.deployment.env.CONFIG_YAML_PATH.value | string | `"config.yaml"` |  |
| eol-exporter.deployment.env.ENVIRONMENT.value | string | `"prod"` |  |
| eol-exporter.deployment.env.JOB_INTERVAL_HOURS.value | int | `24` |  |
| eol-exporter.deployment.envFrom | object | `{}` |  |
| eol-exporter.deployment.image.digest | string | `""` |  |
| eol-exporter.deployment.image.pullPolicy | string | `"IfNotPresent"` |  |
| eol-exporter.deployment.image.repository | string | `"saritasallc/eol-exporter"` |  |
| eol-exporter.deployment.image.tag | string | `"prod-d0d3488"` |  |
| eol-exporter.deployment.initContainers | list | `[]` |  |
| eol-exporter.deployment.livenessProbe.enabled | bool | `true` |  |
| eol-exporter.deployment.livenessProbe.exec | object | `{}` |  |
| eol-exporter.deployment.livenessProbe.failureThreshold | int | `3` |  |
| eol-exporter.deployment.livenessProbe.httpGet.path | string | `"/favicon.ico"` |  |
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
| eol-exporter.deployment.readinessProbe.httpGet.path | string | `"/favicon.ico"` |  |
| eol-exporter.deployment.readinessProbe.httpGet.port | int | `8080` |  |
| eol-exporter.deployment.readinessProbe.initialDelaySeconds | int | `10` |  |
| eol-exporter.deployment.readinessProbe.periodSeconds | int | `10` |  |
| eol-exporter.deployment.readinessProbe.successThreshold | int | `1` |  |
| eol-exporter.deployment.readinessProbe.tcpSocket | object | `{}` |  |
| eol-exporter.deployment.readinessProbe.timeoutSeconds | int | `1` |  |
| eol-exporter.deployment.resources | object | `{}` |  |
| eol-exporter.deployment.revisionHistoryLimit | int | `5` |  |
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
| eol-exporter.deployment.volumes.config.configMap.name | string | `"config.yaml"` |  |
| eol-exporter.enabled | bool | `true` |  |
| eol-exporter.externalSecrets.enabled | bool | `false` |  |
| eol-exporter.ingress.additionalLabels | object | `{}` |  |
| eol-exporter.ingress.annotations."cert-manager.io/cluster-issuer" | string | `"letsencrypt-staging"` |  |
| eol-exporter.ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"100m"` |  |
| eol-exporter.ingress.annotations."nginx.ingress.kubernetes.io/proxy-connect-timeout" | string | `"300"` |  |
| eol-exporter.ingress.annotations."nginx.ingress.kubernetes.io/proxy-read-timeout" | string | `"300"` |  |
| eol-exporter.ingress.annotations."nginx.ingress.kubernetes.io/server-snippet" | string | `"add_header X-Robots-Tag \"noindex, nofollow, nosnippet, noarchive\";\n\n# this prevents hidden files (beginning with a period) from being served\nlocation ~ /\\. {\n  access_log        off;\n  log_not_found     off;\n  deny              all;\n}\n"` |  |
| eol-exporter.ingress.enabled | bool | `false` |  |
| eol-exporter.ingress.hosts | list | `[]` |  |
| eol-exporter.ingress.ingressClassName | string | `"nginx"` |  |
| eol-exporter.ingress.pathType | string | `"Prefix"` |  |
| eol-exporter.ingress.servicePort | string | `"http"` |  |
| eol-exporter.ingress.tls | list | `[]` |  |
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
