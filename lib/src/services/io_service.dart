abstract class IO {
  static void red(Object? value) => print(value);
  static void green(Object? value) => print(value);
  static void yellow(Object? value) => print(value);
  static void blue(Object? value) => print(value);
  static void cyan(Object? value) => print(value);

  // static void red(Object? value) => print('\x1b[91m$value\x1b[0m');
  // static void green(Object? value) => print('\x1b[92m$value\x1b[0m');
  // static void yellow(Object? value) => print('\x1b[93m$value\x1b[0m');
  // static void blue(Object? value) => print('\x1b[94m$value\x1b[0m');
  // static void cyan(Object? value) => print('\x1b[96m$value\x1b[0m');
}
