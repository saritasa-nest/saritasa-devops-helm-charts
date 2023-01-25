#!/bin/bash

#
# Default colors
#
COLOR_RED="#DB2D43"
COLOR_GREEN="#7CD197"

#
# Get git info using GH CLI
#
_get_git_info() {
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
	export GITHUB_BRANCH_URL=$(echo $_view | jq -r ".url")/tree/${GITHUB_BRANCH}
	export GITHUB_BRANCH=$(git branch --show-current)
	export GITHUB_PR_URL=$(echo $_status | jq -r ".currentBranch.url // false")

	#
	# If we don't run in the PR mode, then we will send red alarm
	# otherwise (if PR is ready) - we will collect PR information for the
	# slack alarm
	#
	if [[ "$GITHUB_PR_URL" != "false" ]]; then
		export GITHUB_PR_DECISION=$(echo $_status | jq -r ".currentBranch.reviewDecision")
		# if we didn't get any data for decision, then most likely it is pending reviews
		[[ "$GITHUB_PR_DECISION" == "null" ]] && export GITHUB_PR_DECISION=$(echo $_status | jq -r ".needsReview[0].reviewDecision")
		# and as a backup use the default version if it is still null value
		[[ "$GITHUB_PR_DECISION" == "null" || $GITHUB_PR_DECISION == "" ]] && export GITHUB_PR_DECISION="REVIEW PENDING"
		# get approvals counter
		export GITHUB_PR_APPROVES=$(echo $_status | jq "[.currentBranch.reviews[] | select(.state==\"APPROVED\")] | length")
		# get unfinished counter
		export GITHUB_PR_UNFINISHED=$(echo $_status | jq ".currentBranch.reviewRequests | length")
		# get declines counter
		export GITHUB_PR_DECLINES=$(echo $_status | jq "[.currentBranch.reviews[] | select(.state==\"CHANGES_REQUESTED\")] | length")
		# get the author
		export GITHUB_PR_AUTHOR=$(echo $_status | jq -r ".currentBranch.author.login")
		# depending on the decision let's define the color of the slack message
		[[ "$GITHUB_PR_DECISION" == "APPROVED" ]] && export COLOR=$COLOR_GREEN || export COLOR=$COLOR_RED

		# send PR comment that the terraform pod was started
		prPodStartedCommentBody=$(
			cat <<-EOF
				# $POD_NAME
				$GITHUB_PR_AUTHOR just created terraform pod on $(date)
			EOF
		)
		gh pr comment --body "$prPodStartedCommentBody"
	fi

	# check if we have a local git-crypt-key in the folder
	if [[ -f git-crypt-key ]]; then
		GIT_CRYPT_KEY_PRESENT="YES"
	else
		GIT_CRYPT_KEY_PRESENT="NO!"
	fi
}

#
# Slack notification when the pod is started
#
slack_notificaton() {

	_get_git_info

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
						},
						{
							"title": "git-crypt-key present",
							"value": "'${GIT_CRYPT_KEY_PRESENT}'",
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
							"value": "'${HELM_CHART_VERSION}'",
							"short": false
						},
						{
							"title": "Terraform version",
							"value": "'${TERRAFORM_VERSION}'",
							"short": false
						},
						{
							"title": "git-crypt-key present",
							"value": "'${GIT_CRYPT_KEY_PRESENT}'",
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

slack_notificaton_ready() {
	json='{
		"text": "'${USERNAME}' the terraform pod '${POD_NAME}' is READY for '${GITHUB_REPOSITORY}'/'${GITHUB_BRANCH}'!:eyes:\n
		kubectl exec -ti $(kgpo -l app.kubernetes.io/name=terraform-pod -l app.kubernetes.io/instance='${CLIENT}' --no-headers -o=\"custom-columns=NAME:.metadata.name\") -c terraform -- bash
		",
	}'

	echo $json | curl -X POST $SLACK_WEBHOOK_URL -d @-
}

#
# Final slack message when the POD is terminated
#
slack_notificaton_finish() {

	_get_git_info

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
