# Domain Expertise Protocol

**LOAD TRIGGER**: Database, frontend, network, legacy, or troubleshooting tasks requiring specialist agent.

## Specialist Agent Capabilities

### Database Expertise
- **SQL Optimization**: Query performance, indexing strategies, schema design
- **NoSQL Systems**: MongoDB, Redis, DynamoDB, Cassandra
- **Database Security**: Access controls, encryption, audit logging
- **Migration Strategies**: Version control, rollback procedures, data integrity

### Frontend Development
- **Modern Frameworks**: React, Vue, Angular, Svelte, solid performance patterns
- **UI/UX Best Practices**: Accessibility, responsive design, component architecture
- **Build Tools**: Webpack, Vite, Rollup, optimization techniques
- **Testing Strategies**: Unit, integration, E2E testing for frontend applications

### Network Infrastructure
- **Network Security**: Firewalls, VPNs, intrusion detection, traffic analysis
- **Load Balancing**: Traffic distribution, failover strategies, health checks
- **CDN Configuration**: Content delivery optimization, caching strategies
- **API Gateway**: Rate limiting, authentication, request routing

### Legacy System Modernization
- **Assessment Strategies**: Technical debt analysis, risk evaluation, migration planning
- **Incremental Migration**: Strangler fig pattern, parallel run strategies
- **Data Migration**: ETL processes, data validation, integrity checks
- **Integration Patterns**: API bridges, message queues, event-driven architecture

### Performance Troubleshooting
- **System Monitoring**: Metrics collection, alerting, performance baselines
- **Bottleneck Identification**: CPU, memory, I/O, network analysis
- **Optimization Techniques**: Caching, indexing, query optimization
- **Capacity Planning**: Resource forecasting, scaling strategies

## Domain-Specific Problem Solving

### Database Issues
```javascript
function diagnoseDatabaseIssue(symptoms) {
  const diagnostics = {
    performance: analyzeQueryPerformance(symptoms),
    connectivity: checkConnectionHealth(symptoms),
    integrity: validateDataIntegrity(symptoms),
    security: assessSecurityPosture(symptoms)
  };
  
  const recommendations = generateDatabaseRecommendations(diagnostics);
  
  return {
    rootCause: identifyRootCause(diagnostics),
    immediateActions: getImmediateActions(diagnostics),
    longTermSolutions: getLongTermSolutions(recommendations),
    preventionStrategies: getPreventionStrategies(diagnostics)
  };
}
```

### Frontend Performance Issues
```javascript
function diagnoseFrontendPerformance(metrics) {
  const analysis = {
    renderingPerformance: analyzeRenderingMetrics(metrics),
    bundleSize: analyzeBundleOptimization(metrics),
    networkRequests: analyzeNetworkEfficiency(metrics),
    userExperience: assessUserExperienceMetrics(metrics)
  };
  
  return {
    criticalIssues: identifyPerformanceCriticalIssues(analysis),
    optimizationOpportunities: findOptimizationOpportunities(analysis),
    implementationPlan: createOptimizationPlan(analysis),
    measurableTargets: definePerformanceTargets(analysis)
  };
}
```

### Network Troubleshooting
```javascript
function diagnoseNetworkIssue(networkData) {
  const diagnostics = {
    connectivity: testConnectivityPaths(networkData),
    latency: analyzeLatencyPatterns(networkData),
    throughput: measureThroughputBottlenecks(networkData),
    security: assessNetworkSecurity(networkData)
  };
  
  return {
    networkHealth: assessOverallNetworkHealth(diagnostics),
    issueLocalization: localizeNetworkIssues(diagnostics),
    resolutionSteps: generateResolutionSteps(diagnostics),
    monitoringRecommendations: getMonitoringRecommendations(diagnostics)
  };
}
```

### Legacy System Analysis
```javascript
function analyzeLegacySystem(systemProfile) {
  const assessment = {
    technicalDebt: calculateTechnicalDebt(systemProfile),
    modernizationOpportunities: identifyModernizationOpportunities(systemProfile),
    riskFactors: assessModernizationRisks(systemProfile),
    businessImpact: evaluateBusinessImpact(systemProfile)
  };
  
  return {
    modernizationStrategy: createModernizationStrategy(assessment),
    phaseApproach: definePhaseApproach(assessment),
    resourceRequirements: estimateResourceRequirements(assessment),
    successMetrics: defineSuccessMetrics(assessment)
  };
}
```

