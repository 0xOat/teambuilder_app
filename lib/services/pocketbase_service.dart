import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();

  late PocketBase _pb;
  
  static const String baseUrl = 'http://127.0.0.1:8090';

  PocketBase get pb => _pb;

  void initialize() {
    _pb = PocketBase(baseUrl);
  }

  // Auth methods
  Future<bool> login(String email, String password) async {
    try {
      await _pb.collection('users').authWithPassword(email, password);
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _pb.authStore.clear();
  }

  bool get isLoggedIn => _pb.authStore.isValid;
  
  // Generic CRUD methods
  Future<List<T>> getList<T>(
    String collection,
    T Function(Map<String, dynamic>) fromJson, {
    int page = 1,
    int perPage = 30,
    String? filter,
    String? sort,
    String? expand,
  }) async {
    try {
      final records = await _pb.collection(collection).getList(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort,
        expand: expand,
      );
      
      return records.items.map((item) => fromJson(item.toJson())).toList();
    } catch (e) {
      print('Get list error: $e');
      return [];
    }
  }

  Future<T?> getOne<T>(
    String collection,
    String id,
    T Function(Map<String, dynamic>) fromJson, {
    String? expand,
  }) async {
    try {
      final record = await _pb.collection(collection).getOne(id, expand: expand);
      return fromJson(record.toJson());
    } catch (e) {
      print('Get one error: $e');
      return null;
    }
  }

  Future<T?> create<T>(
    String collection,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final record = await _pb.collection(collection).create(body: data);
      return fromJson(record.toJson());
    } catch (e) {
      print('Create error: $e');
      return null;
    }
  }

  Future<T?> update<T>(
    String collection,
    String id,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final record = await _pb.collection(collection).update(id, body: data);
      return fromJson(record.toJson());
    } catch (e) {
      print('Update error: $e');
      return null;
    }
  }

  Future<bool> delete(String collection, String id) async {
    try {
      await _pb.collection(collection).delete(id);
      return true;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  // File URL helper
  String getFileUrl(String collection, String recordId, String filename) {
    return '$baseUrl/api/files/$collection/$recordId/$filename';
  }
}