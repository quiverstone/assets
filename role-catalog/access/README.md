# Account Access Templates

This directory contains CloudFormation templates for deploying Quiverstone account access roles to individual AWS accounts and organization-wide deployments using StackSets.

For additional information on deploying these templates, please visit:

- **Individual account access:** <https://docs.quiverston.io/setup/accounts/access>
- **Organization roles:** <https://docs.quiverston.io/setup/organizations/inventory>

## Templates

### Individual Account Deployment

#### quiverstone-direct-account-access.yaml

Direct assumption from Quiverstone production account for read-only account access. Provides ReadOnlyAccess via AWS managed policy.

#### quiverstone-chained-account-access-destination.yaml

Destination role for chained access in individual account. Trusts intermediate account for enhanced security through role chaining.

#### quiverstone-chained-account-access-intermediate.yaml

Intermediate role for chained access in trusted account. Enables role chaining from Quiverstone production account to destination roles in child accounts.

#### quiverstone-browser-switch-role.yaml

Browser-based role switching for interactive AWS Console access. Provides configurable permissions with browser-friendly role assumption.

### Organization-Wide StackSet Deployment

#### stackset-quiverstone-direct-account-access.yaml

StackSet to deploy direct account access roles across all organization accounts. Enables automatic deployment to new accounts.

#### stackset-quiverstone-chained-account-access-destination.yaml

StackSet to deploy chained destination roles across all organization accounts. Enables automatic deployment to new accounts with role chaining.

#### stackset-quiverstone-browser-switch-role.yaml

StackSet to deploy browser-accessible roles across all organization accounts. Enables automatic deployment to new accounts with browser-based access.

## Quick Launch - Individual Account Templates

| Template                          | Description                                     | Deploy To                    | Launch                                                                                                                                                                                                                                                                                                                                              |
| --------------------------------- | ----------------------------------------------- | ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Direct Account Access**         | Direct assumption for read-only account access  | Individual Account           | [![Launch Stack](../assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/quiverstone-direct-account-access.yaml&stackName=quiverstone-direct-account-access)                             |
| **Chained Access - Destination**  | Destination role for chained access in account  | Individual Account           | [![Launch Stack](../assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/quiverstone-chained-account-access-destination.yaml&stackName=quiverstone-chained-account-access-destination)   |
| **Chained Access - Intermediate** | Intermediate role for chained access            | Intermediate/Trusted Account | [![Launch Stack](../assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/quiverstone-chained-account-access-intermediate.yaml&stackName=quiverstone-chained-account-access-intermediate) |
| **Browser Switch Role**           | Browser-based role switching for console access | Individual Account           | [![Launch Stack](../assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/quiverstone-browser-switch-role.yaml&stackName=quiverstone-browser-switch-role)                                 |

## Quick Launch - Organization StackSet Templates

| Template                                | Description                                                       | Deploy To          | Launch                                                                                                                                                                                                                                                                                                                                                                    |
| --------------------------------------- | ----------------------------------------------------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Direct Account Access StackSet**      | Deploy direct access roles across all organization accounts       | Management Account | [![Launch StackSet](../assets/stackset.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/stackset-quiverstone-direct-account-access.yaml&stackName=stackset-quiverstone-direct-account-access)                           |
| **Chained Access Destination StackSet** | Deploy chained destination roles across all organization accounts | Management Account | [![Launch StackSet](../assets/stackset.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/stackset-quiverstone-chained-account-access-destination.yaml&stackName=stackset-quiverstone-chained-account-access-destination) |
| **Browser Switch Role StackSet**        | Deploy browser roles across all organization accounts             | Management Account | [![Launch StackSet](../assets/stackset.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/stackset-quiverstone-browser-switch-role.yaml&stackName=stackset-quiverstone-browser-switch-role)                               |

## Access Methods

### Direct Access

Direct assumption from Quiverstone production account (684035162433) to target accounts. Simplest deployment option with minimal configuration.

**When to use:**

- Quick setup for basic account access
- Security policies allow direct external account trust
- No requirement for additional security layers

### Chained Access

Multi-hop role assumption through intermediate account for enhanced security.

**When to use:**

- Security policies require additional layers beyond direct access
- Compliance mandates intermediate account controls
- Want to audit all role assumptions through a single point
- Have existing intermediate role infrastructure

### Browser-Based Access

Interactive browser-based role switching for manual AWS Console access.

**When to use:**

- Need manual console access for troubleshooting
- Interactive operations required
- User-driven account access scenarios

## CloudFormation StackSets

StackSets enable deployment of CloudFormation templates across multiple AWS accounts and regions with a single operation. This is the recommended approach for organization-wide access role deployment.

### Prerequisites

1. **Enable Organization Trust for CloudFormation StackSets**
   - [AWS Documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-orgs-enable-trusted-access.html)

2. **Required IAM Permissions**
   - `cloudformation:*` for StackSet operations
   - `organizations:ListAccounts` to discover target accounts
   - `organizations:DescribeOrganization` to validate organization structure

### Key Benefits

- **Single Operation Deployment:** Deploy to hundreds of accounts simultaneously
- **Automatic Account Inclusion:** New accounts automatically receive the stack
- **Centralized Management:** Manage updates and deletions from management account
- **Regional Deployment:** Deploy across multiple regions as needed

## Security Features

All templates implement:

- **Read-Only Access:** AWS managed ReadOnlyAccess policy
- **External ID Support:** Additional security token for role assumption
- **Principle of Least Privilege:** Minimum permissions required
- **Audit Trail:** All role assumptions logged in CloudTrail
- **MFA Compatible:** Works with MFA-enabled accounts

## Common Permissions

All account access templates grant:

### AWS Managed Policies

- ReadOnlyAccess (AWS managed policy)

### Additional Permissions

- Account information (contact details, regions)
- Basic support case access for account health monitoring

## Deployment Recommendations

### Small Organizations (< 10 accounts)

- Use individual templates for direct deployment
- Simple management and quick setup

### Medium Organizations (10-50 accounts)

- Use StackSets for consistent deployment
- Enable auto-deployment for new accounts

### Large Organizations (50+ accounts)

- Use StackSets with organizational unit targeting
- Implement chained access for additional security
- Consider Service Catalog for self-service deployment

## Support

For questions about template deployment or configuration, contact your Quiverstone administrator or visit the documentation at <https://docs.quiverston.io>.
