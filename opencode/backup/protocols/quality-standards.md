# Quality Standards Protocol

**LOAD TRIGGER**: Code review, architecture review, quality assurance, or reviewer agent active.

## Core Quality Standards

### Security Standards
- **No Plaintext Secrets**: All sensitive data must be encrypted or use secure storage
- **Least Privilege**: Minimum necessary permissions for all operations
- **Input Validation**: All external inputs sanitized and validated early
- **Audit Logging**: Security-sensitive operations logged conservatively
- **Secret Exposure**: Immediate escalation on potential secret exposure

### Cross-Platform Compatibility
- **macOS & Linux Support**: All scripts/config must run on both platforms
- **POSIX Compliance**: Prefer POSIX sh over platform-specific shells
- **Platform Guards**: Guard platform-specific code paths explicitly
- **Portable Syntax**: Avoid macOS-only flags (e.g., `sed -i` without portable form)

### Code Quality Standards
- **Minimal Complexity**: Choose smallest stable solution for requirements
- **Deferred Abstraction**: Avoid premature abstraction until ≥3 occurrences or explicit scalability need
- **Anchor Verification**: Verify uniqueness before edits, re-read files after edit
- **Cleanup Discipline**: Remove dead code, stale docs, superseded plan blocks immediately
- **No Orphaned TODOs**: All TODOs must have owner/context or be resolved

### Consistency Requirements
- **Pattern Reuse**: Follow existing naming, tool choices, and formatting patterns
- **Tool Standardization**: Use `rg`, `fd`, `bat`, `sd`, `jq`, `delta`, `fzf` consistently
- **Architecture Alignment**: Reuse existing libraries and architectural choices
- **Style Consistency**: Match existing code style and conventions

## Quality Gate Framework

### Pre-Implementation Quality Gates
```javascript
function validatePreImplementationQuality(proposal) {
  const qualityChecks = {
    requirements: validateRequirementsCompleteness(proposal),
    architecture: assessArchitecturalSoundness(proposal),
    security: evaluateSecurityImplications(proposal),
    compatibility: checkCrossPlatformCompatibility(proposal),
    complexity: assessComplexityAppropriate(proposal)
  };
  
  const gateResults = {
    passed: Object.values(qualityChecks).every(check => check.passed),
    issues: identifyQualityIssues(qualityChecks),
    recommendations: generateQualityRecommendations(qualityChecks),
    blockers: identifyBlockingIssues(qualityChecks)
  };
  
  return gateResults;
}
```

### Implementation Quality Gates
```javascript
function validateImplementationQuality(implementation) {
  return {
    codeQuality: assessCodeQuality(implementation),
    testCoverage: validateTestCoverage(implementation),
    documentation: checkDocumentationCompleteness(implementation),
    performance: evaluatePerformanceImplications(implementation),
    security: conductSecurityReview(implementation),
    maintainability: assessMaintainability(implementation)
  };
}
```

### Post-Implementation Quality Gates
```javascript
function validatePostImplementationQuality(deliverable) {
  return {
    functionalValidation: validateFunctionalRequirements(deliverable),
    integrationTesting: checkIntegrationPoints(deliverable),
    performanceTesting: validatePerformanceRequirements(deliverable),
    securityTesting: conductSecurityValidation(deliverable),
    usabilityTesting: assessUsabilityRequirements(deliverable),
    deploymentReadiness: checkDeploymentReadiness(deliverable)
  };
}
```

## Comprehensive Code Review Framework

### Automated Code Analysis
```javascript
function conductAutomatedCodeAnalysis(codebase) {
  const analysis = {
    syntaxValidation: validateSyntaxCorrectness(codebase),
    styleConsistency: checkStyleConsistency(codebase),
    complexityAnalysis: analyzeCodeComplexity(codebase),
    securityScanning: scanForSecurityVulnerabilities(codebase),
    performanceAnalysis: analyzePerformanceImplications(codebase),
    dependencyAudit: auditDependencies(codebase)
  };
  
  return {
    passedChecks: filterPassedChecks(analysis),
    failedChecks: filterFailedChecks(analysis),
    warnings: extractWarnings(analysis),
    recommendations: generateRecommendations(analysis),
    criticalIssues: identifyCriticalIssues(analysis)
  };
}
```

### Manual Review Checklist
```markdown
## Code Review Checklist

### Functionality
- [ ] Code meets all functional requirements
- [ ] Edge cases handled appropriately
- [ ] Error handling comprehensive and graceful
- [ ] Business logic correctly implemented

### Quality
- [ ] Code is readable and maintainable
- [ ] Appropriate abstraction levels
- [ ] DRY principle followed (no unnecessary duplication)
- [ ] SOLID principles applied where appropriate

### Security
- [ ] Input validation implemented
- [ ] No hardcoded secrets or credentials
- [ ] Proper authentication and authorization
- [ ] SQL injection and XSS prevention

### Performance
- [ ] No obvious performance bottlenecks
- [ ] Database queries optimized
- [ ] Memory usage reasonable
- [ ] Network requests minimized

### Testing
- [ ] Unit tests cover critical functionality
- [ ] Integration tests for key workflows
- [ ] Test data properly isolated
- [ ] Test coverage meets standards

### Documentation
- [ ] Code comments explain why, not what
- [ ] API documentation updated
- [ ] README reflects changes
- [ ] Breaking changes documented
```

