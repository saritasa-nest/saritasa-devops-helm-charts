
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

![Version: 0.1.37-dev-ksenia.1](https://img.shields.io/badge/Version-0.1.37--dev--ksenia.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
        - name: hello1
          image: node:16
          imagePullPolicy: IfNotPresent
          workingDir: $(resources.inputs.app.path)
          script: |
            #!/bin/bash
            echo "hello world1"

        - name: hello2
          image: node:16
          imagePullPolicy: IfNotPresent
          workingDir: $(resources.inputs.app.path)
          script: |
            #!/bin/bash
            echo "hello world2"
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
| buildpacks.cnbPlatformAPI | string | `"0.4"` | cnb (cloud native buildpacks) platform API to support see more details [here](https://buildpacks.io/docs/reference/spec/platform-api/) and [here](https://github.com/buildpacks/spec/blob/main/platform.md) |
| buildpacks.enabled | bool | `false` | should we enable buildpack based pipelines |
| buildpacks.generate.buildpackDjangoBuildPipeline.buildTaskName | string | `"buildpack-django"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackDjangoBuildPipeline.buildTaskSteps | list | see values.yaml for the default values of it | steps to run in the `buildpack-django` task prior to executing /cnb/lifecycle/creator CLI |
| buildpacks.generate.buildpackDjangoBuildPipeline.enabled | bool | `false` | should we enable the django buildpack pipeline |
| buildpacks.generate.buildpackDjangoBuildPipeline.name | string | `"buildpack-django-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackDjangoBuildPipeline.postDeployTaskSteps[0].image | string | `"badouralix/curl-jq"` |  |
| buildpacks.generate.buildpackDjangoBuildPipeline.postDeployTaskSteps[0].imagePullPolicy | string | `"IfNotPresent"` |  |
| buildpacks.generate.buildpackDjangoBuildPipeline.postDeployTaskSteps[0].name | string | `"argo-events"` |  |
| buildpacks.generate.buildpackDjangoBuildPipeline.postDeployTaskSteps[0].resources | object | `{}` |  |
| buildpacks.generate.buildpackDjangoBuildPipeline.postDeployTaskSteps[0].script | string | `"#!/usr/bin/env bash\n\n# add extra params from env and convert them to lowercase to work with this\n# data later in argo workflow\nEXTRA=$(jq -n env | jq 'walk(if type==\"object\" then with_entries(.key|=ascii_downcase) else . end)')\nJSON_PAYLOAD='{\n  \"project\": \"$(params.project)\",\n  \"environment\": \"$(params.environment)\",\n  \"application\": \"$(params.application)\",\n  \"sha\": \"$(params.sha)\",\n  \"extra\": ${EXTRA}\n}'\n\necho \"Payload: $JSON_PAYLOAD\"\n\nOUTPUT=$(curl -s -o /dev/null -w httpcode=%{http_code} --location --request POST \"build-succeed-eventsource-svc.argo-events.svc.cluster.local\" \\\n  --header 'Content-Type: application/json' \\\n  --data-raw \"$JSON_PAYLOAD\")\n\nSTATUS_CODE=$(echo \"${OUTPUT}\" | sed -e 's/.*\\httpcode=//')\nif [ ${STATUS_CODE} -ne 204 ]; then\n    echo \"Curl operation/command failed due to server return code - ${STATUS_CODE}\"\n    exit 1\nfi\n\necho \"Sent 'build-succeed' webhook\"\n"` |  |
| buildpacks.generate.buildpackDjangoBuildPipeline.postDeployTaskSteps[0].securityContext.privileged | bool | `true` |  |
| buildpacks.generate.buildpackDotnetBuildPipeline.buildTaskName | string | `"buildpack-dotnet"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackDotnetBuildPipeline.buildTaskSteps | list | see values.yaml for the default values of it | steps to run in the `buildpack-dotnet` task prior to executing /cnb/lifecycle/creator CLI |
| buildpacks.generate.buildpackDotnetBuildPipeline.enabled | bool | `false` | should we enable the dotnet buildpack pipeline |
| buildpacks.generate.buildpackDotnetBuildPipeline.name | string | `"buildpack-dotnet-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackFrontendBuildPipeline.buildTaskName | string | `"buildpack-frontend"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackFrontendBuildPipeline.buildTaskSteps | list | see values.yaml for the default values of it | steps to run in the `buildpack-frontend` task prior to executing /cnb/lifecycle/creator CLI |
| buildpacks.generate.buildpackFrontendBuildPipeline.enabled | bool | `false` | should we enable the frontend buildpack pipeline |
| buildpacks.generate.buildpackFrontendBuildPipeline.name | string | `"buildpack-frontend-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackFrontendBuildPipeline.postDeployTaskSteps[0].image | string | `"badouralix/curl-jq"` |  |
| buildpacks.generate.buildpackFrontendBuildPipeline.postDeployTaskSteps[0].imagePullPolicy | string | `"IfNotPresent"` |  |
| buildpacks.generate.buildpackFrontendBuildPipeline.postDeployTaskSteps[0].name | string | `"argo-events"` |  |
| buildpacks.generate.buildpackFrontendBuildPipeline.postDeployTaskSteps[0].resources | object | `{}` |  |
| buildpacks.generate.buildpackFrontendBuildPipeline.postDeployTaskSteps[0].script | string | `"#!/usr/bin/env bash\n\n# add extra params from env and convert them to lowercase to work with this\n# data later in argo workflow\nEXTRA=$(jq -n env | jq 'walk(if type==\"object\" then with_entries(.key|=ascii_downcase) else . end)')\nJSON_PAYLOAD='{\n  \"project\": \"$(params.project)\",\n  \"environment\": \"$(params.environment)\",\n  \"application\": \"$(params.application)\",\n  \"sha\": \"$(params.sha)\",\n  \"extra\": ${EXTRA}\n}'\n\necho \"Payload: $JSON_PAYLOAD\"\n\nOUTPUT=$(curl -s -o /dev/null -w httpcode=%{http_code} --location --request POST \"build-succeed-eventsource-svc.argo-events.svc.cluster.local\" \\\n  --header 'Content-Type: application/json' \\\n  --data-raw \"$JSON_PAYLOAD\")\n\nSTATUS_CODE=$(echo \"${OUTPUT}\" | sed -e 's/.*\\httpcode=//')\nif [ ${STATUS_CODE} -ne 204 ]; then\n    echo \"Curl operation/command failed due to server return code - ${STATUS_CODE}\"\n    exit 1\nfi\n\necho \"Sent 'build-succeed' webhook\"\n"` |  |
| buildpacks.generate.buildpackFrontendBuildPipeline.postDeployTaskSteps[0].securityContext.privileged | bool | `true` |  |
| buildpacks.generate.buildpackGoBuildPipeline.buildTaskName | string | `"buildpack-go"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackGoBuildPipeline.enabled | bool | `false` | should we enable the GO buildpack pipeline |
| buildpacks.generate.buildpackGoBuildPipeline.name | string | `"buildpack-go-build-pipeline"` | the name of the generated pipeline |
| buildpacks.generate.buildpackJavaBuildPipeline.buildTaskName | string | `"buildpack-java"` | the generated name of the tekton task implementing the "build" step |
| buildpacks.generate.buildpackJavaBuildPipeline.enabled | bool | `false` | should we enable the java buildpack pipeline |
| buildpacks.generate.buildpackJavaBuildPipeline.name | string | `"buildpack-java-build-pipeline"` | the name of the generated pipeline |
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
| images.argocd_cli | string | `"https://github.com/argoproj/argo-cd/releases/download/v2.3.4/argocd-linux-amd64"` | argocd cli downdload URL |
| images.awscli | string | `"docker.io/amazon/aws-cli:2.7.4"` | aws cli image (used for aws ecr auth) |
| images.bash | string | `"docker.io/library/bash:5.1.8"` | bash image (used for various ops in steps) |
| images.git | string | `"alpine/git:v2.32.0"` | git image |
| images.kaniko | string | `"gcr.io/kaniko-project/executor@sha256:b44b0744b450e731b5a5213058792cd8d3a6a14c119cf6b1f143704f22a7c650"` | kaniko image used to build containers containing docker files - v1.8.1, uploaded April 5 2022 |
| images.kubectl | string | `"bitnami/kubectl:1.22.10"` | kubectl cli |
| images.kubeval | string | `"public.ecr.aws/saritasa/kubeval:0.16.1"` | kubeval image - validate Kubernetes manifests |
| images.kustomize | string | `"registry.k8s.io/kustomize/kustomize:v5.0.0"` | kustomize cli |
| images.python | string | `"saritasallc/python3:0.4"` | python image |
| images.sentry_cli | string | `"getsentry/sentry-cli:2.19.1"` | sentry cli image - needs to prepare Sentry releases |
| images.slack | string | `"cloudposse/slack-notifier:0.4.0"` | slack notifier |
| images.yamlfix | string | `"public.ecr.aws/saritasa/yamlfix:1.8.1"` | yamlfix image - format yaml files |
| kaniko.enabled | bool | `false` | should we enable the kaniko pipeline |
| kaniko.postDeployTaskSteps[0].image | string | `"badouralix/curl-jq"` |  |
| kaniko.postDeployTaskSteps[0].imagePullPolicy | string | `"IfNotPresent"` |  |
| kaniko.postDeployTaskSteps[0].name | string | `"argo-events"` |  |
| kaniko.postDeployTaskSteps[0].resources | object | `{}` |  |
| kaniko.postDeployTaskSteps[0].script | string | `"#!/usr/bin/env bash\n\n# add extra params from env and convert them to lowercase to work with this\n# data later in argo workflow\nEXTRA=$(jq -n env | jq 'walk(if type==\"object\" then with_entries(.key|=ascii_downcase) else . end)')\nJSON_PAYLOAD='{\n  \"project\": \"$(params.project)\",\n  \"environment\": \"$(params.environment)\",\n  \"application\": \"$(params.application)\",\n  \"sha\": \"$(params.sha)\",\n  \"extra\": ${EXTRA}\n}'\n\necho \"Payload: $JSON_PAYLOAD\"\n\nOUTPUT=$(curl -s -o /dev/null -w httpcode=%{http_code} --location --request POST \"build-succeed-eventsource-svc.argo-events.svc.cluster.local\" \\\n  --header 'Content-Type: application/json' \\\n  --data-raw \"$JSON_PAYLOAD\")\n\nSTATUS_CODE=$(echo \"${OUTPUT}\" | sed -e 's/.*\\httpcode=//')\nif [ ${STATUS_CODE} -ne 204 ]; then\n    echo \"Curl operation/command failed due to server return code - ${STATUS_CODE}\"\n    exit 1\nfi\n\necho \"Sent 'build-succeed' webhook\"\n"` |  |
| kaniko.postDeployTaskSteps[0].securityContext.privileged | bool | `true` |  |
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
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
