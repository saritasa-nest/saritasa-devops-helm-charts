# ┌──────────────────────────────────────────────────────────────────────────────┐
# │  Default params                                                              │
# │                                                                              │
# └──────────────────────────────────────────────────────────────────────────────┘
{{- define "params.app" -}}
- name: project
  {{ if ne .target "tt"}}type: string{{ end }}
  description: name of the project, which component is deployed

- name: application
  {{ if ne .target "tt"}}type: string{{ end }}
  description: name of the argocd application we're going to deploy/sync

- name: component
  {{ if ne .target "tt"}}type: string{{ end }}
  description: name of the application component, which is deployed

- name: environment
  {{ if ne .target "tt"}}type: string{{ end }}
  description: environment name of the app being built, i.e. dev/staging/prod

- name: namespace
  {{ if ne .target "tt"}}type: string{{ end }}
  description: project's namespace

{{- end}}
{{- define "params.git" -}}
- name: sha
  {{ if ne .target "tt"}}type: string {{ end }}
  description: sha commit ID of the image deployed in cluster

- name: head_commit
  {{ if ne .target "tt"}}type: string {{ end }}
  description: full SHA commit ID

- name: head_commit_message
  {{ if ne .target "tt"}}type: string {{ end }}
  description: description of the commit (by developer)

- name: pusher_name
  {{ if ne .target "tt"}}type: string {{ end }}
  description: author name

- name: pusher_email
  {{ if ne .target "tt"}}type: string {{ end }}
  description: author email

- name: pusher_avatar
  {{ if ne .target "tt"}}type: string {{ end }}
  description: author url avatar image

- name: pusher_url
  {{ if ne .target "tt"}}type: string {{ end }}
  description: author link to profile

- name: repository_url
  {{ if ne .target "tt"}}type: string {{ end }}
  description: git repository https url

- name: repository_ssh_url
  {{ if ne .target "tt"}}type: string {{ end }}
  description: git repository ssh url

- name: branch
  {{ if ne .target "tt"}}type: string {{ end }}
  description: git branch

- name: repository_submodules
  {{ if ne .target "tt"}}type: string {{ end }}
  description: defines whether repository should be initialized with submodules or not (if false value is set, it means no repository submodules would be downloaded)
  default: "true"

{{- end}}
{{- define "params.registry" -}}
- name: image_registry
  {{ if ne .target "tt"}}type: string {{ end }}
  description: private docker registry address

- name: image_registry_repository
  {{ if ne .target "tt"}}type: string {{ end }}
  description: private docker registry repository address

- name: app_image
  {{ if ne .target "tt"}}type: string {{ end }}
  description: reference to a app result image

{{- end}}
{{- define "params.docker" -}}
- name: docker_file
  {{ if ne .target "tt"}}type: string {{ end }}
  default: Dockerfile
  description: location of the dockerfile, should be Dockerfile if it is in the root of the repository

- name: docker_context
  {{ if ne .target "tt"}}type: string {{ end }}
  default: "."
  description: dockerfile context path

- name: docker_extra_args
  {{ if eq .target "task"}}type: array{{ else if ne .target "tt"}}type: string{{ end }}
  default: ''
  description: additional arguments to pass to 'kaniko build' (similar to 'docker build')

{{- end}}
{{- define "params.buildpack" -}}
- name: buildpack_builder_image
  {{ if ne .target "tt"}}type: string {{ end }}
  description: the image on which builds will run (must include lifecycle and compatible buildpacks).

- name: buildpack_runner_image
  {{ if ne .target "tt"}}type: string {{ end }}
  description: reference to a run image to use

- name: source_subpath
  {{ if ne .target "tt"}}type: string {{ end }}
  description: a subpath within the `source` input where the source to build is located.
  default: ""

- name: platform_dir
  {{ if ne .target "tt"}}type: string {{ end }}
  description: name of the platform directory. for buildpack /cnb/lifecycle/creator
  default: "platform"

- name: buildpack_config_filename
  {{ if ne .target "tt"}}type: string {{ end }}
  description: The name of the buildpack.yml file which should be used for build
  default: "buildpack.yml"

- name: project_config_filename
  {{ if ne .target "tt"}}type: string {{ end }}
  description: The name of the project.toml file which should be used for build
  default: "project.toml"

- name: process_type
  {{ if ne .target "tt"}}type: string {{ end }}
  description: the default process type to set on the image.
  default: "web"

- name: user_id
  {{ if ne .target "tt"}}type: string {{ end }}
  description: the user id of the builder image user.
  default: "1000"

- name: group_id
  {{ if ne .target "tt"}}type: string {{ end }}
  description: the group id of the builder image user.
  default: "1000"

- name: buildpack_cache_pvc
  {{ if ne .target "tt"}}type: string {{ end }}
  description: the name of the persistent app cache volume.
  default: "empty-dir"

- name: buildpack_cache_image
  {{ if ne .target "tt"}}type: string {{ end }}
  description: the name of the persistent app cache image.
  default: ""

