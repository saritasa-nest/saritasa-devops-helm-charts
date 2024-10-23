# Changelog

## 2024-10-11

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
