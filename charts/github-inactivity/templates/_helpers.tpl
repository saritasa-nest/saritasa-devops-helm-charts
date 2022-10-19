{{/*
Expand the name of the chart.
*/}}
{{- define "github-inactivity.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "github-inactivity.fullname" -}}
{{- if .Values.fullnameOverride  }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else if .Values.environment }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Values.environment $name | trunc 63 | trimSuffix "-" }}
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
{{- define "github-inactivity.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "github-inactivity.labels" -}}
helm.sh/chart: {{ include "github-inactivity.chart" . }}
{{ include "github-inactivity.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "github-inactivity.selectorLabels" -}}
app.kubernetes.io/name: {{ include "github-inactivity.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
maintenance: 'true'
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "github-inactivity.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "github-inactivity.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "github-inactivity.required" -}}
{{ required (printf "Field `%s` is required!" .field_name) .field_value }}
{{- end }}
