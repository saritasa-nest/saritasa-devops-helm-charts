
# saritasa-tekton-pipelines

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
 * Written by Dmitry Semenov, November 2021
 */

```

## `chart.deprecationWarning`

## `chart.name`

saritasa-tekton-pipelines

## `chart.version`

![Version: 0.1.10](https://img.shields.io/badge/Version-0.1.10-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.28.2](https://img.shields.io/badge/AppVersion-v0.28.2-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa |  | https://www.saritasa.com/ |

## `chart.description`

A Helm chart for Tekton Pipelines

Implements:
- common tekton tasks
- common tekton pipelines
- common tekton trigger templates
- common tekton trigger bindings

Implemented pipelines include:
- buildpack based pipelines based on generator template (php, python, frontend, nodejs, ruby, go)
- kaniko pipeline
- wordpress pipeline

## `example usage with argocd`

Install the chart:

```
helm repo add saritasa https://saritasa-nest.github.io/saritasa-devops-helm-charts/
```

then if you want to support only frontend and django pipelines based on buildpack without any script modifications:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tekton-pipelines
  namespace: argo-cd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
    argocd.argoproj.io/sync-wave: "60"
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: ci
  project: default
  source:
    chart: saritasa-tekton-pipelines
    helm:
      values: |
        buildpacks:
          enabled: true
          generate:
            buildpackFrontendBuildPipeline:
              enabled: true

            buildpackDjangoBuildPipeline:
              enabled: true

    repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
    targetRevision: "0.1.4"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

If you want to modify the behavior of the build step you can easily do that by redefining steps you want to run prior to running the `build` step
of the associated buildpack pipeline. You can create multiple versions of pipelines as a result. Just make sure to give them a different name

an example:

```yaml
buildpacks:
  enabled: true
  generate:
    buildpackFrontendBuildPipelineNew:
      name: buildpack-frontend-build-pipeline-new
      enabled: false
      buildTaskName: buildpack-frontend-new
      buildTaskSteps:
        - name: hello1
          image: node:14
          imagePullPolicy: IfNotPresent
          workingDir: $(resources.inputs.app.path)
          script: |
            #!/bin/bash
            echo "hello world1"

        - name: hello2
          image: node:15
          imagePullPolicy: IfNotPresent
          workingDir: $(resources.inputs.app.path)
          script: |
            #!/bin/bash
            echo "hello world2"
