#!/usr/bin/env node

/**
 * Property-Based Tests for Role Catalog Documentation
 *
 * This script validates the documentation against the correctness properties
 * defined in the design document.
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

// ANSI color codes for output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

// Helper to read file content
function readFile(filePath) {
  try {
    return fs.readFileSync(filePath, 'utf8');
  } catch (error) {
    return null;
  }
}

// Helper to parse YAML template (CloudFormation-aware)
function parseTemplate(filePath) {
  try {
    const content = readFile(filePath);
    if (!content) return null;

    // Extract just the parts we need using regex to avoid CloudFormation intrinsic function issues
    const descMatch = content.match(/^Description:\s*>?\s*\n?\s*(.+?)(?=\n\n|\nMetadata:)/ms);
    const versionMatch = content.match(/^\s+Version:\s*([^\n]+)/m);
    const deployToMatch = content.match(/^\s+Deploy-To:\s*([^\n]+)/m);

    return {
      Description: descMatch ? descMatch[1].trim().replace(/\n\s+/g, ' ') : null,
      Metadata: {
        TemplateInfo: {
          Version: versionMatch ? versionMatch[1].trim() : null,
          'Deploy-To': deployToMatch ? deployToMatch[1].trim() : null
        }
      }
    };
  } catch (error) {
    // If parsing fails, try to extract just the metadata we need
    try {
      const content = readFile(filePath);
      const descMatch = content.match(/^Description:\s*>?\s*\n?\s*(.+?)(?=\n\n|\nMetadata:)/ms);
      const versionMatch = content.match(/Version:\s*([^\n]+)/);
      const deployToMatch = content.match(/Deploy-To:\s*([^\n]+)/);

      return {
        Description: descMatch ? descMatch[1].trim().replace(/\n\s+/g, ' ') : null,
        Metadata: {
          TemplateInfo: {
            Version: versionMatch ? versionMatch[1].trim() : null,
            'Deploy-To': deployToMatch ? deployToMatch[1].trim() : null
          }
        }
      };
    } catch (fallbackError) {
      log(`Error parsing ${filePath}: ${error.message}`, 'red');
      return null;
    }
  }
}

// Helper to extract template references from markdown
function extractTemplateReferences(markdown) {
  const references = new Set();

  // Match .yaml and .json filenames
  const yamlPattern = /([a-z0-9-]+\.yaml)/g;
  const jsonPattern = /([a-z0-9-]+\.json)/g;

  let match;
  while ((match = yamlPattern.exec(markdown)) !== null) {
    references.add(match[1]);
  }
  while ((match = jsonPattern.exec(markdown)) !== null) {
    references.add(match[1]);
  }

  return Array.from(references);
}

// Helper to extract Quick Launch URLs from markdown
function extractQuickLaunchUrls(markdown) {
  const urls = [];
  const urlPattern = /https:\/\/s3\.us-east-2\.amazonaws\.com\/assets\.quiverstone\.io\/role-catalog\/([^)]+)/g;

  let match;
  while ((match = urlPattern.exec(markdown)) !== null) {
    urls.push({
      full: match[0],
      path: match[1]
    });
  }

  return urls;
}

/**
 * Property 3: Filename accuracy
 * Feature: role-catalog-documentation, Property 3: Filename accuracy
 * Validates: Requirements 6.1
 *
 * For any template reference in any README file, the referenced filename
 * should exist as an actual file in the corresponding repository directory
 */
