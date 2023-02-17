
# opsgenie-heartbeat

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

opsgenie-heartbeat

## `chart.version`

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa | <nospam@saritasa.com> | <https://www.saritasa.com/> |

## `chart.description`

Chart that installs our solution to send heartbeat pings via OpsGenie API automatically

You will need to create the secret containing opsgenie APIKEY first:

```sh
kubectl -n opsgenie create secret generic opsgenie-apikey-secret \
  --from-literal=apikey=YOUR_APIKEY
```

Keep in mind that the name of your heartbeat in opsgenie should be the exact name of your kubernetes cluster

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| existingSecret | string | `"opsgenie-apikey-secret"` | existing secret with apikey info for opsgenie API |
| fullnameOverride | string | `""` |  |
| heartbeatName | string | `""` | name of the kubernetes cluster (should be also the heartbeat name in opsgenie) |
| image.pullPolicy | string | `"IfNotPresent"` | pull policy |
| image.repository | string | `"saritasallc/opsgenie-heartbeat"` | default docker registry |
| image.tag | string | `"0.0.1"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | docker pull secret |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| resources.limits.cpu | string | `"50m"` |  |
| resources.limits.memory | string | `"50Mi"` |  |
| resources.requests.cpu | string | `"50m"` |  |
| resources.requests.memory | string | `"50Mi"` |  |
| securityContext | object | `{"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000}` | security options for the running pod |
| service | object | `{"port":8080,"type":"ClusterIP"}` | type of the service to create |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` |  |
