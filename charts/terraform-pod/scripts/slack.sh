#!/bin/bash

#
# Default colors
#
COLOR_RED="#DB2D43"
COLOR_GREEN="#7CD197"

#
# Cache github API calls, so that we execute the script faster
#
_view=$(
    gh repo view \
        --json nameWithOwner \
        --json url
)

_status=$(
    gh pr status \
        --json url \
        --json reviewDecision \
        --json reviewRequests \
        --json reviews \
        --json author
)

#
# Obtain various repo information
#
export GITHUB_REPO_NAME=$(echo $_view | jq -r ".nameWithOwner")
export GITHUB_BRANCH_URL=$(echo $_viewl | jq -r ".url")/tree/${GITHUB_BRANCH}
export GITHUB_BRANCH=$(git branch --show-current)
export GITHUB_PR_URL=$(echo $_status | jq -r ".currentBranch.url // false")

#
# If we don't run in the PR mode, then we will send red alarm
# otherwise (if PR is ready) - we will collect PR information for the
# slack alarm
#
if [[ "$GITHUB_PR_URL" != "false" ]]; then
    export GITHUB_PR_DECISION=$(echo $_status | jq -r ".currentBranch.reviewDecision")
    export GITHUB_PR_APPROVES=$(echo $_status | jq "[.currentBranch.reviews[] | select(.state==\"APPROVED\")] | length")
    export GITHUB_PR_UNFINISHED=$(echo $_status | jq ".currentBranch.reviewRequests | length")
    export GITHUB_PR_DECLINES=$(echo $_status | jq "[.currentBranch.reviews[] | select(.state==\"CHANGES_REQUESTED\")] | length")
    export GITHUB_PR_AUTHOR=$(echo $_status | jq -r ".currentBranch.author.login")

    [[ "$GITHUB_PR_DECISION" == "APPROVED" ]] && export COLOR=$COLOR_GREEN || export COLOR=$COLOR_RED
fi

#
# Slack notification when the pod is started
#
slack_notificaton() {
    #
    # Prepare slack CURL payload and send it
    #
    if [[ "$GITHUB_PR_URL" != "false" ]]; then
        json='{
            "text": "'${USERNAME}' started terraform pod '${POD_NAME}' for '${GITHUB_REPO_NAME}' repository!:tada:",
            "attachments": [

                {
                    "title": "['${GITHUB_PR_DECISION}']",
                    "author_name": "'${GITHUB_PR_AUTHOR}'",
                    "color": "'${COLOR}'",
                    "fields": [
                        {
                            "title": "Repository",
                            "value": "'${GITHUB_REPO_NAME}'",
                            "short": true

                        },
                        {
                            "title": "Branch",
                            "value": "'${GITHUB_BRANCH}'",
                            "short": true

                        },
                        {
                            "title": "#Approves",
                            "value": "'${GITHUB_PR_APPROVES}'",
                            "short": true
                        },
                        {
                            "title": "#Declines",
                            "value": "'${GITHUB_PR_DECLINES}'",
                            "short": true
                        },
                        {
                            "title": "#Waiting",
                            "value": "'${GITHUB_PR_UNFINISHED}'",
                            "short": true
                        },
                        {
                            "title": "HELM chart version",
                            "value": "'${HELM_CHART_VERSION}'",
                            "short": false
                        },
                        {
                            "title": "Terraform version",
                            "value": "'${TERRAFORM_VERSION}'",
                            "short": false
                        }
                    ]
                },
                {
                    "fallback": "Please see in github",
                    "title": "Actions",
                    "color": "'${COLOR}'",
                    "attachment_type": "default",
                    "actions": [
                        {
                            "type": "button",
                            "name": "PR",
                            "text": "Open PR",
                            "value": "PR",
                            "url": "'${GITHUB_PR_URL}'"
                        },
                        {
                            "type": "button",
                            "name": "branch",
                            "text": "See '${GITHUB_BRANCH}'",
                            "value": "branch",
                            "url": "'${GITHUB_BRANCH_URL}'"
                        }
                    ]
                }
            ]
        }'

        echo $json | curl -X POST $SLACK_WEBHOOK_URL -d @-

    else
        COLOR=$COLOR_RED
        json='{
            "text": "'${USERNAME}' started terraform pod for '${GITHUB_REPO_NAME}' repository!:tada:",
            "attachments": [

                {
                    "title": "active branch: ['${GITHUB_BRANCH}'] is outside of PR, be careful!",
                    "author_name": "'${USERNAME}'",
                    "color": "'${COLOR}'",
                     "fields": [
                        {
                            "title": "Repository",
                            "value": "'${GITHUB_REPO_NAME}'",
                            "short": true

                        },
                        {
                            "title": "Branch",
                            "value": "'${GITHUB_BRANCH}'",
                            "short": true

                        },
                        {
                            "title": "HELM chart version",
                            "value": "1.3.4",
                            "short": false
                        },
                        {
                            "title": "Terraform version",
                            "value": "1.3.4",
                            "short": false
                        }
                    ]
                },
                {
                    "fallback": "Please see in github",
                    "title": "Actions",
                    "color": "'${COLOR}'",
                    "attachment_type": "default",
                    "actions": [
                        {
                            "type": "button",
                            "name": "branch",
                            "text": "See '${GITHUB_BRANCH}'",
                            "value": "branch",
                            "url": "'${GITHUB_BRANCH_URL}'"
                        }
                    ]
                }
            ]
        }'

        echo $json | curl -X POST $SLACK_WEBHOOK_URL -d @-
    fi

}

#
# Final slack message when the POD is terminated
#
slack_notificaton_finish() {

    COLOR=$COLOR_GREEN

    json='{
            "text": "'${USERNAME}' finished terraform pod for '${GITHUB_REPO_NAME}' repository!:tada:",
            "attachments": [

                {
                    "title": "work performed in the branch: ['${GITHUB_BRANCH}']",
                    "author_name": "'${USERNAME}'",
                    "color": "'${COLOR}'",
                },
                {
                    "fallback": "Please see in github",
                    "title": "Actions",
                    "color": "'${COLOR}'",
                    "attachment_type": "default",
                    "actions": [
                        {
                            "type": "button",
                            "name": "branch",
                            "text": "See '${GITHUB_BRANCH}'",
                            "value": "branch",
                            "url": "'${GITHUB_BRANCH_URL}'"
                        }
                    ]
                }
            ]
        }'

    echo $json | curl -X POST $SLACK_WEBHOOK_URL -d @-

}
