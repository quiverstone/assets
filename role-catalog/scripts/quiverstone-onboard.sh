#!/usr/bin/env bash
#
# Quiverstone role onboarding script (AWS CloudShell).
#
# Deploys one Quiverstone role-catalog CloudFormation template into the AWS
# account you are signed in to. The Quiverstone app generates the exact
# command for you; it looks like:
#
#   curl -fsSL <script-url> -o quiverstone-onboard.sh && bash quiverstone-onboard.sh \
#     --role-type account-access --variant direct --external-id <id> ...
#
# Role types and variants (template in parentheses):
#
#   org-inventory         direct   (inventory/direct-org-inventory-role.yaml)
#                         chained  (inventory/chained-org-inventory-role.yaml)
#   standalone-inventory  direct   (inventory/standalone-account-inventory-role.yaml)
#   account-access        browser  (access/browser-access-role.yaml)
#                         direct   (access/direct-access-role.yaml)
#                         chained  (access/chained-access-role.yaml)
#   intermediate          -        (intermediate/trusted-intermediate-role.yaml)
#
# The script never stores credentials and only creates/updates a single
# CloudFormation stack containing one IAM role. Published at:
#   https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/scripts/quiverstone-onboard.sh
set -euo pipefail

DEFAULT_TEMPLATE_BASE="https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog"
TEMPLATE_BASE="${QUIVERSTONE_TEMPLATE_BASE:-$DEFAULT_TEMPLATE_BASE}"

ROLE_TYPE="org-inventory"
VARIANT=""
EXTERNAL_ID=""
ROLE_NAME=""
INTERMEDIATE_ROLE_ARN=""
TRUST_SCOPE="all"
TRUSTED_ACCOUNT_ID=""
PERMISSIONS="read-only"
ACCOUNT_TYPE="management"
EXPECTED_ACCOUNT_ID=""
ASSUME_SCOPE="any-role-any-account"
DESTINATION_ROLE_NAME=""
DESTINATION_ACCOUNT_ID=""
REGION="us-east-1"
STACK_NAME=""
CALLBACK_URL=""
TOKEN=""
SESSION_ID=""

DEPLOY_STARTED=0

err() { printf '\nERROR: %s\n' "$1" >&2; exit 1; }
info() { printf '==> %s\n' "$1"; }
warn() { printf 'WARNING: %s\n' "$1" >&2; }

usage() {
  cat <<'EOF'
Usage: quiverstone-onboard.sh --role-type <type> [--variant <variant>] [options]

  --role-type              org-inventory | standalone-inventory | account-access | intermediate
  --variant                org-inventory: direct|chained; standalone-inventory: direct;
                           account-access: browser|direct|chained; intermediate: (none)
  --external-id            Your Quiverstone External ID (required for direct and intermediate;
                           optional hop-2 External ID for chained; not used for browser)
  --role-name              IAM role name to create (defaults per role type)
  --intermediate-role-arn  chained: ARN of your existing intermediate role
  --trust-scope            chained: all | named (default all)
  --trusted-account-id     browser: account whose console users may switch into the role
  --permissions            account-access: comma list of read-only, administrator, power-user,
                           view-only, security-audit, system-administrator, support-user, billing
                           (default read-only)
  --account-type           org-inventory: management | delegated-admin (default management)
  --assume-scope           intermediate: any-role-any-account | specific-role-any-account |
                           specific-account-and-role (default any-role-any-account)
  --destination-role-name  intermediate: role name the intermediate role may assume
  --destination-account-id intermediate: account for specific-account-and-role
  --expected-account-id    stop unless signed in to this AWS account
  --region                 region the CloudFormation stack is created in (default us-east-1)
  --stack-name             CloudFormation stack name (defaults per role type)
  --callback-url/--token/--session-id   org-inventory Quick Setup callback (all three together)
EOF
}

