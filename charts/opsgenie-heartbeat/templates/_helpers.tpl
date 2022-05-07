{{/*
Expand the name of the chart.
*/}}
{{- define "opsgenie-heartbeat.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "opsgenie-heartbeat.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "opsgenie-heartbeat.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "opsgenie-heartbeat.labels" -}}
helm.sh/chart: {{ include "opsgenie-heartbeat.chart" . }}
{{ include "opsgenie-heartbeat.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "opsgenie-heartbeat.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opsgenie-heartbeat.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "opsgenie-heartbeat.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "opsgenie-heartbeat.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/* Compile all validation warnings into a single message and call fail. */}}
{{- define "opsgenie-heartbeat.validateValues" -}}
{{- $messages := list -}}
{{- $messages = append $messages (include "opsgenie-heartbeat.validateValues.existingSecret" .) -}}
{{- $messages = append $messages (include "opsgenie-heartbeat.validateValues.heartbeatName" .) -}}
{{- $messages = without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate value of existingSecret */}}
{{- define "opsgenie-heartbeat.validateValues.existingSecret" -}}
{{- if not (and .Values.existingSecret (kindIs "string" .Values.existingSecret)) -}}
opsgenie-heartbeat: existingSecret
    `existingSecret` is required and should be a non-empty string. That secret should contain a single field `apikey` with APIKEY of OpsGenie API
{{- end -}}
{{- end -}}

{{/* Validate the value of heartbeatName */}}
{{- define "opsgenie-heartbeat.validateValues.heartbeatName" -}}
{{- if not (and .Values.heartbeatName (kindIs "string" .Values.heartbeatName)) -}}
opsgenie-heartbeat: heartbeatName
    `heartbeatName` is required and should be a non-empty string. It is typically your kubernetes cluster name, like  NAME-staging-eks
{{- end -}}
{{- end -}}
