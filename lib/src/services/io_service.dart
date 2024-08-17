import 'dart:io';

abstract class IO {
  static void border(Object? value) => print('\x1b[51m$value\x1b[0m');
  static void greenBorderStdout(Object? value) => stdout.write('\x1b[51m\x1b[32m$value\x1b[0m\x1b[0m');
  static void blueBorderStdout(Object? value) => stdout.write('\x1b[51m\x1b[34m$value\x1b[0m\x1b[0m');
  static void redBorderStdout(Object? value) => stdout.write('\x1b[51m\x1b[31m$value\x1b[0m\x1b[0m');

  static void bold(Object? value) => print('\x1B[1m$value\x1B[0m');

  static void red(Object? value) => print('\x1b[91m$value\x1b[0m');
  static void green(Object? value) => print('\x1b[92m$value\x1b[0m');
  static void yellow(Object? value) => print('\x1b[93m$value\x1b[0m');
  static void blue(Object? value) => print('\x1b[94m$value\x1b[0m');
  static void magenta(Object? value) => print('\x1b[95m$value\x1b[0m');
  static void cyan(Object? value) => print('\x1b[96m$value\x1b[0m');
  static void white(Object? value) => print('\x1b[97m$value\x1b[0m');

  static void borderStdout(Object? value) => stdout.write('\x1b[51m$value\x1b[0m');
  static void boldStdout(Object? value) => stdout.write('\x1B[1m$value\x1B[0m');

  static void redStdout(Object? value) => stdout.write('\x1b[91m$value\x1b[0m');
  static void greenStdout(Object? value) => stdout.write('\x1b[92m$value\x1b[0m');
  static void blueStdout(Object? value) => stdout.write('\x1b[94m$value\x1b[0m');
  static void yellowStdout(Object? value) => stdout.write('\x1b[93m$value\x1b[0m');
}