# ── Failure reporting ────────────────────────────────────────────────────────
# shellcheck disable=SC2329  # invoked via trap
on_error() {
  local rc=$?
  trap - ERR
  if [[ "$DEPLOY_STARTED" -eq 1 ]]; then
    printf '\nERROR: the CloudFormation deployment of stack %s in %s did not succeed.\n' "$STACK_NAME" "$REGION" >&2
    printf 'Most recent failure reasons:\n' >&2
    aws cloudformation describe-stack-events --stack-name "$STACK_NAME" --region "$REGION" \
      --max-items 40 \
      --query "StackEvents[?contains(ResourceStatus, 'FAILED')].[LogicalResourceId, ResourceStatus, ResourceStatusReason]" \
      --output text 2>/dev/null | head -n 8 | sed 's/^/  /' >&2 || true
    printf 'Full history: aws cloudformation describe-stack-events --stack-name %s --region %s\n' "$STACK_NAME" "$REGION" >&2
  else
    printf '\nERROR: onboarding stopped (exit code %s) before anything was deployed.\n' "$rc" >&2
  fi
  exit "$rc"
}
trap on_error ERR

[[ $# -eq 0 ]] && { usage; exit 1; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --role-type)              ROLE_TYPE="${2:-}"; shift 2 ;;
    --variant)                VARIANT="${2:-}"; shift 2 ;;
    --external-id)            EXTERNAL_ID="${2:-}"; shift 2 ;;
    --role-name)              ROLE_NAME="${2:-}"; shift 2 ;;
    --intermediate-role-arn)  INTERMEDIATE_ROLE_ARN="${2:-}"; shift 2 ;;
    --trust-scope)            TRUST_SCOPE="${2:-}"; shift 2 ;;
    --trusted-account-id)     TRUSTED_ACCOUNT_ID="${2:-}"; shift 2 ;;
    --permissions)            PERMISSIONS="${2:-}"; shift 2 ;;
    --account-type)           ACCOUNT_TYPE="${2:-}"; shift 2 ;;
    --assume-scope)           ASSUME_SCOPE="${2:-}"; shift 2 ;;
    --destination-role-name)  DESTINATION_ROLE_NAME="${2:-}"; shift 2 ;;
    --destination-account-id) DESTINATION_ACCOUNT_ID="${2:-}"; shift 2 ;;
    --expected-account-id)    EXPECTED_ACCOUNT_ID="${2:-}"; shift 2 ;;
    --region)                 REGION="${2:-}"; shift 2 ;;
    --stack-name)             STACK_NAME="${2:-}"; shift 2 ;;
    --callback-url)           CALLBACK_URL="${2:-}"; shift 2 ;;
    --token)                  TOKEN="${2:-}"; shift 2 ;;
    --session-id)             SESSION_ID="${2:-}"; shift 2 ;;
    -h|--help)                usage; exit 0 ;;
    *) err "unknown option: $1 (run with --help for usage)" ;;
  esac
done

# ── Validate every parameter (same allowlists as the Quiverstone UI) ─────────
ROLE_NAME_RE='^[A-Za-z0-9+=,.@_-]{1,64}$'
ACCOUNT_RE='^[0-9]{12}$'
TENANT_EXTERNAL_ID_RE='^[a-f0-9-]{36}$'
HOP2_EXTERNAL_ID_RE='^[A-Za-z0-9+=,.@:/_-]{2,1224}$'

case "$ROLE_TYPE" in
  org-inventory)
    case "$VARIANT" in
      direct|chained) ;;
      open|browser) err "org inventory roles are assumed by Quiverstone itself, so there is no '$VARIANT' variant. Use --variant direct or --variant chained." ;;
      *) err "--variant must be 'direct' or 'chained' for --role-type org-inventory" ;;
    esac
    case "$ACCOUNT_TYPE" in
      management|delegated-admin) ;;
      *) err "--account-type must be 'management' or 'delegated-admin'" ;;
    esac
    ;;
  standalone-inventory)
    VARIANT="${VARIANT:-direct}"
    [[ "$VARIANT" == "direct" ]] || err "--role-type standalone-inventory only supports --variant direct"
    ;;
  account-access)
    case "$VARIANT" in
      browser|direct|chained) ;;
      *) err "--variant must be 'browser', 'direct' or 'chained' for --role-type account-access" ;;
    esac
    ;;
  intermediate)
    VARIANT="direct"
    ;;
  *) err "--role-type must be one of: org-inventory, standalone-inventory, account-access, intermediate" ;;
esac

