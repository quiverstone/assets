# Organization and Standalone Account Inventory Templates

This directory contains CloudFormation templates for deploying Quiverstone inventory roles. These roles provide read-only access to AWS Organizations and standalone accounts for inventory and discovery purposes. Inventory roles enable Quiverstone to discover and catalog your AWS accounts, organizational structure, and resources.

## Overview

Inventory roles grant read-only permissions to list and describe AWS accounts within an organization or standalone account. These roles are essential for Quiverstone to maintain an accurate inventory of your AWS environment. Choose the inventory role type that matches your account structure and security requirements.

## Inventory Templates

This directory contains 3 CloudFormation templates and 1 IAM policy document:

### Organization Inventory Templates

#### direct-org-inventory-role.yaml

**Description:** Quiverstone Organization Inventory Role - Deploys inventory role in Organization account that can be assumed directly from Quiverstone.

**Deploy To:** Management/Delegated Account Home Region (e.g. us-east-1)

**Version:** 1.0.0

**Key Features:**
- Direct assumption from Quiverstone production account (684035162433)
- Read-only access to AWS Organizations APIs
- Supports External ID for enhanced security (recommended)
- Simplest deployment option for organization inventory

**Key Parameters:**
- `pRoleName`: Name for the direct organization inventory role (Default: QuiverstoneDirectOrgInventory)
- `pQuiverstoneProductionAccountId`: Quiverstone production account ID (Default: 684035162433)
- `pExternalId`: External ID for additional security (recommended)

**Permissions Granted:**
- `organizations:List*`: List all organization resources
- `organizations:Describe*`: Describe organization structure and accounts

#### chained-org-inventory-role.yaml

**Description:** Quiverstone Chained Organization Inventory Role - Deploys inventory role in Organization account that can be assumed via role chaining from intermediate account.

**Deploy To:** Management/Delegate Org Account in Home Region(e.g. us-east-1)

**Version:** 1.0.0

**Key Features:**
- Multi-hop role assumption through intermediate account
- Read-only access to AWS Organizations APIs
- Enhanced security through role chaining architecture
- Supports External ID for both destination and intermediate roles

**Key Parameters:**
- `pInventoryRoleName`: Name for the destination organization inventory role (Default: QuiverstoneChainedOrgInventory)
- `pExternalId`: External ID for role assumption (recommended for security)
- `pIntermediateAccountId`: AWS Account ID that serves as the intermediate hop for role chaining
- `pTrustPrincipals`: Trust all principals in the intermediate account (All) or only a named role (Named)
- `pIntermediateRoleName`: Name of the role in the intermediate account (Default: QuiverstoneTrustedIntermediate)
- `pIntermediateRoleExternalId`: External ID for Intermediate role assumption (reference only)

**Permissions Granted:**
- `organizations:List*`: List all organization resources
- `organizations:Describe*`: Describe organization structure and accounts

### Standalone Account Inventory Template

#### standalone-account-inventory-role.yaml

**Description:** Quiverstone Standalone Account Inventory Role - Provides read-only access to a Standalone account for inventory purposes.

**Deploy To:** Management Account Home Region (e.g. us-east-1)

**Version:** 1.0.0

**Key Features:**
- Direct assumption from Quiverstone production account (684035162433)
- Read-only access for account-level inventory
- Supports External ID for enhanced security (recommended)
- For accounts not part of an AWS Organization

**Key Parameters:**
- `pRoleName`: Name for the direct organization inventory role (Default: QuiverstoneStandaloneAccountInventory)
- `pQuiverstoneProductionAccountId`: Quiverstone production account ID (Default: 684035162433)
- `pExternalId`: External ID for additional security (recommended)

**Permissions Granted:**
- Read-only access to account metadata and basic resource information
- No organization-level permissions (account is standalone)

### Organization Delegation Policy

#### organization-delegation-policy.json

**Type:** IAM Resource Policy (not a CloudFormation template)

**Purpose:** This policy document delegates AWS Organizations read permissions from a Management Account to a Delegated Administrator account. It allows the delegated account to list and describe organization resources without requiring management account credentials.

**Usage:**
1. Replace `{DelegatedOrganizationAccountId}` placeholder with your delegated administrator account ID
2. Attach this policy as a resource policy in the AWS Organizations service
3. Deploy the inventory role template to the delegated administrator account

**Policy Permissions:**
- **Effect:** Allow
- **Principal:** Delegated administrator account ARN
- **Actions:** `organizations:List*`, `organizations:Describe*`
- **Resource:** All organization resources

**When to Use:**
- Security policies prohibit direct management account access
- Want to delegate organization inventory to a specific account
- Implementing least privilege access patterns
- Separating management account responsibilities

