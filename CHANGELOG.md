# Changelog

## 2025-07-10

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/158)
- Hotfix: change gcr to ghcr image repository in tekton-pipeline

## 2025-07-01

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/157)
- Release new `terraform-pod` version with `1.12.2` terraform

## 2025-06-26

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/156)
- Add persistent logs for tekton:
  - Remember to first create S3 bucket and IAM role in infra-aws repo
  - Remember to first add logging-operator addon to cluster

## 2025-06-24

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/155)
- Update tekton-pipelines:
  - Removed resources blocks as they are deprecated
  - Add new git-clone task from tekton catalog
  - update all pipelines to use new versions and tasks

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/154)
- Update tekton:
  - Pipelines:    "1.1.0"
  - Triggers:     "0.32.0"
  - Interceptors: "0.32.0"
  - Dashboard:    "0.58.0"
- Breaking change: must also update tekton-pipelines to latest

## 2025-05-26

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/153)
- Release new `terraform-pod` version with `1.12.1` terraform

## 2025-05-07

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/152)
- Add UV support in Django Tekton pipeline

## 2025-04-16

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/150)
- Add PrometheusRule and ServiceMonitor support to eol-exporter

## 2025-04-11

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/151)
- Release new `terraform-pod` version with `terraform:1.11.3` (based on `python:3.12.10-alpine3.21`)

## 2025-03-13

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/149)
- Release new `terraform-pod` version with `1.11.2` terraform

## 2025-03-10

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/148)
- Release new `terraform-pod` version with postgres variable name fix

## 2025-03-05

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/147)
- Release new `terraform-pod` version with `1.11.0` terraform

## 2024-01-27

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/146)
- Release `eol-prometheus-exporter` version `1.0.0`

## 2025-01-24

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/145)
- Release new `terraform-pod` version with `1.10.5` terraform

## 2024-12-05

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/142)
- Release new `terraform-pod` version with `1.10.1` terraform

## 2024-11-19

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/141)
- Release `eol-prometheus-exporter` version `0.1.1`

## 2024-11-11

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/140)
- Add option to select `priorityClass` in Wordpress components for tekton-apps

## 2024-10-21

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/139)
- Add option to select `kustomize-build-with-helm` plugin in tekton-apps

## 2024-10-11

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/138)
- Breaking change(!): move EventListener definition from "tekton-apps" to "tekton" helm chart.
  You must update both these charts for correct work.
- Define triggers as standalone entity, not part as EventListener definition.
  EventListener finds matching triggers by label selector.

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/137)
- Tekton pipeline prepare template fix

## 2024-10-08

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/136)
- Release new `terraform-pod` version with 1.9.7 terraform

## 2024-09-23

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/135)
- Add EOL exporter helm chart

## 2024-09-13

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/134)
- Fix RBAC definitions for developers and client roles

## 2024-09-09

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/132)
- update path for `readinessProbe` and `customLivenessProbe` in the wordpress helm chart

## 2024-09-02

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/131)
- Changed strategy type in wordpress helm chart to `Recreate`

## 2024-08-28

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/129)
- Release new `terraform-pod` version with 1.9.5 terraform

## 2024-08-21

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/128)
- Update wordpress helm chart to the latest version `23.1.4`

## 2024-08-08

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/126)
- Release new `terraform-pod` version with 1.9.3 terraform

## 2024-07-23

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/125)
- Release new `rbac` version 0.1.11 - fix developer permissions to compatible with Kubernetes 1.30: allow 'get pods/exec'

## 2024-07-08

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/123)
- Release new `terraform-pod` version with 1.9.1 terraform

## 2024-06-21

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/122)
- Release new `terraform-pod` version with 1.8.5 terraform

## 2024-06-04

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/121)
- Add `pre-deploy` step for buildpacks and Kaniko CI/CD

## 2024-05-20

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/120)
- Release new `terraform-pod` version with 1.8.3 terraform

## 2024-04-15

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/119)
- Release new `terraform-pod` version with 1.8.0 terraform

## 2024-03-22

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/117)
- Updated poetry version in tekton-pipelines: `1.5.1` -> `1.8.2`

## 2024-03-21

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/116)
- Fix typo in `tekton-pipeline` helm chart for `kaniko` image

## 2024-03-01

[dev]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/115)
- adding `mergeable` configuration

## 2024-02-29

[dev]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/114)
- removing `mergeable` configuration

## 2024-02-28

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/113)
- Release new `terraform-pod` version with 1.7.4 terraform

## 2024-01-31

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/112)
- Fix typo in `tekton-apps` helm chart for `build-pipeline-role` Role generation

## 2024-01-25

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/109)
- Changed ArgoCD slack notifications logic to remove notifications from AppProjects CRD and put them in Applications CRDs

## 2024-01-24

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/111)
- Added compability with new jammy paketo buildpacks for tekton-pipelines

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/110)
- Release terraform-pod chart with 1.7.0 terraform version `0.0.22`


## 2023-12-26

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/100)
- Added push image to registry with additional tag `latest`

## 2023-12-22

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/104)
- Release terraform-pod chart with 1.6.6 terraform version `0.0.21`

## 2023-10-27

[prod]

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/99)
- Added GitHub mergeable bot for checking PR  version `0.2.0`

- [associated PR](https://github.com/saritasa-nest/saritasa-devops-helm-charts/pull/98)
- Changed tekton-apps version to 0.2.15
