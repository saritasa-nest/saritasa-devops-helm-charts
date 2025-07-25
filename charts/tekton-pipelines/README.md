
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
 * Written by Saritasa Devops Team, April 2022
 */

```

## `chart.deprecationWarning`

## `chart.name`

saritasa-tekton-pipelines

## `chart.version`

![Version: 2.2.2](https://img.shields.io/badge/Version-2.2.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa |  | <https://www.saritasa.com/> |

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
        - name: build-hello-world
          image: node:22
          imagePullPolicy: IfNotPresent
          workingDir: $(workspaces.source.path)
          script: |
            #!/bin/bash
            echo "hello world"
      preDeployTaskSteps:
        - name: pre-deploy-hello-world
          image: node:22
          imagePullPolicy: IfNotPresent
          workingDir: $(workspaces.source.path)
          script: |
            #!/bin/bash
            echo "hello world"
      extraPostDeployTaskSteps:
        - name: post-deploy-hello-world
          image: node:22
          imagePullPolicy: IfNotPresent
          workingDir: $(workspaces.source.path)
          script: |
            #!/bin/bash
            echo "hello world"
```

If you want to modify `build` step from buildpack's `build` Task added by default, you just need to add a new `overrideBuildStep` key with new step
content in values.yaml for required pipeline and helm chart will provision a custom `build` step:

 ```yaml
buildpacks:
  enabled: true
  generate:
    buildpackFrontendBuildPipelineNew:
      name: buildpack-frontend-build-pipeline-new
      enabled: false
      buildTaskName: buildpack-frontend-new

      overrideBuildStep:
        name: build
        image: node:22
        imagePullPolicy: IfNotPresent
        workingDir: $(workspaces.source.path)
        script: |
          #!/bin/bash
          az login --identity --username <managed-indentity>
          az acr login --name <container-registry>
          /cnb/lifecycle/creator \
            -app=$(params.source_subpath) \
            -project-metadata=project.toml \
            -cache-dir=/cache \
            -layers=/layers \
            -platform=$(workspaces.source.path)/$(params.platform_dir) \
            -report=/layers/report.toml \
            -cache-image=$(params.cache_image) \
            -uid=$(params.user_id) \
            -gid=$(params.group_id) \
            -process-type=$(params.process_type) \
            -skip-restore=$(params.skip_restore) \
            -previous-image=$(params.docker_registry_repository) \
            -run-image=$(params.run_image) \
            $(params.image)

      buildTaskSteps:
        - name: build-hello-world
          image: node:22
          imagePullPolicy: IfNotPresent
          workingDir: $(workspaces.source.path)
          script: |
            #!/bin/bash
            echo "hello world"
```

If you want to modify Kaniko build arguments, you can pass `kaniko_extra_args` parameter to `kaniko-pipeline`.
For example, if you want to pass `BASE_IMAGE` build argument value to be used in Dockerfile you can add following line
to specific project trigger-binding:
```yaml
- name: kaniko_extra_args
  value: --build-arg=BASE_IMAGE=965067289393.dkr.ecr.us-west-2.amazonaws.com/saritasa/legacy/php:php71-smart-screen-base
```

Chart has possibility to perform `Sentry` releases if it is needed, you can configure it by updating below settings in values.yaml:

```yaml
sentry:
  enabled: true
  authTokenSecret: "sentry-auth-token"  # auth token to connect to Sentry API (change it if you have custom value)
  authTokenSecretKey: "auth-token"      # key for auth token in `authTokenSecret` secret (change it if you have custom value)
  org: "saritasa"                       # name of your Sentry organization (change it if you have custom value)
  url: https://sentry.saritasa.rocks/   # Sentry url (change it if you have custom value)
```