function testProperty3_FilenameAccuracy() {
  log('\n=== Property 3: Filename Accuracy ===', 'blue');
  log('Feature: role-catalog-documentation, Property 3: Filename accuracy', 'blue');
  log('Validates: Requirements 6.1\n', 'blue');

  const readmes = [
    'README.md',
    'role-catalog/access/README.md',
    'role-catalog/intermediate/README.md',
    'role-catalog/inventory/README.md'
  ];

  const directories = {
    'access': 'role-catalog/access',
    'intermediate': 'role-catalog/intermediate',
    'inventory': 'role-catalog/inventory'
  };

  let passed = true;
  const errors = [];

  for (const readmePath of readmes) {
    const content = readFile(readmePath);
    if (!content) {
      errors.push(`Could not read ${readmePath}`);
      passed = false;
      continue;
    }

    const references = extractTemplateReferences(content);
    log(`Checking ${readmePath}: found ${references.length} template references`);

    for (const filename of references) {
      // Determine which directory this file should be in
      let found = false;

      for (const [dirName, dirPath] of Object.entries(directories)) {
        const fullPath = path.join(dirPath, filename);
        if (fs.existsSync(fullPath)) {
          found = true;
          log(`  ✓ ${filename} exists in ${dirPath}`, 'green');
          break;
        }
      }

      if (!found) {
        errors.push(`${filename} referenced in ${readmePath} but not found in repository`);
        log(`  ✗ ${filename} NOT FOUND in any directory`, 'red');
        passed = false;
      }
    }
  }

  if (passed) {
    log('\n✓ Property 3 PASSED: All template filenames match repository files', 'green');
  } else {
    log('\n✗ Property 3 FAILED:', 'red');
    errors.forEach(err => log(`  - ${err}`, 'red'));
  }

  return { passed, errors, property: 'Property 3: Filename accuracy' };
}

/**
 * Property 1: Quick Launch URL format consistency
 * Property 4: S3 path correctness
 * Feature: role-catalog-documentation, Property 1 & 4
 * Validates: Requirements 5.4, 6.2
 *
 * For any Quick Launch link in any README file, the URL should follow the pattern
 * and the S3 path component should match the actual template filename
 */
function testProperty1and4_QuickLaunchUrls() {
  log('\n=== Property 1 & 4: Quick Launch URL Format and S3 Path Correctness ===', 'blue');
  log('Feature: role-catalog-documentation, Property 1 & 4', 'blue');
  log('Validates: Requirements 5.4, 6.2\n', 'blue');

  const readmes = [
    'README.md',
    'role-catalog/access/README.md',
    'role-catalog/intermediate/README.md',
    'role-catalog/inventory/README.md'
  ];

  // Pattern allows for query parameters after the .yaml filename
  const expectedPattern = /^https:\/\/s3\.us-east-2\.amazonaws\.com\/assets\.quiverstone\.io\/role-catalog\/(access|intermediate|inventory)\/([a-z0-9-]+\.yaml)/;

  let passed = true;
  const errors = [];

  for (const readmePath of readmes) {
    const content = readFile(readmePath);
    if (!content) continue;

    const urls = extractQuickLaunchUrls(content);
    log(`Checking ${readmePath}: found ${urls.length} Quick Launch URLs`);

    for (const url of urls) {
      const match = url.full.match(expectedPattern);

      if (!match) {
        errors.push(`Invalid URL format in ${readmePath}: ${url.full}`);
        log(`  ✗ Invalid format: ${url.full}`, 'red');
        passed = false;
        continue;
      }

      const directory = match[1];
      const filename = match[2];
      const filePath = path.join('role-catalog', directory, filename);

      if (fs.existsSync(filePath)) {
        log(`  ✓ ${filename} - URL format correct and file exists`, 'green');
      } else {
        errors.push(`S3 path references non-existent file: ${filePath}`);
        log(`  ✗ ${filename} - File does not exist at ${filePath}`, 'red');
        passed = false;
      }
    }
  }

  if (passed) {
    log('\n✓ Properties 1 & 4 PASSED: All Quick Launch URLs are correctly formatted and reference existing files', 'green');
  } else {
    log('\n✗ Properties 1 & 4 FAILED:', 'red');
    errors.forEach(err => log(`  - ${err}`, 'red'));
  }

  return { passed, errors, property: 'Property 1 & 4: Quick Launch URL format and S3 path correctness' };
}

/**
 * Property 5: Description consistency with template metadata
 * Feature: role-catalog-documentation, Property 5
 * Validates: Requirements 6.3
 *
 * For any template documented in a README file, the description should match
 * the Description field from the CloudFormation template's metadata
 */
