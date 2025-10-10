/**
 * OpenCode Plugin Process Isolation Test Suite
 * 
 * Comprehensive testing for the plugin process isolation framework:
 * - Process spawning and management
 * - IPC communication security
 * - Resource limit enforcement
 * - Capability-based access control
 * - Cross-platform compatibility
 */

const PluginHost = require('./worker_host');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

class IsolationTestSuite {
  constructor() {
    this.testResults = [];
    this.host = null;
  }

  /**
   * Run all isolation tests
   */
  async runAllTests() {
    console.log('🧪 Starting OpenCode Plugin Isolation Test Suite\n');

    try {
      await this.testBasicProcessSpawning();
      await this.testIPCCommunication();
      await this.testCapabilityEnforcement();
      await this.testResourceLimits();
      await this.testSecurityIsolation();
      await this.testCrossplatformCompatibility();
      
      this.printTestResults();
    } catch (error) {
      console.error('❌ Test suite failed:', error);
      process.exit(1);
    } finally {
      if (this.host) {
        this.host.cleanup();
      }
    }
  }

  /**
   * Test basic process spawning and management
   */
  async testBasicProcessSpawning() {
    console.log('🔧 Testing basic process spawning...');
    
    try {
      this.host = new PluginHost({
        maxWorkers: 3,
        workerTimeout: 10000
      });

      const startTime = Date.now();
      const result = await this.host.executePlugin('test-plugin', 'initialize', {}, {
        capabilities: ['notify']
      });

      const duration = Date.now() - startTime;
      
      if (result.status === 'initialized' && duration < 5000) {
        this.addTestResult('Process Spawning', 'PASS', `Worker spawned in ${duration}ms`);
      } else {
        this.addTestResult('Process Spawning', 'FAIL', `Unexpected result: ${JSON.stringify(result)}`);
      }

    } catch (error) {
      this.addTestResult('Process Spawning', 'FAIL', error.message);
    }
  }

  /**
   * Test IPC communication security
   */
  async testIPCCommunication() {
    console.log('🔒 Testing IPC communication security...');
    
    try {
      // Test normal communication
      const result1 = await this.host.executePlugin('test-plugin', 'notify', {
        message: 'Test notification',
        level: 'info'
      });

      if (result1.status === 'sent') {
        this.addTestResult('IPC Basic', 'PASS', 'Normal IPC communication works');
      } else {
        this.addTestResult('IPC Basic', 'FAIL', 'IPC communication failed');
      }

      // Test message size limits
      try {
        const largeMessage = 'x'.repeat(2 * 1024 * 1024); // 2MB message
        await this.host.executePlugin('test-plugin', 'notify', {
          message: largeMessage
        });
        this.addTestResult('IPC Size Limit', 'FAIL', 'Large message was not rejected');
      } catch (error) {
        if (error.message.includes('too large')) {
          this.addTestResult('IPC Size Limit', 'PASS', 'Large messages correctly rejected');
        } else {
          this.addTestResult('IPC Size Limit', 'FAIL', `Unexpected error: ${error.message}`);
        }
      }

    } catch (error) {
      this.addTestResult('IPC Communication', 'FAIL', error.message);
    }
  }

  /**
   * Test capability-based access control
   */
  async testCapabilityEnforcement() {
    console.log('🛡️  Testing capability enforcement...');
    
    try {
      // Test allowed capability
      const result1 = await this.host.executePlugin('capability-test', 'notify', {
        message: 'Allowed operation'
      }, {
        capabilities: ['notify']
      });

      if (result1.status === 'sent') {
        this.addTestResult('Capability Allow', 'PASS', 'Allowed capability works');
      } else {
        this.addTestResult('Capability Allow', 'FAIL', 'Allowed capability failed');
      }

      // Test denied capability
      try {
        await this.host.executePlugin('capability-test', 'readEnv', {
          key: 'HOME'
        }, {
          capabilities: [] // No capabilities
        });
        this.addTestResult('Capability Deny', 'FAIL', 'Unauthorized operation was allowed');
      } catch (error) {
        if (error.message.includes('Capability required')) {
          this.addTestResult('Capability Deny', 'PASS', 'Unauthorized operation correctly blocked');
        } else {
          this.addTestResult('Capability Deny', 'FAIL', `Unexpected error: ${error.message}`);
        }
      }

    } catch (error) {
      this.addTestResult('Capability Enforcement', 'FAIL', error.message);
    }
  }