After configuring these values, you will have an extra `sentry-release` step after `argocd-deploy` one for buildpacks and kaniko builds.

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| buildpacks.cnbPlatformAPI | string | `"0.10"` | cnb (cloud native buildpacks) platform API to support see more details [here](https://buildpacks.io/docs/reference/spec/platform-api/) and [here](https://github.com/buildpacks/spec/blob/main/platform.md) |
| buildpacks.enabled | bool | `false` | should we enable buildpack based pipelines |
| buildpacks.generate.buildpackDjangoBuildPipeline.buildTaskName | string | `"buildpack-django"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackDjangoBuildPipeline.buildTaskSteps | list | see values.yaml for the default values of it | steps to run in the `buildpack-django` task prior to executing /cnb/lifecycle/creator CLI |
| buildpacks.generate.buildpackDjangoBuildPipeline.enabled | bool | `false` | should we enable the django buildpack pipeline |
| buildpacks.generate.buildpackDjangoBuildPipeline.name | string | `"buildpack-django-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackDjangoBuildPipeline.overrideBuildStep | object | `{}` | buildpack `build` step can be overridden to be able to perform custom docker auth or add other required functionality |
| buildpacks.generate.buildpackDjangoBuildPipeline.preDeployTaskSteps | list | `[]` | steps to run in the `pre-deploy` task prior to ArgoCD sync command can be useful to prepare different backups and tests before real deploy |
| buildpacks.generate.buildpackDotnetBuildPipeline.buildTaskName | string | `"buildpack-dotnet"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackDotnetBuildPipeline.buildTaskSteps | list | see values.yaml for the default values of it | steps to run in the `buildpack-dotnet` task prior to executing /cnb/lifecycle/creator CLI |
| buildpacks.generate.buildpackDotnetBuildPipeline.enabled | bool | `false` | should we enable the dotnet buildpack pipeline |
| buildpacks.generate.buildpackDotnetBuildPipeline.name | string | `"buildpack-dotnet-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackDotnetBuildPipeline.overrideBuildStep | object | `{}` | buildpack `build` step can be overridden to be able to perform custom docker auth or add other required functionality |
| buildpacks.generate.buildpackDotnetBuildPipeline.preDeployTaskSteps | list | `[]` | steps to run in the `pre-deploy` task prior to ArgoCD sync command can be useful to prepare different backups and tests before real deploy |
| buildpacks.generate.buildpackFrontendBuildPipeline.buildTaskName | string | `"buildpack-frontend"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackFrontendBuildPipeline.buildTaskSteps | list | see values.yaml for the default values of it | steps to run in the `buildpack-frontend` task prior to executing /cnb/lifecycle/creator CLI |
| buildpacks.generate.buildpackFrontendBuildPipeline.enabled | bool | `false` | should we enable the frontend buildpack pipeline |
| buildpacks.generate.buildpackFrontendBuildPipeline.name | string | `"buildpack-frontend-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackFrontendBuildPipeline.overrideBuildStep | object | `{}` | buildpack `build` step can be overridden to be able to perform custom docker auth or add other required functionality |
| buildpacks.generate.buildpackFrontendBuildPipeline.preDeployTaskSteps | list | `[]` | steps to run in the `pre-deploy` task prior to ArgoCD sync command can be useful to prepare different backups and tests before real deploy |
| buildpacks.generate.buildpackGoBuildPipeline.buildTaskName | string | `"buildpack-go"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackGoBuildPipeline.enabled | bool | `false` | should we enable the GO buildpack pipeline |
| buildpacks.generate.buildpackGoBuildPipeline.name | string | `"buildpack-go-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackGoBuildPipeline.overrideBuildStep | object | `{}` | buildpack `build` step can be overridden to be able to perform custom docker auth or add other required functionality |
| buildpacks.generate.buildpackGoBuildPipeline.preDeployTaskSteps | list | `[]` | steps to run in the `pre-deploy` task prior to ArgoCD sync command can be useful to prepare different backups and tests before real deploy |
| buildpacks.generate.buildpackJavaBuildPipeline.buildTaskName | string | `"buildpack-java"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackJavaBuildPipeline.enabled | bool | `false` | should we enable the java buildpack pipeline |
| buildpacks.generate.buildpackJavaBuildPipeline.name | string | `"buildpack-java-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackJavaBuildPipeline.overrideBuildStep | object | `{}` | buildpack `build` step can be overridden to be able to perform custom docker auth or add other required functionality |
| buildpacks.generate.buildpackJavaBuildPipeline.preDeployTaskSteps | list | `[]` | steps to run in the `pre-deploy` task prior to ArgoCD sync command can be useful to prepare different backups and tests before real deploy |
| buildpacks.generate.buildpackNodejsBuildPipeline.buildTaskName | string | `"buildpack-nodejs"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackNodejsBuildPipeline.enabled | bool | `false` | should we enable the nodejs buildpack pipeline |
| buildpacks.generate.buildpackNodejsBuildPipeline.name | string | `"buildpack-nodejs-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackNodejsBuildPipeline.overrideBuildStep | object | `{}` | buildpack `build` step can be overridden to be able to perform custom docker auth or add other required functionality |
| buildpacks.generate.buildpackNodejsBuildPipeline.preDeployTaskSteps | list | `[]` | steps to run in the `pre-deploy` task prior to ArgoCD sync command can be useful to prepare different backups and tests before real deploy |
| buildpacks.generate.buildpackPhpBuildPipeline.buildTaskName | string | `"buildpack-php"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackPhpBuildPipeline.buildTaskSteps | list | see values.yaml for the default values of it | steps to run in the `buildpack-php` task prior to executing /cnb/lifecycle/creator CLI |
| buildpacks.generate.buildpackPhpBuildPipeline.description | string | `"Additional steps in the build task are required for\n- compile static with node.js (old legacy projects, where static html is bundled with the PHP repo)\n- fix PHP detection if repo contains buth node.js and php code"` |  |
| buildpacks.generate.buildpackPhpBuildPipeline.enabled | bool | `false` | should we enable the php buildpack pipeline |
| buildpacks.generate.buildpackPhpBuildPipeline.name | string | `"buildpack-php-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackPhpBuildPipeline.overrideBuildStep | object | `{}` | buildpack `build` step can be overridden to be able to perform custom docker auth or add other required functionality |
| buildpacks.generate.buildpackPhpBuildPipeline.preDeployTaskSteps | list | `[]` | steps to run in the `pre-deploy` task prior to ArgoCD sync command can be useful to prepare different backups and tests before real deploy |
| buildpacks.generate.buildpackRubyBuildPipeline.buildTaskName | string | `"buildpack-ruby"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackRubyBuildPipeline.enabled | bool | `false` | should we enable the ruby buildpack pipeline |
| buildpacks.generate.buildpackRubyBuildPipeline.name | string | `"buildpack-ruby-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackRubyBuildPipeline.overrideBuildStep | object | `{}` | buildpack `build` step can be overridden to be able to perform custom docker auth or add other required functionality |
| buildpacks.generate.buildpackRubyBuildPipeline.preDeployTaskSteps | list | `[]` | steps to run in the `pre-deploy` task prior to ArgoCD sync command can be useful to prepare different backups and tests before real deploy |
| imagePullPolicy | string | `"IfNotPresent"` | default imagePullPolicy to be used for images pulled in tekton task steps |
| images | object | See below | default images used in our solution |
| images.argocd_cli | string | `"https://github.com/argoproj/argo-cd/releases/download/v2.14.15/argocd-linux-amd64"` | argocd cli downdload URL |
| images.awscli | string | `"docker.io/amazon/aws-cli:2.7.4"` | aws cli image (used for aws ecr auth) |
| images.bash | string | `"docker.io/library/bash:5.2.37"` | bash image (used for various ops in steps) |
| images.git | string | `"alpine/git:v2.49.0"` | git image |
| images.kaniko | string | `"gcr.io/kaniko-project/executor@sha256:4e7a52dd1f14872430652bb3b027405b8dfd17c4538751c620ac005741ef9698"` | kaniko image used to build containers containing docker files - v1.24.0, uploaded May 23 2025 |
| images.kubectl | string | `"bitnami/kubectl:1.33.1"` | kubectl cli |
| images.kubeval | string | `"public.ecr.aws/saritasa/kubeval:0.16.1"` | kubeval image - validate Kubernetes manifests |
| images.kustomize | string | `"registry.k8s.io/kustomize/kustomize:v5.6.0"` | kustomize cli |
| images.python | string | `"saritasallc/python3:0.4"` | python image |
| images.sentry_cli | string | `"getsentry/sentry-cli:2.46.0"` | sentry cli image - needs to prepare Sentry releases |
| images.slack | string | `"cloudposse/slack-notifier:0.4.0"` | slack notifier |
| images.yamlfix | string | `"public.ecr.aws/saritasa/yamlfix:1.8.1"` | yamlfix image - format yaml files |
| kaniko.enabled | bool | `false` | should we enable the kaniko pipeline |
| kaniko.preDeployTaskSteps | list | `[]` | steps to run in the `pre-deploy` task prior to ArgoCD sync command can be useful to prepare different backups and tests before real deploy |
| podTemplate | object | see values.yaml | default configuration to be added into each pod created by tekton engine we want to plave them in a specific node with added tolerations/taints. |
| podTemplate.nodeSelector | object | `{"ci":"true"}` | node selector for pods spawned by tekton |
| podTemplate.tolerations | list | `[{"effect":"NoSchedule","key":"ci","operator":"Equal","value":"true"}]` | tolerations |
| saritasa-tekton.enabled | bool | `false` | should we configure dependency chart here. |
| sentry.authTokenSecret | string | `"sentry-auth-token"` |  |
| sentry.authTokenSecretKey | string | `"auth-token"` |  |
| sentry.enabled | bool | `false` |  |
| sentry.org | string | `"saritasa"` |  |
| sentry.url | string | `"https://sentry.saritasa.rocks/"` |  |
| wordpress.enabled | bool | `false` | should we enable the wordpress pipeline |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
