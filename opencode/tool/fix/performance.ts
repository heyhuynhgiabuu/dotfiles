// Performance monitoring class
export class PerformanceMonitor {
  private startTime: number = 0;
  private fileCount: number = 0;
  private changeCount: number = 0;

  start() {
    this.startTime = Date.now();
  }

  recordFile() {
    this.fileCount++;

    // Check limits
    if (this.fileCount > 100) {
      throw new Error("File limit exceeded (max 100 files)");
    }

    if (Date.now() - this.startTime > 30000) {
      throw new Error("Timeout exceeded (max 30 seconds)");
    }
  }

  recordChange() {
    this.changeCount++;

    if (this.changeCount > 1000) {
      throw new Error("Change limit exceeded (max 1000 changes)");
    }
  }

  getMetrics() {
    return {
      duration: Date.now() - this.startTime,
      filesProcessed: this.fileCount,
      changesApplied: this.changeCount,
    };
  }
}