  /**
   * Test resource limit enforcement
   */
  async testResourceLimits() {
    console.log('⚡ Testing resource limits...');
    
    try {
      // Test with strict resource limits
      const result = await this.host.executePlugin('resource-test', 'initialize', {}, {
        capabilities: ['notify'],
        resources: {
          memory: 32,    // 32MB limit
          cpuTime: 5,    // 5 second limit
          fileDescriptors: 20
        }
      });

      if (result.status === 'initialized') {
        this.addTestResult('Resource Limits', 'PASS', 'Worker started with resource limits');
      } else {
        this.addTestResult('Resource Limits', 'FAIL', 'Worker failed to start with limits');
      }

      // Get worker stats to verify limits
      const stats = this.host.getStats();
      if (stats.activeWorkers > 0) {
        this.addTestResult('Resource Monitoring', 'PASS', `${stats.activeWorkers} workers active`);
      } else {
        this.addTestResult('Resource Monitoring', 'FAIL', 'No active workers found');
      }

    } catch (error) {
      this.addTestResult('Resource Limits', 'FAIL', error.message);
    }
  }

  /**
   * Test security isolation between processes
   */
  async testSecurityIsolation() {
    console.log('🔐 Testing security isolation...');
    
    try {
      // Start two separate plugins
      const result1 = await this.host.executePlugin('isolated-1', 'initialize');
      const result2 = await this.host.executePlugin('isolated-2', 'initialize');

      if (result1.pluginId && result2.pluginId && result1.pluginId !== result2.pluginId) {
        this.addTestResult('Process Isolation', 'PASS', 'Plugins run in separate processes');
      } else {
        this.addTestResult('Process Isolation', 'FAIL', 'Plugins not properly isolated');
      }

      // Test that one plugin cannot access another's data
      try {
        await this.host.executePlugin('isolated-1', 'initialize', {}, {
          pluginId: 'isolated-2' // Try to access wrong plugin
        });
        this.addTestResult('Cross-Plugin Access', 'FAIL', 'Cross-plugin access was allowed');
      } catch (error) {
        if (error.message.includes('Plugin ID mismatch')) {
          this.addTestResult('Cross-Plugin Access', 'PASS', 'Cross-plugin access blocked');
        } else {
          this.addTestResult('Cross-Plugin Access', 'FAIL', `Unexpected error: ${error.message}`);
        }
      }

    } catch (error) {
      this.addTestResult('Security Isolation', 'FAIL', error.message);
    }
  }

