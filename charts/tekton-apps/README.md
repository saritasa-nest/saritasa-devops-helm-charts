
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
 * Written by Saritasa Devops Team, April 2022
 */

```

## `chart.deprecationWarning`

## `chart.name`

saritasa-tekton-apps

## `chart.version`

![Version: 0.2.15-dev.10](https://img.shields.io/badge/Version-0.2.15-dev.10-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.29.0](https://img.shields.io/badge/AppVersion-v0.29.0-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa | <nospam@saritasa.com> | <https://www.saritasa.com/> |

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
- argocd notifications for each app project

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
        storageClassName: gp3
        nodeSelector:
          ops: 'true'
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
              notifications:
                annotations:
                  # In rocks/cloud cluster use slack-token integration:
                  notifications.argoproj.io/subscribe.on-health-degraded.slack: project-vp; project-vp-alarms
                  notifications.argoproj.io/subscribe.on-sync-failed.slack: project-vp-ci; project-vp-alarms
                  notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: project-vp; project-vp-alarms
                  notifications.argoproj.io/subscribe.on-deployed.slack: project-vp-ci
                  # In staging/prod client cluster use webhook integration:
                  notifications.argoproj.io/subscribe.on-health-degraded.project-webhook: enabled
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
                argocd:
                  syncWave: 220
                tekton:
                  workspacePVC: 15Gi
                  buildpacksPVC: 25Gi
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
                argocd:
                  syncWave: 220
                tekton:
                  workspacePVC: 15Gi
                  buildpacksPVC: 25Gi
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
    targetRevision: "0.1.16"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

  ```

  Above helm chart creates a new ArgoCD project for each project in values, for each component in project's components there is created a separate ArgoCD
  application and required for Tekton ci/cd resources (triggerbindings, roles, configmaps, jobs, serviceaccounts, pvcs and etc).

  For each Argocd project, notifications to multiple slack channels with different types of triggers are added. The example above define for each subscription, the slack channels (project-xx, project-xx-ci project-xx-alarms) that should be added by default. This can be modified to add/remove a channel in case of a custom config needed.

  There are two ways of activating notifications, using slack-token integration and using project-webhooks integration.
  The slack-token allows sending to any slack channel where the app is installed, that's why we should only use it in rocks/cloud cluster and not in clients clusters.
  The project-webhook integrations can only send to the channel where it's created in Slack app 'client deployments' (https://api.slack.com/apps/A01LM626QTZ/incoming-webhooks?) and it should be used in staging/prod client clusters.

  # fill below parameters for each `project` block

  - apps[PROJECT].environment - possbility to define custom project's environment, needed for cases when need to deploy `dev` and `prod` envs to the same cluster. For example `xxx` dev
    and prod both deployed in rocks EKS (not required)
  - apps[PROJECT].enabled - boolean value to define whether the project enabled or not (required)
  - apps[PROJECT].argocd.labels - labels which are added to ArgoCD project (required)
  - apps[PROJECT].argocd.namespace - allowed for ArgoCD project namespace (required)
  - apps[PROJECT].argocd.notifications.annotations[] - list of slack channels subscriptions, each with a different trigger
  - apps[PROJECT].argocd.syncWave - ArgoCD project sync wave, i.e. sequence in which project should be synced (not required, default: "200")
  - apps[PROJECT].argocd.sourceRepos[] - source repositories added to ArgoCD project (not required, default: [<apps[PROJECT].kubernetesRepository.url>])
  - apps[PROJECT].argocd.extraDestinationNamespaces[] - adds extra destination namespaces for ArgoCD project to be able to create custom apps within project's kubernetes repo (not required, default: null)
  - apps[PROJECT].mailList - project's team email address (required)
  - apps[PROJECT].devopsMailList - project's devops team email address (required)
  - apps[PROJECT].jiraURL - project's JIRA url (required)
  - apps[PROJECT].tektonURL - link to Tekton pipelineruns used in Tekton ConfigMap as `TEKTON_URL` during Slack notification send (required)
  - apps[PROJECT].slack - project's Slack channel name (required)
  - apps[PROJECT].kubernetesRepository.name - project's kubernetes repository name used in ArgoCD application and Tekton TriggerBinding (may be absent and replaced with
    `apps[PROJECT].components[NAME].argocd` and `apps[PROJECT].argocd.sourceRepos[]` blocks in case if project has no kubernetes repo)
  - apps[PROJECT].kubernetesRepository.branch - project's kubernetes repository branch used in ArgoCD application and Tekton TriggerBinding (may be absent and replaced
    with `apps[PROJECT].components[NAME].argocd` and `apps[PROJECT].argocd.sourceRepos[]` blocks in case if project has no kubernetes repo)
  - apps[PROJECT].kubernetesRepository.url - project's kubernetes repository url used in ArgoCD application and Tekton TriggerBinding (may be absent and replaced with
    `apps[PROJECT].components[NAME].argocd` and `apps[PROJECT].argocd.sourceRepos[]` blocks in case if project has no kubernetes repo)

  Basically we have 2 different types of ci/cd - basic (buildpacks, kaniko) and wordpress ones. So depending on project's component type you will need to fill different parameters.

  # fill below parameters for each `component` block

  - apps[PROJECT].components[NAME].repository - the name of the repository containing the code (may be absent in case of wordpress application without deployment, i.e. bolrdswp, taco,
    saritasa-wordpress-demo)
  - apps[PROJECT].components[NAME].pipeline - the name of the pipeline building the code from the repository above
  - apps[PROJECT].components[NAME].namespace - the name of the namespace for component. Optional parameter
  - apps[PROJECT].components[NAME].argocd.source.syncWave - custom component ArgoCD application sync wave (default: "210")
  - apps[PROJECT].components[NAME].argocd.source.path - path to directory responsible for kubernetes resources creation of the ArgoCD Application (default: kubernetes repo path for basic
    projects "apps/<apps[PROJECT].components[NAME].name>/manifests/<environment>" or "null" for wordpress projects)
  - apps[PROJECT].components[NAME].argocd.source.repoUrl - url of repository which should be used for ArgoCD Application (default: kubernetes repo for basic projects
    "<apps[PROJECT].kubernetesRepository.url>" or `https://charts.bitnami.com/bitnami` for wordpress projects)
  - apps[PROJECT].components[NAME].argocd.source.targetRevision - tag or branch in the repository for ArgoCD Application (default: kubernetes branch for basic projects
    "<apps[PROJECT].kubernetesRepository.branch>" or "11.0.14" for wordpress projects)
  - apps[PROJECT].components[NAME].argocd.ignoreDeploymentReplicasDiff - flag whether this exact ArgoCD application should ignore `Replicas` count differences for deployments. It may be needed for `staging` and `prod` environments which use HPA (default: false)
  - apps[PROJECT].components[NAME].applicationURL - url that should be used in tekton build ConfigMap `APPLICATION_URL` param
  - apps[PROJECT].components[NAME].tektonKubernetesRepoDeployKeyName - name of existing in kubernetes cluster secret with SSH key to kubernetes repository, used in `kustomize` deployment
    step (i.e. addon-backend-deploy-key). This param sets by default to `<project>-kubernetes-aws-deploy-key` if project has `kubernetesRepository` param in values (actual only for basic
    components, not wordpress)
  - apps[PROJECT].components[NAME].eventlistener.template - the name of the trigger template for the component to be used
  - apps[PROJECT].components[NAME].eventlistener.enableWebhookSecret - should you enable the git web hook for this particular app/component in the eventlistener configuration
  - apps[PROJECT].components[NAME].eventlistener.filter - custom filter for the component of the eventlistener
  - apps[PROJECT].components[NAME].eventlistener.extraOverlays - extra overlays to be added into the eventlistener for the component
  - apps[PROJECT].components[NAME].eventlistener.eventTypes - github event types to trigger the ci/cd
  - apps[PROJECT].components[NAME].eventlistener.gitWebhookBranches[] - list of branches, push to which triggers ci/cd
  - apps[PROJECT].components[NAME].extraBuildConfigParams - additional key/values to be added into `build-pipeline-config configmap` ConfigMap associated with the app
  - apps[PROJECT].components[NAME].triggerBinding - values to be added into the TriggerBinding manifest except default ones

  What is important to know is that any key defined in apps[PROJECT].components[NAME].triggerBinding would be added as is
  into the generated triggerbinding associated with your app. However the chart renders some default values based on the values
  in this values.yaml file:

    - application, project, environment, docker_registry, kubernetes_repository_ssh_url, kubernetes_branch, kubernetes_repository_kustomize_path, source_subpath, repository_submodules (for basic components)
    - application, project, environment, namespace (for wordpress components)

  Note: sometimes github repository may contain another github repositories as submodules. These github `submodules` may be public or private. In case of private submodules usage there is a necessity to add
  separate submodules private repos `deploy-keys` to be able to pull them within Tekton build. Currently this feature to pull private github submodules during build doesn't work. So there is added workaround
  for this problem - you can pass `repository_submodules: false` value and it will omit github submodules upload during build process (default value for `repository_submodules` is true, so we try to load
  repo submodules by default). Example:

  ```yaml
  apps:
    - project: xxx
      ...
      components:
        - name: backend
          ...
          triggerBinding:
            - name: repository_submodules
              value: false
  ```

  # fill below parameters block only for `wordpress` components

  - apps[PROJECT].components[NAME].wordpress.image.tag - tag of the wordpress image (default: "6.1.1")
  - apps[PROJECT].components[NAME].wordpress.image.debug - Bitnami debug mode, exposes credentials (default: "true")
  - apps[PROJECT].components[NAME].wordpress.resources - wordpress pod resources params (default: requests.cpu: 100m, requests.memory: 128Mi)
  - apps[PROJECT].components[NAME].wordpress.commonLabels - wordpress pod common labels (default: commonLabels.tech_stack: php, commonLabels.application: wordpress)
  - apps[PROJECT].components[NAME].wordpress.updateStrategy - strategy that should be used for wordpress pod update (default: updateStrategy.type: RollingUpdate,
    updateStrategy.rollingUpdate.maxSurge: 0%, updateStrategy.rollingUpdate.maxUnavailable: 100%, i.e. stop old pod and then create a new one)
  - apps[PROJECT].components[NAME].wordpress.replica_count - wordpress deployment replica count (default: 1)
  - apps[PROJECT].components[NAME].wordpress.nodeSelector - wordpress pod node selector params (default: nodeSelector.tech_stack: php, nodeSelector.pvc: "true")
  - apps[PROJECT].components[NAME].wordpress.podSecurityContext - wordpress pod's security context params (default: bitnami chart defaults)
  - apps[PROJECT].components[NAME].wordpress.containerSecurityContext - wordpress pod container's security context params (default: bitnami chart defaults)
  - apps[PROJECT].components[NAME].wordpress.initContainers - init containers (default: init container for ci/cd purposes)
  - apps[PROJECT].components[NAME].wordpress.extraInitContainers - extra init containers if needed (default: null)
  - apps[PROJECT].components[NAME].wordpress.repositorySshUrl - project's wordpress repository SSH url
  - apps[PROJECT].components[NAME].wordpress.repositoryDeployKey - name of a secret with wordpress repository SSH url (default: "<project_name>-<component_name>-deploy-key")
  - apps[PROJECT].components[NAME].wordpress.repositoryRevision - project's wordpress repository revision/branch (default: null, default branch from repo will be used)
  - apps[PROJECT].components[NAME].wordpress.repositoryUseWPConfig - project's wordpress wp-config.php usage from repository (default: null)
  - apps[PROJECT].components[NAME].wordpress.extraVolumes - extra volumes that might be needed to wordpress pod (default: null)
  - apps[PROJECT].components[NAME].wordpress.extraVolumesMounts - extra volumes mounts that might be needed to wordpress pod (default: null)
  - apps[PROJECT].components[NAME].wordpress.extraEnvVars - extra env variables that might be needed to wordpress pod (default: null)
  - apps[PROJECT].components[NAME].wordpress.extraEnvVarsSecret - secret with extra env variables that might be needed to wordpress pod (default: null)

  - apps[PROJECT].components[NAME].wordpress.ingress.hostname - wordpress ingress hostname (default: "<project_name>.saritasa.rocks", i.e. "taco.saritasa.rocks")
  - apps[PROJECT].components[NAME].wordpress.ingress.annotations - extra wordpress ingress annotations (default: null)
    - apps[PROJECT].components[NAME].wordpress.ingress.basicAuth - basic auth usage flag for wordpress ingress (default: null)
  - apps[PROJECT].components[NAME].wordpress.ingress.authSecret - name of kubernetes secret that should be used in ingress for basic auth, requires basicAuth flag (default: "<project_name>-<compinent_name>-<env>-basic-auth",
    i.e. "taco-wordpress-dev-basic-auth")
  - apps[PROJECT].components[NAME].wordpress.ingress.restrictAccessByIp - whitelist usage flag for wordpress ingress, enabled for any value except 'false' (default: null)
  - apps[PROJECT].components[NAME].wordpress.ingress.extraHosts - list of extra hosts that may be defined in ingress (default: null)
  - apps[PROJECT].components[NAME].wordpress.persistence - optional - pass through [bitnami/wordpress Persistense](https://github.com/bitnami/charts/tree/main/bitnami/wordpress#persistence-parameters) section options
  - apps[PROJECT].components[NAME].wordpress.overrideDatabaseSettings - flag for initial Bitnami script that overrides  settings in DB with values from wp_config.php (default: false)
  - apps[PROJECT].components[NAME].wordpress.externalDatabase - map with settings for wordpress DB host (required)
  - apps[PROJECT].components[NAME].wordpress.externalDatabase.host - wordpress DB host (required)
  - apps[PROJECT].components[NAME].wordpress.externalDatabase.user - wordpress DB user (required)
  - apps[PROJECT].components[NAME].wordpress.externalDatabase.existingSecret - name of existing in kubernetes secret with DB user password (required)
  - apps[PROJECT].components[NAME].wordpress.externalDatabase.database - wordpress DB name (required)
  - apps[PROJECT].components[NAME].wordpress.externalDatabase.port - wordpress DB port (required)
  - apps[PROJECT].components[NAME].wordpress.wordpressSkipInstall - flag to skip bitnami wp init on pod start (default: false)
  - apps[PROJECT].components[NAME].wordpress.existingWordPressConfigurationSecret - secret with wp-config.php (default: "")
  - apps[PROJECT].components[NAME].wordpress.wordpressExtraConfigContent - wordpress extra configs if needed (default: null)
  - apps[PROJECT].components[NAME].wordpress.wordpressBlogName - wordpress blog name (default: <project-name>)
  - apps[PROJECT].components[NAME].wordpress.wordpressTablePrefix - wordpress DB tables prefix (default: wp_)
  - apps[PROJECT].components[NAME].wordpress.wordpressScheme - wordpress access scheme (default: "https")
  - apps[PROJECT].components[NAME].wordpress.wordpressEmail - target for sending emails (default: devops+<client-name>@saritasa.com)
  - apps[PROJECT].components[NAME].wordpress.existingSecret - name of existing in kubernetes secret with wp admin and smtp auth info, should contain sections: 'wordpress-password', 'smtp-password'.
  - apps[PROJECT].components[NAME].wordpress.smtpHost - SMTP host for sending emails (default: mailhog.mailhog.svc.cluster.local)
  - apps[PROJECT].components[NAME].wordpress.smtpPort - SMTP port for sending emails (default: 1025)
  - apps[PROJECT].components[NAME].wordpress.smtpUser - SMTP user for sending emails (default: <project_name>, i.e. taco)
  - apps[PROJECT].components[NAME].wordpress.smtpPassword - SMTP password for sending emails (default: anypassword)

  Example of values with extra `eventlistener` and `extraBuildConfigParams` in component:

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
                notifications:
                  annotations:
                    # In rocks/cloud cluster use slack-token integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-failed.slack: project-xxx-ci; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-deployed.slack: project-xxx-ci
                    # In staging/prod client cluster use webhook integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.project-webhook: enabled
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
      targetRevision: "0.1.16"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  ```

  Example of old application from `saritasa-clients` repo, which has no separate `kubernetes` repository. Here we replace `apps[PROJECT].kubernetesRepository` block with
  `apps[PROJECT].argocd.sourceRepos` and `apps[PROJECT].components[NAME].argocd` block, also it is required to set `apps[PROJECT].components[NAME].tektonKubernetesRepoDeployKeyName`
  in such a case to use correct secret with deploy key as far as there is no kubernetes repo that is used by default.

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
                namespace: xxx
                notifications:
                  annotations:
                    # In rocks/cloud cluster use slack-token integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-failed.slack: project-xxx-ci; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-deployed.slack: project-xxx-ci
                    # In staging/prod client cluster use webhook integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.project-webhook: enabled
                sourceRepos:
                  - git@github.com:saritasa-nest/xxx-backend.git
                  - git@github.com:saritasa-nest/xxx-frontend.git
              mailList: xxx@saritasa.com
              devopsMailList: devops+xxx@saritasa.com
              jiraURL: https://saritasa.atlassian.net/browse/xxx
              tektonURL: https://tekton.saritasa.rocks/#/namespaces/ci/pipelineruns
              slack: client-xxx-ci

              components:
                - name: backend
                  repository: xxx-backend
                  pipeline: buildpack-django-build-pipeline
                  applicationURL: https://api.xxx.site.url
                  argocd:
                    source:
                      path: .kubernetes/manifests/dev
                      repoUrl: git@github.com:saritasa-nest/xxx-backend.git
                      targetRevision: develop
                  eventlistener:
                    template: buildpack-django-build-pipeline-trigger-template
                  tektonKubernetesRepoDeployKeyName: xxx-backend-deploy-key
                  triggerBinding:
                    - name: docker_registry_repository
                      value: xxx.dkr.ecr.us-west-2.amazonaws.com/xxx/backend
                    - name: buildpack_builder_image
                      value: public.ecr.aws/saritasa/buildpacks/google/builder:v1
                    - name: buildpack_runner_image
                      value: public.ecr.aws/saritasa/buildpacks/google/runner:v1
                - name: frontend
                  repository: xxx-frontend
                  pipeline: buildpack-frontend-build-pipeline
                  applicationURL: https://xxx.site.url
                  argocd:
                    source:
                      path: .kubernetes/manifests/dev
                      repoUrl: git@github.com:saritasa-nest/xxx-frontend.git
                      targetRevision: develop
                  eventlistener:
                    template: buildpack-frontend-build-pipeline-trigger-template
                  tektonKubernetesRepoDeployKeyName: xxx-frontend-deploy-key
                  triggerBinding:
                    - name: docker_registry_repository
                      value: xxx.dkr.ecr.us-west-2.amazonaws.com/xxx/frontend
                    - name: buildpack_builder_image
                      value: public.ecr.aws/saritasa/buildpacks/paketo/builder:full
                    - name: buildpack_runner_image
                      value: public.ecr.aws/saritasa/buildpacks/paketo/runner:full
                    - name: source_subpath
                      value: dist/web

      repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
      targetRevision: "0.1.16"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  ```

  Example with creating an ArgoCD project and application with its custom `environment` (case when in common `staging` environment we need to create for some reason project with
  `dev` environment). Here is added an extra `apps[PROJECT].environment` param, which overrides default `environment` in helm values for this project, and
  `apps[PROJECT].components[NAME].eventlistener.gitWebhookBranches` param, which defines that ci/cd should be trigger on push to `develop` branch.

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
            - project: xxx-dev
              environment: dev
              enabled: true
              argocd:
                labels:
                  created-by: xxx
                  ops-main: xxx
                  ops-secondary: xxx
                  pm: xxx
                  tm: xxx
                namespace: xxx-dev
                notifications:
                  annotations:
                    # In rocks/cloud cluster use slack-token integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-failed.slack: project-xxx-ci; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-deployed.slack: project-xxx-ci
                    # In staging/prod client cluster use webhook integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.project-webhook: enabled
              mailList: xxx@saritasa.com
              devopsMailList: devops+xxx@saritasa.com
              jiraURL: https://saritasa.atlassian.net/browse/xxx
              tektonURL: https://tekton.saritasa.rocks/#/namespaces/ci/pipelineruns
              slack: client-xxx-ci
              kubernetesRepository:
                name: xxx-kubernetes-aws
                branch: main
                url: git@github.com:saritasa-nest/xxx-kubernetes-aws.git

              components:
                - name: backend
                  repository: xxx-backend
                  pipeline: buildpack-django-build-pipeline
                  applicationURL: https://xxx.site.url
                  eventlistener:
                    template: buildpack-django-build-pipeline-trigger-template
                    gitWebhookBranches:
                      - develop
                  triggerBinding:
                    - name: docker_registry_repository
                      value: xxx.dkr.ecr.us-west-2.amazonaws.com/xxx/backend
                    - name: buildpack_builder_image
                      value: public.ecr.aws/saritasa/buildpacks/google/builder:v1
                    - name: buildpack_runner_image
                      value: public.ecr.aws/saritasa/buildpacks/google/runner:v1

      repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
      targetRevision: "0.1.16"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  ```

  Also there might a situation that you would like to provision custom utility ArgoCD Application in argo-cd from project's kubernetes repo (for example VP project provisions
  like this `jitsi` application). To reach this you might need to add an extra destination namespace to ArgoCD Project, you should use
  `apps[PROJECT].argocd.extraDestinationNamespaces[]` param for that like in below example.

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
            - project: xxx-dev
              environment: dev
              enabled: true
              argocd:
                labels:
                  created-by: xxx
                  ops-main: xxx
                  ops-secondary: xxx
                  pm: xxx
                  tm: xxx
                namespace: xxx-dev
                extraDestinationNamespaces:
                  - argo-cd
                notifications:
                  annotations:
                    # In rocks/cloud cluster use slack-token integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-failed.slack: project-xxx-ci; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-deployed.slack: project-xxx-ci
                    # In staging/prod client cluster use webhook integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.project-webhook: enabled
              mailList: xxx@saritasa.com
              devopsMailList: devops+xxx@saritasa.com
              jiraURL: https://saritasa.atlassian.net/browse/xxx
              tektonURL: https://tekton.saritasa.rocks/#/namespaces/ci/pipelineruns
              slack: client-xxx-ci
              kubernetesRepository:
                name: xxx-kubernetes-aws
                branch: main
                url: git@github.com:saritasa-nest/xxx-kubernetes-aws.git

              components:
                - name: backend
                  repository: xxx-backend
                  pipeline: buildpack-django-build-pipeline
                  applicationURL: https://xxx.site.url
                  eventlistener:
                    template: buildpack-django-build-pipeline-trigger-template
                    gitWebhookBranches:
                      - develop
                  triggerBinding:
                    - name: docker_registry_repository
                      value: xxx.dkr.ecr.us-west-2.amazonaws.com/xxx/backend
                    - name: buildpack_builder_image
                      value: public.ecr.aws/saritasa/buildpacks/google/builder:v1
                    - name: buildpack_runner_image
                      value: public.ecr.aws/saritasa/buildpacks/google/runner:v1

      repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
      targetRevision: "0.1.16"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  ```

  If you want to enable ignoring deployment replicas count differences in ArgoCD application of your component add `apps[PROJECT].components[NAME].argocd.ignoreDeploymentReplicasDiff: true` flag like in the below example (it may be needed for `staging` and `prod` envs, where you have horizontal pod autoscheduling - HPA):

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
            - project: xxx-dev
              environment: dev
              enabled: true
              argocd:
                labels:
                  created-by: xxx
                  ops-main: xxx
                  ops-secondary: xxx
                  pm: xxx
                  tm: xxx
                namespace: xxx-dev
                extraDestinationNamespaces:
                  - argo-cd
                notifications:
                  annotations:
                    # In rocks/cloud cluster use slack-token integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-failed.slack: project-xxx-ci; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-deployed.slack: project-xxx-ci
                    # In staging/prod client cluster use webhook integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.project-webhook: enabled
              mailList: xxx@saritasa.com
              devopsMailList: devops+xxx@saritasa.com
              jiraURL: https://saritasa.atlassian.net/browse/xxx
              tektonURL: https://tekton.saritasa.rocks/#/namespaces/ci/pipelineruns
              slack: client-xxx-ci
              kubernetesRepository:
                name: xxx-kubernetes-aws
                branch: main
                url: git@github.com:saritasa-nest/xxx-kubernetes-aws.git

              components:
                - name: backend
                  repository: xxx-backend
                  argocd:
                    ignoreDeploymentReplicasDiff: true
                  pipeline: buildpack-django-build-pipeline
                  applicationURL: https://xxx.site.url
                  eventlistener:
                    template: buildpack-django-build-pipeline-trigger-template
                    gitWebhookBranches:
                      - develop
                  triggerBinding:
                    - name: docker_registry_repository
                      value: xxx.dkr.ecr.us-west-2.amazonaws.com/xxx/backend
                    - name: buildpack_builder_image
                      value: public.ecr.aws/saritasa/buildpacks/google/builder:v1
                    - name: buildpack_runner_image
                      value: public.ecr.aws/saritasa/buildpacks/google/runner:v1

      repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
      targetRevision: "0.1.16"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  ```

  If you need to pass custom project's name for Sentry, use `sentry_project_name` parameter in Trigger Binding as in example below. By
  default `sentry_project_name` is configured as  `<project_name>-<component_name>` if custom value is not passed.

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
          environment: dev
          ...
          apps:
            - project: xxx-dev
              enabled: true
              argocd:
                labels:
                  created-by: xxx
                  ops-main: xxx
                  ops-secondary: xxx
                  pm: xxx
                  tm: xxx
                namespace: xxx-dev
                notifications:
                  annotations:
                    # In rocks/cloud cluster use slack-token integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-failed.slack: project-xxx-ci; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-deployed.slack: project-xxx-ci
                    # In staging/prod client cluster use webhook integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.project-webhook: enabled
              mailList: xxx@saritasa.com
              devopsMailList: devops+xxx@saritasa.com
              jiraURL: https://saritasa.atlassian.net/browse/xxx
              tektonURL: https://tekton.saritasa.rocks/#/namespaces/ci/pipelineruns
              slack: client-xxx-ci
              kubernetesRepository:
                name: xxx-kubernetes-aws
                branch: main
                url: git@github.com:saritasa-nest/xxx-kubernetes-aws.git

              components:
                - name: backend
                  repository: xxx-backend
                  pipeline: buildpack-django-build-pipeline
                  applicationURL: https://xxx.site.url
                  eventlistener:
                    template: buildpack-django-build-pipeline-trigger-template
                    gitWebhookBranches:
                      - develop
                  triggerBinding:
                    - name: docker_registry_repository
                      value: xxx.dkr.ecr.us-west-2.amazonaws.com/xxx/backend
                    - name: buildpack_builder_image
                      value: public.ecr.aws/saritasa/buildpacks/google/builder:v1
                    - name: buildpack_runner_image
                      value: public.ecr.aws/saritasa/buildpacks/google/runner:v1
                    - name: sentry_project_name
                      value: custom-xxx-dev-backend

      repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
      targetRevision: "0.1.16"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  ```

  If you want use to some other file instead of original `project.toml` or `buildpack.yml` files (i.e. ovio-api-project.toml, ovio-api-buildpack.yml)
  you will need to add `buildpack_config_filename` and `project_config_filename` Trigger Binding params as in example below:

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
            - project: xxx-dev
              enabled: true
              argocd:
                labels:
                  created-by: xxx
                  ops-main: xxx
                  ops-secondary: xxx
                  pm: xxx
                  tm: xxx
                namespace: xxx-dev
                notifications:
                  annotations:
                    # In rocks/cloud cluster use slack-token integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-failed.slack: project-xxx-ci; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-deployed.slack: project-xxx-ci
                    # In staging/prod client cluster use webhook integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.project-webhook: enabled
              mailList: xxx@saritasa.com
              devopsMailList: devops+xxx@saritasa.com
              jiraURL: https://saritasa.atlassian.net/browse/xxx
              tektonURL: https://tekton.saritasa.rocks/#/namespaces/ci/pipelineruns
              slack: client-xxx-ci
              kubernetesRepository:
                name: xxx-kubernetes-aws
                branch: main
                url: git@github.com:saritasa-nest/xxx-kubernetes-aws.git

              components:
                - name: backend
                  repository: xxx-backend
                  pipeline: buildpack-django-build-pipeline
                  applicationURL: https://xxx.site.url
                  eventlistener:
                    template: buildpack-django-build-pipeline-trigger-template
                    gitWebhookBranches:
                      - develop
                  triggerBinding:
                    - name: docker_registry_repository
                      value: xxx.dkr.ecr.us-west-2.amazonaws.com/xxx/backend
                    - name: buildpack_builder_image
                      value: public.ecr.aws/saritasa/buildpacks/google/builder:v1
                    - name: buildpack_runner_image
                      value: public.ecr.aws/saritasa/buildpacks/google/runner:v1
                    - name: buildpack_config_filename
                      value: ovio-api-buildpack.yml
                    - name: project_config_filename
                      value: ovio-api-project.toml

      repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
      targetRevision: "0.1.16"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  ```

  Simple wordpress application example filled by default:

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
                namespace: xxx
                notifications:
                  annotations:
                    # In rocks/cloud cluster use slack-token integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-failed.slack: project-xxx-ci; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-deployed.slack: project-xxx-ci
                    # In staging/prod client cluster use webhook integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.project-webhook: enabled
                sourceRepos:
                  - https://charts.bitnami.com/bitnami
              mailList: xxx@saritasa.com
              devopsMailList: devops+xxx@saritasa.com
              jiraURL: https://saritasa.atlassian.net/browse/xxx
              tektonURL: https://tekton.saritasa.rocks/#/namespaces/ci/pipelineruns
              slack: client-xxx-ci

              components:
                - name: wordpress
                  repository: xxx-wordpress
                  pipeline: wordpress-build-pipeline
                  applicationURL: https://xxx.site.url
                  argocd:
                    ignoreDeploymentReplicasDiff: true
                    source:
                      targetRevision: 15.0.16
                  wordpress:
                    repository_ssh_url: git@github.com:saritasa-nest/xxx-wordpress.git
                    externalDatabase:
                      host: xxx.xxx.us-west-2.rds.amazonaws.com
                      user: xxx-wordpress-user-dev
                      existingSecret: xxx-wordpress-dev-externaldb
                      database: xxx-wordpress-dev
                    persistence:
                      storageClass: gp3
                  eventlistener:
                    template: wordpress-build-pipeline-trigger-template

      repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
      targetRevision: "0.1.16"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  ```

  Simple wordpress application example filled by default, but without ci/cd:

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
                namespace: xxx
                notifications:
                  annotations:
                    # In rocks/cloud cluster use slack-token integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-failed.slack: project-xxx-ci; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-deployed.slack: project-xxx-ci
                    # In staging/prod client cluster use webhook integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.project-webhook: enabled
                sourceRepos:
                  - https://charts.bitnami.com/bitnami
              mailList: xxx@saritasa.com
              devopsMailList: devops+xxx@saritasa.com
              jiraURL: https://saritasa.atlassian.net/browse/xxx
              tektonURL: https://tekton.saritasa.rocks/#/namespaces/ci/pipelineruns
              slack: client-xxx-ci

              components:
                - name: wordpress
                  repository: xxx-wordpress
                  pipeline: wordpress-build-pipeline
                  applicationURL: https://xxx.site.url
                  wordpress:
                    ci: false
                    externalDatabase:
                      host: xxx.xxx.us-west-2.rds.amazonaws.com
                      user: xxx-wordpress-user-dev
                      existingSecret: xxx-wordpress-dev-externaldb
                      database: xxx-wordpress-dev
                    persistence:
                      storageClass: gp3
                  eventlistener:
                    template: wordpress-build-pipeline-trigger-template

      repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
      targetRevision: "0.1.16"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  ```

  More complicated example of project containing `wordpress` and `frontend` component.
  If you need to deploy wordpress component in a namespace different from ArgoCD project's one (i.e. `wordpress`), you need to add `extraDestinationNamespaces: ["wordpress"]` and `argocd.namespace=wordpress`, like in the example below
  Also defined sample of all extra wordpress params that could be set:

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
                namespace: xxx
                extraDestinationNamespaces:
                  - wordpress
                notifications:
                  annotations:
                    # In rocks/cloud cluster use slack-token integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-failed.slack: project-xxx-ci; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: project-xxx; project-xxx-alarms
                    notifications.argoproj.io/subscribe.on-deployed.slack: project-xxx-ci
                    # In staging/prod client cluster use webhook integration:
                    notifications.argoproj.io/subscribe.on-health-degraded.project-webhook: enabled
                sourceRepos:
                  - https://charts.bitnami.com/bitnami
                  - git@github.com:saritasa-nest/xxx-kubernetes-aws.git
              mailList: xxx@saritasa.com
              devopsMailList: devops+xxx@saritasa.com
              jiraURL: https://saritasa.atlassian.net/browse/xxx
              tektonURL: https://tekton.saritasa.rocks/#/namespaces/ci/pipelineruns
              slack: client-xxx-ci
              kubernetesRepository:
                name: xxx-kubernetes-aws
                branch: main
                url: git@github.com:saritasa-nest/xxx-kubernetes-aws.git

              components:
                - name: wordpress
                  repository: xxx-wordpress
                  pipeline: wordpress-build-pipeline
                  applicationURL: https://xxx.site.url
                  argocd:
                    source:
                    targetRevision: 16.1.14
                    destinationNamespace: wordpress
                  wordpress:
                    imageTag: "5.8.1"
                    repository_ssh_url: "git@github.com:saritasa-nest/xxx-wordpress.git"
                    resources:
                      requests:
                        memory: 512Mi
                        cpu: 100m
                    commonLabels:
                      tech_stack: php
                      application: wordpress
                    wordpressTablePrefix: "qbf_"
                    existingSecret: xxx-wordpress
                    updateStrategy:
                      type: RollingUpdate
                      rollingUpdate:
                        maxSurge: 25%
                        maxUnavailable: 25%
                    smtp:
                      host: mysmtp.site.url
                      port: 1010
                      user: myuser
                      password: mypassword
                    nodeSelector:
                      tech_stack: php
                      pvc: "true"
                    podSecurityContext:
                      enabled: true
                      fsGroup: 1001
                    containerSecurityContext:
                      enabled: true
                      runAsUser: 1001
                    ci: true
                    extraInitContainers:
                      - name: build-frontend
                        image: node:14
                        imagePullPolicy: Always
                        command:
                          - bash
                          - -c
                          - |
                            git -c core.sshCommand="ssh -i ~/.ssh/id_rsa" clone git@github.com:saritasa-nest/xxx.git -b develop ~/xxx
                            cd ~/xxx
                            npm install
                            npm run build:embedded-questionnaire
                            cp -Rf $(pwd)/dist/* /bitnami/wordpress/wp-content/
                            echo "Copied built files into /bitnami/wordpress/wp-content/"
                            ls -la /bitnami/wordpress/wp-content/
                            echo "Done BUILD FRONTEND"
                        volumeMounts:
                        - mountPath: /bitnami/wordpress
                          name: wordpress-data
                          subPath: wordpress
                        - mountPath: /home/node/.ssh/id_rsa
                          name: xxx-ssh-key
                          subPath: ssh-privatekey
                        - mountPath: /home/node/.ssh/known_hosts
                          name: github-known-hosts
                          subPath: config.ssh
                        securityContext:
                          runAsNonRoot: true
                          runAsUser: 1000
                          allowPrivilegeEscalation: false
                    extraVolumesSshKeySecret: xxx-wordpress-deploy-key
                    extraVolumes:
                    - name: xxx-ssh-key
                      secret:
                        secretName: xxx-deploy-key
                    ingress:
                      hostname: test.xxx.site.url
                      annotations:
                        kubernetes.io/ingress.class: "nginx"
                        cert-manager.io/cluster-issuer: "letsencrypt-prod"
                        nginx.ingress.kubernetes.io/proxy-body-size: 100m
                        nginx.ingress.kubernetes.io/client-max-body-size: 100m
                        nginx.ingress.kubernetes.io/server-snippet: |-
                          add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
                        nginx.ingress.kubernetes.io/whitelist-source-range: |
                          35.85.92.224/32,
                          100.21.244.185/32
                      extraHosts:
                        - name: test.xxx.site.url
                          path: /wp-admin
                    externalDatabase:
                      host: "xxx.xxx.us-west-2.rds.amazonaws.com"
                      user: "xxx-wp-user-dev"
                      existingSecret: "xxx-wordpress-dev-externaldb"
                      database: "xxx-wp-dev"
                    wordpressExtraConfigContent: |
                      @ini_set('WP_MEMORY_LIMIT', '512M');
                      @ini_set('ALLOW_UNFILTERED_UPLOADS', true);
                    extraEnvVars:
                      KEY: VALUE
                    persistence:
                      size: 5Gi
                      storageClass: gp3
                  eventlistener:
                    template: wordpress-build-pipeline-trigger-template

                - name: frontend
                  repository: xxx-frontend
                  pipeline: buildpack-frontend-build-pipeline
                  applicationURL: https://app.xxx.site.url
                  eventlistener:
                    template: buildpack-frontend-build-pipeline-trigger-template
                  triggerBinding:
                    - name: docker_registry_repository
                      value: xxx.dkr.ecr.us-west-2.amazonaws.com/xxx/frontend
                    - name: buildpack_builder_image
                      value: public.ecr.aws/saritasa/buildpacks/paketo/builder:full
                    - name: buildpack_runner_image
                      value: public.ecr.aws/saritasa/buildpacks/paketo/runner:full
                    - name: source_subpath
                      value: dist

      repoURL: https://saritasa-nest.github.io/saritasa-devops-helm-charts/
      targetRevision: "0.1.16"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  ```

If you want to bypass authentication for Wordpress (and other legacy projects) for certain list of IPs
(ex. in office network or inside VPN), you can specify list of whitelist IP masks (in [Nginx format](https://nginx.org/en/docs/http/ngx_http_access_module.html))

```yaml
whitelistIP: |
  35.85.92.224/32,
  35.82.81.78/32
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
| eventlistener.suffix | string | `""` | unique suffix (in case there are several eventlisteners in the cluster) |
| gitBranchPrefixes[0] | string | `"develop"` |  |
| nodeSelector | string | `""` | node selector for event listener pod |
| runPostInstallMountPvcJob | bool | `false` | run job that will mount created (but not bound) PVCs in order for argocd to mark the app as "healthy" |
| serviceAccount.create | string | `"true"` |  |
| serviceAccount.name | string | `"build-bot-sa"` |  |
| slack.imagesLocation | string | `"https://saritasa-rocks-ci.s3.us-west-2.amazonaws.com"` | slack notification images (s3 bucket prefix) |
| slack.prefix | string | `"client"` | channel prefix |
| slack.suffix | string | `"ci"` | channel suffix |
| storageClassName | string | `"gp2"` | storage class for PVCs associated with the apps |
| whitelistIP | string | `""` | Comma-separated list of IP masks to bypass access limitation (if applicable, ex. for legacy projects protected with basic authentication) |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)
