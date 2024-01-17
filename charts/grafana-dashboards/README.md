
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

![Version: 0.0.3](https://img.shields.io/badge/Version-0.0.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa | <nospam@saritasa.com> | <https://www.saritasa.com/> |

## `chart.description`

A Helm chart for provisioning grafana dashboards

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aws.billing | bool | `true` | provision `AWS Billing Dashboard` dashboard |
| aws.cloudwatchLogs | bool | `true` | provision `Amazon CloudWatch Logs` dashboard |
| aws.cniMetrics | bool | `true` | provision `AWS CNI Metrics` dashboard |
| aws.ebs | bool | `true` | provision `Amazon EBS` dashboard |
| aws.ec2 | bool | `true` | provision `AWS EC2` dashboard |
| aws.enabled | bool | `true` | if you want to enable aws dashboards |
| aws.lambda | bool | `true` | provision `AWS Lambda` dashboard |
| aws.namespace | string | `"grafana"` | namespace where configmaps for aws dashboards should be created |
| aws.rds | bool | `true` | provision `Amazon RDS` dashboard |
| aws.route53 | bool | `true` | provision `AWS Route 53` dashboard |
| aws.ses | bool | `true` | provision `AWS SES` dashboard |
| aws.sqs | bool | `true` | provision `AWS SQS` dashboard |
| aws.targetDirectory | string | `"/var/lib/grafana/dashboards/aws/"` | directory where aws dashboards will be installed |
| ingressNginx.controller | bool | `true` | provision `NGINX Ingress controller` dashboard |
| ingressNginx.controllerLoki | bool | `true` | provision `NGINX Ingress controller - Loki` dashboard |
| ingressNginx.enabled | bool | `true` | if you want to enable ingress-nginx dashboards |
| ingressNginx.namespace | string | `"grafana"` | namespace where configmaps for ingress-nginx dashboards should be created |
| ingressNginx.requestHandlingPerformance | bool | `true` | provision `Request Handling Performance` dashboard |
| ingressNginx.targetDirectory | string | `"/var/lib/grafana/dashboards/ingress-nginx/"` | directory where ingress-nginx dashboards will be installed |

