class LocalDBConfig {
  final String storeName;
  final String dbName;

  const LocalDBConfig({this.storeName = 'mystore', this.dbName = 'my.db'});

  LocalDBConfig copyWith({String? storeName, String? dbName}) {
    return LocalDBConfig(
      storeName: storeName ?? this.storeName,
      dbName: dbName ?? this.dbName,
    );
  }

  Map<String, dynamic> toMap() {
    return {'storeName': storeName, 'dbName': dbName};
  }

  factory LocalDBConfig.fromMap(Map<String, dynamic> map) {
    return LocalDBConfig(
      storeName: map['storeName'] ?? 'mystore',
      dbName: map['dbName'] ?? 'my.db',
    );
  }
}
