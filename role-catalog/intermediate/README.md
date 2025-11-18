# Trusted Intermediate Role Template

This directory contains the CloudFormation template for deploying the Quiverstone trusted intermediate role. This role enables secure chained access to AWS accounts by serving as an intermediate hop between Quiverstone and destination accounts. The intermediate role is a critical component of the chained access architecture, providing an additional security layer and centralized audit point for role assumptions.

## Overview

The trusted intermediate role is deployed in a dedicated intermediate account (also called a trusted account) that you control. This role acts as a bridge, allowing Quiverstone to assume roles in your destination accounts through a two-step process: first assuming the intermediate role, then using that role to assume destination roles. This architecture provides enhanced security, centralized auditing, and compliance-friendly access patterns.

## Intermediate Template

This directory contains 1 CloudFormation template:

### trusted-intermediate-role.yaml

**Description:** Quiverstone Trusted Intermediate Role - Deploys in the Intermediate Account to enable role chaining.

**Deploy To:** Intermediate/Trusted Account Home Region (e.g. us-east-1)

**Version:** 1.0.0

**Key Features:**
- Acts as intermediate hop for chained role assumption
- Configurable scope for destination role access (any role, specific role, or specific account and role)
- Supports External ID for enhanced security (recommended)
- Enables centralized audit point for all role assumptions
- Provides additional security layer beyond direct access

**Key Parameters:**
- `pIntermediateRoleName`: Name for the intermediate role (Default: QuiverstoneTrustedIntermediate)
- `pExternalId`: External ID for this intermediate role assumption (recommended for security)
- `pQuiverstoneProductionAccountId`: Quiverstone production account ID (Default: 684035162433)
- `pAssumeRoleScope`: Scope of destination roles this intermediate role can assume
  - `any-role-any-account`: Least restrictive - can assume any role in any account
  - `specific-account-and-role`: Most restrictive - can assume only a specific named role in a specific account
  - `specific-role-any-account`: Best option - can assume the same role name across multiple accounts/organizations
- `pDestinationAccountId`: Management Account ID where the destination role exists (required only for `specific-account-and-role` scope)
- `pDestinationRoleName`: Name of the destination role (required for `specific-account-and-role` and `specific-role-any-account` scopes)

**Permissions Granted:**
- `sts:AssumeRole`: Ability to assume roles in destination accounts based on configured scope

## Role in Chained Access Architecture

The trusted intermediate role is the cornerstone of the chained access pattern. Understanding how it fits into the overall architecture is essential for proper deployment and configuration.

### Chained Access Flow

```
Quiverstone Production Account (684035162433)
    ↓ (assumes with External ID)
Intermediate Role in Your Trusted Account
    ↓ (assumes with External ID)
Destination Role in Target Account(s)
    ↓
Access to AWS Resources
```

### Step-by-Step Process

1. **Initial Assumption**: Quiverstone production account (684035162433) assumes the intermediate role in your trusted account using External ID for authentication
2. **Intermediate Hop**: The intermediate role provides temporary credentials that can assume destination roles
3. **Destination Assumption**: Using the intermediate role's credentials, Quiverstone assumes the destination role (access or inventory role) in the target account
4. **Resource Access**: The destination role provides access to AWS resources based on its permissions

### Why Use Chained Access?

**Security Benefits:**
- **Additional Security Layer**: Two-step authentication process with separate External IDs
- **Centralized Control**: All role assumptions flow through your controlled intermediate account
- **Audit Trail**: Complete visibility into all role assumptions through CloudTrail in intermediate account
- **Principle of Least Privilege**: Fine-grained control over which destination roles can be assumed

**Compliance Benefits:**
- **Regulatory Requirements**: Meets compliance mandates requiring intermediate controls
- **Security Policies**: Satisfies policies prohibiting direct external account trust
- **Audit Requirements**: Provides centralized audit point for all access
- **Change Control**: Easier to modify access patterns without touching destination accounts

