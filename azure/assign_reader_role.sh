#!/bin/bash

# =====================================================================
# Script Name: assign_reader_role.sh
# Description: Assigns the "Reader" role to a Service Principal (SPN)
#              identified by its display name across all enabled Azure
#              subscriptions.
# Requirements:
#   - Azure CLI installed and authenticated
#   - Sufficient permissions to assign roles at the subscription level
# =====================================================================

# ----------------------------- Variables -----------------------------

# Service Principal Display Name
SPN_DISPLAY_NAME="MyApp"

# Role to Assign
ROLE_NAME="Reader"

# ------------------------- Function Definitions ----------------------

# Function to check if user is logged in
check_login() {
  if ! az account show &> /dev/null; then
    echo "Error: You are not logged in to Azure CLI."
    echo "Please run 'az login' to authenticate."
    exit 1
  fi
}

# Function to retrieve SPN Object ID
get_spn_object_id() {
  local spn_name="$1"
  local spn_id

  spn_id=$(az ad sp list --display-name "$spn_name" --query '[0].id' -o tsv)

  if [ -z "$spn_id" ]; then
    echo "Error: Service Principal with display name '$spn_name' not found."
    exit 1
  fi

  echo "$spn_id"
}

# Function to retrieve enabled subscriptions
get_enabled_subscriptions() {
  az account list --query "[?state=='Enabled'].id" -o tsv
}

# Function to assign role to SPN in a subscription
assign_role() {
  local spn_id="$1"
  local subscription_id="$2"
  local role="$3"

  echo "Assigning role '$role' to SPN in subscription '$subscription_id'..."

  az role assignment create \
    --assignee "$spn_id" \
    --role "$role" \
    --scope "/subscriptions/$subscription_id" \
    --only-show-errors

  if [ $? -eq 0 ]; then
    echo "Successfully assigned '$role' role in subscription '$subscription_id'."
  else
    echo "Error: Failed to assign '$role' role in subscription '$subscription_id'."
  fi
}

# ----------------------------- Main Script ---------------------------

# Step 1: Check if the user is logged in
check_login

# Step 2: Retrieve the SPN Object ID
echo "Retrieving Object ID for Service Principal '$SPN_DISPLAY_NAME'..."
SPN_OBJECT_ID=$(get_spn_object_id "$SPN_DISPLAY_NAME")
echo "SPN Object ID: $SPN_OBJECT_ID"

# Step 3: Retrieve all enabled subscriptions
echo "Retrieving list of enabled subscriptions..."
ENABLED_SUBSCRIPTIONS=$(get_enabled_subscriptions)

# Check if there are any enabled subscriptions
if [ -z "$ENABLED_SUBSCRIPTIONS" ]; then
  echo "No enabled subscriptions found. Exiting."
  exit 0
fi

echo "Enabled Subscriptions:"
echo "$ENABLED_SUBSCRIPTIONS"
echo ""

# Step 4: Assign the Reader role to the SPN across all enabled subscriptions
for SUBSCRIPTION_ID in $ENABLED_SUBSCRIPTIONS; do
  assign_role "$SPN_OBJECT_ID" "$SUBSCRIPTION_ID" "$ROLE_NAME"
done

echo ""
echo "Role assignment process completed."