```

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| buildpacks.cnbPlatformAPI | string | `"0.4"` | cnb (cloud native buildpacks) platform API to support see more details [here](https://buildpacks.io/docs/reference/spec/platform-api/) and [here](https://github.com/buildpacks/spec/blob/main/platform.md) |
| buildpacks.enabled | bool | `false` | should we enable buildpack based pipelines |
| buildpacks.generate.buildpackDjangoBuildPipeline.buildTaskName | string | `"buildpack-django"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackDjangoBuildPipeline.buildTaskSteps | list | see values.yaml for the default values of it | steps to run in the `buildpack-django` task prior to executing /cnb/lifecycle/creator CLI |
| buildpacks.generate.buildpackDjangoBuildPipeline.enabled | bool | `false` | should we enable the django buildpack pipeline |
| buildpacks.generate.buildpackDjangoBuildPipeline.name | string | `"buildpack-django-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackDotnetBuildPipeline.buildTaskName | string | `"buildpack-dotnet"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackDotnetBuildPipeline.buildTaskSteps | list | see values.yaml for the default values of it | steps to run in the `buildpack-dotnet` task prior to executing /cnb/lifecycle/creator CLI |
| buildpacks.generate.buildpackDotnetBuildPipeline.enabled | bool | `false` | should we enable the dotnet buildpack pipeline |
| buildpacks.generate.buildpackDotnetBuildPipeline.name | string | `"buildpack-dotnet-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackFrontendBuildPipeline.buildTaskName | string | `"buildpack-frontend"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackFrontendBuildPipeline.buildTaskSteps | list | see values.yaml for the default values of it | steps to run in the `buildpack-frontend` task prior to executing /cnb/lifecycle/creator CLI |
| buildpacks.generate.buildpackFrontendBuildPipeline.enabled | bool | `false` | should we enable the frontend buildpack pipeline |
| buildpacks.generate.buildpackFrontendBuildPipeline.name | string | `"buildpack-frontend-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackGoBuildPipeline.buildTaskName | string | `"buildpack-go"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackGoBuildPipeline.enabled | bool | `false` | should we enable the GO buildpack pipeline |
| buildpacks.generate.buildpackGoBuildPipeline.name | string | `"buildpack-go-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackNodejsBuildPipeline.buildTaskName | string | `"buildpack-nodejs"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackNodejsBuildPipeline.enabled | bool | `false` | should we enable the nodejs buildpack pipeline |
| buildpacks.generate.buildpackNodejsBuildPipeline.name | string | `"buildpack-nodejs-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackPhpBuildPipeline.buildTaskName | string | `"buildpack-php"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackPhpBuildPipeline.buildTaskSteps | list | see values.yaml for the default values of it | steps to run in the `buildpack-php` task prior to executing /cnb/lifecycle/creator CLI |
| buildpacks.generate.buildpackPhpBuildPipeline.description | string | `"Additional steps in the build task are required for\n- compile static with node.js (old legacy projects, where static html is bundled with the PHP repo)\n- fix PHP detection if repo contains buth node.js and php code"` |  |
| buildpacks.generate.buildpackPhpBuildPipeline.enabled | bool | `false` | should we enable the php buildpack pipeline |
| buildpacks.generate.buildpackPhpBuildPipeline.name | string | `"buildpack-php-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackRubyBuildPipeline.buildTaskName | string | `"buildpack-ruby"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackRubyBuildPipeline.enabled | bool | `false` | should we enable the ruby buildpack pipeline |
| buildpacks.generate.buildpackRubyBuildPipeline.name | string | `"buildpack-ruby-build-pipeline"` | the name of the generated pipeline |
| imagePullPolicy | string | `"IfNotPresent"` | default imagePullPolicy to be used for images pulled in tekton task steps |
| images | object | See below | default images used in our solution |
| images.argocd | string | `"argoproj/argocd:v2.1.3"` | argocd cli image (used in argocd-deploy task) |
| images.awscli | string | `"docker.io/amazon/aws-cli:2.2.46"` | aws cli image (used for aws ecr auth) |
| images.bash | string | `"docker.io/library/bash:5.1.8"` | bash image (used for various ops in steps) |
| images.git | string | `"alpine/git:v2.32.0"` | git image |
| images.kaniko | string | `"gcr.io/kaniko-project/executor@sha256:6ecc43ae139ad8cfa11604b592aaedddcabff8cef469eda303f1fb5afe5e3034"` | kaniko image used to build containers containing docker files |
| images.kubectl | string | `"bitnami/kubectl:1.21.5"` | kubectl cli |
| images.kustomize | string | `"k8s.gcr.io/kustomize/kustomize:v4.4.0"` | kustomize cli |
| images.python | string | `"saritasallc/python3:0.4"` | python image |
| images.slack | string | `"cloudposse/slack-notifier:0.4.0"` | slack notifier |
| kaniko.enabled | bool | `false` | should we enable the kaniko pipeline |
| podTemplate | object | see values.yaml | default configuration to be added into each pod created by tekton engine we want to plave them in a specific node with added tolerations/taints. |
| podTemplate.nodeSelector | object | `{"ci":"true"}` | node selector for pods spawned by tekton |
| podTemplate.tolerations | list | `[{"effect":"NoSchedule","key":"ci","operator":"Equal","value":"true"}]` | tolerations |
| saritasa-tekton.enabled | bool | `false` | should we configure dependency chart here. |
| wordpress.enabled | bool | `false` | should we enable the wordpress pipeline |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
