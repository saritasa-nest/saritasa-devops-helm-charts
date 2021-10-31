{{/*
Create a default mail list address for the project
*/}}
{{- define "tekton-apps.mailList" -}}
{{ $email := ternary .project.mailList (printf "%s@%s" .project.project "saritasa.com") 
             (hasKey .project "mailList") -}}
{{- $email }}
{{- end }}

{{/*
Create a default devops mail list address for the project
*/}}
{{- define "tekton-apps.devopsMailList" -}}
{{ $email := ternary .project.devopsMailList (printf "devops+%s@%s" .project.project "saritasa.com") 
             (hasKey .project "devopsMailList") -}}
{{- $email }}
{{- end }}

{{/*
Create a default slack channel used to send notification (typically client-NAME-ci)
*/}}
{{- define "tekton-apps.slackChannel" -}}
{{ $email := ternary .project.slack (printf "%s-%s-%s" .slackConf.prefix .project.project .slackConf.suffix) 
             (hasKey .project "slack") -}}
{{- $email }}
{{- end }}

{{/*
Create a default Jira project URL
*/}}
{{- define "tekton-apps.jiraProjectURL" -}}
{{ $email := ternary .project.jiraURL (printf "https://saritasa.atlassian.net/browse/%s" .project.project) 
             (hasKey .project "jiraURL") -}}
{{- $email }}
{{- end }}

{{/*
Create a default Tekton URL to be accessible from the slack notification to developers.
*/}}
{{- define "tekton-apps.tektonURL" -}}
{{ $email := ternary .project.tektonURL (printf "https://%s.%s/#/namespaces/ci/pipelineruns" "tekton" .awsConf.dns) 
             (hasKey .project "tektonURL") -}}
{{- $email }}
{{- end }}

{{/*
Create a proper name prefix for various resources based on client, component, environment names
*/}}
{{- define "tekton-apps.resourceName" -}}
{{- if .suffix }}
{{- printf "%s-%s-%s-%s" .project.project .component.name .environment .suffix }}
{{- else }}
{{- printf "%s-%s-%s" .project.project .component.name .environment }}
{{- end }}
{{- end }}


{{/*
Create a proper name prefix for various resources based on client, component, environment names
*/}}
{{- define "tekton-apps.eventlistener._filter" -}}
{{- range  $prefix := $  -}}
body.ref.startsWith('refs/heads/{{- $prefix -}}/'),
{{- end -}}
{{- end }}

{{- define "tekton-apps.eventlistener.filter" -}}
({{ (join " || " (compact (splitList "," (include "tekton-apps.eventlistener._filter" $ )))) }})
{{- end }}

{{/*
Create an element for eventlistener trigger array items
*/}}
{{- define "tekton-apps.eventlistener.trigger" -}}
{{ $filter := ternary .component.eventlistener.filter (include "tekton-apps.eventlistener.filter" .gitBranchPrefixes)
              (hasKey .component.eventlistener "filter") -}}
- name: {{ include "tekton-apps.resourceName" (set $ "suffix" "listener") }}
  serviceAccountName: {{ include "tekton-apps.resourceName" (set $ "suffix" "trigger-sa") }}
  interceptors:
  - ref:
      name: "cel"
    params: 
      - name: "filter"
        value: {{ $filter }} &&
               body.head_commit.author.name != "tekton-kustomize" &&
               body.repository.name == {{ .component.repository | required (printf "apps[%s].components[%s].repository is required" .project.project .component.name) | quote }}
      - name: "overlays"
        value:
        - key: truncated_sha
          expression: "body.head_commit.id.truncate(7)"
        - key: branch_name
          expression: "body.ref.split('/')[2]"
        {{- if .eventlistener.extraOverlays }}
        {{- toYaml .eventlistener.extraOverlays | nindent 8 }}
        {{ end }}
        {{- if .component.eventlistener.extraOverlays }}
        {{- toYaml .component.eventlistener.extraOverlays | nindent 8 }}
        {{ end }}
  - ref:
      name: "github"
    params:
      {{- if hasKey .component.eventlistener "enableWebhookSecret" | ternary .component.eventlistener.enableWebhookSecret .eventlistener.enableWebhookSecret }}
      - name: "secretRef"
        value:
          secretName: {{ include "tekton-apps.resourceName" (set $ "suffix" "webhook-secret") }}
          secretKey: secret-token
      {{- end }}
      - name: "eventTypes"
        value: 
      {{- if .component.eventlistener.eventTypes }}
        {{- toYaml .component.eventlistener.eventTypes | nindent 8 }}
      {{- else }}
        - "push"
      {{- end }}      
  bindings:
  - name: sha
    value: $(extensions.truncated_sha)
  - ref: {{ include "tekton-apps.resourceName" (set $ "suffix" "env") }}
  - ref: github-trigger-binding
  template:
    ref: {{ .component.eventlistener.template | required (printf "apps[%s].components[%s].eventlistener.template is required" .project.project .component.name) }}
{{ end }}


{{/*
Create a name of the kubernetes secret containing project component's SSH deploy key
*/}}
{{- define "tekton-apps.component-repo-deploy-key" -}}
{{- printf "%s-%s-deploy-key" .project.project .component.name }}
{{- end }}

{{/*
Create a name of the kubernetes secret containing project kubernetes repository SSH deploy key
*/}}
{{- define "tekton-apps.kubernetes-repo-deploy-key" -}}
{{- printf "%s-deploy-key" .project.kubernetesRepository.name }}
{{- end }}

{{/*
Create a name of the kubernetes secret containing project component's github repo webhook secret value (for el validation)
*/}}
{{- define "tekton-apps.component-repo-webhook-secret" -}}
{{- printf "%s-%s-webhook-secret" .project.project .component.name }}
{{- end }}

{{/*
Create a service account
*/}}
{{- define "tekton-apps.service-account" -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "tekton-apps.resourceName" $ }}
  namespace: {{ .namespace }}
  annotations:
    argocd.argoproj.io/sync-wave: "1"
secrets:
{{- if .secret }}
- name: {{ .secret }}
{{- end }}
---

{{ end }}

{{/*
Create a pvc for tekton pods
*/}}
{{- define "tekton-apps.tekton-pvc" -}}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "tekton-apps.resourceName" $ }}
  namespace: {{ .namespace }}
  annotations:
    argocd.argoproj.io/sync-wave: "100"
    argocd.argoproj.io/compare-options: IgnoreExtraneous
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: {{ .storage }}
  storageClassName: {{ .storageClassName | default "gp2" }}
---

{{ end }}


{{/*
Check if list of maps (dict name, value) contains a specific named key and then render it or default
the way you use it:
{{- include "tekton-apps.get-triggerbinding-value-or-default" (dict "triggerBinding" $component.triggerBinding "name" "kubernetes_branch" "default" "main" ) | nindent 2 }}
*/}}
{{- define "tekton-apps.get-triggerbinding-value-or-default" -}}
{{- $search := dict "found" false }}
{{- range $item := .triggerBinding }}  
{{- if contains $.name $item.name }}{{- $_ := set $search "found" true }}{{- end }}
{{- end }}
{{- if not $search.found -}}
- name: {{ .name }}
  value: {{ .default }}
{{- end -}}
{{- end -}}