## Account Type Comparison

### Management Account Inventory

**How it works:** Deploy inventory role directly in the AWS Organizations management account with full organization read access.

**When to use:**
- You have direct access to the management account
- Security policies allow external role assumption in management account
- Want simplest deployment with fewest components
- No delegation requirements

**Advantages:**
- Direct access to all organization data
- Simplest configuration
- No additional delegation setup required
- Complete organization visibility

**Disadvantages:**
- Requires management account access
- External role in management account (some policies restrict this)
- All assumptions occur in management account

**Best for:** Small to medium organizations, straightforward security policies

### Delegated Administrator Account Inventory

**How it works:** Use organization-delegation-policy.json to delegate organization read permissions to a designated administrator account, then deploy inventory role in that account.

**When to use:**
- Security policies restrict external access to management account
- Want to separate management account responsibilities
- Implementing least privilege access patterns
- Have designated administrator accounts for specific functions

**Advantages:**
- Management account remains isolated
- Follows AWS best practices for delegation
- Centralized administration in delegated account
- Maintains full organization visibility

**Disadvantages:**
- Requires delegation policy setup
- Additional configuration step
- Need to manage delegated account permissions

**Best for:** Large organizations, highly regulated environments, security-conscious deployments

### Standalone Account Inventory

**How it works:** Deploy inventory role in an AWS account that is not part of an AWS Organization.

**When to use:**
- Account is not part of an AWS Organization
- Single account deployment
- Testing or proof-of-concept scenarios
- Small businesses with single AWS account

**Advantages:**
- Simple deployment for non-organization accounts
- No organization prerequisites
- Quick setup

**Disadvantages:**
- No organization-level visibility
- Limited to single account inventory
- Must deploy separately to each standalone account

**Best for:** Standalone accounts, single account deployments, testing

## Access Method Comparison

### Direct Inventory Access

**How it works:** Inventory role trusts Quiverstone production account (684035162433) directly for role assumption.

**When to use:**
- Security policies allow direct external account trust
- Want simplest configuration
- No requirement for additional security layers
- Standard deployment scenarios

**Security considerations:**
- Supports External ID (recommended)
- Direct trust relationship with Quiverstone production account
- All role assumptions logged in CloudTrail
- Read-only permissions minimize risk

**Best for:** Standard deployments, organizations comfortable with direct trust relationships

### Chained Inventory Access

**How it works:** Multi-hop role assumption through an intermediate trusted account. Quiverstone assumes a role in the intermediate account, which then assumes the inventory role.

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
- Read-only permissions minimize risk

**Best for:** Large enterprises, highly regulated environments, organizations requiring additional security controls

## Quick Launch - Inventory Templates

| Template | Description | Deploy To | Launch |
|----------|-------------|-----------|--------|
| **Direct Org Inventory Role** | Direct assumption for organization inventory | Management/Delegated Account | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/inventory/direct-org-inventory-role.yaml&stackName=quiverstone-direct-org-inventory-role) |
| **Chained Org Inventory Role** | Chained assumption for organization inventory through intermediate account | Management/Delegated Account | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/inventory/chained-org-inventory-role.yaml&stackName=quiverstone-chained-org-inventory-role) |
| **Standalone Account Inventory Role** | Direct assumption for standalone account inventory | Standalone Account | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/inventory/standalone-account-inventory-role.yaml&stackName=quiverstone-standalone-account-inventory-role) |

## Configuration Guidance

### Role Naming

Choose descriptive role names that indicate their purpose:

- Default names clearly indicate inventory purpose and access method
- Use consistent naming conventions across your organization
- Include environment indicators if managing multiple role sets
- Recommended pattern: `Quiverstone[AccessMethod][AccountType]Inventory`

### External ID Configuration

External IDs provide an additional layer of security to prevent the "confused deputy" problem in cross-account access:

- **Direct Inventory Access**: Supports External ID (strongly recommended)
- **Chained Inventory Access**: Supports External ID for both destination and intermediate roles (strongly recommended)

**Best Practice:** Always use External ID. Generate a unique, random string (minimum 32 characters) and store it securely. Configure the same External ID in both the CloudFormation template and your Quiverstone account settings.

### Deployment Region

Inventory roles should be deployed in your organization's home region (typically us-east-1):

- AWS Organizations is a global service accessed through home region
- Deploy inventory roles in the same region as your organization
- Most organizations use us-east-1 as home region
- Verify your organization's home region before deployment

### Trust Configuration for Chained Access

When deploying chained inventory roles, configure trust relationships:

- **Trust All Principals (All)**: Any principal in the intermediate account can assume the role
  - Simpler configuration
  - Suitable when intermediate account is tightly controlled
