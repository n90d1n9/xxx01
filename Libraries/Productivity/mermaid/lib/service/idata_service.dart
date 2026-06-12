import '../model/data_source.dart';

/// Advanced Database Service with multiple backends
abstract class IDataService {
  Future<void> initialize();
  Future<List<Map<String, dynamic>>> query(DataSource source, String query);
  Future<void> save<T>(String collection, T data);
  Future<T?> get<T>(String collection, String id);
  Future<List<T>> list<T>(String collection);
  Future<void> delete(String collection, String id);
  Stream<List<Map<String, dynamic>>> watch(DataSource source);
}