# Per-type template, default role name and default stack name.
case "$ROLE_TYPE:$VARIANT" in
  org-inventory:direct)        TEMPLATE_PATH="inventory/direct-org-inventory-role.yaml";        DEF_ROLE="QuiverstoneInventory";                 DEF_STACK="quiverstone-inventory-role" ;;
  org-inventory:chained)       TEMPLATE_PATH="inventory/chained-org-inventory-role.yaml";       DEF_ROLE="QuiverstoneInventory";                 DEF_STACK="quiverstone-inventory-role" ;;
  standalone-inventory:direct) TEMPLATE_PATH="inventory/standalone-account-inventory-role.yaml"; DEF_ROLE="QuiverstoneStandaloneAccountInventory"; DEF_STACK="quiverstone-standalone-inventory-role" ;;
  account-access:browser)      TEMPLATE_PATH="access/browser-access-role.yaml";                 DEF_ROLE="QuiverstoneBrowserSession";            DEF_STACK="quiverstone-browser-access-role" ;;
  account-access:direct)       TEMPLATE_PATH="access/direct-access-role.yaml";                  DEF_ROLE="QuiverstoneDirectAccess";              DEF_STACK="quiverstone-direct-access-role" ;;
  account-access:chained)      TEMPLATE_PATH="access/chained-access-role.yaml";                 DEF_ROLE="QuiverstoneChainedAccess";             DEF_STACK="quiverstone-chained-access-role" ;;
  intermediate:direct)         TEMPLATE_PATH="intermediate/trusted-intermediate-role.yaml";     DEF_ROLE="QuiverstoneTrustedIntermediate";       DEF_STACK="quiverstone-trusted-intermediate-role" ;;
esac
ROLE_NAME="${ROLE_NAME:-$DEF_ROLE}"
STACK_NAME="${STACK_NAME:-$DEF_STACK}"

[[ "$ROLE_NAME" =~ $ROLE_NAME_RE ]] || err "--role-name may only contain letters, numbers and + = , . @ _ - (max 64 characters)"
[[ "$REGION" =~ ^[a-z]{2}(-[a-z]+)+-[0-9]$ ]] || err "--region '$REGION' is not a valid AWS region (example: us-east-1)"
[[ "$STACK_NAME" =~ ^[A-Za-z][A-Za-z0-9-]{0,127}$ ]] || err "--stack-name is not a valid CloudFormation stack name"
[[ -z "$EXPECTED_ACCOUNT_ID" || "$EXPECTED_ACCOUNT_ID" =~ $ACCOUNT_RE ]] || err "--expected-account-id must be a 12-digit AWS account ID"
[[ "$TEMPLATE_BASE" =~ ^https://[A-Za-z0-9.-]+(/[A-Za-z0-9._/-]*)?$ ]] || err "QUIVERSTONE_TEMPLATE_BASE must be an https URL"

# External ID rules:
#  - direct roles and the intermediate role trust the Quiverstone production
#    account and REQUIRE your tenant External ID (Quiverstone always sends it).
#  - chained target roles take an OPTIONAL hop-2 External ID; your tenant
#    External ID is enforced on the intermediate role (hop 1).
#  - browser roles are assumed from the AWS console, which cannot send one.
case "$VARIANT" in
  direct)
    [[ -n "$EXTERNAL_ID" ]] || err "--external-id is required for this role. Copy your External ID from Quiverstone."
    [[ "$EXTERNAL_ID" =~ $TENANT_EXTERNAL_ID_RE ]] || err "--external-id must be your 36-character Quiverstone External ID"
    ;;
  chained)
    [[ -z "$EXTERNAL_ID" || "$EXTERNAL_ID" =~ $HOP2_EXTERNAL_ID_RE ]] || err "--external-id contains characters AWS does not allow in an External ID"
    ;;
  browser)
    [[ -z "$EXTERNAL_ID" ]] || err "browser (console switch-role) access cannot use an External ID; remove --external-id"
    ;;
esac

