# Design Document

## Overview

This design outlines the structure and content for comprehensive documentation of the Quiverstone Role Catalog CloudFormation templates. The documentation will be organized across four README files (main, access, intermediate, and inventory) with consistent formatting, accurate template references, and clear guidance for users deploying IAM roles for AWS account access.

## Architecture

The documentation architecture follows a hierarchical structure:

```
README.md (Main)
├── role-catalog/access/README.md
├── role-catalog/intermediate/README.md
└── role-catalog/inventory/README.md
```

Each README serves a specific purpose:
- **Main README**: High-level overview, access method comparison, directory navigation
- **Access README**: Detailed documentation for all 6 access role templates
- **Intermediate README**: Detailed documentation for the trusted intermediate role template
- **Inventory README**: Detailed documentation for all 3 inventory role templates

## Components and Interfaces

### Documentation Components

#### 1. Main README (README.md)

**Sections:**
- Project title and description
- Access methods overview (Browser, Direct, Chained)
- Role types overview (Inventory vs Access)
- Directory structure with descriptions
- Quick reference table for common deployments
- Navigation links to subdirectory READMEs
- Security features summary
- Support information

#### 2. Access README (role-catalog/access/README.md)

**Sections:**
- Directory introduction
- Template catalog (6 templates):
  - browser-access-role.yaml
  - browser-access-role-stackset.yaml
  - direct-access-role.yaml
  - direct-access-role-stackset.yaml
  - chained-access-role.yaml
  - chained-access-role-stackset.yaml
- Access method comparison (Browser vs Direct vs Chained)
- Deployment type comparison (Individual vs StackSet)
- Quick Launch tables (separate for individual and StackSet)
- Configuration guidance
- Prerequisites and permissions
- Deployment recommendations by organization size
- Security features
- Support information

#### 3. Intermediate README (role-catalog/intermediate/README.md)

**Sections:**
- Purpose and overview
- Template documentation:
  - trusted-intermediate-role.yaml
- Role in chained access architecture
- Assume role scope options explanation
- Configuration parameters
- Trust relationship details
- Deployment scenarios
- Quick Launch link
- Integration with access and inventory roles
- Security considerations
- Support information

#### 4. Inventory README (role-catalog/inventory/README.md)

**Sections:**
- Directory introduction
- Template catalog (3 templates + 1 policy):
  - direct-org-inventory-role.yaml
  - chained-org-inventory-role.yaml
  - standalone-account-inventory-role.yaml
  - organization-delegation-policy.json
- Account type comparison (Management vs Delegated vs Standalone)
- Access method comparison (Direct vs Chained)
- Quick Launch table
- Configuration guidance
- Permissions granted
- Deployment scenarios
- Organization delegation policy usage
- Security features
- Support information

## Data Models

### Template Metadata Structure

Each template documentation entry should include:

```yaml
Template Name: <filename>
Purpose: <one-line description>
Deploy To: <target account type>
Access Method: <Browser|Direct|Chained>
Deployment Type: <Individual|StackSet>
Key Parameters:
  - Parameter name: Description
  - ...
Quick Launch URL: <S3 URL>
```

### Quick Launch Table Structure