**Operational Benefits:**
- **Scalability**: Single intermediate role can access hundreds of destination accounts
- **Consistency**: Uniform access pattern across all accounts
- **Flexibility**: Easy to add or remove destination accounts without reconfiguring Quiverstone

## Assume Role Scope Options

The intermediate role supports three scope configurations that control which destination roles it can assume. Choose the scope that balances your security requirements with operational flexibility.

### Option 1: any-role-any-account (Least Restrictive)

**Configuration:**
- Set `pAssumeRoleScope` to `any-role-any-account`
- No need to specify `pDestinationAccountId` or `pDestinationRoleName`

**What It Allows:**
- Intermediate role can assume ANY role in ANY AWS account
- Maximum flexibility for multi-account, multi-organization scenarios
- Simplest configuration with no role name or account restrictions

**When to Use:**
- Managing multiple organizations with different role naming conventions
- Need maximum flexibility for dynamic account structures
- Trusted account is tightly controlled and secured
- Operational simplicity is priority

**Security Considerations:**
- Least restrictive option - intermediate role has broad permissions
- Relies on destination role trust policies for access control
- Requires strong security controls on intermediate account
- All role assumptions still logged in CloudTrail

**IAM Policy:**
```json
{
  "Effect": "Allow",
  "Action": "sts:AssumeRole",
  "Resource": "arn:aws:iam::*:role/*"
}
```

**Best for:** Large enterprises managing multiple organizations, maximum operational flexibility

### Option 2: specific-account-and-role (Most Restrictive)

**Configuration:**
- Set `pAssumeRoleScope` to `specific-account-and-role`
- Specify `pDestinationAccountId` (e.g., 123456789012)
- Specify `pDestinationRoleName` (e.g., QuiverstoneChainedOrgInventory)

**What It Allows:**
- Intermediate role can assume ONLY the specified role in the specified account
- Single destination role only
- Maximum security through explicit resource specification

**When to Use:**
- Single organization with one inventory role
- Maximum security requirements
- Want explicit control over exact destination
- Compliance requires specific resource ARNs

**Security Considerations:**
- Most restrictive option - explicit single destination
- Requires template update to add additional destinations
- Provides maximum security through specificity
- Ideal for highly regulated environments

**IAM Policy:**
```json
{
  "Effect": "Allow",
  "Action": "sts:AssumeRole",
  "Resource": "arn:aws:iam::123456789012:role/QuiverstoneChainedOrgInventory"
}
```

**Best for:** Single organization deployments, maximum security requirements, highly regulated environments

### Option 3: specific-role-any-account (Recommended)

**Configuration:**
- Set `pAssumeRoleScope` to `specific-role-any-account`
- Specify `pDestinationRoleName` (e.g., QuiverstoneChainedAccess)
- No need to specify `pDestinationAccountId`

**What It Allows:**
- Intermediate role can assume roles with the specified name in ANY account
- Supports multiple accounts with consistent role naming
- Balances security and flexibility

**When to Use:**
- Managing single or multiple organizations with consistent role naming
- Want security through role name restriction
- Need flexibility to add accounts without template updates
- Following AWS best practices for role naming conventions

**Security Considerations:**
- Balanced approach - restricts by role name but allows multiple accounts
- Requires consistent role naming across accounts
- Provides good security while maintaining operational flexibility
- Recommended for most production deployments

**IAM Policy:**
```json
{
  "Effect": "Allow",
  "Action": "sts:AssumeRole",
  "Resource": "arn:aws:iam::*:role/QuiverstoneChainedAccess"
}
```

**Best for:** Most production deployments, organizations with consistent role naming, balance of security and flexibility

## Configuration Parameters

### Required Parameters

**pIntermediateRoleName**
- **Purpose**: Name for the intermediate role created in your trusted account
- **Default**: QuiverstoneTrustedIntermediate
- **Constraints**: Must be valid IAM role name (alphanumeric and +=,.@-_ characters)
- **Recommendation**: Use default unless you have specific naming requirements