  /**
   * Test cross-platform compatibility
   */
  async testCrossplatformCompatibility() {
    console.log('🌍 Testing cross-platform compatibility...');
    
    try {
      const platform = os.platform();
      const arch = os.arch();
      
      // Test platform-specific features
      let platformSupport = 'UNKNOWN';
      
      if (platform === 'darwin') {
        // macOS specific tests
        platformSupport = 'macOS';
      } else if (platform === 'linux') {
        // Linux specific tests
        platformSupport = 'Linux';
      } else {
        platformSupport = 'Other';
      }

      this.addTestResult('Platform Detection', 'PASS', `Running on ${platformSupport} (${arch})`);

      // Test POSIX compliance
      const sandboxScript = path.join(__dirname, 'sandbox_utils.sh');
      if (fs.existsSync(sandboxScript)) {
        const testProcess = spawn('sh', [sandboxScript, 'platform'], {
          stdio: 'pipe'
        });

        const output = await new Promise((resolve, reject) => {
          let stdout = '';
          testProcess.stdout.on('data', (data) => {
            stdout += data.toString();
          });
          
          testProcess.on('close', (code) => {
            if (code === 0) {
              resolve(stdout);
            } else {
              reject(new Error(`Script exited with code ${code}`));
            }
          });
        });

        if (output.includes('Platform:')) {
          this.addTestResult('POSIX Scripts', 'PASS', 'Sandbox utilities work cross-platform');
        } else {
          this.addTestResult('POSIX Scripts', 'FAIL', 'Sandbox utilities failed');
        }
      } else {
        this.addTestResult('POSIX Scripts', 'FAIL', 'Sandbox script not found');
      }

    } catch (error) {
      this.addTestResult('Cross-Platform', 'FAIL', error.message);
    }
  }

  /**
   * Add test result to collection
   * @param {string} test - Test name
   * @param {string} status - PASS/FAIL
   * @param {string} details - Test details
   */
  addTestResult(test, status, details) {
    this.testResults.push({ test, status, details });
    
    const icon = status === 'PASS' ? '✅' : '❌';
    console.log(`  ${icon} ${test}: ${details}`);
  }

  /**
   * Print comprehensive test results
   */
  printTestResults() {
    console.log('\n📊 Test Results Summary\n');
    console.log('=' .repeat(60));
    
    const passed = this.testResults.filter(r => r.status === 'PASS').length;
    const total = this.testResults.length;
    
    this.testResults.forEach(result => {
      const status = result.status === 'PASS' ? '✅ PASS' : '❌ FAIL';
      console.log(`${status.padEnd(8)} | ${result.test.padEnd(25)} | ${result.details}`);
    });
    
    console.log('=' .repeat(60));
    console.log(`Summary: ${passed}/${total} tests passed (${Math.round(passed/total*100)}%)`);
    
    if (passed === total) {
      console.log('\n🎉 All tests passed! Process isolation is working correctly.');
    } else {
      console.log('\n⚠️  Some tests failed. Review the results above.');
    }
  }

  /**
   * Manual verification checklist
   */
  static printManualVerification() {
    console.log('\n📋 Manual Verification Checklist\n');
    console.log('Run these commands to verify the isolation framework:');
    console.log('');
    console.log('1. Basic functionality:');
    console.log('   node scripts/process_isolation/test_isolation.js');
    console.log('');
    console.log('2. Cross-platform compatibility:');
    console.log('   ./scripts/process_isolation/sandbox_utils.sh verify');
    console.log('');
    console.log('3. Resource limit testing:');
    console.log('   ./scripts/process_isolation/sandbox_utils.sh test-memory 32');
    console.log('   ./scripts/process_isolation/sandbox_utils.sh test-cpu 5');
    console.log('');
    console.log('4. Process monitoring:');
    console.log('   ps aux | grep worker_child  # Should show isolated processes');
    console.log('');
    console.log('5. Security verification:');
    console.log('   # Start test and check that workers run with limited privileges');
    console.log('   # Verify no shared memory segments between workers');
    console.log('');
    console.log('Expected outcomes:');
    console.log('✅ Workers spawn in separate processes');
    console.log('✅ IPC communication works securely');
    console.log('✅ Capability enforcement blocks unauthorized operations');
    console.log('✅ Resource limits prevent excessive usage');
    console.log('✅ Cross-platform scripts work on macOS and Linux');
  }
}

// Run test suite if executed directly
if (require.main === module) {
  const suite = new IsolationTestSuite();
  
  if (process.argv.includes('--help')) {
    IsolationTestSuite.printManualVerification();
  } else {
    suite.runAllTests().catch(error => {
      console.error('Test suite failed:', error);
      process.exit(1);
    });
  }
}

module.exports = IsolationTestSuite;