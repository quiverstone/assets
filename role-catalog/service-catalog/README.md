# Service Catalog Portfolios

> Note: Not in production or referenced

This directory contains AWS Service Catalog portfolio templates for deploying Quiverstone roles through a centralized, self-service catalog.

For additional information on AWS Service Catalog and deploying these portfolios, please visit:

- **AWS Service Catalog Documentation:** <https://docs.aws.amazon.com/servicecatalog/>
- **Quiverstone Setup Guide:** <https://docs.quiverston.io/setup/>

## Templates

### quiverstone-inventory-roles-portfolio.yaml

AWS Service Catalog portfolio for Managed Service Providers (MSP) containing organization inventory role products. This portfolio can be shared with customer organizations to enable self-service deployment of inventory roles.

**Products Included:**

- Direct Organization Inventory Role
- Chained Organization Inventory - Destination Role
- Chained Organization Inventory - Intermediate Role

**Target Users:** MSPs managing multiple customer organizations

### quiverstone-account-access-portfolio.yaml

AWS Service Catalog portfolio for organization-wide account access role deployment. Contains both individual and StackSet-based products for read-only account access across all organization accounts.

**Products Included:**

- Direct Account Access Role (individual + StackSet)
- Chained Account Access Destination Role (individual + StackSet)
- Chained Account Access Intermediate Role
- Browser Switch Role (individual + StackSet)

**Target Users:** Organizations deploying access roles to all accounts

## Quick Launch