INTERMEDIATE_ACCOUNT_ID=""
INTERMEDIATE_ROLE_NAME=""
if [[ "$VARIANT" == "chained" ]]; then
  [[ "$INTERMEDIATE_ROLE_ARN" =~ ^arn:aws:iam::([0-9]{12}):role/([A-Za-z0-9+=,.@_-]{1,64})$ ]] \
    || err "--intermediate-role-arn is required for chained roles and must be an IAM role ARN without a path (arn:aws:iam::<account>:role/<name>)"
  # The chained templates take the intermediate account id and role name as
  # separate parameters — split them out of the ARN.
  INTERMEDIATE_ACCOUNT_ID="${BASH_REMATCH[1]}"
  INTERMEDIATE_ROLE_NAME="${BASH_REMATCH[2]}"
  case "$TRUST_SCOPE" in
    all)   TRUST_PRINCIPALS="All" ;;
    named) TRUST_PRINCIPALS="Named" ;;
    *) err "--trust-scope must be 'all' or 'named'" ;;
  esac
fi

if [[ "$VARIANT" == "browser" ]]; then
  [[ "$TRUSTED_ACCOUNT_ID" =~ $ACCOUNT_RE ]] \
    || err "--trusted-account-id is required for browser access: the 12-digit account your console users sign in to before switching roles"
fi

declare -a PERMISSION_PARAMS=()
if [[ "$ROLE_TYPE" == "account-access" ]]; then
  declare -A PERM_MAP=(
    [read-only]=pIsReadOnlyAccess [administrator]=pIsAdministratorAccess
    [power-user]=pIsPowerUserAccess [view-only]=pIsViewOnlyAccess
    [security-audit]=pIsSecurityAudit [system-administrator]=pIsSystemAdministrator
    [support-user]=pIsSupportUser [billing]=pIsBillingAccess
  )
  declare -A PERM_ON=()
  IFS=',' read -r -a REQUESTED_PERMS <<<"$PERMISSIONS"
  [[ ${#REQUESTED_PERMS[@]} -gt 0 ]] || err "--permissions must list at least one permission level"
  for p in "${REQUESTED_PERMS[@]}"; do
    [[ -n "${PERM_MAP[$p]:-}" ]] || err "--permissions: unknown level '$p' (allowed: ${!PERM_MAP[*]})"
    PERM_ON[$p]=1
  done
  for p in "${!PERM_MAP[@]}"; do
    if [[ -n "${PERM_ON[$p]:-}" ]]; then PERMISSION_PARAMS+=("${PERM_MAP[$p]}=yes"); else PERMISSION_PARAMS+=("${PERM_MAP[$p]}=no"); fi
  done
fi

if [[ "$ROLE_TYPE" == "intermediate" ]]; then
  case "$ASSUME_SCOPE" in
    any-role-any-account) ;;
    specific-role-any-account)
      [[ "$DESTINATION_ROLE_NAME" =~ $ROLE_NAME_RE ]] || err "--destination-role-name is required for --assume-scope specific-role-any-account" ;;
    specific-account-and-role)
      [[ "$DESTINATION_ROLE_NAME" =~ $ROLE_NAME_RE ]] || err "--destination-role-name is required for --assume-scope specific-account-and-role"
      [[ "$DESTINATION_ACCOUNT_ID" =~ $ACCOUNT_RE ]] || err "--destination-account-id is required for --assume-scope specific-account-and-role" ;;
    *) err "--assume-scope must be any-role-any-account, specific-role-any-account or specific-account-and-role" ;;
  esac
fi

CALLBACK_PARTS=0
[[ -n "$CALLBACK_URL" ]] && CALLBACK_PARTS=$((CALLBACK_PARTS + 1))
[[ -n "$TOKEN" ]] && CALLBACK_PARTS=$((CALLBACK_PARTS + 1))
[[ -n "$SESSION_ID" ]] && CALLBACK_PARTS=$((CALLBACK_PARTS + 1))
if [[ "$CALLBACK_PARTS" -ne 0 && "$CALLBACK_PARTS" -ne 3 ]]; then
  err "--callback-url, --token and --session-id must be provided together"
