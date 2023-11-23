# This script checks a Terraform Plan to see if the only difference is the image of the container app
# Used to approve the plan automatically in the CI/CD pipeline if that's the case

set -u

RESOURCE_NAME=${RESOURCE_NAME:-module.microservice.azurerm_container_app.app}
GITHUB_OUTPUT=${GITHUB_OUTPUT:-output.txt}
RUN_ID=${RUN_ID}
TF_TOKEN=${TF_TOKEN}

echo Getting plan output for run $RUN_ID

# Get the plan
curl --location "https://app.terraform.io/api/v2/runs/$RUN_ID/plan/json-output" \
    --fail-with-body \
    --header "Authorization: Bearer $TF_TOKEN" > plan.json \
    || { echo "Error getting plan"; exit 1; }

# Get the changes
jq '[.resource_changes[] | select(.change.actions != ["no-op"])]' plan.json > changes.json

# Check that there is only 1 element in changes.json
N_CHANGES=$(jq '. | length' changes.json)
if [[ $N_CHANGES -ne 1 ]]; then
    echo "There are $N_CHANGES changes in the plan"
    echo "require-approval=true" >> "$GITHUB_OUTPUT"
    exit
fi

# Check that the resource name is the expected one
CHANGED_RESOURCE=$(jq '.[0] | .address' changes.json)
if [[ $CHANGED_RESOURCE != "\"$RESOURCE_NAME\"" ]]; then
    echo "The changed resource is not $RESOURCE_NAME ($CHANGED_RESOURCE)"
    echo "require-approval=true" >> "$GITHUB_OUTPUT"
    exit
fi

# Get the difference between the before and after
DIFF=$(diff <(jq --sort-keys '.[0] | .change.after' changes.json) \
    <(jq --sort-keys '.[0] | .change.before' changes.json) \
    -y --left-column --suppress-common-lines)

# Check that the only difference is the image
REGEX='^.*"image".*$'
N_OTHER=$(echo "$DIFF" | grep -vcP "$REGEX")
N_IMAGE=$(echo "$DIFF" | grep -cP "$REGEX")

if [[ $N_OTHER -ne 0 ]] || [[ $N_IMAGE -ne 1 ]]; then
    echo "The image is not the only difference"
    echo "require-approval=true" >> "$GITHUB_OUTPUT"
    exit
fi

# Check that there are no diffs in the sensitive data

diff -q <(jq --sort-keys '.[0] | .change.after_sensitive' changes.json) \
    <(jq --sort-keys '.[0] | .change.before_sensitive' changes.json)
if [[ $? -ne 0 ]]; then
    echo "There are diffs in the sensitive data"
    echo "require-approval=true" >> "$GITHUB_OUTPUT"
    exit
fi

# The only difference is the image, so we can exit with 0
echo "The only difference is the image"
echo "require-approval=false" >> "$GITHUB_OUTPUT"
exit 0