**pQuiverstoneProductionAccountId**
- **Purpose**: Quiverstone production account ID that will assume this intermediate role
- **Default**: 684035162433
- **Constraints**: Must be 12-digit AWS account ID
- **Recommendation**: DO NOT MODIFY - this is Quiverstone's production account

**pAssumeRoleScope**
- **Purpose**: Controls which destination roles the intermediate role can assume
- **Default**: any-role-any-account
- **Options**: any-role-any-account, specific-account-and-role, specific-role-any-account
- **Recommendation**: Use specific-role-any-account for best balance of security and flexibility

### Optional Parameters

**pExternalId**
- **Purpose**: External ID for intermediate role assumption security
- **Default**: Empty string (not recommended)
- **Constraints**: Maximum 1224 characters
- **Recommendation**: ALWAYS use External ID - generate unique random string (minimum 32 characters)
- **Security**: Prevents confused deputy attacks, required for production deployments

**pDestinationAccountId**
- **Purpose**: Specific AWS account ID for destination role (used only with specific-account-and-role scope)
- **Default**: Empty string
- **Constraints**: Must be 12-digit AWS account ID or empty
- **When Required**: Only when pAssumeRoleScope is specific-account-and-role
- **When Ignored**: For any-role-any-account and specific-role-any-account scopes

**pDestinationRoleName**
- **Purpose**: Name of destination role(s) the intermediate role can assume
- **Default**: Empty string
- **Constraints**: Must be valid IAM role name or empty
- **When Required**: For specific-account-and-role and specific-role-any-account scopes
- **When Ignored**: For any-role-any-account scope
- **Recommendation**: Use consistent role names across accounts (e.g., QuiverstoneChainedAccess)

## Trust Relationship Configuration

The intermediate role's trust policy controls who can assume it. Understanding this trust relationship is critical for security.

### Trust Policy Structure

