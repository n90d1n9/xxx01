class SurveyMLAnalysis {
  Future<Map<String, dynamic>> performClusterAnalysis(
    List<Map<String, dynamic>> responses,
    ClusteringConfig config,
  ) async {
    final preprocessor = DataPreprocessor();
    final normalized = await preprocessor.normalize(responses);
    
    final clusterer = KMeansClusterer(
      k: config.numberOfClusters,
      maxIterations: config.maxIterations,
      convergenceThreshold: config.convergenceThreshold,
    );
    
    final clusters = await clusterer.fit(normalized);
    return await generateClusteringReport(clusters);
  }

  Future<PredictiveModel> trainResponsePredictor(
    List<Map<String, dynamic>> trainingData,
    String targetVariable,
  ) async {
    final modelBuilder = RandomForestBuilder(
      numberOfTrees: 100,
      maxDepth: 10,
      minSamplesPerLeaf: 5,
    );
    
    return await modelBuilder.train(trainingData, targetVariable);
  }
}
