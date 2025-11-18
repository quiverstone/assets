# Quiverstone Role Catalog

CloudFormation templates for deploying IAM roles that enable secure access to AWS accounts through the Quiverstone platform. This catalog provides templates for three access methods (Browser Session, Direct, and Chained) and two role types (Inventory and Access), supporting both individual account and organization-wide deployments.

## Overview

The Quiverstone Role Catalog simplifies the deployment of IAM roles required for secure AWS account access and inventory management. Whether you're managing a single account or a large AWS Organization, these templates provide flexible, secure, and scalable solutions for integrating with Quiverstone.

## Access Methods

Quiverstone supports three distinct methods for accessing AWS accounts, each designed for different security requirements and use cases:

### Browser Session Access

**How it works:** Role assumption through the AWS Console browser session. Requires authentication to a trusted AWS account in the same browser session before switching roles.

**Key characteristics:**
- Interactive console access for manual operations
- Browser-based role switching using AWS Console
- Does NOT support External ID (relies on browser session authentication)
- Requires user to be logged into trusted account in same browser

**When to use:**
- Manual troubleshooting and interactive operations
- Ad-hoc account access needs
- Small teams performing console-based tasks
- User-driven account access scenarios

**Security model:** Trust relationship with a specific AWS account you control, authenticated through browser session

**Best for:** Small teams, manual operations, troubleshooting, interactive console work

### Direct Access

**How it works:** Direct role assumption from Quiverstone production account (684035162433) to target accounts using federated URLs.

**Key characteristics:**
- Direct trust relationship with Quiverstone production account
- Supports External ID for enhanced security (recommended)
- Simplest deployment with minimal configuration
- Federated access through Quiverstone application
- No intermediate accounts required

**When to use:**
- Standard deployments with straightforward security requirements
- Organizations comfortable with direct external account trust
- Quick setup for basic account access
- No compliance requirements for intermediate controls

**Security model:** Direct trust with Quiverstone production account, secured with External ID

**Best for:** Standard deployments, organizations with straightforward security policies, quick setup scenarios

### Chained Access

**How it works:** Multi-hop role assumption through an intermediate trusted account. Quiverstone assumes a role in your intermediate account, which then assumes roles in destination accounts.

**Key characteristics:**
- Two-step authentication process with separate External IDs
- Additional security layer through intermediate account you control
- All role assumptions flow through auditable intermediate point
- Supports External ID for both intermediate and destination roles
- More complex setup but enhanced security

**When to use:**
- Security policies require additional layers beyond direct access
- Compliance mandates intermediate account controls
- Need centralized audit point for all role assumptions
- Large enterprises with strict security requirements
- Highly regulated environments

**Security model:** Chained trust through your controlled intermediate account, providing additional security boundary and audit point

**Best for:** Large enterprises, highly regulated environments, organizations requiring additional security controls and centralized auditing

## Role Types

The role catalog provides two distinct types of IAM roles, each serving a specific purpose in the Quiverstone platform:

### Inventory Roles

**Purpose:** Provide read-only access to AWS Organizations or standalone accounts for inventory and discovery purposes.

**What they do:**
- Enable Quiverstone to discover and catalog your AWS accounts
- List and describe AWS Organizations structure (OUs, accounts, hierarchy)
- Retrieve account metadata (name, email, status)
- Maintain accurate inventory of your AWS environment

**Permissions:** Read-only access to AWS Organizations APIs (`organizations:List*`, `organizations:Describe*`) or account-level metadata

**Deployment scope:**
- **Organization Inventory**: Deploy once per organization (management or delegated account)
- **Standalone Inventory**: Deploy to each standalone account not in an organization

**Access methods supported:** Direct or Chained

**Templates available:**
- `direct-org-inventory-role.yaml`: Direct access to organization inventory
- `chained-org-inventory-role.yaml`: Chained access to organization inventory
- `standalone-account-inventory-role.yaml`: Standalone account inventory

**Documentation:** See [Inventory Role README](role-catalog/inventory/README.md)

### Access Roles

**Purpose:** Provide varying levels of permissions to AWS accounts, from read-only access to full administrative access.

**What they do:**
- Enable account-level access with configurable permission levels
- Support eight permission levels (Read-Only, Administrator, Power User, etc.)
- Provide interactive console access or programmatic access
- Allow users to perform operations within AWS accounts

**Permissions:** Configurable from read-only to full administrative access based on deployment parameters

**Deployment scope:**
- **Individual Deployment**: Deploy to specific accounts as needed
- **Organization Deployment**: Deploy across all organization accounts using StackSets

**Access methods supported:** Browser Session, Direct, or Chained

**Templates available:**
- `browser-access-role.yaml` / `browser-access-role-stackset.yaml`: Browser session access
- `direct-access-role.yaml` / `direct-access-role-stackset.yaml`: Direct access
- `chained-access-role.yaml` / `chained-access-role-stackset.yaml`: Chained access

