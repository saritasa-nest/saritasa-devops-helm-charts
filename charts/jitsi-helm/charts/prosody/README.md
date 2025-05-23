
# prosody

![Version: 1.2.2](https://img.shields.io/badge/Version-1.2.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.11.13](https://img.shields.io/badge/AppVersion-0.11.13-informational?style=flat-square)

A Helm chart for Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| dataDir | string | `"/config/data"` |  |
| domain | string | `nil` |  |
| extraEnvFrom | list | `[]` |  |
| extraEnvs | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"nginx"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe.httpGet.path | string | `"/http-bind"` |  |
| livenessProbe.httpGet.port | string | `"bosh-insecure"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence.enabled | bool | `true` |  |
| persistence.size | string | `"3G"` |  |
| persistence.storageClassName | string | `nil` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| readinessProbe.httpGet.path | string | `"/http-bind"` |  |
| readinessProbe.httpGet.port | string | `"bosh-insecure"` |  |
| resources | object | `{}` |  |
| secretEnvs | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.ports.bosh-insecure | int | `5280` |  |
| service.ports.bosh-secure | int | `5281` |  |
| service.ports.xmpp-c2s | int | `5222` |  |
| service.ports.xmpp-component | int | `5347` |  |
| service.ports.xmpp-s2s | int | `5269` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
