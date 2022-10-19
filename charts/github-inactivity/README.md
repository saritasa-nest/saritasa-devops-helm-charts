
# github-inactivity

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

github-inactivity

## `chart.version`

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Saritasa | <nospam@saritasa.com> | <https://www.saritasa.com/> |

## `chart.description`

A Helm chart for Kubernetes to perform check for github inactive repos. It
creates CronJob, which scans github organization repos, checks whether they
were inactive for some period and send github notifications to corresponding
slack channels and emails about found inactive repos.

Algorithm:

  1. Search in <github-org> using <github-token> for github teams, which
  have only not archived repos inactive for <inactive-days-count> of days
  (repos which had no pushes during this period).

  2. Connect to K8S cluster with <kubeconfig-path> and search for
  namespaces, which <k8s-ns-github-team-label-name> label value corresponds
  to github teams with inactive repos.

  3. Extract notifications info from found on the previous step namespaces.
  This info is located in namespace annotations: slack channels ->
  <k8s-ns-slack-channels-notify-annotation-name>, emails ->
  <k8s-ns-emails-notify-annotation-name>.

  4. For each github team, which has corresponding info in namespace in
  K8S cluster, send `github-inactivity` message to slack channels and
  emails defined in namespace annotations + send slack message to
  <default-inactivity-slack-channels> + send email to
  <default-inactivity-emails>.

  5. There could be left some repos, which have no resources in K8S cluster,
  but have mot archived inactive repos. Send info about these repos also
  to <default-inactivity-slack-channels> and <default-inactivity-emails>.

You can adjust script configuration with below params:

```yaml

githubOrg: "saritasa-nest" # required
fromEmail: "no-reply@saritasa.com" # required

# secret, which should contain `GITHUB_TOKEN`, `SLACK_BOT_TOKEN`,
# `SENDGRID_API_KEY`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` data
githubInactivitySecret: "<your-github-inactivity-secret-name>"

# config map which should contain kubeconfig to connect to correct EKS
kubeconfigConfigMap: "<your-kubeconfig-config-map-name>"

# extra ENV vars needed for required script execution
githubInactivityExtraEnvVars:
  INACTIVE_DAYS_COUNT: 190
  DEFAULT_INACTIVITY_EMAILS: "devops@saritasa.com"
  DEFAULT_INACTIVITY_SLACK_CHANNELS: "client-inactive-projects"
  ERRORS_EMAILS: "devops@saritasa.com"
  K8S_NS_GITHUB_TEAM_LABEL_NAME: "github.com/saritasa-nest.team"
  K8S_NS_SLACK_CHANNELS_NOTIFY_ANNOTATION_NAME: "saritasa.com/slack.channels.notify"
  K8S_NS_EMAILS_NOTIFY_ANNOTATION_NAME: "saritasa.com/emails.notify"

githubOrg: "saritasa-nest"
fromEmail: "no-reply@saritasa.com"
kubeconfigMountPath: "<your-kubeconfig-mount-path>"
kubeconfigSubPath: "<your-kubeconfig-sub-path>"

```

## `chart.valuesTable`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| concurrencyPolicy | string | `"Forbid"` | not allow concurrent job builds |
| cronJobSecurityContext | object | `{}` |  |
| environment | string | `""` | name of the environment you're placing the github-inactivity for like dev, prod, staging |
| failedJobsHistoryLimit | int | `5` |  |
| fromEmail | string | `""` | sender email for inactive repos notifications |
| fullnameOverride | string | `""` |  |
| githubInactivityExtraEnvs | object | `{}` | extra ENV vars needed for required script execution (default values are show below, you can change them if it is needed)  INACTIVE_DAYS_COUNT: 190 DEFAULT_INACTIVITY_EMAILS: "" DEFAULT_INACTIVITY_SLACK_CHANNELS: "" ERRORS_EMAILS: "" K8S_NS_GITHUB_TEAM_LABEL_NAME: "github.com/saritasa-nest.team" K8S_NS_SLACK_CHANNELS_NOTIFY_ANNOTATION_NAME: "saritasa.com/slack.channels.notify" K8S_NS_EMAILS_NOTIFY_ANNOTATION_NAME: "saritasa.com/emails.notify" |
| githubInactivitySecret | string | `"github-inactivity-secret"` |  |
| githubOrg | string | `""` | name of github-organization in which inactive repos should be found |
| image.pullPolicy | string | `"IfNotPresent"` | pull policy |
| image.repository | string | `"public.ecr.aws/saritasa/github-inactivity"` | container repository, adjust in https://github.com/saritasa-nest/saritasa-devops-docker-images/pull/29 |
| image.tag | string | `"0.1"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | credentials for docker login |
| kubeconfigConfigMap | string | `"github-inactivity-kubeconfig-cm"` |  |
| kubeconfigMountPath | string | `"/workspace/kubeconfig/eks-config"` |  |
| kubeconfigSubPath | string | `"eks-config"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| restartPolicy | string | `"Never"` |  |
| schedule | string | `"0 0 1 * *"` | run job in the 1st day of the month |
| securityContext | object | `{}` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| successfulJobsHistoryLimit | int | `5` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
