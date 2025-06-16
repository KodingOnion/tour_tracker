import 'expense.dart'; // Import your Expense model

import 'package:path/path.dart'; // Make sure this import is present at the top of your file
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Make sure this import is present

// Database Helper
// A singleton class to manage all database operations.
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database; // The actual database connection

  // Private constructor for the singleton pattern
  DatabaseHelper._internal();

  // Factory constructor to return the single instance of DatabaseHelper
  factory DatabaseHelper() {
    return _instance;
  }

  // Getter for the database instance.
  // This ensures the database is initialized before it's used.
  Future<Database> get database async {
    if (_database != null) {
      return _database!; // If database already exists, return it
    }
    _database = await _initDb(); // Otherwise, initialize it
    return _database!;
  }

  // Initializes the database: opens it and creates tables if they don't exist.
  Future<Database> _initDb() async {
    // Construct the path to the database file.
    // This will create a 'budget_tracker.db' file in a default location
    // (often in your project's root or a system-specific app data folder).
    String databasesPath = await getDatabasesPath(); // Gets the default path for databases
    String path = join(databasesPath, 'budget_tracker.db'); // Joins path parts correctly

    print('Database will be created/opened at: $path'); // Helpful for debugging

    // Open the database.
    return await openDatabase(
      path,
      version: 1, // Start with version 1. Increment this if you change your table schema.
      onCreate: (db, version) async {
        // This callback runs only when the database is first created.
        // It's where you define your SQL to create tables.
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
        print('Expenses table created successfully!');
      },
      onOpen: (db) {
        print('Database opened!'); // Called every time the database is opened
      }
    );
  }

  // Insert an expense into the database
  Future<int> insertExpense(Expense expense) async {
    final db = await database; // Get the database instance
    // `insert` returns the `id` (primary key) of the newly inserted row
    // We don't include expense.id in the map here because it's AUTOINCREMENT
    return await db.insert(
      'expenses', // Table name
      expense.toMap(), // The data to insert
      conflictAlgorithm: ConflictAlgorithm.replace, // Handle potential conflicts
    );
  }

  // Retrieve all expenses from the database
  Future<List<Expense>> getExpenses() async {
    final db = await database;
    // Query all rows from the 'expenses' table
    final List<Map<String, dynamic>> maps = await db.query('expenses');

    // Convert the List<Map> to a List<Expense> using Expense.fromMap()
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Update an existing expense in the database
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    // Update a row where the `id` matches
    return await db.update(
      'expenses', // Table name
      expense.toMap(), // The updated data
      where: 'id = ?', // SQL WHERE clause
      whereArgs: [expense.id], // Arguments for the WHERE clause
    );
  }

  // Delete an expense from the database
  Future<int> deleteExpense(int id) async {
    final db = await database;
    // Delete a row where the `id` matches
    return await db.delete(
      'expenses', // Table name
      where: 'id = ?', // SQL WHERE clause
      whereArgs: [id], // Argument for the WHERE clause
    );
  }

  // Resets the expenses table by clearing all data and resetting the ID counter.
  // Use with caution, as this will delete all your expense data!
  Future<void> resetExpensesTable() async {
    final db = await database;
    try {
      // 1. Delete all data from the expenses table
      await db.delete('expenses');
      print('All data cleared from expenses table.');

      // 2. Reset the AUTOINCREMENT counter in sqlite_sequence
      await db.execute("DELETE FROM sqlite_sequence WHERE name = 'expenses'");
      print('AUTOINCREMENT counter for expenses table reset.');

      // Optional: Re-vacuum the database to reclaim space
      await db.rawQuery('VACUUM');
      print('Database vacuumed.');

    } catch (e) {
      print('Error resetting expenses table: $e');
    }
  }

  Future<void> close() async {
    final db = await database;
    if (db.isOpen) {
      await db.close();
      _database = null; // Clear the instance for potential re-initialization
      print('Database connection closed.');
    }
  }
}