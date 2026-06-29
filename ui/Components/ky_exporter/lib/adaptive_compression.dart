class AdaptiveCompression {
  /// Compresses data with adaptive algorithm selection
  Future<CompressedData> compress({
    required List<int> data,
    CompressionConfig? config,
  }) async {
    final analyzer = DataAnalyzer();
    final dataCharacteristics = await analyzer.analyzeData(data);
    
    final algorithm = await _selectOptimalAlgorithm(
      characteristics: dataCharacteristics,
      config: config,
    );
    
    final compressed = await algorithm.compress(data);
    
    return CompressedData(
      data: compressed,
      algorithm: algorithm.identifier,
      metadata: await _generateCompressionMetadata(
        original: data,
        compressed: compressed,
        characteristics: dataCharacteristics,
      ),
    );
  }
}
