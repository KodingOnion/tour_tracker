import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/menu_screen.dart';
import 'methods.dart';
import 'expense.dart';
import 'database_helper.dart';


void menuReponse() {
  int? choice = menuScreen();
  switch (choice) {
    case 0:
      stdout.write('Expense added successfully.\n');
      break;
    case 1:
      stdout.write('Current budget displayed.\n');
      break;
    case 2:
      stdout.write('All expenses displayed.\n');
      break;
    case 3:
      stdout.write('Expense edited/deleted successfully.\n');
      break;
    case 4:
      stdout.write('Exiting the application. Goodbye!\n');
      exit(0);
    default:
      stdout.write('An error occurred. Please try again.\n');
  }
  stdout.write('Do you want to return to the menu? (y/n): ');
  String? response = stdin.readLineSync()?.toLowerCase();
  if (response == 'y' || response == 'yes') {
    menuReponse();
  } else {
    stdout.write('Exiting the application. Goodbye!\n');
    exit(0);
  }
}

Future<void> main() async { // Main must be async now to await db operations
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbHelper = DatabaseHelper(); // Get the singleton instance

  // This will trigger the database to be opened and table created if it's the first run
  await dbHelper.database; // Await the database getter to ensure it's initialized

  print('Database and table setup complete! Ready for CRUD operations.');

  print('\n--- Testing Add Expense ---');
  final testExpense = Expense(
    description: 'Lunch in London',
    amount: 12.50,
    category: 'Food',
    date: DateTime.now(),
  );

  try {
    final id = await dbHelper.insertExpense(testExpense);
    print('Added expense with ID: $id');
  } catch (e) {
    print('Error adding expense: $e');
  }

  print('\n--- Testing View Expenses ---');
  try {
    final expenses = await dbHelper.getExpenses();
    if (expenses.isEmpty) {
      print('No expenses found.');
    } else {
      print('Found ${expenses.length} expenses:');
      for (var expense in expenses) {
        print(expense); // Uses the toString() method you defined
      }
    }
  } catch (e) {
    print('Error viewing expenses: $e');
  }
  
  print('\n--- Testing Update Expense (Assuming ID 1 exists) ---');
  try {
    // First, get the expense you want to update (e.g., the one with ID 1)
    final expenses = await dbHelper.getExpenses();
    Expense? expenseToUpdate;
    if (expenses.isNotEmpty) {
      expenseToUpdate = expenses.firstWhere((exp) => exp.id == 1);
    }

    if (expenseToUpdate != null) {
      expenseToUpdate.description = 'Evening Meal in London'; // Update description
      expenseToUpdate.amount = 25.00; // Update amount

      final rowsAffected = await dbHelper.updateExpense(expenseToUpdate);
      if (rowsAffected > 0) {
        print('Updated expense ID ${expenseToUpdate.id}. Rows affected: $rowsAffected');
      } else {
        print('Expense ID ${expenseToUpdate.id} not found for update.');
      }
    } else {
      print('Expense with ID 1 not found to update.');
    }
  } catch (e) {
    print('Error updating expense: $e');
  }

  print('\n--- Testing Delete Expense (Assuming ID 1 exists) ---');
  try {
    final rowsAffected = await dbHelper.deleteExpense(1); // Try to delete ID 1
    if (rowsAffected > 0) {
      print('Deleted expense ID 1. Rows affected: $rowsAffected');
    } else {
      print('Expense ID 1 not found for deletion.');
    }
  } catch (e) {
    print('Error deleting expense: $e');
  }
}
