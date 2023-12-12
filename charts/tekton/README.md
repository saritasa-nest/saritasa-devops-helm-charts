
# saritasa-tekton

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

saritasa-tekton

## `chart.version`

![Version: 1.0.0-dev.4](https://img.shields.io/badge/Version-1.0.0--dev.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.54.0](https://img.shields.io/badge/AppVersion-v0.54.0-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa | <nospam@saritasa.com> | <https://www.saritasa.com/> |

## `chart.description`

A Helm chart for Tekton.

Implements:
- tekton engine
- tekton dashboard
- tekton triggers
- tekton dashboard ingress
- webhook ingress

## `example usage with argocd`

Install the chart:

```
helm repo add saritasa https://saritasa-nest.github.io/saritasa-devops-helm-charts/
```

then create the manifest and apply:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tekton-engine
  namespace: argo-cd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
    argocd.argoproj.io/sync-wave: "40"
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: tekton-pipelines
  project: default
  source:
    chart: saritasa-tekton
    helm:
      values: |
        domainZone: staging.site.com

        # install engine
        engine:
          enabled: true
          config:
            defaultServiceAccount: "build-bot-sa"
            defaultTimeoutMinutes: "60"
            defaultPodTemplate: |
              nodeSelector:
                ci: "true"

        # install triggers
        triggers:
          enabled: true

        # install dashboard with a public ingress
        dashboard:
          enabled: true
          ingress:
            enabled: true
            annotations:
              kubernetes.io/ingress.class: "nginx"
              nginx.ingress.kubernetes.io/proxy-body-size: 100m
              cert-manager.io/cluster-issuer: "letsencrypt-prod"
              nginx.ingress.kubernetes.io/auth-type: basic
              nginx.ingress.kubernetes.io/auth-secret: tekton-basic-auth
              nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
              argocd.argoproj.io/sync-wave: "1"
            hosts:
              - host: tekton.staging.site.com
                paths:
                  - path: /
                    pathType: Prefix
                    backend:
                      service:
                        name: tekton-dashboard
                        port:
                          number: 9097
            tls:
             - secretName: tekton.staging.site.com-crt
               hosts:
                 - tekton.staging.site.com

        # install github webhook ingress that invokes tekton's eventlistener
        webhook:
          enabled: true
          namespace: "ci"
          ingress:
            enabled: true
            annotations:
              kubernetes.io/ingress.class: "nginx"
              nginx.ingress.kubernetes.io/proxy-body-size: 100m
              cert-manager.io/cluster-issuer: "letsencrypt-prod"
              argocd.argoproj.io/sync-wave: "10"
            hosts:
              - host: webhook.staging.site.com
                paths:
                  - path: /
                    pathType: Prefix
                    backend:
                      service:
                        name: el-build-pipeline-event-listener
                        port:
                          number: 8080
            tls:
             - secretName: webhook.staging.site.com-crt
               hosts:
                 - webhook.staging.site.com

        serviceAccount:
          create: true
          name: "build-bot-sa"

        nodeSelector:
          tekton_builder: "true"

    repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
    targetRevision: "0.1.4"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

```

Keep in mind that tekton has config-default configmap, an example you can see
[here](https://github.com/tektoncd/pipeline/blob/main/config/config-defaults.yaml).
You can customize it values in this map `engine.config: {}`.

Just add keys in the map and they will be added into the tekton-pipelines/config-defaults configmap.

```yaml
engine:
  config:
    defaultServiceAccount: "build-bot-sa"
    defaultTimeoutMinutes: "60"
    defaultPodTemplate: |
      nodeSelector:
        ci: "true"
```

If you want to pull images from a private registry (or if you want to skip 200 pulls on dockerhub)

```
imagePullSecrets:
  - name: "your-docker-secret-name"
```

You can generate that secret by doing the following

```
kubectl create secret -n argo-cd generic docker-saritasa-infra-v2-ro \
  --from-file=.dockerconfigjson=~/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson
```

Make dure this `~/.docker/config.json` is cleaned from non-infra-v2 registries first.

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | default is to avoid running tekton pods on windows nodes. | affinity for tekton-related pods |
| dashboard.enabled | bool | `true` | enable tekton dashboard |
| dashboard.ingress | object | `{}` | tekton ingress configuration |
| domainZone | string | `"site.com"` | This is required name of the hosted zone. All public services would be created under this hosted zone |
| engine.config | object | `{}` | tekton-defaults configuration which will be added into tekton-pipelines/config-defaults cm |
| engine.controller | object | use args multiline string to set additional launch arguments for the tekton controller | controller launch arguments |
| engine.enabled | bool | `true` | if you want to enable the tekton engine (pipelines, pipelineruns, tasks, taskruns etc) |
| imagePullSecrets | list | `[]` | list of docker registry secrets to pull images |
| nodeSelector | object | `{}` | what node to run tekton related pods |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `"build-bot-sa"` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | tolerations for tekton related pods |
| triggers.enabled | bool | `true` | enable tekton triggers |
| webhook.enabled | bool | `true` | enable tekton eventlistener webhook (github trigger) |
| webhook.ingress | object | `{}` | webhook ingress configuration |
| webhook.namespace | string | `"ci"` | namespace where this webhook should be installed |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
