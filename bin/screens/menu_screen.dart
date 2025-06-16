import 'dart:io';
import '../methods.dart';

void drawMenuScreen() {
  clearScreen();
  // Title
  stdout.write('Tour Tracker\n');
  stdout.write('--------------------------\n');

  // Menu options
  stdout.write('Menu:\n');
  stdout.write('1. Add expense\n');
  stdout.write('2. Current Budget\n');
  stdout.write('3. All Expenses (Detailed)\n');
  stdout.write('4. Edit/Delete Expense\n');
  stdout.write('5. Exit\n');
  stdout.write('--------------------------');
}

int menuLogic(String choice) {
  switch (choice) {
    case '1':
      // Logic for adding an expense
      return 0; // Return 0 to indicate success
    case '2':
      // Logic for showing current budget
      return 1; // Return 0 to indicate success
    case '3':
      // Logic for showing all expenses
      return 2; // Return 0 to indicate success
    case '4':
      // Logic for editing/deleting an expense
      return 3; // Return 0 to indicate success
    case '5':
      // Exit the application
      return 4; // Return 0 to indicate success
    default:
      return -1; // Return -1 to indicate an error
  }
}

int menuScreen() {
  drawMenuScreen();
  stdout.write('\nPlease select an option: ');

  // Read user input
  String? choice;

  while (choice == null ||
      choice.isEmpty ||
      !['1', '2', '3', '4', '5'].contains(choice)) {
    choice = stdin.readLineSync();
    if (choice == null || choice.isEmpty || !['1', '2', '3', '4', '5'].contains(choice)) {
      drawMenuScreen();
      stdout.write('\nInvalid choice. Please select a valid option: ');
    }
  }

  return menuLogic(choice);
}
