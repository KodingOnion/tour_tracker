import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/menu_screen.dart';
import 'methods.dart';
import 'expense.dart';
import 'database_helper.dart';


void menuReponse(DatabaseHelper databaseHelper) {
  int? choice = menuScreen();
  switch (choice) {
    case 0:
      stdout.write('Expense added successfully.\n');
      break;
    case 1:
      stdout.write('Current budget displayed.\n');
      break;
    case 2:
      clearScreen();

      databaseHelper.getExpenses().then((expenses) {
        if (expenses.isEmpty) {
          stdout.write('No expenses found.\n');
        } else {
          stdout.write('All Expenses:\n');
          for (var expense in expenses) {
            stdout.write('$expense\n');
          }
        }
      }).catchError((error) {
        stdout.write('Error retrieving expenses: $error\n');
      });
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
    menuReponse(databaseHelper);
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

  await Future.delayed(Duration(seconds: 1)); // Optional delay for better UX

  menuReponse(dbHelper); // Start the menu response loop
}
