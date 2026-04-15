# Account Access Role Templates

This directory contains CloudFormation templates for deploying Quiverstone account access roles. These roles enable secure access to AWS accounts through three different methods: Browser Session, Direct Access, and Chained Access. Templates are available for both individual account deployment and organization-wide deployment using CloudFormation StackSets.

## Overview

Access roles provide varying levels of permissions to AWS accounts, from read-only access to full administrative access. Choose the access method and deployment type that best fits your security requirements and organizational structure.

## Access Templates

This directory contains 6 CloudFormation templates:

### Individual Account Templates

#### browser-access-role.yaml

**Description:** Quiverstone Browser Role - Provides varying levels of access to AWS Accounts for browser-based role switching from a trusted account you are currently logged into.

**Deploy To:** Any or all Account(s) Home Region (e.g. us-east-1)

**Version:** 1.0.0

**Key Features:**

- Browser-based role switching for interactive AWS Console access
- Does NOT support External ID (browser session authentication only)
- Configurable permission levels (Read-Only, Administrator, Power User, etc.)
- Requires authentication to trusted account in same browser session

**Key Parameters:**

- `pRoleName`: Name for the browser-accessible role (Default: QuiverstoneBrowserSession)
- `pTrustedAccountId`: AWS Account ID you have access to that can assume this role via browser session
- Permission flags: `pIsReadOnlyAccess`, `pIsAdministratorAccess`, `pIsPowerUserAccess`, `pIsViewOnlyAccess`, `pIsSecurityAudit`, `pIsSystemAdministrator`, `pIsSupportUser`, `pIsBillingAccess`

#### direct-access-role.yaml

**Description:** Quiverstone Direct to Account Access Role - Provides varying levels of access to AWS Accounts for federated role switching from the Quiverstone application.

**Deploy To:** Any or all Account(s) Home Region (e.g. us-east-1)

**Version:** 1.0.0

**Key Features:**

- Direct assumption from Quiverstone production account (684035162433)
- Supports External ID for enhanced security (recommended)
- Simplest deployment option with minimal configuration
- Federated access through Quiverstone application

**Key Parameters:**

- `pRoleName`: Name for the federated access role (Default: QuiverstoneDirectAccess)
- `pQuiverstoneProductionAccountId`: Quiverstone production account ID (Default: 684035162433)
- `pExternalId`: External ID for additional security (recommended)
- Permission flags: Same as browser-access-role.yaml

#### chained-access-role.yaml

**Description:** Quiverstone Chained Access Role - Deploys in target accounts to allow access through role chaining.

**Deploy To:** Individual Account Home Region (e.g. us-east-1)

**Version:** 1.0.0

**Key Features:**

- Multi-hop role assumption through intermediate account
- Enhanced security through role chaining architecture
- Supports External ID for both destination and intermediate roles
- Requires trusted intermediate account

**Key Parameters:**

- `pChainedAccessRoleName`: Name for the destination account access role (Default: QuiverstoneChainedAccess)
- `pExternalId`: External ID for role assumption (recommended)
- `pIntermediateAccountId`: AWS Account ID that serves as the intermediate hop
- `pTrustPrincipals`: Trust all principals in intermediate account (All) or only a named role (Named)
- `pIntermediateRoleName`: Name of the role in the intermediate account (Default: QuiverstoneTrustedIntermediate)
- Permission flags: Same as browser-access-role.yaml

### Organization StackSet Templates

#### browser-access-role-stackset.yaml

**Description:** Quiverstone Browser Role StackSet - Deploys browser-accessible roles across all organization accounts.

**Deploy To:** Management or Delegated CloudFormation StackSet Account Home Region (e.g. us-east-1)

**Version:** 1.0.0

**Key Features:**

- Deploy browser-accessible roles across multiple accounts simultaneously
- Automatic deployment to new accounts
- Centralized management from management account

**Key Parameters:**

- `pDeploymentOUs`: Organization Unit IDs to deploy to (comma-separated)
- `pDeploymentRegion`: AWS Region to deploy the roles (Default: us-east-1)
- `pRoleName`: Name for the browser-accessible role (Default: QuiverstoneBrowserSession)
- `pTrustedAccountId`: AWS Account ID you have access to that can assume this role
- Permission flags: Same as browser-access-role.yaml

#### direct-access-role-stackset.yaml

**Description:** Quiverstone Direct to Account Access Role StackSet - Deploys federated role across all Organization Accounts for federated role switching from the Quiverstone application.