- **Trust Named Role (Named)**: Only a specific role in the intermediate account can assume the role
  - Enhanced security through explicit trust
  - Requires specifying exact intermediate role name
  - Recommended for production deployments

## Permissions Granted

### Organization Inventory Roles

Organization inventory roles (both direct and chained) grant read-only access to AWS Organizations:

**AWS Organizations Permissions:**
- `organizations:ListAccounts`: List all accounts in the organization
- `organizations:ListAccountsForParent`: List accounts within organizational units
- `organizations:ListOrganizationalUnitsForParent`: List organizational units
- `organizations:ListRoots`: List organization roots
- `organizations:DescribeAccount`: Get detailed account information
- `organizations:DescribeOrganization`: Get organization details
- `organizations:DescribeOrganizationalUnit`: Get OU details
- `organizations:ListParents`: List parent containers for resources
- `organizations:ListChildren`: List child resources
- `organizations:ListTagsForResource`: List tags on organization resources

**What These Permissions Enable:**
- Discover all accounts in your organization
- Map organizational structure (OUs, accounts, hierarchy)
- Retrieve account metadata (name, email, status)
- Understand organization configuration
- Track organizational changes over time

**What These Permissions Do NOT Allow:**
- Modify organization structure
- Create or delete accounts
- Change account settings
- Modify organizational policies
- Access resources within accounts
- Any write operations

### Standalone Account Inventory Role

Standalone account inventory roles grant read-only access to account-level information:

**Account-Level Permissions:**
- Basic account metadata access
- No organization-level permissions (account is not in an organization)
- Read-only access to account configuration

**What These Permissions Enable:**
- Identify the standalone account
- Retrieve basic account information
- Track account configuration

## Deployment Scenarios and Use Cases

### Scenario 1: Standard Organization with Management Account Access

**Setup:**
- AWS Organization with management account access
- Security policies allow external role assumption in management account
- Want simplest deployment

**Recommended Template:** `direct-org-inventory-role.yaml`

**Deployment Steps:**
1. Log into AWS management account
2. Deploy direct-org-inventory-role.yaml via Quick Launch
3. Configure External ID parameter (generate secure random string)
4. Note the role ARN and External ID
5. Configure Quiverstone with role ARN and External ID

**Benefits:** Simplest setup, direct access, minimal configuration

### Scenario 2: Organization with Delegated Administrator

**Setup:**
- AWS Organization with delegated administrator account
- Security policies restrict external access to management account
- Want to follow AWS delegation best practices

**Recommended Template:** `direct-org-inventory-role.yaml` + `organization-delegation-policy.json`

**Deployment Steps:**
1. Log into AWS management account
2. Edit organization-delegation-policy.json and replace `{DelegatedOrganizationAccountId}` with delegated account ID
3. Attach delegation policy to AWS Organizations service
4. Log into delegated administrator account
5. Deploy direct-org-inventory-role.yaml via Quick Launch
6. Configure External ID parameter
7. Note the role ARN and External ID
8. Configure Quiverstone with role ARN and External ID

**Benefits:** Management account isolation, follows AWS best practices, centralized administration

### Scenario 3: High-Security Organization with Chained Access

**Setup:**
- AWS Organization with strict security requirements
- Compliance mandates intermediate account controls
- Want additional security layers and audit capabilities

**Recommended Template:** `chained-org-inventory-role.yaml` + intermediate role

**Deployment Steps:**
1. Deploy trusted intermediate role in intermediate account (see [Intermediate Role README](../intermediate/README.md))
2. Log into AWS management account (or delegated administrator account)
3. Deploy chained-org-inventory-role.yaml via Quick Launch
4. Configure External ID parameter for inventory role
5. Configure intermediate account ID and role name
6. Set pTrustPrincipals to "Named" for enhanced security
7. Note the role ARN and External ID
8. Configure Quiverstone with role ARN, External ID, and intermediate role details

**Benefits:** Enhanced security, additional audit layer, compliance-friendly

### Scenario 4: Standalone Account (Not in Organization)

**Setup:**
- Single AWS account not part of an organization
- Want Quiverstone inventory for standalone account
- No organization structure

**Recommended Template:** `standalone-account-inventory-role.yaml`

**Deployment Steps:**
1. Log into standalone AWS account
2. Deploy standalone-account-inventory-role.yaml via Quick Launch
3. Configure External ID parameter
4. Note the role ARN and External ID
5. Configure Quiverstone with role ARN and External ID

**Benefits:** Simple deployment for non-organization accounts, quick setup

### Scenario 5: Multiple Standalone Accounts

