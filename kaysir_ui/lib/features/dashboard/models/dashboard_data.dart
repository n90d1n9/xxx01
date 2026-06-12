class DashboardData {
  final int photos;
  final String photosChange;
  final int video;
  final String videoChange;
  final int event;
  final String eventChange;
  final double growth;
  final String growthChange;
  final List<SalesDataPoint> salesData;
  final AcquisitionData acquisitionData;
  final List<Product> topProducts;
  final List<CustomerDataPoint> customerData;

  DashboardData({
    required this.photos,
    required this.photosChange,
    required this.video,
    required this.videoChange,
    required this.event,
    required this.eventChange,
    required this.growth,
    required this.growthChange,
    required this.salesData,
    required this.acquisitionData,
    required this.topProducts,
    required this.customerData,
  });
}

class SalesDataPoint {
  final DateTime date;
  final int currentWeekSales;
  final int previousWeekSales;

  SalesDataPoint({
    required this.date,
    required this.currentWeekSales,
    required this.previousWeekSales,
  });
}

class AcquisitionData {
  final int reviews;
  final int education;
  final int deals;

  AcquisitionData({
    required this.reviews,
    required this.education,
    required this.deals,
  });
}

class Product {
  final String name;
  final DateTime date;
  final double price;
  final int quantity;
  final String code;

  Product({
    required this.name,
    required this.date,
    required this.price,
    required this.quantity,
    required this.code,
  });
}

class CustomerDataPoint {
  final String month;
  final int value;

  CustomerDataPoint({
    required this.month,
    required this.value,
  });
}