**Deploy To:** Management or Delegated CloudFormation StackSet Account Home Region (e.g. us-east-1)

**Version:** 1.0.0

**Key Features:**

- Deploy direct access roles across multiple accounts simultaneously
- Automatic deployment to new accounts
- Centralized management from management account

**Key Parameters:**

- `pDeploymentOUs`: Organization Unit IDs to deploy to (comma-separated)
- `pDeploymentRegion`: AWS Region to deploy the roles (Default: us-east-1)
- `pRoleName`: Name for the federated access role (Default: QuiverstoneDirectAccess)
- `pQuiverstoneProductionAccountId`: Quiverstone production account ID (Default: 684035162433)
- `pExternalId`: External ID for additional security (recommended)
- Permission flags: Same as browser-access-role.yaml

#### chained-access-role-stackset.yaml

**Description:** Quiverstone Chained Access Role StackSet - Deploys chained access role across all organization accounts.

**Deploy To:** Management Account Home Region (e.g. us-east-1)

**Version:** 1.0.0

**Key Features:**

- Deploy chained access roles across multiple accounts simultaneously
- Automatic deployment to new accounts
- Enhanced security through role chaining architecture

**Key Parameters:**

- `pDeploymentOUs`: Organization Unit IDs to deploy to (comma-separated)
- `pDeploymentRegion`: AWS Region to deploy the roles (Default: us-east-1)
- `pChainedAccessRoleName`: Name for the destination account access role (Default: QuiverstoneChainedAccess)
- `pExternalId`: External ID for role assumption (recommended)
- `pIntermediateAccountId`: AWS Account ID that serves as the intermediate hop
- `pTrustPrincipals`: Trust all principals in intermediate account (All) or only a named role (Named)
- `pIntermediateRoleName`: Name of the role in the intermediate account (Default: QuiverstoneTrustedIntermediate)
- Permission flags: Same as browser-access-role.yaml

## Access Method Comparison

### Browser Session Access

**How it works:** Role assumption through AWS Console browser session. Requires authentication to a trusted AWS account in the same browser session.

**When to use:**

- Manual console access for troubleshooting
- Interactive operations required
- User-driven account access scenarios
- Ad-hoc access needs

**Security considerations:**

- Does NOT support External ID
- Relies on browser session authentication
- Suitable for interactive use cases

**Best for:** Small teams, manual operations, troubleshooting

### Direct Access

**How it works:** Direct assumption from Quiverstone production account (684035162433) to target accounts using federated URLs.

**When to use:**

- Quick setup for basic account access
- Security policies allow direct external account trust
- No requirement for additional security layers
- Streamlined access without intermediate hops

**Security considerations:**

- Supports External ID (recommended)
- Direct trust relationship with Quiverstone production account
- All role assumptions logged in CloudTrail

**Best for:** Standard deployments, organizations comfortable with direct trust relationships

### Chained Access

**How it works:** Multi-hop role assumption through an intermediate trusted account. Quiverstone assumes a role in the intermediate account, which then assumes roles in destination accounts.

**When to use:**

- Security policies require additional layers beyond direct access
- Compliance mandates intermediate account controls
- Want to audit all role assumptions through a single point
- Have existing intermediate role infrastructure
- Need additional security boundaries

**Security considerations:**

- Supports External ID for both intermediate and destination roles
- Additional security layer through intermediate account
- All assumptions flow through auditable intermediate point
- More complex setup but enhanced security

**Best for:** Large enterprises, highly regulated environments, organizations requiring additional security controls

## Deployment Type Comparison

### Individual Account Deployment

**How it works:** Deploy CloudFormation template to a single AWS account.

**When to use:**

- Small number of accounts (< 10)
- Testing or proof-of-concept deployments
- Accounts not part of an AWS Organization
- Need account-specific customization

**Advantages:**

- Simple and straightforward
- Quick setup
- Full control per account
- No organization prerequisites

**Disadvantages:**

- Manual deployment to each account
- Difficult to maintain consistency across many accounts
- No automatic deployment to new accounts

**Best for:** Small organizations, standalone accounts, testing

### StackSet Deployment

**How it works:** Deploy CloudFormation template across multiple accounts and regions using CloudFormation StackSets from the management account.

**When to use:**

- Medium to large organizations (10+ accounts)
- AWS Organization structure in place
- Need consistent deployment across accounts
- Want automatic deployment to new accounts

