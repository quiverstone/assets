# Quiverstone Roles Catalog

This repository contains CloudFormation templates for deploying Quiverstone IAM roles across different AWS account types and access levels. Templates support individual deployments, organization-wide StackSets, and AWS Service Catalog portfolios.

For detailed deployment documentation, visit <https://docs.quiverston.io>

## Access Methods

Quiverstone supports three methods for accessing customer AWS accounts. Every template follows the
same trust contract:

| Method | Role trusts | External ID |
|---|---|---|
| **Browser** (access roles only) | An AWS account you sign in to (`pTrustedAccountId`), for console switch-role | Not supported |
| **Direct** | Quiverstone production account `684035162433` (`:root`) | **Required** — your Quiverstone tenant External ID |
| **Chained** | Your intermediate account (`All`) or the named intermediate role (`Named`) | Optional hop-2 External ID; the tenant External ID is enforced on the intermediate role |

The intermediate role (`intermediate/trusted-intermediate-role.yaml`, default name
`QuiverstoneTrustedIntermediate`) trusts the Quiverstone production account and requires the tenant
External ID. Inventory roles are always assumed by Quiverstone itself, so they have direct and
chained variants only.

## Directory Structure

### [inventory/](inventory/)

CloudFormation templates for AWS Organizations management accounts with read-only organization inventory permissions.

**Templates:**

- Direct organization inventory role
- Chained organization inventory role (destination; uses the intermediate role below)
- Standalone account inventory role
- Organization delegation policy (JSON)

**Use Case:** Deploy to management accounts for organization-level monitoring

📖 **[View Inventory README](inventory/README.md)**

### [access/](access/)

CloudFormation templates for individual account access and organization-wide StackSet deployments.

**Templates:**

- Direct account access roles (individual + StackSet)
- Chained account access roles (destination + StackSet; uses the intermediate role below)
- Browser switch roles (individual + StackSet)

**Use Case:** Deploy read-only access roles across all organization accounts

📖 **[View Access README](access/README.md)**

### [intermediate/](intermediate/)

The trusted intermediate role (hop 1) shared by chained inventory and chained access.

📖 **[View Intermediate README](intermediate/README.md)**

### [scripts/](scripts/)

AWS CloudShell one-command deployment for every role type.

📖 **[View Scripts README](scripts/README.md)**

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

| Template | Description | Deploy To | Launch |
| --- | --- | --- | --- |
| **Direct Org Inventory** | Assumed directly by Quiverstone | Management or Delegated Admin Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/inventory/direct-org-inventory-role.yaml&stackName=quiverstone-direct-org-inventory-role) |
| **Chained Org Inventory** | Assumed through your intermediate role | Management or Delegated Admin Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/inventory/chained-org-inventory-role.yaml&stackName=quiverstone-chained-org-inventory-role) |
| **Standalone Account Inventory** | Account outside an AWS Organization | Standalone Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/inventory/standalone-account-inventory-role.yaml&stackName=quiverstone-standalone-account-inventory-role) |
| **Trusted Intermediate** | Hop 1 for chained inventory and access | Intermediate/Trusted Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/intermediate/trusted-intermediate-role.yaml&stackName=quiverstone-trusted-intermediate-role) |

## Quick Launch - Account Access Roles

| Template | Description | Deploy To | Launch |
| --- | --- | --- | --- |
| **Browser Access** | Console switch-role from your account | Individual Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/browser-access-role.yaml&stackName=quiverstone-browser-access-role) |
| **Browser Access StackSet** | Browser roles across org accounts | Management Account | [![Launch StackSet](assets/stackset.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/browser-access-role-stackset.yaml&stackName=stackset-quiverstone-browser-access-role) |
| **Direct Access** | Assumed directly by Quiverstone | Individual Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/direct-access-role.yaml&stackName=quiverstone-direct-access-role) |
| **Direct Access StackSet** | Direct roles across org accounts | Management Account | [![Launch StackSet](assets/stackset.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/direct-access-role-stackset.yaml&stackName=stackset-quiverstone-direct-access-role) |
| **Chained Access** | Assumed through your intermediate role | Individual Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/chained-access-role.yaml&stackName=quiverstone-chained-access-role) |
| **Chained Access StackSet** | Chained roles across org accounts | Management Account | [![Launch StackSet](assets/stackset.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/chained-access-role-stackset.yaml&stackName=stackset-quiverstone-chained-access-role) |
| **Trusted Intermediate** | Hop 1 for chained access | Intermediate/Trusted Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/intermediate/trusted-intermediate-role.yaml&stackName=quiverstone-trusted-intermediate-role) |

## Deploy from AWS CloudShell

Every individual-account template can also be deployed with one command from AWS CloudShell in the
target account. The Quiverstone app generates the command; see [scripts/](scripts/) for all flags.

```bash
curl -fsSL https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/scripts/quiverstone-onboard.sh -o quiverstone-onboard.sh && bash quiverstone-onboard.sh --role-type <org-inventory|standalone-inventory|account-access|intermediate> --variant <browser|direct|chained> ...
```

## Quick Launch - Service Catalog Portfolios

| Template                      | Description                                     | Deploy To          | Launch                                                                                                                                                                                                                                                                                                                                |
| ----------------------------- | ----------------------------------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Inventory Roles Portfolio** | MSP portfolio for organization inventory roles  | MSP Account        | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/service-catalog/inventory-roles-portfolio.yaml&stackName=quiverstone-inventory-roles-portfolio) |
| **Account Access Portfolio**  | Organization portfolio for account access roles | Management Account | [![Launch Stack](assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/service-catalog/account-access-portfolio.yaml&stackName=quiverstone-account-access-portfolio)   |

## Quick Start

1. Choose the appropriate role type for your needs
2. Use the quick launch buttons above to deploy templates directly
3. Review the directory-specific READMEs for detailed configuration options
4. Use the External ID shown in Quiverstone (direct and intermediate roles require it)

## Support

For questions about role deployment or configuration, contact your Quiverstone administrator.
