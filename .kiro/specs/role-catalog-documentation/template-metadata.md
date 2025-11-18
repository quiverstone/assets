# CloudFormation Template Metadata Reference

This document contains extracted metadata from all CloudFormation templates in the role-catalog repository.

## Access Templates

### 1. browser-access-role.yaml

**Metadata:**
- **Name:** quiverstone-browser-access-role
- **Deploy-To:** Any or all Account(s) Home Region (e.g. us-east-1)
- **Version:** 1.0.0
- **Description:** Quiverstone Browser Role - Provides varying levels of access to AWS Accounts for browser-based role switching from a trusted account you are currently logged into.
- **Note:** Deploys a role that can be assumed via browser session for account access - Does not require the use of a trusted intermediate account and CANNOT use External ID for role assumption.
- **Quick Launch URL:** https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/browser-access-role.yaml&stackName=quiverstone-browser-access-role

**Key Parameters:**
- pRoleName: Name for the role to assume via browser session (Default: QuiverstoneBrowserSession)
- pTrustedAccountId: AWS Account ID you have access to that can assume this role via the same browser session
- Permission flags: pIsReadOnlyAccess, pIsAdministratorAccess, pIsPowerUserAccess, pIsViewOnlyAccess, pIsSecurityAudit, pIsSystemAdministrator, pIsSupportUser, pIsBillingAccess

### 2. browser-access-role-stackset.yaml

**Metadata:**
- **Name:** stackset-quiverstone-browser-access-role
- **Deploy-To:** Management or Delegated CloudFormation StackSet Account Home Region (e.g. us-east-1)
- **Version:** 1.0.0
- **Description:** Quiverstone Browser Role StackSet - Deploys browser-accessible roles across all organization accounts
- **Note:** Creates a StackSet that deploys browser-accessible roles to all organization accounts
- **Quick Launch URL:** https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/browser-access-role-stackset.yaml&stackName=stackset-quiverstone-browser-access-role

**Key Parameters:**
- pDeploymentOUs: Organization Unit IDs to deploy to (comma-separated)
- pDeploymentRegion: AWS Region to deploy the roles (Default: us-east-1)
- pRoleName: Name for the browser-accessible organization inventory role (Default: QuiverstoneBrowserSession)
- pTrustedAccountId: AWS Account ID you have access to that can assume this role
- Permission flags: Same as browser-access-role.yaml

### 3. direct-access-role.yaml

**Metadata:**
- **Name:** quiverstone-direct-access-role
- **Deploy-To:** Any or all Account(s) Home Region (e.g. us-east-1)
- **Version:** 1.0.0
- **Description:** Quiverstone Direct to Account Access Role - Provides varying levels of access to AWS Accounts for federated role switching from the Quiverstone application
- **Note:** Deploys a role that can be assumed via browser session for account access - Does not require the use of a trusted intermediate account and External ID is recommeneded for role assumption.
- **Quick Launch URL:** https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/direct-access-role.yaml&stackName=quiverstone-direct-access-role

**Key Parameters:**
- pRoleName: Name for the federated access role (Default: QuiverstoneDirectAccess)
- pQuiverstoneProductionAccountId: Quiverstone production account ID (Default: 684035162433)
- pExternalId: External ID for additional security (recommended)
- Permission flags: Same as browser-access-role.yaml

### 4. direct-access-role-stackset.yaml

**Metadata:**
- **Name:** stackset-quiverstone-direct-access-role
- **Deploy-To:** Management or Delegated CloudFormation StackSet Account Home Region (e.g. us-east-1)
- **Version:** 1.0.0
- **Description:** Quiverstone Direct to Account Access Role StackSet - Deploys federated role across all Organization Accounts for federated role switching from the Quiverstone application
- **Note:** Creates a StackSet that deploys federated roles to all organization accounts
- **Quick Launch URL:** https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/direct-access-role-stackset.yaml&stackName=stackset-quiverstone-direct-access-role

**Key Parameters:**
- pDeploymentOUs: Organization Unit IDs to deploy to (comma-separated)
- pDeploymentRegion: AWS Region to deploy the roles (Default: us-east-1)
- pRoleName: Name for the federated access role (Default: QuiverstoneDirectAccess)
- pQuiverstoneProductionAccountId: Quiverstone production account ID (Default: 684035162433)
- pExternalId: External ID for additional security (recommended)
- Permission flags: Same as browser-access-role.yaml

### 5. chained-access-role.yaml

**Metadata:**
- **Name:** quiverstone-chained-access-role
- **Deploy-To:** Individual Account Home Region (e.g. us-east-1)
- **Version:** 1.0.0
- **Description:** Quiverstone Chained Access Role - Deploys in target accounts to allow access through role chaining
- **Note:** Deploys destination role in target account that can be assumed via role chaining from intermediate account
- **Quick Launch URL:** https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/chained-access-role.yaml&stackName=quiverstone-chained-access-role