## Multi-Domain Integration Patterns

### Cross-Domain Problem Resolution
```javascript
function resolveCrossDomainIssue(issue) {
  const domains = identifyAffectedDomains(issue);
  const domainExperts = assignDomainExperts(domains);
  
  const collaborativeDiagnosis = {
    individualAnalyses: gatherDomainAnalyses(domainExperts, issue),
    integrationPoints: identifyIntegrationPoints(domains),
    systemicIssues: findSystemicIssues(individualAnalyses),
    holisticSolution: designHolisticSolution(individualAnalyses, integrationPoints)
  };
  
  return {
    coordinatedResponse: coordinateResponseAcrossDomains(collaborativeDiagnosis),
    implementationSequence: defineImplementationSequence(collaborativeDiagnosis),
    validationStrategy: createValidationStrategy(collaborativeDiagnosis),
    knowledgeTransfer: planKnowledgeTransfer(domainExperts)
  };
}
```

### Domain Knowledge Synthesis
```javascript
function synthesizeDomainKnowledge(knowledgeSources) {
  const synthesis = {
    commonPatterns: identifyCommonPatterns(knowledgeSources),
    bestPractices: extractBestPractices(knowledgeSources),
    antiPatterns: identifyAntiPatterns(knowledgeSources),
    emergingTrends: trackEmergingTrends(knowledgeSources)
  };
  
  return {
    unifiedApproach: createUnifiedApproach(synthesis),
    decisionFramework: buildDecisionFramework(synthesis),
    implementationGuidelines: developImplementationGuidelines(synthesis),
    continuousLearning: establishLearningFramework(synthesis)
  };
}
```

## Domain-Specific Quality Assurance

### Database Quality Gates
- **Schema Validation**: Constraint verification, referential integrity
- **Performance Benchmarking**: Query execution plans, index effectiveness
- **Security Compliance**: Access controls, encryption at rest/transit
- **Backup Verification**: Recovery testing, data consistency checks

### Frontend Quality Gates
- **Accessibility Compliance**: WCAG guidelines, screen reader compatibility
- **Performance Budgets**: Bundle size limits, rendering metrics
- **Cross-Browser Testing**: Compatibility across target browsers
- **Security Scanning**: XSS prevention, content security policy

### Network Quality Gates
- **Security Posture**: Vulnerability scanning, penetration testing
- **Performance Monitoring**: Latency thresholds, throughput targets
- **Redundancy Testing**: Failover procedures, disaster recovery
- **Compliance Verification**: Regulatory requirements, audit trails

### Legacy System Quality Gates
- **Regression Testing**: Functionality preservation during modernization
- **Data Integrity**: Migration accuracy, business rule preservation
- **Performance Parity**: Ensuring modernized system meets performance targets
- **User Acceptance**: Stakeholder validation, training effectiveness

## Continuous Domain Expertise Enhancement

### Knowledge Base Maintenance
```javascript
function maintainDomainKnowledgeBase() {
  const updates = {
    technologyTrends: trackTechnologyEvolution(),
    bestPracticeEvolution: monitorBestPracticeChanges(),
    toolingAdvancements: assessNewToolingOptions(),
    securityUpdates: incorporateSecurityUpdates()
  };
  
  return {
    knowledgeBaseUpdates: applyKnowledgeBaseUpdates(updates),
    expertiseGapAnalysis: identifyExpertiseGaps(updates),
    trainingRecommendations: generateTrainingRecommendations(updates),
    specialistDevelopment: planSpecialistDevelopment(updates)
  };
}
```

### Domain Expertise Metrics
```javascript
function measureDomainExpertise() {
  return {
    problemResolutionRate: calculateResolutionSuccessRate(),
    timeToResolution: measureAverageResolutionTime(),
    stakeholderSatisfaction: assessStakeholderSatisfaction(),
    knowledgeTransferEffectiveness: measureKnowledgeTransfer(),
    continuousImprovementMetrics: trackContinuousImprovement()
  };
}
```

## Expected Domain Expertise Benefits
- **Problem Resolution Quality**: 90%+ successful resolution for domain-specific issues
- **Cross-Domain Integration**: 85%+ successful multi-domain problem resolution
- **Knowledge Application**: 95% adherence to domain best practices
- **Stakeholder Satisfaction**: 90%+ satisfaction with specialist recommendations

This protocol provides comprehensive domain expertise for database, frontend, network, legacy, and troubleshooting challenges with integrated quality assurance and continuous improvement.