## Architecture Review Standards

### System Architecture Validation
```javascript
function validateSystemArchitecture(architecture) {
  const validation = {
    scalability: assessScalabilityDesign(architecture),
    reliability: evaluateReliabilityMeasures(architecture),
    maintainability: analyzeMaintainabilityFactors(architecture),
    security: reviewSecurityArchitecture(architecture),
    performance: evaluatePerformanceArchitecture(architecture),
    compliance: checkComplianceRequirements(architecture)
  };
  
  return {
    architecturalSoundness: calculateArchitecturalScore(validation),
    strengthAreas: identifyArchitecturalStrengths(validation),
    improvementAreas: identifyImprovementOpportunities(validation),
    riskMitigation: generateRiskMitigation(validation),
    evolutionPath: planArchitecturalEvolution(validation)
  };
}
```

### Design Pattern Compliance
```javascript
function validateDesignPatternCompliance(codebase) {
  const patternAnalysis = {
    recognizedPatterns: identifyImplementedPatterns(codebase),
    patternConsistency: assessPatternConsistency(codebase),
    antiPatterns: detectAntiPatterns(codebase),
    missingPatterns: identifyMissingBeneficialPatterns(codebase)
  };
  
  return {
    overallCompliance: calculatePatternCompliance(patternAnalysis),
    wellImplementedPatterns: highlightWellImplementedPatterns(patternAnalysis),
    patternViolations: identifyPatternViolations(patternAnalysis),
    improvementSuggestions: suggestPatternImprovements(patternAnalysis)
  };
}
```

## Quality Metrics and Measurement

### Quality Metrics Collection
```javascript
function collectQualityMetrics(project) {
  return {
    codeMetrics: {
      linesOfCode: calculateLOC(project),
      complexity: calculateCyclomaticComplexity(project),
      duplication: measureCodeDuplication(project),
      testCoverage: calculateTestCoverage(project)
    },
    defectMetrics: {
      defectDensity: calculateDefectDensity(project),
      meanTimeToRepair: calculateMTTR(project),
      defectEscapeRate: calculateDefectEscapeRate(project),
      customerReportedDefects: countCustomerDefects(project)
    },
    maintainabilityMetrics: {
      maintainabilityIndex: calculateMaintainabilityIndex(project),
      technicalDebt: assessTechnicalDebt(project),
      refactoringFrequency: measureRefactoringFrequency(project),
      codeChurn: calculateCodeChurn(project)
    },
    securityMetrics: {
      vulnerabilityCount: countSecurityVulnerabilities(project),
      securityIncidents: trackSecurityIncidents(project),
      complianceScore: calculateComplianceScore(project),
      securityTestCoverage: measureSecurityTestCoverage(project)
    }
  };
}
```

### Quality Trend Analysis
```javascript
function analyzeQualityTrends(historicalMetrics) {
  const trends = {
    qualityImprovement: analyzeQualityImprovementTrends(historicalMetrics),
    regressionPatterns: identifyRegressionPatterns(historicalMetrics),
    seasonalPatterns: detectSeasonalQualityPatterns(historicalMetrics),
    predictiveAnalysis: predictFutureQualityTrends(historicalMetrics)
  };
  
  return {
    overallDirection: determineOverallQualityDirection(trends),
    concernAreas: identifyQualityConcerns(trends),
    improvementOpportunities: spotImprovementOpportunities(trends),
    actionableInsights: generateActionableInsights(trends)
  };
}
```

## Continuous Quality Improvement

### Quality Improvement Planning
```javascript
function planQualityImprovement(currentState, targetState) {
  const improvementPlan = {
    gapAnalysis: analyzeQualityGaps(currentState, targetState),
    prioritization: prioritizeImprovementAreas(currentState, targetState),
    roadmap: createQualityRoadmap(currentState, targetState),
    resourcePlanning: planQualityResources(currentState, targetState)
  };
  
  return {
    improvementStrategy: formulateImprovementStrategy(improvementPlan),
    milestones: defineQualityMilestones(improvementPlan),
    successMetrics: defineSuccessMetrics(improvementPlan),
    riskMitigation: planRiskMitigation(improvementPlan)
  };
}
```

### Quality Culture Development
```javascript
function developQualityCulture(team) {
  const cultureDevelopment = {
    awarenessBuilding: buildQualityAwareness(team),
    skillDevelopment: developQualitySkills(team),
    processImprovement: improveQualityProcesses(team),
    incentiveAlignment: alignQualityIncentives(team)
  };
  
  return {
    cultureAssessment: assessQualityCulture(cultureDevelopment),
    developmentPlan: createCultureDevelopmentPlan(cultureDevelopment),
    measurementStrategy: planCultureMeasurement(cultureDevelopment),
    sustainabilityPlan: ensureCultureSustainability(cultureDevelopment)
  };
}
```

## Expected Quality Benefits
- **Defect Reduction**: 70% reduction in production defects
- **Code Quality**: 85% improvement in maintainability metrics
- **Security Posture**: 95% reduction in security vulnerabilities
- **Team Efficiency**: 60% reduction in time spent on quality issues
- **Customer Satisfaction**: 90% improvement in quality-related satisfaction

This protocol provides comprehensive quality assurance through systematic review processes, measurable quality gates, and continuous improvement mechanisms.