fi
if [[ "$CALLBACK_PARTS" -eq 3 ]]; then
  [[ "$ROLE_TYPE" == "org-inventory" ]] || err "the Quick Setup callback is only supported for --role-type org-inventory"
  [[ "$CALLBACK_URL" =~ ^https://(webhook\.quiverstone\.io|webhook\.[a-z0-9-]+\.qvst\.io|[a-z0-9]+\.execute-api\.[a-z0-9-]+\.amazonaws\.com)(/[A-Za-z0-9._/-]*)?$ ]] \
    || err "--callback-url must be a Quiverstone webhook or API Gateway https URL"
  [[ "$TOKEN" =~ ^[A-Za-z0-9_-]{16,128}$ ]] || err "--token has an unexpected format"
  [[ "$SESSION_ID" =~ ^[a-f0-9-]{36}$ ]] || err "--session-id has an unexpected format"
fi

# ── Preflight ────────────────────────────────────────────────────────────────
command -v aws >/dev/null 2>&1 || err "aws CLI not found — run this from AWS CloudShell"
command -v curl >/dev/null 2>&1 || err "curl not found — run this from AWS CloudShell"

info "Checking AWS identity..."
if ! CALLER="$(aws sts get-caller-identity --query '[Account, Arn]' --output text 2>&1)"; then
  err "unable to call sts:GetCallerIdentity — are you signed in? AWS said: $CALLER"
fi
ACCOUNT_ID="$(awk '{print $1}' <<<"$CALLER")"
CALLER_ARN="$(awk '{print $2}' <<<"$CALLER")"
[[ "$ACCOUNT_ID" =~ $ACCOUNT_RE ]] || err "unexpected account id: $ACCOUNT_ID"
info "Signed in to account $ACCOUNT_ID as $CALLER_ARN"
info "CloudShell region: ${AWS_REGION:-${AWS_DEFAULT_REGION:-unknown}} — stack region: $REGION (IAM roles are global; the region only decides where the stack lives)"

if [[ -n "$EXPECTED_ACCOUNT_ID" && "$EXPECTED_ACCOUNT_ID" != "$ACCOUNT_ID" ]]; then
  err "you are signed in to account $ACCOUNT_ID but this command was generated for account $EXPECTED_ACCOUNT_ID. Open CloudShell in account $EXPECTED_ACCOUNT_ID and run the command again."
fi

if [[ "$ROLE_TYPE" == "org-inventory" ]]; then
  # Piped/non-interactive runs cannot prompt, so a mismatch is a hard stop with guidance.
  MGMT_ACCOUNT_ID="$(aws organizations describe-organization --query Organization.MasterAccountId --output text 2>/dev/null || true)"
  if [[ -z "$MGMT_ACCOUNT_ID" || "$MGMT_ACCOUNT_ID" == "None" ]]; then
    err "account $ACCOUNT_ID does not appear to belong to an AWS Organization (or you lack organizations:DescribeOrganization). Run this from your Organization management account, or use --role-type standalone-inventory for an account outside an Organization."
  fi
  if [[ "$ACCOUNT_TYPE" == "management" && "$MGMT_ACCOUNT_ID" != "$ACCOUNT_ID" ]]; then
    err "you are signed in to account $ACCOUNT_ID but the Organization management account is $MGMT_ACCOUNT_ID. Sign in to the management account's CloudShell and run the command again (or pass --account-type delegated-admin if $ACCOUNT_ID is a delegated administrator)."
  fi
  if [[ "$ACCOUNT_TYPE" == "delegated-admin" && "$MGMT_ACCOUNT_ID" == "$ACCOUNT_ID" ]]; then
    warn "account $ACCOUNT_ID is the management account; --account-type management grants the full inventory permission set."
  fi
fi

# A stack stuck in ROLLBACK_COMPLETE (first create failed) holds no resources
# and cannot be updated — remove it so the deploy can start cleanly.
STACK_STATUS="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" \
  --query 'Stacks[0].StackStatus' --output text 2>/dev/null || true)"
case "$STACK_STATUS" in
  ROLLBACK_COMPLETE)
    info "Stack $STACK_NAME is in ROLLBACK_COMPLETE from an earlier failed attempt (it holds no resources); deleting it first..."
    aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION"
    aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$REGION"
    STACK_STATUS="" ;;
  *_IN_PROGRESS)
    err "stack $STACK_NAME in $REGION is currently $STACK_STATUS. Wait for it to finish and run the command again." ;;
esac

