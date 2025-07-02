import 'package:sqflite/sqflite.dart';

abstract class DatabaseService {
  /// Get the database instance
  Future<Database> get database;
  
  /// Initialize the database and create tables
  Future<void> initialize();
  
  /// Close the database connection
  Future<void> close();
}