**Advantages:**

- Single operation deploys to hundreds of accounts
- Automatic deployment to new accounts
- Centralized management and updates
- Consistent configuration across organization
- Regional deployment support

**Disadvantages:**

- Requires AWS Organization setup
- Additional IAM permissions needed
- More complex initial configuration

**Best for:** Medium to large organizations, organization-wide deployments

## Quick Launch - Individual Account Templates

| Template                | Description                                                      | Deploy To          | Launch                                                                                                                                                                                                                                                                                                                                                   |
| ----------------------- | ---------------------------------------------------------------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Browser Access Role** | Browser-based role switching for console access                  | Any Account        | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/browser-access-role.yaml&stackName=quiverstone-browser-access-role) |
| **Direct Access Role**  | Direct assumption for federated account access                   | Any Account        | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/direct-access-role.yaml&stackName=quiverstone-direct-access-role)   |
| **Chained Access Role** | Destination role for chained access through intermediate account | Individual Account | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/chained-access-role.yaml&stackName=quiverstone-chained-access-role) |

## Quick Launch - StackSet Templates

| Template                         | Description                                                       | Deploy To          | Launch                                                                                                                                                                                                                                                                                                                                                                     |
| -------------------------------- | ----------------------------------------------------------------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Browser Access Role StackSet** | Deploy browser roles across all organization accounts             | Management Account | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/browser-access-role-stackset.yaml&stackName=stackset-quiverstone-browser-access-role) |
| **Direct Access Role StackSet**  | Deploy direct access roles across all organization accounts       | Management Account | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/direct-access-role-stackset.yaml&stackName=stackset-quiverstone-direct-access-role)   |
| **Chained Access Role StackSet** | Deploy chained destination roles across all organization accounts | Management Account | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/chained-access-role-stackset.yaml&stackName=stackset-quiverstone-chained-access-role) |

## Configuration Guidance

### Permission Levels

All access templates support configurable permission levels through boolean parameters. By default, only Read-Only access is enabled. You can enable multiple permission levels simultaneously:

- **Read-Only Access** (`pIsReadOnlyAccess`): AWS managed ReadOnlyAccess policy - view all resources but make no changes
- **Administrator Access** (`pIsAdministratorAccess`): Full administrative access to all AWS services
- **Power User Access** (`pIsPowerUserAccess`): Full access except IAM and Organizations management
- **View-Only Access** (`pIsViewOnlyAccess`): AWS managed ViewOnlyAccess policy - read-only access without describe permissions
- **Security Audit** (`pIsSecurityAudit`): AWS managed SecurityAudit policy - permissions for security auditing
- **System Administrator** (`pIsSystemAdministrator`): AWS managed SystemAdministrator policy - system administration tasks
- **Support User** (`pIsSupportUser`): AWS managed SupportUser policy - create and manage AWS Support cases
- **Billing Access** (`pIsBillingAccess`): AWS managed Billing policy - view and manage billing information

### External ID Configuration

External IDs provide an additional layer of security to prevent the "confused deputy" problem in cross-account access:

- **Browser Access**: Does NOT support External ID (uses browser session authentication)
- **Direct Access**: Supports External ID (strongly recommended)
- **Chained Access**: Supports External ID for both destination and intermediate roles (strongly recommended)

**Best Practice:** Always use External ID when supported. Generate a unique, random string (minimum 32 characters) and store it securely.

### Role Naming

Choose descriptive role names that indicate their purpose and access method:

- Default names are provided but can be customized
- Use consistent naming conventions across your organization
- Include environment or purpose indicators if managing multiple role sets

### StackSet Configuration

When deploying StackSets, configure:

- **Deployment OUs**: Comma-separated list of Organization Unit IDs to target
- **Deployment Region**: AWS region where roles will be created (typically us-east-1)
- **Auto-deployment**: Enable to automatically deploy to new accounts added to target OUs

## Prerequisites and IAM Permissions

### For Individual Account Deployment

**Required Permissions:**

- `cloudformation:CreateStack`
- `cloudformation:DescribeStacks`
- `iam:CreateRole`
- `iam:AttachRolePolicy`
- `iam:PutRolePolicy`

**Prerequisites:**

- AWS account access with sufficient IAM permissions
- Quiverstone production account ID (684035162433) for Direct and Chained access
- Trusted account ID for Browser access
- Intermediate account ID for Chained access