# IAM role names are global to the account. If the role already exists and is
# not owned by this stack in this region, CloudFormation fails with a terse
# "already exists" — explain it up front instead.
if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  OWNED_BY_STACK=""
  if [[ -n "$STACK_STATUS" && "$STACK_STATUS" != "None" ]]; then
    OWNED_BY_STACK="$(aws cloudformation describe-stack-resources --stack-name "$STACK_NAME" --region "$REGION" \
      --query "StackResources[?ResourceType=='AWS::IAM::Role' && PhysicalResourceId=='$ROLE_NAME'] | [0].PhysicalResourceId" \
      --output text 2>/dev/null || true)"
  fi
  if [[ "$OWNED_BY_STACK" != "$ROLE_NAME" ]]; then
    OWNER_HINT="$(aws iam list-role-tags --role-name "$ROLE_NAME" \
      --query "Tags[?Key=='aws:cloudformation:stack-id'] | [0].Value" --output text 2>/dev/null || true)"
    if [[ "$OWNER_HINT" =~ ^arn:aws:cloudformation:([a-z0-9-]+):[0-9]{12}:stack/([^/]+)/ ]]; then
      err "IAM role '$ROLE_NAME' already exists and belongs to stack '${BASH_REMATCH[2]}' in ${BASH_REMATCH[1]}. Re-run with --region ${BASH_REMATCH[1]} --stack-name ${BASH_REMATCH[2]} to update it, or choose a different --role-name."
    fi
    err "IAM role '$ROLE_NAME' already exists in account $ACCOUNT_ID but is not managed by stack '$STACK_NAME' in $REGION. IAM role names are global, so it was created manually or by a stack in another region. Re-run with the --region/--stack-name of that stack, delete the existing role, or choose a different --role-name."
  fi
fi

# ── Fetch template ───────────────────────────────────────────────────────────
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

TEMPLATE_URL="$TEMPLATE_BASE/$TEMPLATE_PATH"
info "Fetching CloudFormation template $TEMPLATE_URL ..."
HTTP_CODE="$(curl -sS -L -o "$TMP/template.yaml" -w '%{http_code}' "$TEMPLATE_URL" 2>"$TMP/curl.err" || true)"
if [[ "$HTTP_CODE" != "200" ]]; then
  err "could not download the template (HTTP ${HTTP_CODE:-none}) from $TEMPLATE_URL. $(tr -d '\n' <"$TMP/curl.err") If this persists, the Quiverstone role catalog may have moved — contact Quiverstone support."
fi
grep -q 'AWSTemplateFormatVersion' "$TMP/template.yaml" || err "the file at $TEMPLATE_URL is not a CloudFormation template"

# ── Parameters (names match the published role-catalog templates) ───────────
declare -a PARAMS=()
case "$ROLE_TYPE:$VARIANT" in
  org-inventory:direct)
    PARAMS=("pRoleName=$ROLE_NAME" "pExternalId=$EXTERNAL_ID") ;;
  org-inventory:chained)
    PARAMS=("pInventoryRoleName=$ROLE_NAME" "pIntermediateAccountId=$INTERMEDIATE_ACCOUNT_ID"
            "pIntermediateRoleName=$INTERMEDIATE_ROLE_NAME" "pTrustPrincipals=$TRUST_PRINCIPALS"
            "pExternalId=$EXTERNAL_ID") ;;
  standalone-inventory:direct)
    PARAMS=("pRoleName=$ROLE_NAME" "pExternalId=$EXTERNAL_ID") ;;
  account-access:browser)
    PARAMS=("pRoleName=$ROLE_NAME" "pTrustedAccountId=$TRUSTED_ACCOUNT_ID") ;;
  account-access:direct)
    PARAMS=("pRoleName=$ROLE_NAME" "pExternalId=$EXTERNAL_ID") ;;
  account-access:chained)
    PARAMS=("pChainedAccessRoleName=$ROLE_NAME" "pIntermediateAccountId=$INTERMEDIATE_ACCOUNT_ID"
            "pIntermediateRoleName=$INTERMEDIATE_ROLE_NAME" "pTrustPrincipals=$TRUST_PRINCIPALS"
            "pExternalId=$EXTERNAL_ID") ;;
  intermediate:direct)
    PARAMS=("pIntermediateRoleName=$ROLE_NAME" "pExternalId=$EXTERNAL_ID" "pAssumeRoleScope=$ASSUME_SCOPE"
            "pDestinationRoleName=$DESTINATION_ROLE_NAME" "pDestinationAccountId=$DESTINATION_ACCOUNT_ID") ;;
