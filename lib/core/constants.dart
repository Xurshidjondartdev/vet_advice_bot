sealed class Constants {
  static const String botToken = "6278652695:AAE4BqnCejJafp4QTFLwx_361RmM4HTgZKE";
  // static const String botToken = "7429063114:AAEmIo9orDdnA8Vt3ZXYVuB72-MBUb_cY0M";
  static const String cardNumber = "5614 6812 1614 1503";
  static const String cardNumberHolder = "Kamoljon Hamzayev";
  static const int subscriptionPrice = 20000;
  static const int subscriptionPeriod = 72;
  static const int adminId = 2119398453;
  // static const int adminId = 1480826067;

  /// database
  static const String host = "localhost";
  static const String database = "vet_advice_bot";
  // static const String username = "postgres";
  static const String username = "userjon";
  static const String password = "root";

// username in my kompyuter postgres
}


// User=root
// WorkingDirectory=/root/vet_advice_bot
// ExecStart=/usr/bin/dart run bin/main.dart
// Restart=always
// RestartSec=10
// StandardOutput=journal
// StandardError=journal
// SyslogIdentifier=bot


// [Unit]
// Description=Vet maslahat bot
// After=network.target
//
// [Service]
// ExecStart=dart vet_advice_bot/bin/main.dart
// WorkingDirectory=/root/vet_advice_bot
// Restart=always
// User=root
// Group=root
// Environment="PATH=/usr/bin:/usr/local/bin"
//
// [Install]
// WantedBy=multi-user.target

