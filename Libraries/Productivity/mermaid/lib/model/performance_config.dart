class PerformanceConfig {
  final bool enableVirtualScrolling;
  final bool enableLazyLoading;
  final bool enableDataCompression;
  final bool enableIndexing;
  final int batchSize;
  final int maxCachedRows;
  final bool useWebWorkers;
  final bool enableProgressiveRendering;

  const PerformanceConfig({
    this.enableVirtualScrolling = true,
    this.enableLazyLoading = true,
    this.enableDataCompression = false,
    this.enableIndexing = true,
    this.batchSize = 100,
    this.maxCachedRows = 1000,
    this.useWebWorkers = false,
    this.enableProgressiveRendering = true,
  });
}
