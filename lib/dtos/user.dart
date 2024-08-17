import '../src/services/orm.dart';

class UserDto extends DB {
  final int id;
  final String fullName;
  final int balance;
  final DateTime? createdAt;
  final DateTime? lastPaymentDate;

  UserDto({
    required this.id,
    required this.fullName,
    this.balance = 0,
    this.createdAt,
    this.lastPaymentDate,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json["id"],
    fullName: json["fullName"],
    balance: json["balance"],
    createdAt: DateTime.parse(json["createdAt"]),
    lastPaymentDate: json["lastPaymentDate"] != null ? DateTime.parse(json["lastPaymentDate"]) : null,
  );

  @override
  Map<String, dynamic> get toJson => {
    "id": id,
    "fullName": fullName,
    "balance": balance,
    "createdAt": createdAt?.toIso8601String(),
    "lastPaymentDate": lastPaymentDate?.toIso8601String(),
  };
}