The intermediate role trusts the Quiverstone production account (684035162433) to assume it:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::684035162433:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "your-external-id-here"
        }
      }
    }
  ]
}
```

### Trust Policy Components

**Principal**: Specifies who can assume the role
- `arn:aws:iam::684035162433:root`: Quiverstone production account
- Allows any principal in the Quiverstone account to assume the role
- Quiverstone controls which principals can actually assume it

**Action**: Specifies what the principal can do
- `sts:AssumeRole`: Permission to assume this role
- Only action granted in trust policy

**Condition**: Additional security requirements
- `sts:ExternalId`: External ID must match for assumption to succeed
- Prevents confused deputy attacks
- Strongly recommended for all production deployments

### External ID Security

**What is External ID?**
- A secret token shared between you and Quiverstone
- Required for role assumption to succeed
- Prevents unauthorized role assumptions

**How It Works:**
1. You generate a unique random string (minimum 32 characters)
2. You configure it in the CloudFormation template parameter
3. You provide it to Quiverstone in your organization configuration
4. Quiverstone must provide the correct External ID when assuming the role
5. AWS validates the External ID before allowing assumption

**Best Practices:**
- Always use External ID in production
- Generate cryptographically random strings
- Use minimum 32 characters (longer is better)
- Store securely (password manager, secrets manager)
- Use different External IDs for intermediate and destination roles
- Rotate periodically for enhanced security

## Deployment Scenarios and Use Cases

### Scenario 1: Single Organization with Chained Inventory Access

**Setup:**
- One AWS Organization
- Want chained access to organization inventory role
- Security policies require intermediate account

**Recommended Configuration:**
- `pAssumeRoleScope`: specific-role-any-account
- `pDestinationRoleName`: QuiverstoneChainedOrgInventory
- `pExternalId`: Generate unique random string

**Deployment Steps:**
1. Choose or create intermediate/trusted AWS account
2. Deploy trusted-intermediate-role.yaml to intermediate account
3. Configure parameters as recommended above
4. Note the intermediate role ARN and External ID
5. Deploy chained-org-inventory-role.yaml to management account
6. Configure Quiverstone with intermediate role ARN and External ID

**Benefits:** Enhanced security, centralized audit, compliance-friendly

### Scenario 2: Multiple Organizations with Chained Access

**Setup:**
- Multiple AWS Organizations
- Want chained access to all organizations
- Consistent role naming across organizations

**Recommended Configuration:**
- `pAssumeRoleScope`: specific-role-any-account
- `pDestinationRoleName`: QuiverstoneChainedOrgInventory
- `pExternalId`: Generate unique random string

**Deployment Steps:**
1. Deploy trusted-intermediate-role.yaml to intermediate account (once)
2. For each organization:
   - Deploy chained-org-inventory-role.yaml to management account
   - Use consistent role name (QuiverstoneChainedOrgInventory)
   - Configure to trust intermediate account
3. Configure Quiverstone with intermediate role ARN and External ID

**Benefits:** Single intermediate role for all organizations, consistent access pattern, scalable

### Scenario 3: Organization-Wide Chained Account Access

**Setup:**
- AWS Organization with many member accounts
- Want chained access roles deployed to all accounts
- Using StackSets for deployment

**Recommended Configuration:**
- `pAssumeRoleScope`: specific-role-any-account
- `pDestinationRoleName`: QuiverstoneChainedAccess
- `pExternalId`: Generate unique random string

**Deployment Steps:**
1. Deploy trusted-intermediate-role.yaml to intermediate account
2. Deploy chained-access-role-stackset.yaml to management account
3. StackSet deploys chained-access-role to all organization accounts
4. All destination roles trust the intermediate account
5. Configure Quiverstone with intermediate role ARN and External ID

**Benefits:** Single intermediate role for hundreds of accounts, automatic deployment to new accounts, centralized management

### Scenario 4: Maximum Security Single Destination

**Setup:**
- Single organization with strict security requirements
- Want maximum security through explicit resource specification
- Compliance requires specific ARNs in policies

**Recommended Configuration:**
- `pAssumeRoleScope`: specific-account-and-role
- `pDestinationAccountId`: Your management account ID
- `pDestinationRoleName`: QuiverstoneChainedOrgInventory
- `pExternalId`: Generate unique random string

**Deployment Steps:**
1. Deploy trusted-intermediate-role.yaml to intermediate account
2. Configure with specific account ID and role name
3. Deploy chained-org-inventory-role.yaml to specified account only
4. Configure Quiverstone with intermediate role ARN and External ID

**Benefits:** Maximum security, explicit resource control, compliance-friendly

### Scenario 5: Maximum Flexibility Multi-Organization

**Setup:**
- Multiple organizations with different role naming conventions
- Legacy accounts with non-standard role names
- Need maximum operational flexibility

**Recommended Configuration:**
- `pAssumeRoleScope`: any-role-any-account
- `pExternalId`: Generate unique random string
- Ensure intermediate account has strong security controls

**Deployment Steps:**
1. Deploy trusted-intermediate-role.yaml to intermediate account
2. Configure with any-role-any-account scope
3. Deploy various destination roles with different names across accounts
4. Configure Quiverstone with intermediate role ARN and External ID

**Benefits:** Maximum flexibility, supports legacy naming, no template updates needed for new destinations

**Caution:** Least restrictive option - ensure intermediate account is highly secured

## Quick Launch

| Template | Description | Deploy To | Launch |
|----------|-------------|-----------|--------|
| **Trusted Intermediate Role** | Intermediate role for chained access architecture | Intermediate/Trusted Account | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/intermediate/trusted-intermediate-role.yaml&stackName=quiverstone-trusted-intermediate-role) |

## Integration with Access and Inventory Roles

The intermediate role works in conjunction with chained access and inventory roles to provide complete chained access functionality.

### Integration with Chained Access Roles

**Purpose**: Intermediate role enables chained access to member accounts

**Access Role Templates:**
- `role-catalog/access/chained-access-role.yaml`: Individual account deployment
- `role-catalog/access/chained-access-role-stackset.yaml`: Organization-wide deployment

**How They Work Together:**
1. Intermediate role deployed in trusted account
2. Chained access roles deployed to target accounts
3. Chained access roles trust the intermediate account (or specific intermediate role)
4. Quiverstone assumes intermediate role, then assumes chained access roles
5. Provides account-level access with configurable permissions

**Configuration Requirements:**
- Chained access roles must specify intermediate account ID in `pIntermediateAccountId` parameter
- Chained access roles must specify intermediate role name in `pIntermediateRoleName` parameter
- Intermediate role must have appropriate scope to assume chained access roles
- Recommended: Use `specific-role-any-account` scope with consistent role naming

**Documentation**: See [Access Role README](../access/README.md)

### Integration with Chained Inventory Roles

**Purpose**: Intermediate role enables chained access to organization inventory

**Inventory Role Template:**
- `role-catalog/inventory/chained-org-inventory-role.yaml`: Organization inventory deployment

**How They Work Together:**
1. Intermediate role deployed in trusted account
2. Chained inventory role deployed to management or delegated account
3. Chained inventory role trusts the intermediate account (or specific intermediate role)
4. Quiverstone assumes intermediate role, then assumes chained inventory role
5. Provides organization-level read access for account discovery

**Configuration Requirements:**
- Chained inventory role must specify intermediate account ID in `pIntermediateAccountId` parameter
- Chained inventory role must specify intermediate role name in `pIntermediateRoleName` parameter
- Intermediate role must have appropriate scope to assume chained inventory role
- Recommended: Use `specific-role-any-account` scope with role name QuiverstoneChainedOrgInventory

**Documentation**: See [Inventory Role README](../inventory/README.md)

### Deployment Order

For chained access deployments, follow this order:

1. **First**: Deploy intermediate role in intermediate/trusted account (this template)
2. **Second**: Deploy chained inventory role in management/delegated account (if needed)
3. **Third**: Deploy chained access roles to target accounts (if needed)
4. **Finally**: Configure Quiverstone with intermediate role ARN, External ID, and destination role details

### Trust Configuration Options

Destination roles (access and inventory) support two trust configuration options:

**Trust All Principals (pTrustPrincipals = All)**
- Destination role trusts all principals in the intermediate account
- Simpler configuration
- Suitable when intermediate account is tightly controlled
- Any principal in intermediate account can assume destination role

**Trust Named Role (pTrustPrincipals = Named)**
- Destination role trusts only the specific intermediate role
- Enhanced security through explicit trust
- Requires specifying exact intermediate role name
- Recommended for production deployments
- Only the named intermediate role can assume destination role

**Recommendation**: Use "Named" trust for production deployments to follow principle of least privilege

## Security Considerations

### Authentication and Authorization

**External ID Usage:**
- Always use External ID for intermediate role assumption
- Generate cryptographically random strings (minimum 32 characters)
- Use different External IDs for intermediate and destination roles
- Store External IDs securely (password manager, AWS Secrets Manager)
- Rotate periodically for enhanced security

**Assume Role Scope:**
- Choose most restrictive scope that meets operational needs
- Use `specific-role-any-account` for best balance
- Use `specific-account-and-role` for maximum security
- Use `any-role-any-account` only when necessary and with strong account controls

**Trust Policies:**
- Intermediate role trusts only Quiverstone production account (684035162433)
- Destination roles trust only intermediate account (or specific intermediate role)
- No wildcard principals in trust policies
- All trust relationships explicitly defined

### Audit and Compliance

**CloudTrail Logging:**
- All role assumptions logged in CloudTrail
- Intermediate account provides centralized audit point
- All assumptions to destination accounts flow through intermediate account
- Complete audit trail from Quiverstone → Intermediate → Destination

**Compliance Benefits:**
- Meets regulatory requirements for intermediate controls
- Satisfies security policies prohibiting direct external trust
- Provides centralized audit point for compliance reporting
- Enables change control through single intermediate role

**Session Tracking:**
- All sessions tagged with source identity
- Role assumption chains visible in CloudTrail
- Session duration limits enforced by AWS
- MFA compatible for enhanced security

### Access Control

**Principle of Least Privilege:**
- Configure most restrictive assume role scope possible
- Use named role trust in destination roles
- Limit intermediate role permissions to sts:AssumeRole only
- No additional permissions granted to intermediate role

**Account Security:**
- Intermediate account should be dedicated to this purpose
- Implement strong security controls on intermediate account
- Limit human access to intermediate account
- Monitor intermediate account for unusual activity
- Enable MFA for all human access to intermediate account

**Network Security:**
- No network access required for intermediate role
- All operations use AWS API over HTTPS
- No VPC or network configuration needed
- Works across all AWS regions

### Monitoring and Alerting

**CloudWatch Integration:**
- Role usage visible in CloudWatch metrics
- Set up alarms for unusual assumption patterns
- Monitor assumption frequency and timing
- Track failed assumption attempts

**AWS Config:**
- Track intermediate role configuration changes
- Ensure role policy remains compliant
- Alert on unauthorized modifications
- Maintain configuration history

**Security Hub:**
- Integrate with AWS Security Hub for centralized security monitoring
- Track security findings related to role usage
- Correlate events across accounts
- Automated compliance checks

## Support and Documentation

### Additional Resources

- **Quiverstone Documentation**: <https://docs.quiverston.io>
- **Chained Access Setup**: <https://docs.quiverston.io/setup/chained-access>
- **Intermediate Role Configuration**: <https://docs.quiverston.io/setup/intermediate-role>
- **AWS IAM Role Chaining**: <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_terms-and-concepts.html>
- **AWS STS AssumeRole**: <https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html>

### Getting Help

For questions about template deployment or configuration:

- Contact your Quiverstone administrator
- Visit the Quiverstone documentation portal
- Review AWS IAM documentation for role chaining concepts
- Check CloudTrail logs for role assumption errors

### Troubleshooting

**Common Issues:**

- **Role assumption fails**: Check External ID matches between template and Quiverstone configuration
- **Cannot assume destination roles**: Verify assume role scope includes destination roles
- **Permission denied**: Ensure intermediate role has sts:AssumeRole permission for destination roles
- **Destination role trust error**: Verify destination roles trust the intermediate account/role
- **External ID mismatch**: Confirm External ID is identical in template, Quiverstone config, and destination roles

**Validation Steps:**

1. Verify intermediate role exists in intermediate account
2. Check intermediate role trust policy includes Quiverstone account (684035162433)
3. Verify External ID is configured in intermediate role trust policy
4. Check intermediate role policy allows sts:AssumeRole for destination roles
5. Verify destination roles trust intermediate account or specific intermediate role
6. Test role assumption using AWS CLI:
   ```bash
   # Test intermediate role assumption
   aws sts assume-role \
     --role-arn arn:aws:iam::INTERMEDIATE-ACCOUNT:role/QuiverstoneTrustedIntermediate \
     --role-session-name test \
     --external-id YOUR-EXTERNAL-ID

   # Test destination role assumption (using intermediate credentials)
   aws sts assume-role \
     --role-arn arn:aws:iam::DESTINATION-ACCOUNT:role/QuiverstoneChainedAccess \
     --role-session-name test
   ```
7. Check CloudTrail logs in intermediate account for assumption attempts and errors
8. Verify assume role scope matches destination role names/accounts

**Debug Checklist:**

- [ ] Intermediate role deployed in correct account
- [ ] Intermediate role name matches configuration
- [ ] External ID configured and matches Quiverstone config
- [ ] Assume role scope configured correctly
- [ ] Destination role names match scope configuration
- [ ] Destination roles trust intermediate account
- [ ] CloudTrail enabled in intermediate account
- [ ] No typos in account IDs or role names

## Version Information

The template in this directory is version 1.0.0. Check template metadata for specific version information and update history.