**Key Parameters:**
- pChainedAccessRoleName: Name for the destination account access role (Default: QuiverstoneChainedAccess)
- pExternalId: External ID for role assumption (recommended for security)
- pIntermediateAccountId: AWS Account ID that serves as the intermediate hop for role chaining
- pTrustPrincipals: Trust all principals in the intermediate account (All) or only a named role (Named)
- pIntermediateRoleName: Name of the role in the intermediate account (Default: QuiverstoneTrustedIntermediate)
- pIntermediateRoleExternalId: External ID for Intermediate role assumption (reference only)
- Permission flags: Same as browser-access-role.yaml

### 6. chained-access-role-stackset.yaml

**Metadata:**
- **Name:** stackset-quiverstone-chained-access-rpole
- **Deploy-To:** Management Account Home Region (e.g. us-east-1)
- **Version:** 1.0.0
- **Description:** Quiverstone Chained Access Role StackSet - Deploys chained access role across all organization accounts
- **Note:** Creates a StackSet that deploys chained account access role to all organization accounts
- **Quick Launch URL:** https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/access/chained-access-role-stackset.yaml&stackName=stackset-quiverstone-chained-access-role

**Key Parameters:**
- pDeploymentOUs: Organization Unit IDs to deploy to (comma-separated)
- pDeploymentRegion: AWS Region to deploy the roles (Default: us-east-1)
- pChainedAccessRoleName: Name for the destination account access role (Default: QuiverstoneChainedAccess)
- pExternalId: External ID for role assumption (recommended for security)
- pIntermediateAccountId: AWS Account ID that serves as the intermediate hop for role chaining
- pTrustPrincipals: Trust all principals in the intermediate account (All) or only a named role (Named)
- pIntermediateRoleName: Name of the role in the intermediate account (Default: QuiverstoneTrustedIntermediate)
- pIntermediateRoleExternalId: External ID for Intermediate role assumption (reference only)
- Permission flags: Same as browser-access-role.yaml

## Intermediate Template

### 7. trusted-intermediate-role.yaml

**Metadata:**
- **Name:** quiverstone-trusted-intermediate-role
- **Deploy-To:** Intermediate/Trusted Account Home Region (e.g. us-east-1)
- **Version:** 1.0.0
- **Description:** Quiverstone Trusted Intermediate Role - Deploys in the Intermediate Account to enable role chaining
- **Note:** Deploys intermediate role in trusted account that can chain to destination Access Roles in other Accounta
- **Quick Launch URL:** https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/intermediate/trusted-intermediate-role.yaml&stackName=quiverstone-trusted-intermediate-role

**Key Parameters:**
- pIntermediateRoleName: Name for the intermediate role (Default: QuiverstoneTrustedIntermediate)
- pExternalId: External ID for this intermediate role assumption (recommended for security)
- pQuiverstoneProductionAccountId: Quiverstone production account ID (Default: 684035162433)
- pAssumeRoleScope: Scope of destination roles (any-role-any-account, specific-account-and-role, specific-role-any-account)
- pDestinationAccountId: Management Account ID where the destination role exists
- pDestinationRoleName: Name of the destination role

## Inventory Templates

### 8. direct-org-inventory-role.yaml

**Metadata:**
- **Name:** quiverstone-dircet-org-inventory-role
- **Deploy-To:** Management/Delegated Account Home Region (e.g. us-east-1)
- **Version:** 1.0.0
- **Description:** Quiverstone Organization Inventory Role - Deploys inventory role in Organization account that can be assumed directly from Quiverstone
- **Note:** Deploys inventory role in Organization that can be assumed directly from Quiverstone
- **Quick Launch URL:** https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/inventory/direct-org-inventory-role.yaml&stackName=quiverstone-direct-org-inventory-role

**Key Parameters:**
- pRoleName: Name for the direct organization inventory role (Default: QuiverstoneDirectOrgInventory)
- pQuiverstoneProductionAccountId: Quiverstone production account ID (Default: 684035162433)
- pExternalId: External ID for additional security (recommended)

### 9. chained-org-inventory-role.yaml

**Metadata:**
- **Name:** quiverstone-chained-org-inventory-role
- **Deploy-To:** Management/Delegate Org Account in Home Region(e.g. us-east-1)
- **Version:** 1.0.0
- **Description:** Quiverstone Chained Organization Inventory Role - Deploys inventory role in Organization account that can be assumed via role chaining from intermediate account
- **Note:** Deploys inventory role in Organization that can be assumed via role chaining from intermediate account
- **Quick Launch URL:** https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/inventory/chained-org-inventory-role.yaml&stackName=quiverstone-chained-org-inventory-role