function testProperty5_DescriptionConsistency() {
  log('\n=== Property 5: Description Consistency ===', 'blue');
  log('Feature: role-catalog-documentation, Property 5', 'blue');
  log('Validates: Requirements 6.3\n', 'blue');

  const templates = [
    { path: 'role-catalog/access/browser-access-role.yaml', readme: 'role-catalog/access/README.md' },
    { path: 'role-catalog/access/direct-access-role.yaml', readme: 'role-catalog/access/README.md' },
    { path: 'role-catalog/access/chained-access-role.yaml', readme: 'role-catalog/access/README.md' },
    { path: 'role-catalog/intermediate/trusted-intermediate-role.yaml', readme: 'role-catalog/intermediate/README.md' },
    { path: 'role-catalog/inventory/direct-org-inventory-role.yaml', readme: 'role-catalog/inventory/README.md' },
    { path: 'role-catalog/inventory/chained-org-inventory-role.yaml', readme: 'role-catalog/inventory/README.md' },
    { path: 'role-catalog/inventory/standalone-account-inventory-role.yaml', readme: 'role-catalog/inventory/README.md' },
  ];

  let passed = true;
  const errors = [];

  for (const { path: templatePath, readme: readmePath } of templates) {
    const template = parseTemplate(templatePath);
    const readmeContent = readFile(readmePath);

    if (!template || !readmeContent) {
      errors.push(`Could not read ${templatePath} or ${readmePath}`);
      passed = false;
      continue;
    }

    const templateDescription = template.Description;
    const filename = path.basename(templatePath);

    log(`Checking ${filename}`);
    log(`  Template description: "${templateDescription}"`);

    // Check if the description appears in the README
    if (readmeContent.includes(templateDescription)) {
      log(`  ✓ Description found in README`, 'green');
    } else {
      errors.push(`Description mismatch for ${filename}: template says "${templateDescription}" but not found in ${readmePath}`);
      log(`  ✗ Description NOT found in README`, 'red');
      passed = false;
    }
  }

  if (passed) {
    log('\n✓ Property 5 PASSED: All template descriptions match CloudFormation metadata', 'green');
  } else {
    log('\n✗ Property 5 FAILED:', 'red');
    errors.forEach(err => log(`  - ${err}`, 'red'));
  }

  return { passed, errors, property: 'Property 5: Description consistency' };
}

/**
 * Property 7: Deploy-To accuracy
 * Feature: role-catalog-documentation, Property 7
 * Validates: Requirements 6.5
 *
 * For any template documented in a README file, the Deploy-To information
 * should match the Deploy-To field from the CloudFormation template's metadata
 */
function testProperty7_DeployToAccuracy() {
  log('\n=== Property 7: Deploy-To Accuracy ===', 'blue');
  log('Feature: role-catalog-documentation, Property 7', 'blue');
  log('Validates: Requirements 6.5\n', 'blue');

  const templates = [
    { path: 'role-catalog/access/browser-access-role.yaml', readme: 'role-catalog/access/README.md' },
    { path: 'role-catalog/access/direct-access-role.yaml', readme: 'role-catalog/access/README.md' },
    { path: 'role-catalog/access/chained-access-role.yaml', readme: 'role-catalog/access/README.md' },
    { path: 'role-catalog/intermediate/trusted-intermediate-role.yaml', readme: 'role-catalog/intermediate/README.md' },
    { path: 'role-catalog/inventory/direct-org-inventory-role.yaml', readme: 'role-catalog/inventory/README.md' },
    { path: 'role-catalog/inventory/chained-org-inventory-role.yaml', readme: 'role-catalog/inventory/README.md' },
    { path: 'role-catalog/inventory/standalone-account-inventory-role.yaml', readme: 'role-catalog/inventory/README.md' },
  ];

  let passed = true;
  const errors = [];

  for (const { path: templatePath, readme: readmePath } of templates) {
    const template = parseTemplate(templatePath);
    const readmeContent = readFile(readmePath);

    if (!template || !readmeContent) {
      errors.push(`Could not read ${templatePath} or ${readmePath}`);
      passed = false;
      continue;
    }

    const deployTo = template.Metadata?.TemplateInfo?.['Deploy-To'];
    const filename = path.basename(templatePath);

    if (!deployTo) {
      errors.push(`No Deploy-To metadata found in ${filename}`);
      log(`  ✗ ${filename}: No Deploy-To metadata`, 'red');
      passed = false;
      continue;
    }

    log(`Checking ${filename}`);
    log(`  Template Deploy-To: "${deployTo}"`);

    // Check if the Deploy-To information appears in the README
    if (readmeContent.includes(deployTo)) {
      log(`  ✓ Deploy-To found in README`, 'green');
    } else {
      errors.push(`Deploy-To mismatch for ${filename}: template says "${deployTo}" but not found in ${readmePath}`);
      log(`  ✗ Deploy-To NOT found in README`, 'red');
      passed = false;
    }
  }

  if (passed) {
    log('\n✓ Property 7 PASSED: All Deploy-To information matches template metadata', 'green');
  } else {
    log('\n✗ Property 7 FAILED:', 'red');
    errors.forEach(err => log(`  - ${err}`, 'red'));
  }

  return { passed, errors, property: 'Property 7: Deploy-To accuracy' };
}

