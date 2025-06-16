import 'dart:io';

void clearScreen() {
  // Clear the console screen
  if (Platform.isWindows) {
    stdout.write('\x1B[2J\x1B[0;0f');
  } else {
    stdout.write('\x1B[2J\x1B[H');
  }
}