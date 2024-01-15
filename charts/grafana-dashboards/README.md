
# grafana-dashboards

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

grafana-dashboards

## `chart.version`

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa | <nospam@saritasa.com> | <https://www.saritasa.com/> |

## `chart.description`

A Helm chart for provisioning grafana dashboards

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingressNginx.controller | bool | `true` | provision `NGINX Ingress controller` dashboard |
| ingressNginx.controllerLoki | bool | `true` | provision `NGINX Ingress controller - Loki` dashboard |
| ingressNginx.enabled | bool | `true` |  |
| ingressNginx.namespace | string | `"grafana"` |  |
| ingressNginx.requestHandlingPerformance | bool | `true` | provision `Request Handling Performance` dashboard |

