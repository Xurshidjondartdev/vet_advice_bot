import 'dart:io';

sealed class Constants {
  static String get botToken => Platform.environment['BOT_TOKEN'] ?? "7429063114:AAEmIo9orDdnA8Vt3ZXYVuB72-MBUb_cY0M";
  static const String cardNumber = "5614 6812 1646 1503";
  static const String cardNumberHolder = "Kamoljon Hamzayev";
  static const int subscriptionPrice = 20000;
  static const int subscriptionPeriod = 72;
  // static const int adminId = 2119398453;
  static const int adminId = 1480826067;

  /// database
  static String get host => Platform.environment['DB_HOST'] ?? "localhost";
  static String get database => Platform.environment['DB_NAME'] ?? "vet_advice_bot";
  static String get username => Platform.environment['DB_USER'] ?? "userjon";
  static String get password => Platform.environment['DB_PASSWORD'] ?? "root";
}