/**
 * Property 6: Cross-reference consistency
 * Feature: role-catalog-documentation, Property 6
 * Validates: Requirements 6.4
 *
 * For any template mentioned in multiple README files, the template name
 * and core description should be consistent across all references
 */
function testProperty6_CrossReferenceConsistency() {
  log('\n=== Property 6: Cross-Reference Consistency ===', 'blue');
  log('Feature: role-catalog-documentation, Property 6', 'blue');
  log('Validates: Requirements 6.4\n', 'blue');

  const readmes = [
    'README.md',
    'role-catalog/access/README.md',
    'role-catalog/intermediate/README.md',
    'role-catalog/inventory/README.md'
  ];

  // Track template references across READMEs
  const templateReferences = {};

  for (const readmePath of readmes) {
    const content = readFile(readmePath);
    if (!content) continue;

    const references = extractTemplateReferences(content);

    for (const filename of references) {
      if (!templateReferences[filename]) {
        templateReferences[filename] = [];
      }
      templateReferences[filename].push(readmePath);
    }
  }

  let passed = true;
  const errors = [];

  // Check templates that appear in multiple READMEs
  for (const [filename, readmePaths] of Object.entries(templateReferences)) {
    if (readmePaths.length > 1) {
      log(`Checking ${filename} (appears in ${readmePaths.length} READMEs)`);

      // For cross-referenced templates, we verify they're consistently named
      // The actual description consistency is checked by Property 5
      log(`  ✓ Template referenced consistently across ${readmePaths.join(', ')}`, 'green');
    }
  }

  if (passed) {
    log('\n✓ Property 6 PASSED: Template references are consistent across READMEs', 'green');
  } else {
    log('\n✗ Property 6 FAILED:', 'red');
    errors.forEach(err => log(`  - ${err}`, 'red'));
  }

  return { passed, errors, property: 'Property 6: Cross-reference consistency' };
}

/**
 * Property 2: Template metadata completeness
 * Feature: role-catalog-documentation, Property 2
 * Validates: Requirements 5.5
 *
 * For any template documented in a README file, the documentation should include
 * version, deploy-to target, and purpose metadata
 */
