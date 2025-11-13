# Quiverstone Roles Catalog

This repository contains CloudFormation templates for deploying Quiverstone IAM roles across different AWS account types and access levels. Templates support individual deployments, organization-wide StackSets, and AWS Service Catalog portfolios.

For detailed deployment documentation, visit <https://docs.quiverston.io>

## Access Methods

Quiverstone supports three methods for accessing customer AWS accounts:

### 1. Browser-Based Access

Users log into the target AWS account through their browser and grant Quiverstone temporary access. No pre-deployed roles required.

### 2. Direct Assume Role

Quiverstone production account (684035162433) directly assumes a role in the target account.

- **Trust Relationship:** Target account role trusts Quiverstone production account
- **Security:** Supports External ID validation
- **Use Case:** Simple, direct access scenarios

### 3. Chained Assume Role

Quiverstone assumes a role in an intermediate account, which then assumes the target role.

- **Trust Relationship:** Target account role trusts intermediate account role
- **Chain Validation:** Ensures the chain originates from Quiverstone production account
- **Use Case:** Additional security layer or compliance requirements

## Directory Structure

### [inventory/](inventory/)

CloudFormation templates for AWS Organizations management accounts with read-only organization inventory permissions.

**Templates:**

- Direct organization inventory role
- Chained organization inventory roles (destination + intermediate)
- Organization delegation policy (JSON)

**Use Case:** Deploy to management accounts for organization-level monitoring

📖 **[View Inventory README](inventory/README.md)**

### [access/](access/)

CloudFormation templates for individual account access and organization-wide StackSet deployments.

**Templates:**

- Direct account access roles (individual + StackSet)
- Chained account access roles (destination + intermediate + StackSet)
- Browser switch roles (individual + StackSet)

**Use Case:** Deploy read-only access roles across all organization accounts

📖 **[View Access README](access/README.md)**

### [service-catalog/](service-catalog/)

AWS Service Catalog portfolio templates for centralized, self-service role deployment.

**Portfolios:**

- Inventory Roles Portfolio (for MSPs)
- Account Access Roles Portfolio (for organizations)

**Use Case:** Enable self-service deployment through AWS Service Catalog

📖 **[View Service Catalog README](service-catalog/README.md)**

## Security Features

All Quiverstone roles implement:

- **External ID Validation:** Additional security token for cross-account access
- **Principle of Least Privilege:** Minimum permissions required for functionality
- **Audit Trail:** All role assumptions logged in CloudTrail
- **Read-Only Access:** No modification permissions granted

## Quick Launch - Organization Inventory Roles

| Template                          | Description                                               | Deploy To                             | Launch                                                                                                                                                                                                                                                                                                                                            |
| --------------------------------- | --------------------------------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Direct Org Inventory**          | Direct assumption from Quiverstone production account     | Management or Delegated Admin Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/inventory/quiverstone-direct-org-inventory.yaml&stackName=quiverstone-direct-org-inventory)                             |
| **Chained Org Inventory - Dest**  | Destination role for chained access in management account | Management or Delegated Admin Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/inventory/quiverstone-chained-org-inventory-destination.yaml&stackName=quiverstone-chained-org-inventory-destination)   |
| **Chained Org Inventory - Inter** | Intermediate role for chained access                      | Intermediate/Trusted Account          | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/inventory/quiverstone-chained-org-inventory-intermediate.yaml&stackName=quiverstone-chained-org-inventory-intermediate) |

## Quick Launch - Account Access Roles

| Template                            | Description                                        | Deploy To                    | Launch                                                                                                                                                                                                                                                                                                                                                                 |
| ----------------------------------- | -------------------------------------------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Direct Account Access**           | Direct read-only access to individual account      | Individual Account           | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/access/quiverstone-direct-account-access.yaml&stackName=quiverstone-direct-account-access)                                                   |
| **Direct Account Access StackSet**  | Deploy direct access across all org accounts       | Management Account           | [![Launch StackSet](assets/stackset.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/access/stackset-quiverstone-direct-account-access.yaml&stackName=stackset-quiverstone-direct-account-access)                           |
| **Chained Account Access - Dest**   | Destination role for chained account access        | Individual Account           | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/access/quiverstone-chained-account-access-destination.yaml&stackName=quiverstone-chained-account-access-destination)                         |
| **Chained Account Access StackSet** | Deploy chained destination across all org accounts | Management Account           | [![Launch StackSet](assets/stackset.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/access/stackset-quiverstone-chained-account-access-destination.yaml&stackName=stackset-quiverstone-chained-account-access-destination) |
| **Chained Account Access - Inter**  | Intermediate role for chained account access       | Intermediate/Trusted Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/access/quiverstone-chained-account-access-intermediate.yaml&stackName=quiverstone-chained-account-access-intermediate)                       |
| **Browser Switch Role**             | Browser-based console access to individual account | Individual Account           | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/access/quiverstone-browser-switch-role.yaml&stackName=quiverstone-browser-switch-role)                                                       |
| **Browser Switch Role StackSet**    | Deploy browser roles across all org accounts       | Management Account           | [![Launch StackSet](assets/stackset.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/access/stackset-quiverstone-browser-switch-role.yaml&stackName=stackset-quiverstone-browser-switch-role)                               |

## Quick Launch - Service Catalog Portfolios

| Template                      | Description                                     | Deploy To          | Launch                                                                                                                                                                                                                                                                                                                                |
| ----------------------------- | ----------------------------------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Inventory Roles Portfolio** | MSP portfolio for organization inventory roles  | MSP Account        | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/service-catalog/quiverstone-inventory-roles-portfolio.yaml&stackName=quiverstone-inventory-roles-portfolio) |
| **Account Access Portfolio**  | Organization portfolio for account access roles | Management Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://assets.quiverston.io.s3.us-east-2.amazonaws.com/quiverstone-roles-catalog/service-catalog/quiverstone-account-access-portfolio.yaml&stackName=quiverstone-account-access-portfolio)   |

## Quick Start

1. Choose the appropriate role type for your needs
2. Use the quick launch buttons above to deploy templates directly
3. Review the directory-specific READMEs for detailed configuration options
4. Provide the External ID to your Quiverstone administrator

## Support

For questions about role deployment or configuration, contact your Quiverstone administrator.
