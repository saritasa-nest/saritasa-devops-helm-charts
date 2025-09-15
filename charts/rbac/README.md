
# saritasa-rbac

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

saritasa-rbac

## `chart.version`

![Version: 0.1.14](https://img.shields.io/badge/Version-0.1.14-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa | <nospam@saritasa.com> | <https://www.saritasa.com/> |

## `chart.description`

A Helm chart for Kubernetes implementing RBAC rules for saritasa developers, devops and
client's team members

You can see role bindings this way:

```sh
➜ k krew install rbac-lookup
➜ k rbac-lookup --kind group G saritasa
  saritasa:sso:developers    ci                 Role/saritasa-developers-role
  saritasa:sso:developers    ingress-nginx      Role/saritasa-developers-role
  saritasa:sso:developers    utils              Role/saritasa-developers-role
  saritasa:sso:developers    prod               Role/saritasa-developers-readonly-role
  saritasa:sso:developers    cluster-wide       ClusterRole/saritasa-developers-readonly-clusterrole
````

## `example usage with agocd`

Install the chart:

```
helm repo add saritasa https://saritasa-nest.github.io/saritasa-devops-helm-charts/
```

Make the argocd manifest

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: rbac
  namespace: argo-cd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
    argocd.argoproj.io/sync-wave: "1000"
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: prod
  project: default
  source:
    chart: saritasa-rbac
    helm:
      values: |
        rbac:
          client:
            name: "example"
            apps: true
          developers:
            ci: true
            ingressNginx: true
            postgres: true
          devops: true
    repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
    targetRevision: "0.1.7"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
````

You can also add any ad-hoc RBAC role/bindings via .Values.extraRbac multiline string

For `example` client:

```yaml
extraRbac: |
  kind: Role
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
   name: example-users-readonly-role
   namespace: {{ .Release.Namespace }}
  rules:
    - apiGroups: [""]
      resources:  ["services", "pods", "pods/log", "configmaps"]
      verbs: ["get", "list", "watch"]
    - apiGroups: [""]
      resources:  ["pods"]
      verbs: ["delete"]
    - apiGroups: [""]
      resources: ["pods/portforward", "services/portforward", "pods/exec"]
      verbs: ["create", "get"]
    - apiGroups: ["extensions"]
      resources:  ["*"]
      verbs: ["get", "list", "watch"]
    - apiGroups: ["batch"]
      resources:  ["*"]
      verbs: ["get", "list", "watch"]
    - apiGroups: ["apps"]
      resources:  ["*"]
      verbs: ["get", "list", "watch"]
    - apiGroups: ["tekton.dev"]
      resources:  ["*"]
      verbs:  ["taskruns", "pipelineruns", "pipelines", "tasks"]

  ---
  kind: RoleBinding
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    name: example:users
    namespace: {{ .Release.Namespace }}
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: example-users-readonly-role
  subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: example:users
````

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| extraRbac | string | `""` | additional rbac to add (should become multiline string) |
| rbac.client.apps | bool | `false` | should we add prod/staging etc namespace access to client team members |
| rbac.client.ci | bool | `false` | should we add ci namespace access to client team members |
| rbac.client.ingressNginx | bool | `true` | should we add ability to work with ingress-nginx pods in ingress-nginx ns |
| rbac.client.name | string | `""` | client name (single word, no spaces, dashes, columns), will be used in RBAC group naming. |
| rbac.client.utils | bool | `false` | should we add utils (cli tools, port-forwarder for dbs) namespace access to client team members |
| rbac.developers.apps | bool | `false` | should we give access to all applications to saritasa developers |
| rbac.developers.ci | bool | `false` | should we add ci namespace access to saritasa developers |
| rbac.developers.ingressNginx | bool | `false` | should we add ability to work with ingress-nginx pods in ingress-nginx ns |
| rbac.developers.utils | bool | `false` | should we add utils (cli tools, port-forwarder for dbs) namespace access to client team members |
| rbac.devops | bool | `false` | should we create cluster role/binding for devops team |