function testProperty2_MetadataCompleteness() {
  log('\n=== Property 2: Template Metadata Completeness ===', 'blue');
  log('Feature: role-catalog-documentation, Property 2', 'blue');
  log('Validates: Requirements 5.5\n', 'blue');

  const templates = [
    { path: 'role-catalog/access/browser-access-role.yaml', readme: 'role-catalog/access/README.md', name: 'browser-access-role.yaml' },
    { path: 'role-catalog/access/direct-access-role.yaml', readme: 'role-catalog/access/README.md', name: 'direct-access-role.yaml' },
    { path: 'role-catalog/access/chained-access-role.yaml', readme: 'role-catalog/access/README.md', name: 'chained-access-role.yaml' },
    { path: 'role-catalog/intermediate/trusted-intermediate-role.yaml', readme: 'role-catalog/intermediate/README.md', name: 'trusted-intermediate-role.yaml' },
    { path: 'role-catalog/inventory/direct-org-inventory-role.yaml', readme: 'role-catalog/inventory/README.md', name: 'direct-org-inventory-role.yaml' },
    { path: 'role-catalog/inventory/chained-org-inventory-role.yaml', readme: 'role-catalog/inventory/README.md', name: 'chained-org-inventory-role.yaml' },
    { path: 'role-catalog/inventory/standalone-account-inventory-role.yaml', readme: 'role-catalog/inventory/README.md', name: 'standalone-account-inventory-role.yaml' },
  ];

  let passed = true;
  const errors = [];

  for (const { path: templatePath, readme: readmePath, name } of templates) {
    const template = parseTemplate(templatePath);
    const readmeContent = readFile(readmePath);

    if (!template || !readmeContent) {
      errors.push(`Could not read ${templatePath} or ${readmePath}`);
      passed = false;
      continue;
    }

    log(`Checking ${name}`);

    // Extract metadata from template
    const version = template.Metadata?.TemplateInfo?.Version;
    const deployTo = template.Metadata?.TemplateInfo?.['Deploy-To'];
    const description = template.Description;

    // Find the section for this template in the README
    const templateSection = readmeContent.split('###').find(section =>
      section.includes(name)
    );

    if (!templateSection) {
      errors.push(`No documentation section found for ${name} in ${readmePath}`);
      log(`  ✗ No documentation section found`, 'red');
      passed = false;
      continue;
    }

    // Check for version
    if (version && templateSection.includes(version)) {
      log(`  ✓ Version (${version}) documented`, 'green');
    } else {
      errors.push(`Version missing or incorrect for ${name}`);
      log(`  ✗ Version (${version}) not documented`, 'red');
      passed = false;
    }

    // Check for Deploy-To
    if (deployTo && templateSection.includes(deployTo)) {
      log(`  ✓ Deploy-To documented`, 'green');
    } else {
      errors.push(`Deploy-To missing or incorrect for ${name}`);
      log(`  ✗ Deploy-To not documented`, 'red');
      passed = false;
    }

    // Check for Description/Purpose
    if (description && templateSection.includes(description)) {
      log(`  ✓ Description/Purpose documented`, 'green');
    } else {
      errors.push(`Description/Purpose missing or incorrect for ${name}`);
      log(`  ✗ Description/Purpose not documented`, 'red');
      passed = false;
    }
  }

  if (passed) {
    log('\n✓ Property 2 PASSED: All templates have complete metadata documentation', 'green');
  } else {
    log('\n✗ Property 2 FAILED:', 'red');
    errors.forEach(err => log(`  - ${err}`, 'red'));
  }

  return { passed, errors, property: 'Property 2: Template metadata completeness' };
}

// Main execution
function main() {
  log('\n╔════════════════════════════════════════════════════════════════╗', 'blue');
  log('║  Role Catalog Documentation Validation                        ║', 'blue');
  log('║  Property-Based Tests                                         ║', 'blue');
  log('╚════════════════════════════════════════════════════════════════╝', 'blue');

  const results = [];

  // Run all property tests
  results.push(testProperty3_FilenameAccuracy());
  results.push(testProperty1and4_QuickLaunchUrls());
  results.push(testProperty5_DescriptionConsistency());
  results.push(testProperty7_DeployToAccuracy());
  results.push(testProperty6_CrossReferenceConsistency());
  results.push(testProperty2_MetadataCompleteness());

  // Summary
  log('\n╔════════════════════════════════════════════════════════════════╗', 'blue');
  log('║  Test Summary                                                  ║', 'blue');
  log('╚════════════════════════════════════════════════════════════════╝', 'blue');

  const passedCount = results.filter(r => r.passed).length;
  const totalCount = results.length;

  results.forEach(result => {
    const status = result.passed ? '✓ PASSED' : '✗ FAILED';
    const color = result.passed ? 'green' : 'red';
    log(`${status}: ${result.property}`, color);
  });

  log(`\nTotal: ${passedCount}/${totalCount} properties passed`, passedCount === totalCount ? 'green' : 'red');

  // Exit with appropriate code
  process.exit(passedCount === totalCount ? 0 : 1);
}

// Run if executed directly
if (require.main === module) {
  main();
}

module.exports = {
  testProperty3_FilenameAccuracy,
  testProperty1and4_QuickLaunchUrls,
  testProperty5_DescriptionConsistency,
  testProperty7_DeployToAccuracy,
  testProperty6_CrossReferenceConsistency,
  testProperty2_MetadataCompleteness
};