**Documentation:** See [Access Role README](role-catalog/access/README.md)

## Directory Structure

The role catalog is organized into three directories, each containing related CloudFormation templates and comprehensive documentation:

### role-catalog/access/

**Purpose:** Account access role templates for Browser, Direct, and Chained access methods

**Contents:**
- 6 CloudFormation templates (3 individual + 3 StackSet)
- Comprehensive README with deployment guidance
- Quick Launch links for all templates

**Templates:**
- `browser-access-role.yaml`: Individual account browser access
- `browser-access-role-stackset.yaml`: Organization-wide browser access
- `direct-access-role.yaml`: Individual account direct access
- `direct-access-role-stackset.yaml`: Organization-wide direct access
- `chained-access-role.yaml`: Individual account chained access
- `chained-access-role-stackset.yaml`: Organization-wide chained access

**When to use:** Deploy access roles to enable account-level access with configurable permissions

**Documentation:** [Access Role README](role-catalog/access/README.md)

### role-catalog/intermediate/

**Purpose:** Trusted intermediate role template for chained access architecture

**Contents:**
- 1 CloudFormation template
- Comprehensive README with chained access architecture documentation
- Configuration guidance for assume role scopes

**Templates:**
- `trusted-intermediate-role.yaml`: Intermediate role for chained access

**When to use:** Deploy intermediate role when using chained access method for enhanced security

**Documentation:** [Intermediate Role README](role-catalog/intermediate/README.md)

### role-catalog/inventory/

**Purpose:** Organization and standalone account inventory role templates

**Contents:**
- 3 CloudFormation templates
- 1 IAM policy document for organization delegation
- Comprehensive README with deployment scenarios
- Quick Launch links for all templates

**Templates:**
- `direct-org-inventory-role.yaml`: Direct access to organization inventory
- `chained-org-inventory-role.yaml`: Chained access to organization inventory
- `standalone-account-inventory-role.yaml`: Standalone account inventory
- `organization-delegation-policy.json`: Policy for delegating organization access

**When to use:** Deploy inventory roles to enable Quiverstone to discover and catalog your AWS accounts

**Documentation:** [Inventory Role README](role-catalog/inventory/README.md)

## Quick Reference: Common Deployment Scenarios

| Scenario | Inventory Role | Access Roles | Intermediate Role | Deployment Method |
|----------|---------------|--------------|-------------------|-------------------|
| **Small org, simple setup** | Direct Org Inventory | Direct Access (individual) | Not needed | Individual templates |
| **Medium org, consistent deployment** | Direct Org Inventory | Direct Access StackSet | Not needed | StackSets |
| **Large org, enhanced security** | Chained Org Inventory | Chained Access StackSet | Required | StackSets + Intermediate |
| **Highly regulated environment** | Chained Org Inventory | Chained Access StackSet | Required | StackSets + Intermediate |
| **Standalone account** | Standalone Inventory | Direct Access (individual) | Not needed | Individual templates |
| **Multiple standalone accounts** | Standalone Inventory (each) | Direct Access (each) | Not needed | Individual templates |
| **Browser-based console access** | Direct Org Inventory | Browser Access (individual or StackSet) | Not needed | Individual or StackSets |

### Deployment Recommendations by Organization Size

**Small Organizations (< 10 accounts):**
- Use individual account templates
- Deploy Direct Access for simplicity
- Manual deployment is manageable at this scale
- **Recommended:** Direct Org Inventory + Direct Access (individual)

**Medium Organizations (10-50 accounts):**
- Use StackSet templates for consistent deployment
- Deploy Direct Access or Chained Access based on security requirements
- Enable auto-deployment for new accounts
- **Recommended:** Direct Org Inventory + Direct Access StackSet

**Large Organizations (50+ accounts):**
- Use StackSet templates with OU targeting
- Deploy Chained Access for enhanced security and audit capabilities
- Implement intermediate account architecture
- **Recommended:** Chained Org Inventory + Chained Access StackSet + Intermediate Role

**Highly Regulated Environments:**
- Use Chained Access exclusively
- Implement strict External ID policies
- Deploy through StackSets for consistency
- Limit permission levels to minimum required
- **Recommended:** Chained Org Inventory + Chained Access StackSet + Intermediate Role

## Individual vs StackSet Deployments

### Individual Account Deployment

**How it works:** Deploy CloudFormation template to a single AWS account using the AWS Console or CLI.

**Advantages:**
- Simple and straightforward deployment
- Quick setup with minimal prerequisites
- Full control and customization per account
- No AWS Organization required

**Disadvantages:**
- Manual deployment to each account
- Difficult to maintain consistency across many accounts
- No automatic deployment to new accounts
- Time-consuming for large organizations

**When to use:**
- Small number of accounts (< 10)
- Standalone accounts not in an organization
- Testing or proof-of-concept deployments
- Need account-specific customization

### StackSet Deployment

