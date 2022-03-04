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
body.ref.startsWith('refs/heads/{{- $prefix -}}'),
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
{{- if and (.argocd.source).repoUrl (.argocd.source).name }}
{{- printf "%s-deploy-key" .argocd.source.name }}
{{- end }}
{{- if and (.argocd.source).repoUrl (not (.argocd.source).name) }}
{{- printf "%s-%s-deploy-key" .project.project .component.name }}
{{- end }}
{{- if and (not (.argocd.source).repoUrl) (hasKey .project "kubernetesRepository") }}
{{- printf "%s-deploy-key" (.project.kubernetesRepository).name | default "" }}
{{- end }}
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


{{/*
Create `helm.Values` element for ArgoCD wordpress application
*/}}
{{- define "tekton-apps.argocd.wordpress.helmValues" -}}
wordpressSkipInstall: false
image:
  repository: bitnami/wordpress
  tag: {{ .wordpress.imageTag | default "5.7.2" }}
  debug: true

{{- if hasKey .wordpress "resources" }}
resources:
  {{- toYaml .wordpress.resources | nindent 2 }}
{{- else }}
resources:
  requests:
    cpu: 100m
    memory: 128Mi
{{- end }}

{{- if hasKey .wordpress "commonLabels" }}
commonLabels:
  {{- toYaml .wordpress.commonLabels | nindent 2 }}
{{- else }}
commonLabels:
  tech_stack: php
  application: wordpress
{{- end }}

wordpressEmail: devops+{{ .project.project }}@saritasa.com
wordpressBlogName: {{ .project.project }}
wordpressScheme: https
wordpressTablePrefix: {{ .wordpress.wordpressTablePrefix | default "wp_" }}
allowEmptyPassword: false
existingSecret: {{ .wordpress.existingSecret | default (printf "%s-%s-%s" .project.project .component.name .environment) }}

{{- if hasKey .wordpress "updateStrategy" }}
updateStrategy:
  {{- toYaml .wordpress.updateStrategy | nindent 2 }}
{{- else }}
updateStrategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 0%
    maxUnavailable: 100%
{{- end }}

replicaCount: 1

{{- if hasKey .wordpress "smtp" }}
smtpHost: {{ .wordpress.smtp.host }}
smtpPort: {{ .wordpress.smtp.port }}
smtpUser: {{ .wordpress.smtp.user }}
smtpPassword: {{ .wordpress.smtp.password }}
{{- else }}
smtpHost: mailhog.mailhog.svc.cluster.local
smtpPort: 1025
smtpUser: {{ .project.project }}
smtpPassword: anypassword
{{- end }}

{{ if hasKey .wordpress "nodeSelector" }}
nodeSelector:
  {{- range $k, $v := .wordpress.nodeSelector }}
  {{ $k }}: {{ $v | quote}}
  {{- end }}
{{- else }}
nodeSelector:
  tech_stack: php
  pvc: "true"
{{- end }}

{{ if hasKey .wordpress "podSecurityContext" }}
podSecurityContext:
  {{- range $k, $v := .wordpress.podSecurityContext }}
  {{ $k }}: {{ $v }}
  {{- end }}
{{- else }}
podSecurityContext:
  enabled: true
  fsGroup: 1000
{{- end }}

{{ if hasKey .wordpress "containerSecurityContext" }}
containerSecurityContext:
  {{- range $k, $v := .wordpress.containerSecurityContext }}
  {{ $k }}: {{ $v }}
  {{- end }}
{{- else }}
containerSecurityContext:
  enabled: true
  runAsUser: 1000
{{- end }}

{{ if ternary .wordpress.ci "true" (hasKey .wordpress "ci") }}
initContainers:
  - name: install
    image: jnewland/git-and-stuff
    imagePullPolicy: Always
    command:
      - bash
      - -c
      - |
        git -c core.sshCommand="ssh -i ~/.ssh/id_rsa" clone {{ .wordpress.repository_ssh_url }} /tmp/wordpress
        cp -Rf /tmp/wordpress/wp-content/* /bitnami/wordpress/wp-content/
        cd /tmp/wordpress
        git_branch=`git rev-parse --abbrev-ref HEAD`
        git_log=`git log --format="%h - by %an - %ae - %s" HEAD~1..HEAD`
        msg="[$git_branch] $git_log"
        printf "%0.s-" $(seq 1 ${#msg})
        echo
        echo "$msg"
        printf "%0.s-" $(seq 1 ${#msg})
        echo
        ls -la /tmp/wordpress/wp-content
        echo "Folder wp-content copied from git repo into bitnami/wodpress"
        echo "Done INIT"
    volumeMounts:
    - mountPath: /bitnami/wordpress
      name: wordpress-data
      subPath: wordpress
    - mountPath: /home/app/.ssh/id_rsa
      name: ssh-key
      subPath: ssh-privatekey
    - mountPath: /home/app/.ssh/known_hosts
      name: github-known-hosts
      subPath: config.ssh
{{- if .wordpress.extraInitContainers }}
{{ toYaml .wordpress.extraInitContainers | indent 2 }}
{{- end }}

extraVolumes:
- name: ssh-key
  secret:
    secretName: {{ .wordpress.extraVolumesSshKeySecret | default (printf "%s-%s-deploy-key" .project.project .component.name) }}
- name: github-known-hosts
  configMap:
    name: github-known-hosts
{{- if .wordpress.extraVolumes }}
{{- toYaml .wordpress.extraVolumes | nindent 0 }}
{{- end }}
{{- end }}

livenessProbe:
  httpGet:
    path: /wp-admin/install.php
    port: 8080

readinessProbe:
  enabled: true
  httpGet:
    path: /wp-admin/install.php
    port: 8080

service:
  type: ClusterIP
  port: 8080

ingress:
  enabled: true
  certManager: true
  hostname: {{ ((.wordpress).ingress).hostname | default (printf "%s.saritasa.rocks" .project.project) }}
  {{- if ((.wordpress).ingress).annotations }}
  annotations:
    {{- range $k, $v := .wordpress.ingress.annotations }}
    {{ $k }}: {{ $v | quote}}
    {{- end }}
  {{- else }}
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/proxy-body-size: 100m
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-next-upstream-timeout: "300"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: {{ ((.wordpress).ingress).authSecret | default (printf "%s-%s-%s-basic-auth" .project.project .component.name .environment) }}
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
    nginx.ingress.kubernetes.io/server-snippet: |-
      add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
  {{- end }}

  tls: true
  {{- if ((.wordpress).ingress).extraHosts }}
  extraHosts:
    {{- range .wordpress.ingress.extraHosts }}
    - name: {{ .name | quote }}
      path: {{ default "/" .path }}
      backend: {{ .backend | default dict }}
    {{- end }}
  {{- end }}

persistence:
  enabled: true
  storageClass: gp2

metrics:
  enabled: true

mariadb:
  enabled: false

externalDatabase:
  host: {{ .wordpress.externalDatabase.host }}
  user: {{ .wordpress.externalDatabase.user }}
  existingSecret: {{ .wordpress.externalDatabase.existingSecret }}
  database: {{ .wordpress.externalDatabase.database }}
  port: {{ .wordpress.externalDatabase.port | default "3306" }}

{{- if hasKey .wordpress "wordpressExtraConfigContent" }}
wordpressExtraConfigContent:
{{- toYaml .wordpress.wordpressExtraConfigContent | indent 2 }}
{{- end }}

{{- if hasKey .wordpress "extraEnvVars" }}
  extraEnvVars:
{{- toYaml .wordpress.extraEnvVars | indent 2 }}
{{- end }}
{{ end }}
