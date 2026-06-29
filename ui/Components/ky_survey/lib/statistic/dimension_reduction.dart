import 'package:ml_algo/ml_algo.dart';

class DimensionReduction {
  /// Performs Principal Component Analysis
  Future<PCAResult> performPCA(
    List<List<double>> data,
    {int? components}
  ) async {
    final pca = PCA(n: components);
    final transformed = await pca.fit(data);
    
    return PCAResult(
      transformedData: transformed,
      explainedVariance: pca.explainedVarianceRatio,
      components: pca.components,
    );
  }

  /// Performs t-SNE dimensionality reduction
  Future<TSNEResult> performTSNE(
    List<List<double>> data,
    {
      int dimensions = 2,
      double perplexity = 30.0,
      int iterations = 1000,
    }
  ) async {
    final tsne = TSNE(
      dimensions: dimensions,
      perplexity: perplexity,
      maxIterations: iterations,
    );
    
    final transformed = await tsne.fit(data);
    
    return TSNEResult(
      transformedData: transformed,
      kldDivergence: tsne.kldDivergence,
    );
  }
}
