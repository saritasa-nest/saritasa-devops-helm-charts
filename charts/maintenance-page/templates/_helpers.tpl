{{/*
Expand the name of the chart.
*/}}
{{- define "maintenance-page.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "maintenance-page.fullname" -}}
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
{{- define "maintenance-page.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "maintenance-page.labels" -}}
helm.sh/chart: {{ include "maintenance-page.chart" . }}
{{ include "maintenance-page.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "maintenance-page.selectorLabels" -}}
app.kubernetes.io/name: {{ include "maintenance-page.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
maintenance: 'true'
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "maintenance-page.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "maintenance-page.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