```markdown
| Template | Description | Deploy To | Launch |
|----------|-------------|-----------|--------|
| Name | Brief description | Account type | Button with URL |
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Property 1: Quick Launch URL format consistency
*For any* Quick Launch link in any README file, the URL should follow the pattern `https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/{directory}/{filename}&stackName={stack-name}`
**Validates: Requirements 5.4**

Property 2: Template metadata completeness
*For any* template documented in a README file, the documentation should include version, deploy-to target, and purpose metadata
**Validates: Requirements 5.5**

Property 3: Filename accuracy
*For any* template reference in any README file, the referenced filename should exist as an actual file in the corresponding repository directory
**Validates: Requirements 6.1**

Property 4: S3 path correctness
*For any* Quick Launch URL in any README file, the S3 path component should match the actual template filename in the repository
**Validates: Requirements 6.2**

Property 5: Description consistency with template metadata
*For any* template documented in a README file, the description should match the Description field from the CloudFormation template's metadata
**Validates: Requirements 6.3**

Property 6: Cross-reference consistency
*For any* template mentioned in multiple README files, the template name and core description should be consistent across all references
**Validates: Requirements 6.4**

Property 7: Deploy-To accuracy
*For any* template documented in a README file, the Deploy-To information should match the Deploy-To field from the CloudFormation template's metadata
**Validates: Requirements 6.5**

## Error Handling

Documentation errors to address:

1. **Missing Templates**: Ensure all template files in directories are documented
2. **Broken Links**: Verify all Quick Launch URLs are properly formatted
3. **Filename Mismatches**: Correct any references to non-existent files
4. **Inconsistent Descriptions**: Align README descriptions with template metadata
5. **Missing Metadata**: Ensure all required metadata fields are present

## Testing Strategy

### Manual Review Tests

Since this is a documentation project, testing will primarily consist of manual review:

1. **Completeness Review**: Verify all templates are documented
2. **Accuracy Review**: Cross-check README content against template metadata
3. **Link Testing**: Manually test Quick Launch links (or use link checker)
4. **Consistency Review**: Compare descriptions across different README files
5. **User Experience Review**: Read through documentation as an end user

### Automated Validation (Optional)

Property-based tests could be implemented using a scripting language (Python, Node.js) to:

1. Parse all CloudFormation YAML templates to extract metadata
2. Parse all README markdown files to extract template references
3. Verify properties 1-7 programmatically

For this documentation project, automated testing is optional but would provide ongoing validation as templates evolve.

### Unit Tests

Unit tests are not applicable for this documentation-only project. Manual review and optional automated validation scripts are sufficient.

## Implementation Notes

### Content Sources

1. **Template Metadata**: Extract descriptions, parameters, and deployment targets from CloudFormation template Metadata sections
2. **Existing Documentation**: Preserve and enhance existing content where appropriate
3. **Template Analysis**: Review template Resources and Parameters sections to understand functionality

### S3 URL Pattern

All Quick Launch URLs should follow this pattern:
```
https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?templateURL=https://s3.us-east-2.amazonaws.com/assets.quiverstone.io/role-catalog/{directory}/{filename}&stackName={stack-name}
```

Where:
- `{directory}`: access, intermediate, or inventory
- `{filename}`: actual template filename
- `{stack-name}`: suggested stack name (typically matches filename without .yaml)

### Documentation Style Guidelines

1. Use clear, concise language
2. Lead with purpose before diving into details
3. Use tables for comparing multiple options
4. Include visual hierarchy with proper heading levels
5. Provide context before technical details
6. Use consistent terminology throughout

### Template Filename Mapping

**Access Directory:**
- browser-access-role.yaml
- browser-access-role-stackset.yaml
- direct-access-role.yaml
- direct-access-role-stackset.yaml
- chained-access-role.yaml
- chained-access-role-stackset.yaml

**Intermediate Directory:**
- trusted-intermediate-role.yaml

**Inventory Directory:**
- direct-org-inventory-role.yaml
- chained-org-inventory-role.yaml
- standalone-account-inventory-role.yaml
- organization-delegation-policy.json (policy document, not a template)

## Dependencies

- Access to all CloudFormation template files for metadata extraction
- Understanding of AWS IAM role assumption patterns
- Knowledge of CloudFormation StackSets
- Familiarity with AWS Organizations structure

## Future Enhancements

1. Add architecture diagrams showing role assumption flows
2. Include example IAM policy snippets
3. Add troubleshooting section for common deployment issues
4. Create video tutorials referenced from documentation
5. Add FAQ section based on user questions
6. Include cost estimation guidance
7. Add integration examples with Quiverstone platform