**Setup:**
- Multiple AWS accounts not part of an organization
- Want Quiverstone inventory for all accounts
- No organization structure

**Recommended Template:** `standalone-account-inventory-role.yaml` (deploy to each account)

**Deployment Steps:**
1. For each standalone account:
   - Log into the account
   - Deploy standalone-account-inventory-role.yaml via Quick Launch
   - Use consistent External ID across all accounts (or unique per account)
   - Note the role ARN
2. Configure Quiverstone with all role ARNs and External ID(s)

**Benefits:** Inventory across multiple standalone accounts, consistent configuration

## Security Features

All inventory role templates implement security best practices:

### Authentication and Authorization
- **External ID Support**: Additional security token for role assumption (strongly recommended)
- **Principle of Least Privilege**: Read-only permissions only, no write access
- **Trust Policies**: Explicit trust relationships with specific accounts
- **Named Principal Support**: Option to trust specific roles (not all principals) in chained access

### Audit and Compliance
- **CloudTrail Integration**: All role assumptions logged automatically
- **MFA Compatible**: Works with MFA-enabled accounts
- **Session Tagging**: Support for session tags in role assumptions
- **Read-Only Access**: Minimizes security risk through read-only permissions

### Access Control
- **No Write Permissions**: Inventory roles cannot modify any resources
- **Organization Scope**: Limited to organization read operations only
- **Regional Deployment**: Deploy roles only in required regions
- **Time-Limited Sessions**: Role sessions expire based on AWS session duration limits

### Monitoring
- **CloudWatch Integration**: Role usage visible in CloudWatch
- **AWS Config Support**: Track role configuration changes
- **Organizations Integration**: Centralized visibility in organization accounts
- **Assumption Tracking**: All role assumptions logged with source identity

## Integration with Other Role Catalog Components

### Access Roles

Inventory roles work alongside access roles to provide complete Quiverstone functionality:

- **Inventory Roles**: Organization-level read access for account discovery (this directory)
- **Access Roles**: Account-level access with configurable permissions
- **Typical Deployment**: Deploy inventory role once per organization + access roles to each account
- **Documentation**: See [Access Role README](../access/README.md)

### Intermediate Roles

Chained inventory access requires deployment of the trusted intermediate role:

- **Template**: `role-catalog/intermediate/trusted-intermediate-role.yaml`
- **Deploy To**: Intermediate/Trusted Account
- **Purpose**: Enables role chaining from Quiverstone to inventory roles
- **Configuration**: Must configure intermediate role to allow assumption of inventory roles
- **Documentation**: See [Intermediate Role README](../intermediate/README.md)

### Deployment Order

For chained access deployments, follow this order:

1. **First**: Deploy intermediate role in intermediate account
2. **Second**: Deploy inventory role in management/delegated account
3. **Third**: Deploy access roles to target accounts (if needed)
4. **Finally**: Configure Quiverstone with all role ARNs and External IDs

## Support and Documentation

### Additional Resources

- **Quiverstone Documentation**: <https://docs.quiverston.io>
- **Organization Inventory Setup**: <https://docs.quiverston.io/setup/organizations/inventory>
- **Standalone Account Setup**: <https://docs.quiverston.io/setup/accounts/standalone>
- **AWS Organizations Documentation**: <https://docs.aws.amazon.com/organizations/>
- **AWS Organizations Delegation**: <https://docs.aws.amazon.com/organizations/latest/userguide/orgs_delegate_policies.html>

### Getting Help

For questions about template deployment or configuration:

- Contact your Quiverstone administrator
- Visit the Quiverstone documentation portal
- Review AWS Organizations documentation for delegation and permissions

### Troubleshooting

**Common Issues:**

- **Role assumption fails**: Check External ID matches between Quiverstone configuration and template parameters
- **Permission denied on organizations APIs**: Verify role is deployed in management account or delegated administrator account with proper delegation policy
- **Delegation policy not working**: Ensure policy is attached to AWS Organizations service and delegated account ID is correct
- **Chained access not working**: Ensure intermediate role is deployed and configured to allow assumption of inventory role
- **Cannot see all accounts**: Verify role has organizations:List* and organizations:Describe* permissions

**Validation Steps:**

1. Verify role exists in correct account (management, delegated, or standalone)
2. Check role trust policy includes correct principal (Quiverstone account or intermediate role)
3. Verify External ID matches in both role and Quiverstone configuration
4. Test role assumption using AWS CLI: `aws sts assume-role --role-arn <role-arn> --role-session-name test --external-id <external-id>`
5. Check CloudTrail logs for role assumption attempts and errors

## Version Information

All templates in this directory are version 1.0.0. Check template metadata for specific version information and update history.
