# ┌──────────────────────────────────────────────────────────────────────────────┐
# │  Default params for pipelines                                                │
# │                                                                              │
# └──────────────────────────────────────────────────────────────────────────────┘
{{- define "pipeline.defaultParams" -}}
- name: application
  type: string
  description: name of the argocd application we're going to deploy/sync

- name: sha
  type: string
  description: sha commit ID of the image deployed in cluster

- name: head_commit
  type: string
  description: full SHA commit ID

- name: head_commit_message
  type: string
  description: description of the commit (by developer)

- name: pusher_name
  type: string
  description: author name

- name: pusher_email
  type: string
  description: author email

- name: pusher_avatar
  type: string
  description: author url avatar image

- name: pusher_url
  type: string
  description: author link to profile

- name: repository_url
  type: string
  description: git repository https url

- name: environment
  type: string
  description: environment name of the app being built, i.e. dev/staging/prod

- name: branch
  type: string
  description: git branch
{{- end}}

{{- define "trigger-template.defaultParams" -}}
- name: application
  description: name of the argocd application we're going to deploy/sync

- name: sha
  description: sha commit ID of the image deployed in cluster

- name: head_commit
  description: full SHA commit ID

- name: head_commit_message
  description: description of the commit (by developer)

- name: pusher_name
  description: author name

- name: pusher_email
  description: author email

- name: pusher_avatar
  description: author url avatar image

- name: pusher_url
  description: author link to profile

- name: repository_url
  description: git repository https url

- name: environment
  description: environment name of the app being built, i.e. dev/staging/prod

- name: project
  description: name of the project, which component is deployed

- name: component
  description: name of the application component, which is deployed

- name: component_name
  description: component name

- name: branch
  description: git branch

- name: kubernetes_repository_ssh_url
  description: git repository ssh url for kubernetes manifests repo
{{- end}}


# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Default params for pipelines where we update kubernetes-aws repository       │
# │ with new version of the image from the docker registry                       │
# │                                                                              │
# └──────────────────────────────────────────────────────────────────────────────┘
{{- define "pipeline.defaultDockerKubernetesParams" -}}
- name: docker_registry
  type: string
  description: private docker registry address

- name: docker_registry_repository
  type: string
  description: private docker registry repository address

- name: kubernetes_repository_kustomize_path
  type: string
  description: overlay path for kustomize call

- name: kubernetes_branch
  type: string
  default: main
  description: git branch for kustomize managed git repo
{{- end}}

{{- define "trigger-template.defaultDockerKubernetesParams" -}}
- name: docker_registry
  description: private docker registry address

- name: docker_registry_repository
  description: private docker registry repository address

- name: kubernetes_repository_kustomize_path
  description: overlay path for kustomize call

- name: kubernetes_branch
  default: main
  description: git branch for kustomize managed git repo
{{- end}}


# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Default bound params for trigger template that are collected from the        │
# │ triggerbindings.                                                             │
# │ Accepts two arguments:                                                       │
# │ - docker (bool)                                                              │
# │ - kubernetes (bool)                                                          │
# │                                                                              │
# └──────────────────────────────────────────────────────────────────────────────┘
{{- define "pipeline.defaultTTBoundParams" -}}
- name: "application"
  value: "$(tt.params.application)"
- name: sha
  value: "$(tt.params.sha)"
- name: head_commit
  value: "$(tt.params.head_commit)"
- name: head_commit_message
  value: "$(tt.params.head_commit_message)"
- name: pusher_name
  value: "$(tt.params.pusher_name)"
- name: pusher_email
  value: "$(tt.params.pusher_email)"
- name: pusher_avatar
  value: "$(tt.params.pusher_avatar)"
- name: pusher_url
  value: "$(tt.params.pusher_url)"
- name: repository_url
  value: "$(tt.params.repository_url)"
- name: branch
  value: "$(tt.params.branch)"
- name: component_name
  value: "$(tt.params.component_name)"
{{- if .docker }}
- name: docker_registry
  value: "$(tt.params.docker_registry)"
