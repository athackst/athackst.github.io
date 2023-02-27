#!/bin/bash

set -e

if [ -f .env ]; then
  source .env
fi

# Set the GitHub API endpoint, user name and personal access token
github_api="https://api.github.com"
user_name=${INPUT_USER:-"$GITHUB_USERNAME"}
echo $user_name
access_token=${INPUT_TOKEN:-"$JEKYLL_GITHUB_TOKEN"}
echo $access_token
output_file=${INPUT_OUTPUT_FILE:-"_data/repo-info.json"}

# Set headers to include the access token
headers=(
  "-H" "Authorization: Bearer $access_token"
  "-H" "Accept: application/vnd.github+json"
  "-H" "X-GitHub-Api-Version: 2022-11-28"
)

# Get the list of repositories for the user, including name and html_url properties
repos_url="$github_api/users/$user_name/repos?type=owner&sort=updated"
repos_response=$(curl -sSL "${headers[@]}" "$repos_url")
repos_json=$(echo "$repos_response" | jq -r '.[] | {name, html_url}')
if [ $? -ne 0 ]; then
  echo $repos_response
fi

# Loop through the repositories and get the number of open pull requests and issues
repo_info=()
for repo in $(echo "$repos_json" | jq -r '.name'); do
  echo "Getting info for $repo"
  prs_url="$github_api/repos/$user_name/$repo/pulls?state=open"
  prs_response=$(curl -sSL "${headers[@]}" "$prs_url")
  prs_json=$(echo "$prs_response" | jq -r '. | length')
  echo "Num PRs: $prs_json"
  issues_url="$github_api/repos/$user_name/$repo/issues?state=open"
  issues_response=$(curl -sSL "${headers[@]}" "$issues_url")
  issues_json=$(echo "$issues_response" | jq -r '. | length')
  issues_json=$((issues_json - prs_json))
  echo "Num Issues: $issues_json"
  html_url_json=$(echo "$repos_json" | jq -r "select(.name == \"$repo\") | .html_url")
  echo "HTML URL: $html_url_json"
  repo_info+=("$(echo "{\"name\":\"$repo\",\"html_url\":\"$html_url_json\",\"issues\":$issues_json,\"pull_requests\":$prs_json}" | jq -c '.')")
done


echo "Saving ${repo_info[@]}"

# Save the repository information to a JSON file
echo "${repo_info[@]}" | jq -s '.' > $output_file

echo "Sent to $PWD/$output_file"