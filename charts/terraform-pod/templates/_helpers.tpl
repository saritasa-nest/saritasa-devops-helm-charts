{{/*
Expand the name of the chart.
*/}}
{{- define "terraform-pod.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "terraform-pod.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Expand the name of configmap containing bash scripts used inside the deployment
*/}}
{{- define "terraform-pod.scripts" -}}
{{ include "terraform-pod.fullname" . }}-scripts
{{- end }}

{{/*
Expand the name of the secret  containing content of the git-crypt-key file
*/}}
{{- define "terraform-pod.git-crypt-key" -}}
{{ include "terraform-pod.fullname" . }}-git-crypt-key
{{- end }}

{{/*
Expand the name of configmap containing ssh known hosts for github
*/}}
{{- define "terraform-pod.github-known-hosts" -}}
{{ include "terraform-pod.fullname" . }}-github-known-hosts
{{- end }}

{{/*
Define default ENV variables for the deployment
*/}}
{{- define "terraform-pod.default-env-vars" -}}
- name: USERNAME
  value: {{ .Values.github.username }}
- name: USEREMAIL
  value: {{ .Values.github.email }}
- name: GITHUB_BRANCH
  value: {{ .Values.github.branch }}
- name: SLACK_WEBHOOK_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.slack.urlSecret }}
      key: url
- name: HELM_CHART_VERSION
  value: {{ .Chart.Version }}
- name: TERRAFORM_VERSION
  value: {{ .Values.image.tag | default .Chart.AppVersion }}
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
{{- end }}


{{/*
Define env vars containing database access to be passed as TF_VAR value into terraform
*/}}
{{- define "terraform-pod.terraform-env-database-vars" -}}
# terraform database credentials
{{- range $db, $conf := .Values.databases }}
- name: {{ $conf.terraformEnvVarName}}
  valueFrom:
    secretKeyRef:
      name: {{ $conf.secret }}
      key: password
{{- end }}
{{- end }}

{{/*
Define env vars containing argocd access to be passed as TF_VAR value into terraform
*/}}
{{- define "terraform-pod.terraform-env-argocd-vars" -}}
# terraform argocd credentials
{{- range $db, $conf := .Values.argocd }}
- name: {{ $conf.terraformEnvVarName}}
  valueFrom:
    secretKeyRef:
      name: {{ $conf.secret }}
      key: password
{{- end }}
{{- end }}

{{/*
Define env vars for terraform
*/}}
{{- define "terraform-pod.terraform-env-vars" -}}
# terraform vars
- name: TF_ORG
  value: {{ .Values.terraform.organization }}
- name: TF_TOKEN_app_terraform_io
  valueFrom:
    secretKeyRef:
      name: {{ .Values.terraform.tokenSecret }}
      key: token
- name: TF_TOKEN_registry_terraform_io
  valueFrom:
    secretKeyRef:
      name: {{ .Values.terraform.tokenSecret }}
      key: token
{{ include "terraform-pod.terraform-env-database-vars" . }}
{{ include "terraform-pod.terraform-env-argocd-vars" . }}
{{- end }}

{{/*
Define env vars containing AWS access
*/}}
{{- define "terraform-pod.aws-env-vars" -}}
# aws CLI
- name: AWS_DEFAULT_REGION
  value: {{ .Values.aws.region }}
- name: AWS_DEFAULT_OUTPUT
  value: {{ .Values.aws.output }}
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.aws.iamCredentialsSecret }}
      key: aws_access_key_id
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.aws.iamCredentialsSecret }}
      key: aws_secret_access_key
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "terraform-pod.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "terraform-pod.labels" -}}
helm.sh/chart: {{ include "terraform-pod.chart" . }}
{{ include "terraform-pod.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "terraform-pod.selectorLabels" -}}
app.kubernetes.io/name: {{ include "terraform-pod.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "terraform-pod.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "terraform-pod.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Compile all validation warnings into a single message and call fail. */}}
{{- define "terraform-pod.validateValues" -}}
{{- $messages := list -}}
{{- $messages = append $messages (include "terraform-pod.validateValues.github" .) -}}
{{- $messages = append $messages (include "terraform-pod.validateValues.gitCryptKey" .) -}}
{{- $messages = append $messages (include "terraform-pod.validateValues.slack" .) -}}
{{- $messages = without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- if $message -}}

{{- printf "\n===========================\n🙄 VALUES VALIDATION:\n===========================\n\n%s" $message | fail -}}
{{- end -}}

{{- end -}}

{{/* Validate value of github */}}
{{- define "terraform-pod.validateValues.github" -}}
{{- if not (and .Values.github.appAuthSecret (kindIs "string" .Values.github.appAuthSecret)) }}
github.appAuthSecret:
    `appAuthSecret` is required and should be a non-empty string. It should contain name of the secret containing PEM file for github terraform provider authentication
{{- end -}}
{{- if not (and .Values.github.repository (kindIs "string" .Values.github.repository)) }}
github.repository:
    `repository` is required and should be a non-empty string. It should contain repository name in format: `org/repo`
{{- end -}}
{{  if not (and .Values.github.branch (kindIs "string" .Values.github.branch)) }}
github.branch:
    `branch` is required and should be a non-empty string. It should contain a name of th4e branch we should checkout
{{- end -}}
{{ if not (and .Values.github.username (kindIs "string" .Values.github.username)) }}
github.username:
    `username` is required and should be a non-empty string. It should contain your github username
{{- end -}}
{{ if not (and .Values.github.email (kindIs "string" .Values.github.email)) }}
github.email:
    `email` is required and should be a non-empty string. It should contain your github user' email
{{- end -}}

{{- end -}}

{{/* Validate the value of gitCryptKey */}}
{{- define "terraform-pod.validateValues.gitCryptKey" -}}
{{- if not (and .Values.gitCryptKey (kindIs "string" .Values.gitCryptKey)) -}}
gitCryptKey:
    `gitCryptKey` is required and should be a non-empty base64 string. It should contain the content of the git-crypt-key file in base64 format.
{{- end -}}
{{- end -}}

{{/* Validate the value of gitCryptKey */}}
{{- define "terraform-pod.validateValues.slack" -}}
{{- if not (and .Values.slack.urlSecret (kindIs "string" .Values.slack.urlSecret)) -}}
slack.urlSecret:
    `urlSecret` is required and should be a non-empty string. It should contain the name of the secret with `url` key containing slack webhook URL
{{- end -}}
{{- end -}}
