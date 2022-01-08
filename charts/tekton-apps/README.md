
# saritasa-tekton-apps

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

saritasa-tekton-apps

## `chart.version`

![Version: 0.1.15](https://img.shields.io/badge/Version-0.1.15-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.28.2](https://img.shields.io/badge/AppVersion-v0.28.2-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa | nospam@saritasa.com | https://www.saritasa.com/ |

## `chart.description`

A Helm chart for tekton apps (rbac, eventlistener)

Implements:
- dynamic records for eventlistener
- PVCs
- RBAC
- configmaps for each app
- triggerbindings for each app
- kubernetes job to make sure the PVCs are bound and argocd marks the app as healthy
- argocd project for each app
- argocd application for each app component

## `example usage with argocd`

Install the chart:

```
helm repo add saritasa https://saritasa-nest.github.io/saritasa-devops-helm-charts/
```

then declare dynamic list of projects (and associated components of that project like backend, api, frontend, etc) that would be dynamically
added into the tekton's eventlistener manifest.

Each component should be a separate git repository.

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tekton-apps
  namespace: argo-cd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
    argocd.argoproj.io/sync-wave: "41"
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: ci
  project: default
  source:
    chart: saritasa-tekton-apps
    helm:
      values: |
        environment: staging

        gitBranchPrefixes:
          - staging

        storageClassName: gp2

        aws:
          region: "us-west-2"
          dns: staging.site.com

        defaultRegistry: xxx.dkr.ecr.us-west-2.amazonaws.com

        argocd:
          server: deploy.staging.site.com

        eventlistener:
          enableWebhookSecret: true

        apps:
          - project: vp
            enabled: true
            argocd:
              labels:
                created-by: xxx
                ops-main: xxx
                ops-secondary: xxx
                pm: xxx
                tm: xxx
              namespace: prod
            mailList: vp@site.com
            devopsMailList: devops+vp@site.com
            jiraURL: https://site.atlassian.net/browse/vp
            tektonURL: https://tekton.staging.site.com/#/namespaces/ci/pipelineruns
            slack: client-vp-ci
            kubernetesRepository:
              name: vp-kubernetes-aws
              branch: main
              url: git@github.com:org-name/vp-kubernetes-aws.git

            components:
              - name: backend
                repository: vp-backend
                pipeline: buildpack-django-build-pipeline
                applicationURL: https://api.staging.site.com
                eventlistener:
                  template: buildpack-django-build-pipeline-trigger-template
                triggerBinding:
                  - name: docker_registry_repository
                    value: xxx.dkr.ecr.us-west-2.amazonaws.com/vp/staging/backend
                  - name: buildpack_builder_image
                    value: xxx.dkr.ecr.us-west-2.amazonaws.com/vp/staging/buildpacks/google/builder:v1
                  - name: buildpack_runner_image
                    value: xxx.dkr.ecr.us-west-2.amazonaws.com/vp/staging/buildpacks/google/runner:v1

              - name: frontend
                repository: vp-frontend
                pipeline: buildpack-frontend-build-pipeline
                applicationURL: https://staging.site.com
                eventlistener:
                  template: buildpack-frontend-build-pipeline-trigger-template
                triggerBinding:
                  - name: docker_registry_repository
                    value: xxx.dkr.ecr.us-west-2.amazonaws.com/vp/staging/frontend
                  - name: buildpack_builder_image
                    value: xxx.dkr.ecr.us-west-2.amazonaws.com/vp/staging/buildpacks/paketo/builder:full
                  - name: buildpack_runner_image
                    value: xxx.dkr.ecr.us-west-2.amazonaws.com/vp/staging/buildpacks/paketo/runner:full
                  - name: source_subpath
                    value: dist/web

        # make sure PVCs are bound after the chart is synced
        # by temporarily mount them into short-live job.
        runPostInstallMountPvcJob: false

    repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
    targetRevision: "0.1.14"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

  ```

  What is important to know is that any key defined in apps[PROJECT].components[NAME].triggerBinding would be added as is
  into the generated triggerbinding associated with your app. However the chart renders some default values - such as
  application, environment, docker_registry based on the values in this values.yaml file.

  - apps[PROJECT].components[NAME].repository - the name of the repository containing the code
  - apps[PROJECT].components[NAME].pipeline - the name of the pipeline building the code in the repository above
  - apps[PROJECT].components[NAME].eventlistener.template - the name of the trigger template for the component to be used
  - apps[PROJECT].components[NAME].eventlistener.enableWebhookSecret - should you enable the git web hook for this particular app/component in the eventlistener configuration
  - apps[PROJECT].components[NAME].eventlistener.filter - custom filter for the component of the eventlistener
  - apps[PROJECT].components[NAME].eventlistener.extraOverlays - extra overlays to be added into the eventlistener for the component
  - apps[PROJECT].components[NAME].eventlistener.eventTypes - github event types to trigger the ci/cd
  - apps[PROJECT].components[NAME].extraBuildConfigParams - additional key/values to be added into `build-pipeline-config configmap` ConfigMap associated with the app
  - apps[PROJECT].components[NAME].triggerBinding - values to be added into the TriggerBinding manifest

  an example of argocd app with the additional params above:

  ```yaml
  apiVersion: argoproj.io/v1alpha1
  kind: Application
  metadata:
    name: tekton-apps
    namespace: argo-cd
    finalizers:
    - resources-finalizer.argocd.argoproj.io
    annotations:
      argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
      argocd.argoproj.io/sync-wave: "41"
  spec:
    destination:
      server: https://kubernetes.default.svc
      namespace: ci
    project: default
    source:
      chart: saritasa-tekton-apps
      helm:
        values: |
          environment: staging

          gitBranchPrefixes:
            - staging

          storageClassName: gp2

          aws:
            region: "us-west-2"
            dns: staging.site.com

          defaultRegistry: xxx.dkr.ecr.us-west-2.amazonaws.com

          argocd:
            server: deploy.staging.site.com

          eventlistener:
            enableWebhookSecret: true

          apps:
            - project: xxx
              enabled: true
              argocd:
                labels:
                  created-by: xxx
                  ops-main: xxx
                  ops-secondary: xxx
                  pm: xxx
                  tm: xxx
                namespace: prod
              mailList: xxx@saritasa.com
              devopsMailList: devops+xxx@saritasa.com
              jiraURL: https://saritasa.atlassian.net/browse/xxx
              tektonURL: https://tekton.site.com/#/namespaces/ci/pipelineruns
              slack: client-xxx-ci
              kubernetesRepository:
                name: xxx-kubernetes-aws
                branch: main
                url: git@github.com:saritasa-nest/xxx-kubernetes-aws.git

              components:
                - name: backend
                  repository: xxx-backend
                  pipeline: buildpack
                  applicationURL: https://api.site.com
                  eventlistener:
                    template: buildpack-backend-build-pipeline-trigger-template
                  extraBuildConfigParams: # what additional K/V pairs you want to add into the build-pipeline-config configmap
                    KEY: value
                  triggerBinding:
                    - name: docker_registry_repository
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/backend
                    - name: buildpack_builder_image
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/buildpacks/google/builder:v1
                    - name: buildpack_runner_image
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/buildpacks/google/runner:v1

                - name: frontend
                  repository: xxx-frontend
                  pipeline: buildpack
                  applicationURL: https://site.com
                  eventlistener:
                    enableWebhookSecret: false
                    filter: (body.ref.startsWith('refs/heads/develop') || body.ref.startsWith('refs/heads/release/'))
                    template: buildpack-frontend-build-pipeline-trigger-template
                    extraOverlays: []
                    # - key: truncated_sha
                    #   expression: "body.head_commit.id.truncate(7)"
                    eventTypes: ["pull_request", "push"]
                  extraBuildConfigParams: {}
                  triggerBinding:
                    - name: docker_registry_repository
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/frontend
                    - name: buildpack_builder_image
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/buildpacks/paketo/builder:full
                    - name: buildpack_runner_image
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/buildpacks/paketo/runner:full
                    - name: source_subpath
                      value: dist/web

          # make sure PVCs are bound after the chart is synced
          # by temporarily mount them into short-live job.
          runPostInstallMountPvcJob: false

      repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
      targetRevision: "0.1.14"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true

  ```

  This chart also has flexible implementation to generate ArgoCD Project and Application manifests. There are below additional
  parameters, which allow you to override default helm chart generation behavior.

  Project extra vars

  - apps[PROJECT].argocd.syncWave - set custom Project sync wave (default: "200")
  - apps[PROJECT].argocd.sourceRepos[] - set custom Project source repositories as list of strings
    (default: [<apps[PROJECT].kubernetesRepository.url>])

  Application extra vars

  - apps[PROJECT].components[NAME].argocd.appName - set custom Application name for the component
    (default: "<apps[PROJECT].project>-<apps[PROJECT].components[NAME].name>-<environment>")
  - apps[PROJECT].components[NAME].argocd.syncWave - set custom Application sync wave (default: "210")
  - apps[PROJECT].components[NAME].argocd.source.path - set custom Application source path
    (default: "apps/<apps[PROJECT].components[NAME].name>/manifests/<environment>")
  - apps[PROJECT].components[NAME].argocd.source.repoUrl - set custom Application source repository url
    (default: "<apps[PROJECT].kubernetesRepository.url>")
  - apps[PROJECT].components[NAME].argocd.source.targetRevision - set custom Application source
    repository target revision - branch or tag (default: "<apps[PROJECT].kubernetesRepository.branch>")

  Example of helm chart with all extra parameters in `apps` section:

  ```yaml
  apiVersion: argoproj.io/v1alpha1
  kind: Application
  metadata:
    name: tekton-apps
    namespace: argo-cd
    finalizers:
    - resources-finalizer.argocd.argoproj.io
    annotations:
      argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
      argocd.argoproj.io/sync-wave: "41"
  spec:
    destination:
      server: https://kubernetes.default.svc
      namespace: ci
    project: default
    source:
      chart: saritasa-tekton-apps
      helm:
        values: |
          environment: staging
          ...
          apps:
            - project: xxx
              enabled: true
              argocd:
                labels:
                  created-by: xxx
                  ops-main: xxx
                  ops-secondary: xxx
                  pm: xxx
                  tm: xxx
                namespace: prod
                syncWave: "200"
                sourceRepos:
                  - git@github.com:saritasa-nest/custom-repo-1.git
                  - git@github.com:saritasa-nest/custom-repo-2.git
              mailList: xxx@saritasa.com
              devopsMailList: devops+xxx@saritasa.com
              jiraURL: https://saritasa.atlassian.net/browse/xxx
              tektonURL: https://tekton.site.com/#/namespaces/ci/pipelineruns
              slack: client-xxx-ci
              kubernetesRepository:
                name: xxx-kubernetes-aws
                branch: main
                url: git@github.com:saritasa-nest/xxx-kubernetes-aws.git

              components:
                - name: backend
                  argocd:
                    appName: custom-backend-app-name
                    syncWave: "210"
                    source:
                      path: "custom/dir"
                      repoUrl: git@github.com:saritasa-nest/custom-repo-1.git
                      targetRevision: custom-v1
                  repository: xxx-backend
                  pipeline: buildpack
                  applicationURL: https://api.site.com
                  eventlistener:
                    template: buildpack-backend-build-pipeline-trigger-template
                  extraBuildConfigParams: # what additional K/V pairs you want to add into the build-pipeline-config configmap
                    KEY: value
                  triggerBinding:
                    - name: docker_registry_repository
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/backend
                    - name: buildpack_builder_image
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/buildpacks/google/builder:v1
                    - name: buildpack_runner_image
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/buildpacks/google/runner:v1

                - name: frontend
                  argocd:
                    appName: custom-frontend-app-name
                    syncWave: "210"
                    source:
                      path: "custom/dir"
                      repoUrl: git@github.com:saritasa-nest/custom-repo-1.git
                      targetRevision: custom-v1
                  repository: xxx-frontend
                  pipeline: buildpack
                  applicationURL: https://site.com
                  eventlistener:
                    enableWebhookSecret: false
                    filter: (body.ref.startsWith('refs/heads/develop') || body.ref.startsWith('refs/heads/release/'))
                    template: buildpack-frontend-build-pipeline-trigger-template
                    extraOverlays: []
                    # - key: truncated_sha
                    #   expression: "body.head_commit.id.truncate(7)"
                    eventTypes: ["pull_request", "push"]
                  extraBuildConfigParams: {}
                  triggerBinding:
                    - name: docker_registry_repository
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/frontend
                    - name: buildpack_builder_image
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/buildpacks/paketo/builder:full
                    - name: buildpack_runner_image
                      value: XXX.dkr.ecr.us-west-2.amazonaws.com/xxx/dev/buildpacks/paketo/runner:full
                    - name: source_subpath
                      value: dist/web

      repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
      targetRevision: "0.1.14"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  ```

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apps | list | `[]` | list of projects and the project's apps to be triggered |
| argocd.rootPath | string | `"/"` | argocd root path (web URL root path) |
| argocd.server | string | `"deploy.site.com"` | argocd public URL |
| aws | object | `{}` | aws configuration |
| defaultRegistry | string | `""` | default docker registry ex: XXX.dkr.ecr.us-west-2.amazonaws.com |
| environment | string | `""` | environment these apps are handling possible values: dev, staging, prod |
| eventlistener.enableWebhookSecret | bool | `true` | should we enable eventlistener for tekton triggers? |
| eventlistener.extraOverlays | list | `[]` | should we add additional overlays for each app running under trigger? |
| gitBranchPrefixes[0] | string | `"develop"` |  |
| runPostInstallMountPvcJob | bool | `false` | run job that will mount created (but not bound) PVCs in order for argocd to mark the app as "healthy" |
| serviceAccount.name | string | `"build-bot-sa"` |  |
| slack.imagesLocation | string | `"https://saritasa-rocks-ci.s3.us-west-2.amazonaws.com"` | slack notification images (s3 bucket prefix) |
| slack.prefix | string | `"client"` | channel prefix |
| slack.suffix | string | `"ci"` | channel suffix |
| storageClassName | string | `"gp2"` | storage class for PVCs associated with the apps |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
