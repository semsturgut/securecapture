import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:securecapture/core/errors/common_error.dart';
import 'package:securecapture/core/shared_data/services/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

@LazySingleton(as: DatabaseService)
class DatabaseServiceImpl implements DatabaseService {
  Database? _database;

  @override
  Future<Database> get database async {
    if (_database != null) return _database!;
    await initialize();
    return _database!;
  }

  @override
  Future<void> initialize() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocDir.path, 'secure_capture.db');

      _database = await openDatabase(dbPath, version: 1, onCreate: _createTables, onUpgrade: _onUpgrade);
    } catch (e) {
      throw CommonError('Failed to initialize database: ${e.toString()}');
    }
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE encrypted_images (
        id TEXT PRIMARY KEY,
        filename TEXT NOT NULL,
        file_path TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // No need to implement for the technical demo
    // Handle database migrations here when you need to update the schema
  }

  @override
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
