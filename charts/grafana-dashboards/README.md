
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

![Version: 0.0.6](https://img.shields.io/badge/Version-0.0.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa | <nospam@saritasa.com> | <https://www.saritasa.com/> |

## `chart.description`

A Helm chart for provisioning grafana dashboards

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alerts.alertmanager | bool | `true` | provision `Alertmanager` dashboard |
| alerts.enabled | bool | `true` | if you want to enable alerts dashboards |
| alerts.namespace | string | `"grafana"` | namespace where configmaps for alerts dashboards should be created |
| alerts.targetDirectory | string | `"/tmp/dashboards/alerts/"` | directory where alerts dashboards will be installed |
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
| aws.targetDirectory | string | `"/tmp/dashboards/aws/"` | directory where aws dashboards will be installed |
| cicd.argocd | bool | `true` | provision `ArgoCD` dashboard |
| cicd.enabled | bool | `true` | if you want to enable cicd dashboards |
| cicd.namespace | string | `"grafana"` | namespace where configmaps for cicd dashboards should be created |
| cicd.targetDirectory | string | `"/tmp/dashboards/cicd/"` | directory where cicd dashboards will be installed |
| databases.enabled | bool | `true` | if you want to enable databases dashboards |
| databases.mysql | bool | `true` | provision `MySQL Instance Summary` dashboard |
| databases.namespace | string | `"grafana"` | namespace where configmaps for databases dashboards should be created |
| databases.postgresql | bool | `true` | provision `PostgreSQL Database` dashboard |
| databases.targetDirectory | string | `"/tmp/dashboards/databases/"` | directory where databases dashboards will be installed |
| default.enabled | bool | `true` | if you want to enable default dashboards |
| default.genericServiceMetrics | bool | `true` | provision `Generic Service Metrics` dashboard |
| default.home | bool | `true` | provision `Home` dashboard |
| default.namespace | string | `"grafana"` | namespace where configmaps for default dashboards should be created |
| default.targetDirectory | string | `"/tmp/dashboards/default/"` | directory where default dashboards will be installed |
| ingressNginx.controller | bool | `true` | provision `NGINX Ingress controller` dashboard |
| ingressNginx.controllerLoki | bool | `true` | provision `NGINX Ingress controller - Loki` dashboard |
| ingressNginx.enabled | bool | `true` | if you want to enable ingress-nginx dashboards |
| ingressNginx.namespace | string | `"grafana"` | namespace where configmaps for ingress-nginx dashboards should be created |
| ingressNginx.requestHandlingPerformance | bool | `true` | provision `Request Handling Performance` dashboard |
| ingressNginx.targetDirectory | string | `"/tmp/dashboards/ingress-nginx/"` | directory where ingress-nginx dashboards will be installed |
| istio.controlPlane | bool | `true` | provision `Istio Control Plane Dashboard` dashboard |
| istio.enabled | bool | `true` | if you want to enable istio dashboards |
| istio.mesh | bool | `true` | provision `Istio Mesh Dashboard` dashboard |
| istio.namespace | string | `"grafana"` | namespace where configmaps for istio dashboards should be created |
| istio.performance | bool | `true` | provision `Istio Performance Dashboard` dashboard |
| istio.service | bool | `true` | provision `Istio Service Dashboard` dashboard |
| istio.targetDirectory | string | `"/tmp/dashboards/istio/"` | directory where istio dashboards will be installed |
| istio.wasmExtension | bool | `true` | provision `Istio Wasm Extension Dashboard` dashboard |
| istio.workload | bool | `true` | provision `Istio Workload Dashboard` dashboard |
| knative.enabled | bool | `true` | if you want to enable knative dashboards |
| knative.eventingBrokerTrigger | bool | `true` | provision `Knative Eventing - Broker/Trigger` dashboard |
| knative.eventingSource | bool | `true` | provision `Knative Eventing - Source` dashboard |
| knative.namespace | string | `"grafana"` | namespace where configmaps for knative dashboards should be created |
| knative.reconciler | bool | `true` | provision `Knative - Reconciler` dashboard |
| knative.servingControlPlaneEfficiency | bool | `true` | provision `Knative Serving - Control Plane Efficiency` dashboard |
| knative.servingRevisionCpuMemoryUsage | bool | `true` | provision `Knative Serving - Revision CPU and Memory Usage` dashboard |
| knative.servingRevisionHttpRequests | bool | `true` | provision `Knative Serving - Revision HTTP Requests` dashboard |
| knative.servingScalingDebugging | bool | `true` | provision `Knative Serving - Scaling Debugging` dashboard |
| knative.targetDirectory | string | `"/tmp/dashboards/knative/"` | directory where knative dashboards will be installed |
| kubernetes.clusterMonitoring | bool | `true` | provision `Kubernetes - Cluster Monitoring` dashboard |
| kubernetes.clusterOverall | bool | `true` | provision `Kubernetes - Cluster Overall Dashboard` dashboard |
| kubernetes.clusterOverview | bool | `true` | provision `Kubernetes - Cluster Overview` dashboard |
| kubernetes.enabled | bool | `true` | if you want to enable kubernetes dashboards |
| kubernetes.namespace | string | `"grafana"` | namespace where configmaps for kubernetes dashboards should be created |
| kubernetes.nodeExporterFull | bool | `true` | provision `Node Exporter Full` dashboard |
| kubernetes.targetDirectory | string | `"/tmp/dashboards/kubernetes/"` | directory where kubernetes dashboards will be installed |

