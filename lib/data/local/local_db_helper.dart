import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:Transcripto/domain/models/response_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Get or initialize the database
  Future<Database?> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB('complex_words.db');
      return _database!;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
      Get.showSnackbar(
        GetSnackBar(
          message: 'Failed to initialize database: $e',
          duration: const Duration(seconds: 3),
        ),
      );
      return null;
    }
  }

  // Initialize the database
  Future<Database> _initDB(String fileName) async {
    try {
      final dbPath = await getDatabasesPath();
      print(dbPath);
      final path = join(dbPath, fileName);
      if (kDebugMode) {
        print('Database path: $path');
      }
      return await openDatabase(path, version: 1, onCreate: _createDB);
    } catch (e) {
      throw Exception('Failed to open database: $e');
    }
  }

  // Create the complex_words table
  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE complex_words (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT NOT NULL UNIQUE,
          wordType TEXT NOT NULL,
          wordTranslated TEXT NOT NULL,
          wordExplanation TEXT NOT NULL,
          examples TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    } catch (e) {
      throw Exception('Failed to create table: $e');
    }
  }

  // Insert a single complex word
  Future<bool> insertComplexWord(ComplexWord complexWord) async {
    final db = await database;
    if (db == null) return false;

    try {
      await db.transaction((txn) async {
        await txn.insert('complex_words', {
          'word': complexWord.word,
          'wordType': complexWord.wordType ?? 'Unknown',
          'wordTranslated': complexWord.wordTranslated,
          'wordExplanation': complexWord.wordExplanation,
          'examples': jsonEncode(
            complexWord.examples
                .map(
                  (e) => {'sentence': e.sentence, 'translation': e.translation},
                )
                .toList(),
          ),
          'created_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting complex word: $e');
      }
      Get.showSnackbar(
        GetSnackBar(
          message: 'Failed to save word: $e',
          duration: const Duration(seconds: 3),
        ),
      );
      return false;
    }
  }

  // Retrieve all complex words
  Future<List<Map<String, dynamic>>> getAllComplexWords() async {
    final db = await database;
    if (db == null) return [];

    try {
      final data = await db.query('complex_words', orderBy: 'created_at DESC');

      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Error querying complex words: $e');
      }
      return [];
    }
  }

  // Retrieve a specific complex word by word
  Future<Map<String, dynamic>?> getComplexWord(String word) async {
    final db = await database;
    if (db == null) return null;
    try {
      final result = await db.query(
        'complex_words',
        where: 'word = ?',
        whereArgs: [word],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error querying word: $e');
      }
      return null;
    }
  }

  // Update a complex word
  Future<bool> updateComplexWord(Map<String, dynamic> wordData) async {
    final db = await database;
    if (db == null) return false;
    try {
      final rowsAffected = await db.update(
        'complex_words',
        wordData,
        where: 'word = ?',
        whereArgs: [wordData['word']],
      );
      return rowsAffected > 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating word: $e');
      }
      return false;
    }
  }

  // Delete a complex word by word
  Future<bool> deleteComplexWord(String word) async {
    final db = await database;
    if (db == null) return false;

    try {
      final rowsAffected = await db.delete(
        'complex_words',
        where: 'word = ?',
        whereArgs: [word],
      );
      return rowsAffected > 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting complex word: $e');
      }
      Get.showSnackbar(
        GetSnackBar(
          message: 'Failed to delete word: $e',
          duration: const Duration(seconds: 3),
        ),
      );
      return false;
    }
  }

  // Close the database
  Future<void> close() async {
    if (_database != null) {
      try {
        await _database!.close();
        _database = null;
      } catch (e) {
        if (kDebugMode) {
          print('Error closing database: $e');
        }
      }
    }
  }

  // Debug method to check if database exists
  Future<bool> databaseExists() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'complex_words.db');
      return await databaseFactory.databaseExists(path);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking database existence: $e');
      }
      return false;
    }
  }
}
