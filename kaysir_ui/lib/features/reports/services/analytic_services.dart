class AnalyticsService {
  Future<SalesReport> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    String? cashierId,
  }) async {
    final transactions = await TransactionService().getTransactions(
      startDate: startDate,
      endDate: endDate,
      cashierId: cashierId,
    );

    return SalesReport(
      totalSales: _calculateTotalSales(transactions),
      itemsSold: _calculateItemsSold(transactions),
      averageTransactionValue: _calculateAverageTransactionValue(transactions),
      peakHours: _analyzePeakHours(transactions),
      paymentMethodBreakdown: _analyzePaymentMethods(transactions),
    );
  }

   Future<Map<String, dynamic>> calculateMetrics(List<Product> products) async {
    final totalProducts = products.length;
    final checkedProducts = products.where((p) => p.lastChecked != null).length;
    final totalValue = products.fold(0.0, 
      (sum, p) => sum + (p.actualStock * p.unitPrice));
    
    final discrepancies = products.where((p) => 
      p.actualStock != p.systemStock).length;
    
    final lowStock = products.where((p) => 
      p.actualStock < p.minimumStock).length;
    
    final categories = groupBy(products, (Product p) => p.category);
    
    return {
      'totalProducts': totalProducts,
      'checkedProducts': checkedProducts,
      'completionRate': totalProducts > 0 
        ? (checkedProducts / totalProducts * 100).toStringAsFixed(1)
        : '0',
      'totalValue': totalValue,
      'discrepancies': discrepancies,
      'lowStock': lowStock,
      'categoryBreakdown': categories.map((key, value) => 
        MapEntry(key ?? 'Uncategorized', value.length)),
    };
  }

}