- name: docker_registry_repository
  value: "$(tt.params.docker_registry_repository)"
{{- end }}
{{- if .kubernetes }}
- name: kubernetes_repository_ssh_url
  value: "$(tt.params.kubernetes_repository_ssh_url)"
- name: kubernetes_repository_kustomize_path
  value: "$(tt.params.kubernetes_repository_kustomize_path)"
- name: kubernetes_branch
  value: "$(tt.params.kubernetes_branch)"
{{- end }}
- name: environment
  value: "$(tt.params.environment)"
{{- end}}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Default workspaces associated with tekton pipeline runs                      │
# │ - source: contains app git repo source code cloned by tekton                 │
# │                                                                              │
# └──────────────────────────────────────────────────────────────────────────────┘
{{- define "pipeline.defaultWorkspaces" -}}
- name: source
  persistentVolumeClaim:
    claimName: $(tt.params.application)-workspace-pvc
{{- end}}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ slack notification reusable snippet in various pipelines                     │
# │                                                                              │
# └──────────────────────────────────────────────────────────────────────────────┘
{{- define "pipeline.finalNotification" -}}
finally:
  - name: slack-notification
    taskRef:
      name: slack-notification
    params:
      - name: application
        value: "$(params.application)"
      - name: sha
        value: "$(params.sha)"
      - name: head_commit
        value: "$(params.head_commit)"
      - name: head_commit_message
        value: "$(params.head_commit_message)"
      - name: pusher_name
        value: "$(params.pusher_name)"
      - name: pusher_email
        value: "$(params.pusher_email)"
      - name: pusher_avatar
        value: "$(params.pusher_avatar)"
      - name: pusher_url
        value: "$(params.pusher_url)"
      - name: repository_url
        value: "$(params.repository_url)"
      - name: branch
        value: "$(params.branch)"
      - name: environment
        value: "$(params.environment)"
      - name: status
        value: "$(tasks.deploy.status)"
{{- end }}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Sentry release reusable snippet in various pipelines                         │
# │                                                                              │
# └──────────────────────────────────────────────────────────────────────────────┘
{{- define "pipeline.sentryRelease" -}}
- name: sentry-release
  taskRef:
    name:  sentry-release
  params:
    - name: environment
      value: "$(params.environment)"
    - name: sentry_project_name
      value: "$(params.sentry_project_name)"
    - name: sourcemaps_dir
      value: "$(params.sourcemaps_dir)"
    - name: subdirectory
      value: {{ default "." .subdirectory | quote }}
  workspaces:
    - name: source
      workspace: source
  runAfter:
    - {{ if eq (.pipeline).name "buildpack-dotnet-build-pipeline" }} git-clone-sentry {{ else }} deploy {{ end }}
{{- end }}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ pre deploy reusable snippet in various pipelines                             │
# │                                                                              │
# └──────────────────────────────────────────────────────────────────────────────┘
{{- define "pipeline.preDeploy" -}}
- name: pre-deploy
  taskRef:
    name:  {{ .name }}
  params:
    - name: application
      value: "$(params.application)"
    - name: project
      value: "$(params.project)"
    - name: namespace
      value: "$(params.namespace)"
    - name: sha
      value: "$(params.sha)"
    - name: environment
      value: "$(params.environment)"
  workspaces:
    - name: source
      workspace: source
  runAfter:
    - kustomize
{{- end }}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ post deploy reusable snippet in various pipelines                            │
# │                                                                              │
# └──────────────────────────────────────────────────────────────────────────────┘
{{- define "pipeline.postDeploy" -}}
- name: post-deploy
  taskRef:
    name:  {{ .name }}
  params:
    - name: application
      value: "$(params.application)"
    - name: project
      value: "$(params.project)"
    - name: namespace
      value: "$(params.namespace)"
    - name: sha
      value: "$(params.sha)"
    - name: environment
      value: "$(params.environment)"
  runAfter:
    - {{ if .sentry_enabled }} sentry-release {{ else }} deploy {{ end }}
{{- end }}
