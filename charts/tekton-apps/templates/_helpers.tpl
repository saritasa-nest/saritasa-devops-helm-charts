{{/*
Expand the name of the chart.
*/}}
{{- define "tekton-apps.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tekton-apps.fullname" -}}
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
{{- define "tekton-apps.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tekton-apps.labels" -}}
helm.sh/chart: {{ include "tekton-apps.chart" . }}
{{ include "tekton-apps.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/tekton-version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tekton-apps.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tekton-apps.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Namespace metadata defaults < project overrides < component/extraApp overrides. */}}
{{- define "tekton-apps.namespace-metadata" -}}
{{- $global := default dict .root.Values.argocd.namespaceMetadata -}}
{{- $project := default dict (default dict .project.argocd).namespaceMetadata -}}
{{- $component := default dict (default dict .component.argocd).namespaceMetadata -}}
{{- $settings := mergeOverwrite (dict "enabled" true "labels" (dict "external-secrets/allow" "true")) (deepCopy $global) (deepCopy $project) (deepCopy $component) -}}
{{- if $settings.enabled }}
managedNamespaceMetadata:
  labels: {{ toYaml $settings.labels | nindent 4 }}
  {{- with $settings.annotations }}
  annotations: {{ toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}