| Template                           | Description                                      | Deploy To          | Launch                                                                                                                                                                                                                                                                                                                       |
| ---------------------------------- | ------------------------------------------------ | ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Inventory Roles Portfolio**      | MSP portfolio for organization inventory roles   | MSP Account        | [![Launch Stack](../assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/service-catalog/quiverstone-inventory-roles-portfolio.yaml&stackName=quiverstone-inventory-roles-portfolio) |
| **Account Access Roles Portfolio** | Organization-wide account access roles portfolio | Management Account | [![Launch Stack](../assets/stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/service-catalog/quiverstone-account-access-portfolio.yaml&stackName=quiverstone-account-access-portfolio)   |

## What is AWS Service Catalog?

AWS Service Catalog allows organizations to create and manage catalogs of IT services that are approved for use on AWS. It enables:

- **Centralized Management:** Manage approved CloudFormation templates in a central catalog
- **Self-Service Deployment:** End users can deploy approved products without deep AWS knowledge
- **Governance and Compliance:** Enforce organizational standards and best practices
- **Version Control:** Manage multiple versions of products
- **Portfolio Sharing:** Share portfolios across AWS Organizations

## Portfolio Details

### Inventory Roles Portfolio

**Purpose:** Enable MSPs to provide organization inventory roles to customer organizations through a self-service catalog.

**Deployment Strategy:**

1. Deploy portfolio in MSP management account
2. Share portfolio with customer organizations via AWS Organizations
3. Customer administrators can self-service deploy inventory roles
4. MSP maintains central control over approved templates and versions

**Products:**

- **Direct Organization Inventory Role** (v1.0.0)
  - Direct assumption from Quiverstone production account
  - Read-only organization data access

- **Chained Organization Inventory - Destination Role** (v1.0.0)
  - Destination role in management account
  - Trusts intermediate account for enhanced security

- **Chained Organization Inventory - Intermediate Role** (v1.0.0)
  - Intermediate role in trusted account
  - Configurable assume role scope

**Owner/Distributor:** Quiverstone
**Support:** <support+iac@quiverston.io>

### Account Access Roles Portfolio

**Purpose:** Enable organizations to deploy read-only account access roles across all accounts through self-service catalog.

**Deployment Strategy:**

1. Deploy portfolio in organization management account
2. Share portfolio with organizational units or specific accounts
3. Account administrators can self-service deploy access roles
4. Use StackSet products for organization-wide deployment

**Products:**

- **Direct Account Access Role** (v1.0.0)
  - Individual account deployment
  - Direct assumption for read-only access

- **Direct Account Access - StackSet** (v1.0.0)
  - Organization-wide deployment
  - Automatic inclusion of new accounts

- **Chained Account Access Destination Role** (v1.0.0)
  - Individual account deployment
  - Trusts intermediate account

- **Chained Account Access Destination - StackSet** (v1.0.0)
  - Organization-wide deployment with chaining
  - Automatic inclusion of new accounts

- **Chained Account Access Intermediate Role** (v1.0.0)
  - Intermediate account deployment
  - Configurable assume role scope

- **Browser Switch Role** (v1.0.0)
  - Individual account deployment
  - Browser-based console access

- **Browser Switch Role - StackSet** (v1.0.0)
  - Organization-wide browser access
  - Automatic inclusion of new accounts

**Owner/Distributor:** Quiverstone
**Support:** <support+iac@quiverston.io>

## Portfolio Sharing

### Sharing with AWS Organizations

Both portfolios support sharing via AWS Organizations:

1. **Navigate to Service Catalog Console**
2. **Select Portfolio**
3. **Click "Share" → "Share with Organization"**
4. **Select Organizational Units or Accounts**
5. **Enable sharing**

### Sharing with Specific Accounts

For granular control, share portfolios with specific AWS accounts:

1. **Navigate to Service Catalog Console**
2. **Select Portfolio**
3. **Click "Share" → "Share with AWS Account"**
4. **Enter target account ID**
5. **Enable sharing**

## Launch Constraints

Both portfolios include Service Catalog launch roles with AdministratorAccess to enable product deployment. These roles are used by Service Catalog to launch products on behalf of end users.

**Launch Role Names:**

- Inventory Portfolio: `ServiceCatalogInventoryRolesLaunchRole`
- Account Access Portfolio: `ServiceCatalogAccountAccessRolesLaunchRole`

## Product Versioning

All products are currently at version 1.0.0. Future versions can be added as new provisioning artifacts to existing products, allowing:

- **Version Control:** Track changes across template versions
- **Rollback Capability:** Revert to previous versions if needed
- **Testing:** Test new versions alongside stable versions
- **Gradual Rollout:** Deploy new versions to subset of users first

## Template Sources

All product templates are sourced from S3:

- **Bucket:** assets.quiverston.io
- **Region:** us-east-2
- **Prefix:** quiverstone-roles-catalog/

**Inventory Templates:** `quiverstone-roles-catalog/inventory/`
**Access Templates:** `quiverstone-roles-catalog/access/`

## Prerequisites

Before deploying Service Catalog portfolios:

1. **S3 Bucket Access**
   - Templates must be accessible from the S3 bucket
   - Bucket policy allows Service Catalog access

2. **IAM Permissions**
   - Permission to create Service Catalog portfolios
   - Permission to create IAM roles (for launch constraints)

3. **Organization Setup** (for portfolio sharing)
   - AWS Organizations enabled
   - Trusted access enabled for Service Catalog (if sharing via Organizations)

## Best Practices

### Portfolio Management

- **Version Control:** Add new versions as provisioning artifacts rather than modifying existing ones
- **Testing:** Test products in non-production environments before sharing
- **Documentation:** Provide clear product descriptions and support information
- **Governance:** Regularly review portfolio access and product usage

### Security

- **Least Privilege:** Launch roles should have minimum required permissions
- **Constraint Policies:** Use tag update constraints to enforce tagging standards
- **Access Control:** Share portfolios only with necessary accounts/OUs
- **Audit:** Enable CloudTrail logging for Service Catalog actions

### User Experience

- **Clear Naming:** Use descriptive product names
- **Product Descriptions:** Provide comprehensive descriptions
- **Support Information:** Include contact information and documentation links
- **Parameter Guidance:** Use parameter labels and descriptions

## Monitoring and Management

### Track Product Usage

Monitor which products are being launched and by whom:

```bash
# List all provisioned products
aws servicecatalog search-provisioned-products

# Describe specific provisioned product
aws servicecatalog describe-provisioned-product --id <product-id>
```

### Portfolio Updates

Update portfolio products with new versions:

```bash
# Create new provisioning artifact
aws servicecatalog create-provisioning-artifact \
    --product-id <product-id> \
    --parameters Name=v1.1.0,Type=CLOUD_FORMATION_TEMPLATE,Info={LoadTemplateFromURL=https://...}
```

### Remove Access

Terminate portfolio sharing:

```bash
# Delete portfolio share
aws servicecatalog delete-portfolio-share \
    --portfolio-id <portfolio-id> \
    --account-id <account-id>
```

## Troubleshooting

### Common Issues

1. **Template Not Found**
   - Verify S3 bucket permissions
   - Confirm template URL is correct
   - Check S3 bucket is in correct region

2. **Launch Failed**
   - Review launch role permissions
   - Check CloudFormation events for errors
   - Verify parameter values are correct

3. **Product Not Visible**
   - Confirm portfolio is shared with correct accounts/OUs
   - Verify user has permission to access Service Catalog
   - Check product is associated with portfolio

4. **Permission Denied**
   - Verify launch constraints are configured
   - Check launch role has required permissions
   - Confirm user has servicecatalog:ProvisionProduct permission

## Support

For questions about Service Catalog portfolio deployment or product configuration:

- **Email:** <support+iac@quiverston.io>
- **Documentation:** <https://docs.quiverston.io/setup/>
- **AWS Service Catalog Docs:** <https://docs.aws.amazon.com/servicecatalog/>

## Additional Resources

- [AWS Service Catalog Administrator Guide](https://docs.aws.amazon.com/servicecatalog/latest/adminguide/)
- [AWS Service Catalog User Guide](https://docs.aws.amazon.com/servicecatalog/latest/userguide/)
- [Service Catalog Best Practices](https://docs.aws.amazon.com/servicecatalog/latest/adminguide/best-practices.html)
- [Portfolio Sharing](https://docs.aws.amazon.com/servicecatalog/latest/adminguide/catalogs_portfolios_sharing.html)