**How it works:** Deploy CloudFormation template across multiple accounts and regions using CloudFormation StackSets from the management account.

**Advantages:**
- Single operation deploys to hundreds of accounts
- Automatic deployment to new accounts in target OUs
- Centralized management and updates
- Consistent configuration across organization
- Regional deployment support

**Disadvantages:**
- Requires AWS Organization setup
- Additional IAM permissions needed
- More complex initial configuration
- Requires management account access

**When to use:**
- Medium to large organizations (10+ accounts)
- AWS Organization structure in place
- Need consistent deployment across accounts
- Want automatic deployment to new accounts

## Security Features

All role catalog templates implement AWS security best practices:

### Authentication and Authorization
- **External ID Support**: Additional security token for role assumption (Direct and Chained access)
- **Principle of Least Privilege**: Configurable permission levels, default to Read-Only for access roles
- **Trust Policies**: Explicit trust relationships with specific accounts
- **Named Principal Support**: Option to trust specific roles (not all principals) in Chained access

### Audit and Compliance
- **CloudTrail Integration**: All role assumptions logged automatically in CloudTrail
- **MFA Compatible**: Works with MFA-enabled accounts
- **Session Tagging**: Support for session tags in role assumptions
- **Chained Access Audit**: Centralized audit point through intermediate account

### Access Control
- **Configurable Permissions**: Eight permission levels for access roles (Read-Only to Administrator)
- **Read-Only Inventory**: Inventory roles have no write permissions
- **Regional Deployment**: Deploy roles only in required regions
- **Time-Limited Sessions**: Role sessions expire based on AWS session duration limits

### Monitoring
- **CloudWatch Integration**: Role usage visible in CloudWatch metrics
- **AWS Config Support**: Track role configuration changes
- **Organizations Integration**: Centralized visibility in organization accounts
- **Assumption Tracking**: All role assumptions logged with source identity

## Getting Started

### Prerequisites

**For Individual Account Deployment:**
- AWS account access with IAM permissions to create roles
- Quiverstone production account ID: 684035162433 (for Direct and Chained access)
- Trusted account ID (for Browser access)
- Intermediate account ID (for Chained access)

**For StackSet Deployment:**
- AWS Organization with management account access
- CloudFormation StackSets enabled with organization trust
- Service-managed permissions enabled for StackSets
- Target Organization Units identified

### Basic Deployment Steps

1. **Choose your access method** (Browser, Direct, or Chained) based on security requirements
2. **Choose your deployment type** (Individual or StackSet) based on organization size
3. **Deploy inventory role** to enable account discovery:
   - Organization: Deploy to management or delegated account
   - Standalone: Deploy to each standalone account
4. **Deploy access roles** to enable account access:
   - Individual: Deploy to specific accounts
   - StackSet: Deploy across organization
5. **Deploy intermediate role** (if using Chained access):
   - Deploy to intermediate/trusted account
6. **Configure Quiverstone** with role ARNs and External IDs

### Quick Launch Links

Quick Launch links are available in each subdirectory README:
- [Access Role Quick Launch](role-catalog/access/README.md#quick-launch---individual-account-templates)
- [Intermediate Role Quick Launch](role-catalog/intermediate/README.md#quick-launch)
- [Inventory Role Quick Launch](role-catalog/inventory/README.md#quick-launch---inventory-templates)

## Support and Documentation

### Additional Resources

- **Quiverstone Documentation**: <https://docs.quiverston.io>
- **Individual Account Access Setup**: <https://docs.quiverston.io/setup/accounts/access>
- **Organization Roles Setup**: <https://docs.quiverston.io/setup/organizations/inventory>
- **Chained Access Setup**: <https://docs.quiverston.io/setup/chained-access>
- **AWS CloudFormation StackSets**: <https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html>
- **AWS Organizations**: <https://docs.aws.amazon.com/organizations/>
- **AWS IAM Role Chaining**: <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_terms-and-concepts.html>

### Getting Help

For questions about template deployment or configuration:
- Contact your Quiverstone administrator
- Visit the Quiverstone documentation portal
- Review subdirectory READMEs for detailed guidance
- Check AWS CloudFormation documentation for troubleshooting

### Troubleshooting

**Common Issues:**
- **Role assumption fails**: Check External ID matches between template and Quiverstone configuration
- **StackSet deployment fails**: Verify organization trust is enabled for CloudFormation StackSets
- **Permission denied**: Verify IAM permissions for CloudFormation and role creation
- **Chained access not working**: Ensure intermediate role is deployed and configured correctly

**Validation Steps:**
1. Verify roles exist in correct accounts
2. Check role trust policies include correct principals
3. Verify External IDs match in both roles and Quiverstone configuration
4. Test role assumption using AWS CLI
5. Check CloudTrail logs for role assumption attempts and errors

## Version Information

All templates in this catalog are version 1.0.0. Check individual template metadata for specific version information and update history.

## License

See [LICENSE](role-catalog/LICENSE) file for details.