esac
if [[ "$ROLE_TYPE" == "org-inventory" ]]; then
  if [[ "$ACCOUNT_TYPE" == "delegated-admin" ]]; then PARAMS+=("pAccountType=DELEGATED_ADMIN"); else PARAMS+=("pAccountType=MANAGEMENT"); fi
fi
if [[ ${#PERMISSION_PARAMS[@]} -gt 0 ]]; then
  PARAMS+=("${PERMISSION_PARAMS[@]}")
fi

# ── Deploy ───────────────────────────────────────────────────────────────────
info "Deploying CloudFormation stack '$STACK_NAME' ($ROLE_TYPE/$VARIANT) in $REGION (this can take a minute)..."
DEPLOY_STARTED=1
aws cloudformation deploy \
  --template-file "$TMP/template.yaml" \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset \
  --tags "quiverstone:role-type=$ROLE_TYPE" "quiverstone:variant=$VARIANT" \
  --parameter-overrides "${PARAMS[@]}"
DEPLOY_STARTED=0

# ── Resolve the deployed role ARN from stack outputs ─────────────────────────
ROLE_ARN=""
for OUTPUT_KEY in oTargetRoleArn oIntermediateRoleArn oRoleArn; do
  # Chained templates also output the (constructed) intermediate ARN — only
  # read it for the intermediate role type.
  [[ "$OUTPUT_KEY" == "oIntermediateRoleArn" && "$ROLE_TYPE" != "intermediate" ]] && continue
  ROLE_ARN="$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='$OUTPUT_KEY'].OutputValue | [0]" \
    --output text 2>/dev/null || true)"
  [[ -n "$ROLE_ARN" && "$ROLE_ARN" != "None" ]] && break
  ROLE_ARN=""
done
[[ -n "$ROLE_ARN" ]] || ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"

printf '\n────────────────────────────────────────────────────────────\n'
printf ' Quiverstone role deployed successfully\n'
printf '────────────────────────────────────────────────────────────\n'
printf ' AWS account:   %s\n' "$ACCOUNT_ID"
printf ' Role type:     %s (%s)\n' "$ROLE_TYPE" "$VARIANT"
printf ' Stack name:    %s (%s)\n' "$STACK_NAME" "$REGION"
printf ' Role ARN:      %s\n' "$ROLE_ARN"
if [[ "$VARIANT" == "chained" ]]; then
  printf ' Intermediate:  %s\n' "$INTERMEDIATE_ROLE_ARN"
fi
if [[ "$VARIANT" == "browser" ]]; then
  printf ' Switch role:   https://signin.aws.amazon.com/switchrole?account=%s&roleName=%s\n' "$ACCOUNT_ID" "$ROLE_NAME"
fi
printf '────────────────────────────────────────────────────────────\n'
printf 'Return to Quiverstone to finish setup. If the form did not\n'
printf 'update automatically, paste the Role ARN above into it.\n\n'

# ── Optional callback to Quiverstone (org inventory Quick Setup) ─────────────
if [[ "$CALLBACK_PARTS" -eq 3 ]]; then
  info "Notifying Quiverstone..."
  PAYLOAD="$(printf '{"sessionId":"%s","token":"%s","accountId":"%s","variant":"%s","roleArn":"%s","intermediateRoleArn":"%s","stackName":"%s","region":"%s"}' \
    "$SESSION_ID" "$TOKEN" "$ACCOUNT_ID" "$VARIANT" "$ROLE_ARN" "$INTERMEDIATE_ROLE_ARN" "$STACK_NAME" "$REGION")"
  if curl -fsS --retry 3 --retry-delay 2 -m 15 -X POST "$CALLBACK_URL" \
    -H 'Content-Type: application/json' \
    -d "$PAYLOAD" >/dev/null; then
    info "Quiverstone notified — the Quick Setup form should now be populated."
  else
    warn "automatic notification failed. The role was deployed — paste the Role ARN shown above into the Quiverstone form manually."
  fi
fi

exit 0