- name: buildpack_skip_restore
  {{ if ne .target "tt"}}type: string {{ end }}
  description: Prevent buildpacks from reusing layers from previous builds, by skipping the restoration of any data to each buildpack's layers directory, with the exception of `store.toml`
  default: "false"

{{- end}}
{{- define "params.kubernetes" -}}
- name: kubernetes_repository_ssh_url
  {{ if ne .target "tt"}}type: string {{ end }}
  description: git repo for kustomize management

- name: kubernetes_branch
  {{ if ne .target "tt"}}type: string {{ end }}
  default: "main"
  description: git branch for kustomize managed git repo

- name: kubernetes_repository_kustomize_path
  {{ if ne .target "tt"}}type: string {{ end }}
  description: overlay path for kustomize call

{{- end}}
{{- define "params.sentry" -}}
- name: sentry_enabled
  {{ if ne .target "tt"}}type: string{{ end }}
  default: "{{.sentry | default "false"}}"
  description: Status sentry for app

- name: sentry_project_name
  {{ if ne .target "tt"}}type: string {{ end }}
  description: name of the project in Sentry

- name: sentry_sourcemaps_dir
  {{ if ne .target "tt"}}type: string {{ end }}
  description: name of the dir where frontend sourcemaps would be stored in workspace
  default: "sourcemaps"

{{- end}}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Default bound params (bonds) for various resources                           │
# │ Accepts argument:                                                            │
# │ - source (string)                                                            │
# │                                                                              │
# └──────────────────────────────────────────────────────────────────────────────┘
{{- define "bonds.app" -}}
- name: project
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.project)"
- name: application
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.application)"
- name: environment
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.environment)"
- name: component
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.component)"
- name: namespace
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.namespace)"
{{- end }}
{{- define "bonds.git" -}}
- name: sha
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.sha)"
- name: head_commit
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.head_commit)"
- name: head_commit_message
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.head_commit_message)"
- name: pusher_name
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.pusher_name)"
- name: pusher_email
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.pusher_email)"
- name: pusher_avatar
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.pusher_avatar)"
- name: pusher_url
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.pusher_url)"
- name: repository_url
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.repository_url)"
- name: repository_ssh_url
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.repository_ssh_url)"
- name: branch
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.branch)"
- name: repository_submodules
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.repository_submodules)"
{{- end }}
{{- define "bonds.registry" -}}
- name: image_registry
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.image_registry)"
- name: image_registry_repository
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.image_registry_repository)"
- name: app_image
  {{ if eq .source "tt"}}
  value: "$(tt.params.image_registry_repository):$(tt.params.environment)-$(tt.params.sha)"
  {{ else }}
  value: "$(params.app_image)"
  {{ end }}
{{- end }}
{{- define "bonds.docker" -}}
- name: docker_file
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.docker_file)"
- name: docker_context
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.docker_context)"
- name: docker_extra_args
  {{ if eq .target "task"}}
  value:
    - "$(params.docker_extra_args)"
  {{ else if ne .target "tt"}}
  value: "$(params.docker_extra_args)"
  {{ else }}
  value: "$(tt.params.docker_extra_args)"
  {{ end }}
{{- end }}
{{- define "bonds.buildpack" -}}
- name: buildpack_builder_image
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.buildpack_builder_image)"
- name: buildpack_runner_image
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.buildpack_runner_image)"
- name: source_subpath
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.source_subpath)"
- name: platform_dir
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.platform_dir)"
- name: repository_submodules
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.repository_submodules)"
- name: buildpack_config_filename
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.buildpack_config_filename)"
- name: project_config_filename
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.project_config_filename)"
- name: process_type
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.process_type)"
- name: user_id
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.user_id)"
- name: group_id
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.group_id)"
- name: buildpack_cache_pvc
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.buildpack_cache_pvc)"
- name: buildpack_cache_pvc
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.buildpack_cache_pvc)"
- name: buildpack_skip_restore
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.buildpack_skip_restore)"
{{- end }}
{{- define "bonds.kubernetes" -}}
- name: kubernetes_repository_ssh_url
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.kubernetes_repository_ssh_url)"
- name: kubernetes_repository_kustomize_path
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.kubernetes_repository_kustomize_path)"
- name: kubernetes_branch
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.kubernetes_branch)"
{{- end }}
{{- define "bonds.sentry" -}}
- name: sentry_enabled
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.sentry_enabled)"
- name: sentry_project_name
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.sentry_project_name)"
- name: sentry_sourcemaps_dir
  value: "$({{ if eq .source "tt"}}tt.{{ end }}params.sentry_sourcemaps_dir)"
{{- end }}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Pipeline workspaces for app and k8s source code                              │
# │                                                                              │
# └──────────────────────────────────────────────────────────────────────────────┘
{{- define "pipeline.source_workspaces" -}}
- name: app-source
  persistentVolumeClaim:
    claimName: $(tt.params.application)-workspace-pvc
- name: k8s-source
  volumeClaimTemplate:
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 2Gi 
{{- end }}


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
    {{- include "bonds.app" (dict "source" "pl") | nindent 6 }}
    {{- include "bonds.git" (dict "source" "pl") | nindent 6 }}
      - name: status
        value: "$(tasks.deploy.status)"
{{- end }}