**Key Parameters:**
- pInventoryRoleName: Name for the destination organization inventory role (Default: QuiverstoneChainedOrgInventory)
- pExternalId: External ID for role assumption (recommended for security)
- pIntermediateAccountId: AWS Account ID that serves as the intermediate hop for role chaining
- pTrustPrincipals: Trust all principals in the intermediate account (All) or only a named role (Named)
- pIntermediateRoleName: Name of the role in the intermediate account (Default: QuiverstoneTrustedIntermediate)
- pIntermediateRoleExternalId: External ID for Intermediate role assumption (reference only)

### 10. standalone-account-inventory-role.yaml

**Metadata:**
- **Name:** quiverstone-standalone-inventory-role
- **Deploy-To:** Management Account Home Region (e.g. us-east-1)
- **Version:** 1.0.0
- **Description:** Quiverstone Standalone Account Inventory Role - Provides read-only access to a Standalone account for inventory purposes
- **Note:** Deploys a role that can be directly assumed by Quiverstone production account for standalone account inventory access
- **Quick Launch URL:** https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/inventory/standalone-account-inventory-role.yaml&stackName=quiverstone-standalone-account-inventory-role

**Key Parameters:**
- pRoleName: Name for the direct organization inventory role (Default: QuiverstoneStandaloneAccountInventory)
- pQuiverstoneProductionAccountId: Quiverstone production account ID (Default: 684035162433)
- pExternalId: External ID for additional security (recommended)

## Verification Summary

### Filename Verification
All template filenames match the expected patterns from the design document:

**Access Directory (6 templates):**
- ✓ browser-access-role.yaml
- ✓ browser-access-role-stackset.yaml
- ✓ direct-access-role.yaml
- ✓ direct-access-role-stackset.yaml
- ✓ chained-access-role.yaml
- ✓ chained-access-role-stackset.yaml

**Intermediate Directory (1 template):**
- ✓ trusted-intermediate-role.yaml

**Inventory Directory (3 templates):**
- ✓ direct-org-inventory-role.yaml
- ✓ chained-org-inventory-role.yaml
- ✓ standalone-account-inventory-role.yaml

### Metadata Consistency
All templates include:
- ✓ Name field in Metadata.TemplateInfo
- ✓ Deploy-To field in Metadata.TemplateInfo
- ✓ Version field in Metadata.TemplateInfo (all are 1.0.0)
- ✓ Description field at template level
- ✓ QuickStackLink URL in Metadata.TemplateInfo

### S3 URL Pattern Verification
All Quick Launch URLs follow the pattern:
```
https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/{directory}/{filename}&stackName={stack-name}
```

Where:
- {directory} = access, intermediate, or inventory
- {filename} = actual template filename
- {stack-name} = suggested stack name

### Common Permission Flags (Access Templates)
All access templates (browser, direct, chained) support the same 8 permission flags:
1. pIsReadOnlyAccess (Default: yes)
2. pIsAdministratorAccess (Default: no)
3. pIsPowerUserAccess (Default: no)
4. pIsViewOnlyAccess (Default: no)
5. pIsSecurityAudit (Default: no)
6. pIsSystemAdministrator (Default: no)
7. pIsSupportUser (Default: no)
8. pIsBillingAccess (Default: no)

### Deployment Patterns
- **Individual Templates:** Deploy to single accounts
- **StackSet Templates:** Deploy across multiple accounts in an organization using CloudFormation StackSets
- **StackSet Parameters:** Include pDeploymentOUs and pDeploymentRegion for organization-wide deployment

### External ID Support
- **Browser Access:** Does NOT support External ID (noted in metadata)
- **Direct Access:** Supports External ID (recommended)
- **Chained Access:** Supports External ID for both destination and intermediate roles
- **Inventory Roles:** All support External ID (recommended)
- **Intermediate Role:** Supports External ID (recommended)


## Additional Files

### organization-delegation-policy.json

**Type:** IAM Resource Policy (not a CloudFormation template)

**Purpose:** This policy document is used to delegate AWS Organizations read permissions from a Management Account to a Delegated Administrator account. It allows the delegated account to list and describe organization resources.

**Usage:** This policy should be attached as a resource policy in the AWS Organizations service to grant the delegated account access to organization information.

**Policy Statement:**
- **Effect:** Allow
- **Principal:** AWS account ARN (placeholder: {DelegatedOrganizationAccountId})
- **Actions:** organizations:List*, organizations:Describe*
- **Resource:** * (all organization resources)

**Note:** The {DelegatedOrganizationAccountId} placeholder must be replaced with the actual AWS account ID of the delegated administrator account before use.