### For StackSet Deployment

**Required Permissions:**

- `cloudformation:CreateStackSet`
- `cloudformation:CreateStackInstances`
- `cloudformation:DescribeStackSet`
- `organizations:ListAccounts`
- `organizations:DescribeOrganization`

**Prerequisites:**

- AWS Organization with management account access
- CloudFormation StackSets enabled with organization trust
  - [Enable Trusted Access for StackSets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-orgs-enable-trusted-access.html)
- Service-managed permissions enabled for StackSets
- Target Organization Units identified

## Deployment Recommendations by Organization Size

### Small Organizations (< 10 accounts)

**Recommended Approach:**

- Use individual account templates
- Deploy Direct Access for simplicity
- Manual deployment is manageable at this scale

**Rationale:** Simple setup, quick deployment, minimal overhead

### Medium Organizations (10-50 accounts)

**Recommended Approach:**

- Use StackSet templates for consistent deployment
- Deploy Direct Access or Chained Access based on security requirements
- Enable auto-deployment for new accounts

**Rationale:** Consistent configuration, reduced management overhead, scalable approach

### Large Organizations (50+ accounts)

**Recommended Approach:**

- Use StackSet templates with OU targeting
- Deploy Chained Access for enhanced security and audit capabilities
- Implement intermediate account architecture
- Use Service Catalog for self-service deployment (see service-catalog directory)

**Rationale:** Enhanced security, centralized audit point, scalable management, self-service capabilities

### Highly Regulated Environments

**Recommended Approach:**

- Use Chained Access exclusively
- Implement strict External ID policies
- Deploy through StackSets for consistency
- Limit permission levels to minimum required (avoid Administrator access)

**Rationale:** Additional security layers, comprehensive audit trail, compliance requirements

## Security Features

All access role templates implement security best practices:

### Authentication and Authorization

- **External ID Support**: Additional security token for role assumption (Direct and Chained access)
- **Principle of Least Privilege**: Configurable permission levels, default to Read-Only
- **Trust Policies**: Explicit trust relationships with specific accounts

### Audit and Compliance

- **CloudTrail Integration**: All role assumptions logged automatically
- **MFA Compatible**: Works with MFA-enabled accounts
- **Session Tagging**: Support for session tags in role assumptions

### Access Control

- **Configurable Permissions**: Eight permission levels from View-Only to Administrator
- **Named Principal Support**: Option to trust specific roles (not all principals) in Chained access
- **Regional Deployment**: Deploy roles only in required regions

### Monitoring

- **CloudWatch Integration**: Role usage visible in CloudWatch
- **AWS Config Support**: Track role configuration changes
- **Organizations Integration**: Centralized visibility in organization accounts

## Integration with Other Role Catalog Components

### Intermediate Roles

Chained access templates require deployment of the trusted intermediate role:

- **Template**: `role-catalog/intermediate/trusted-intermediate-role.yaml`
- **Deploy To**: Intermediate/Trusted Account
- **Purpose**: Enables role chaining from Quiverstone to destination accounts
- **Documentation**: See [Intermediate Role README](../intermediate/README.md)

### Inventory Roles

Access roles provide account access, while inventory roles provide organization-level read access:

- **Access Roles**: Account-level access with configurable permissions
- **Inventory Roles**: Organization-level read-only access for account discovery
- **Documentation**: See [Inventory Role README](../inventory/README.md)

## Support and Documentation

### Additional Resources

- **Quiverstone Documentation**: <https://docs.quiverston.io>
- **Individual Account Access Setup**: <https://docs.quiverston.io/setup/accounts/access>
- **Organization Roles Setup**: <https://docs.quiverston.io/setup/organizations/inventory>
- **AWS CloudFormation StackSets**: <https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html>

### Getting Help

For questions about template deployment or configuration:

- Contact your Quiverstone administrator
- Visit the Quiverstone documentation portal
- Review AWS CloudFormation documentation for StackSet troubleshooting

### Troubleshooting

**Common Issues:**

- **StackSet deployment fails**: Verify organization trust is enabled for CloudFormation StackSets
- **Role assumption fails**: Check External ID matches between Quiverstone configuration and template parameters
- **Permission denied**: Verify IAM permissions for CloudFormation and role creation
- **Chained access not working**: Ensure intermediate role is deployed and configured correctly

## Version Information

All templates in this directory are version 1.0.0. Check template metadata for specific version information and update history.
