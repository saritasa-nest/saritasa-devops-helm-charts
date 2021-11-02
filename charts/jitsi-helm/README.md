# jitsi-meet

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: stable-5963](https://img.shields.io/badge/AppVersion-stable--5963-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
|  | prosody | 0.2.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| enableAuth | bool | `false` |  |
| enableGuests | bool | `true` |  |
| extraCommonEnvs | object | `{}` |  |
| fullnameOverride | string | `""` |  |
| global.podAnnotations | object | `{}` |  |
| global.podLabels | object | `{}` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| imagePullSecrets | list | `[]` |  |
| jicofo.affinity | object | `{}` |  |
| jicofo.extraEnvs | object | `{}` |  |
| jicofo.image.repository | string | `"jitsi/jicofo"` |  |
| jicofo.livenessProbe.tcpSocket.port | int | `8888` |  |
| jicofo.nodeSelector | object | `{}` |  |
| jicofo.podAnnotations | object | `{}` |  |
| jicofo.podLabels | object | `{}` |  |
| jicofo.podSecurityContext | object | `{}` |  |
| jicofo.readinessProbe.tcpSocket.port | int | `8888` |  |
| jicofo.replicaCount | int | `1` |  |
| jicofo.resources | object | `{}` |  |
| jicofo.securityContext | object | `{}` |  |
| jicofo.tolerations | list | `[]` |  |
| jicofo.xmpp.componentSecret | string | `nil` |  |
| jicofo.xmpp.password | string | `nil` |  |
| jicofo.xmpp.user | string | `"focus"` |  |
| jvb.TCPPort | int | `4443` |  |
| jvb.UDPPort | int | `10000` |  |
| jvb.affinity | object | `{}` |  |
| jvb.breweryMuc | string | `"jvbbrewery"` |  |
| jvb.enableTCP | bool | `false` |  |
| jvb.extraEnvs | object | `{}` |  |
| jvb.image.repository | string | `"jitsi/jvb"` |  |
| jvb.livenessProbe.httpGet.path | string | `"/about/health"` |  |
| jvb.livenessProbe.httpGet.port | int | `8080` |  |
| jvb.metrics.enabled | bool | `false` |  |
| jvb.metrics.image.pullPolicy | string | `"IfNotPresent"` |  |
| jvb.metrics.image.repository | string | `"docker.io/systemli/prometheus-jitsi-meet-exporter"` |  |
| jvb.metrics.image.tag | string | `"1.1.6"` |  |
| jvb.metrics.resources.limits.cpu | string | `"20m"` |  |
| jvb.metrics.resources.limits.memory | string | `"32Mi"` |  |
| jvb.metrics.resources.requests.cpu | string | `"10m"` |  |
| jvb.metrics.resources.requests.memory | string | `"16Mi"` |  |
| jvb.metrics.serviceMonitor.enabled | bool | `true` |  |
| jvb.metrics.serviceMonitor.interval | string | `"10s"` |  |
| jvb.metrics.serviceMonitor.selector.release | string | `"prometheus-operator"` |  |
| jvb.nodeSelector | object | `{}` |  |
| jvb.podAnnotations | object | `{}` |  |
| jvb.podLabels | object | `{}` |  |
| jvb.podSecurityContext | object | `{}` |  |
| jvb.readinessProbe.httpGet.path | string | `"/about/health"` |  |
| jvb.readinessProbe.httpGet.port | int | `8080` |  |
| jvb.replicaCount | int | `1` |  |
| jvb.resources | object | `{}` |  |
| jvb.securityContext | object | `{}` |  |
| jvb.service.annotations | object | `{}` |  |
| jvb.service.enabled | string | `nil` |  |
| jvb.service.externalIPs | list | `[]` |  |
| jvb.service.type | string | `"ClusterIP"` |  |
| jvb.stunServers | string | `"meet-jit-si-turnrelay.jitsi.net:443"` |  |
| jvb.tolerations | list | `[]` |  |
| jvb.useHostPort | bool | `false` |  |
| jvb.xmpp.password | string | `nil` |  |
| jvb.xmpp.user | string | `"jvb"` |  |
| nameOverride | string | `""` |  |
| prosody.enabled | bool | `true` |  |
| prosody.extraEnvFrom[0].secretRef.name | string | `"{{ include \"prosody.fullname\" . }}-jicofo"` |  |
| prosody.extraEnvFrom[1].secretRef.name | string | `"{{ include \"prosody.fullname\" . }}-jvb"` |  |
| prosody.extraEnvFrom[2].configMapRef.name | string | `"{{ include \"prosody.fullname\" . }}-common"` |  |
| prosody.image.repository | string | `"jitsi/prosody"` |  |
| prosody.image.tag | string | `"stable-5963"` |  |
| prosody.server | string | `nil` |  |
| publicURL | string | `""` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` |  |
| tz | string | `"Europe/Amsterdam"` |  |
| web.affinity | object | `{}` |  |
| web.extraEnvs | object | `{}` |  |
| web.httpRedirect | bool | `false` |  |
| web.httpsEnabled | bool | `false` |  |
| web.image.repository | string | `"jitsi/web"` |  |
| web.ingress.annotations | object | `{}` |  |
| web.ingress.enabled | bool | `false` |  |
| web.ingress.hosts[0].host | string | `"jitsi.local"` |  |
| web.ingress.hosts[0].paths[0] | string | `"/"` |  |
| web.ingress.tls | list | `[]` |  |
| web.livenessProbe.httpGet.path | string | `"/"` |  |
| web.livenessProbe.httpGet.port | int | `80` |  |
| web.nodeSelector | object | `{}` |  |
| web.podAnnotations | object | `{}` |  |
| web.podLabels | object | `{}` |  |
| web.podSecurityContext | object | `{}` |  |
| web.readinessProbe.httpGet.path | string | `"/"` |  |
| web.readinessProbe.httpGet.port | int | `80` |  |
| web.replicaCount | int | `1` |  |
| web.resources | object | `{}` |  |
| web.securityContext | object | `{}` |  |
| web.service.externalIPs | list | `[]` |  |
| web.service.port | int | `80` |  |
| web.service.type | string | `"ClusterIP"` |  |
| web.tolerations | list | `[]` |  |
| xmpp.authDomain | string | `nil` |  |
| xmpp.domain | string | `"meet.jitsi"` |  |
| xmpp.guestDomain | string | `nil` |  |
| xmpp.internalMucDomain | string | `nil` |  |
| xmpp.mucDomain | string | `nil` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
