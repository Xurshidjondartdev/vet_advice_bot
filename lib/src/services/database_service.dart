import 'package:postgres/postgres.dart';
import 'package:vet_advice_bot/src/services/io_service.dart';

import '../../core/constants.dart';

abstract class DatabaseService {
  Future<Connection> connectionOpen() async => await Connection.open(
    Endpoint(
      host: Constants.host,
      database: Constants.database,
      username: Constants.username,
      password: Constants.password
    ),
    settings: ConnectionSettings(
      sslMode: SslMode.disable,
      timeZone: "Asia/Tashkent",
    )
  );

  Future<T> _executeQuery<T>(Future<T> Function(Connection connection) queryFunction) async {
    Connection? connection;

    try {
      connection = await connectionOpen();
      return await queryFunction(connection);
    } catch (e) {
      IO.red("too many clients already");
      return Future.error("too many clients already");
    } finally {
      if (connection != null && connection.isOpen) {
        await connection.close();
      }
    }
  }

  Future<bool> existsUser(int id) async => await _executeQuery((connection) async {
    final Result result = await connection.execute(
      Sql.named("select exists(select 1 from users where id = @id)"),
      parameters: {"id": id}
    );

    return result.first.first as bool;
  });

  Future<int> getBalance(int id) async => await _executeQuery<int>((connection) async {
    final Result result = await connection.execute(
      Sql.named("select balance from users where id = @id"),
      parameters: {"id": id}
    );
    return result.first.first as int;
  });

  Future<void> storage(String tableName, Map<String, dynamic> json) async => await _executeQuery((connection) async {
    final String columnNames = json.keys.join(", ");
    final String values = json.keys.map((e) => "@$e").join(", ");
    final String query  = "insert into $tableName ($columnNames) values ($values)";
    await connection.execute(Sql.named(query), parameters: json);
  });

  Future<int> subscribers() async => await _executeQuery<int>((connection) async {
    final Result result = await connection.execute(Sql.named("select count(*) from users"));
    return result.first.first as int;
  });

  Future<int> activeSubscribers() async => await _executeQuery<int>((connection) async {
    final Result result = await connection.execute(Sql.named("select count(*) from users where lastPaymentDate is not null"));
    return result.first.first as int;
  });

  Future<String?> getState(int id) async => await _executeQuery<String?>((connection) async {
    final Result result = await connection.execute(
      Sql.named("select state from users where id = @id"),
      parameters: {"id": id}
    );

    return result.first.first as String?;
  });

  Future<void> updateState(String? state, int id) async => await _executeQuery((connection) async {
    await connection.execute(
      Sql.named("update users set state = @state where id = @id"),
      parameters: {"state": state, "id": id}
    );
  });

  Future<void> updateUserBalance(int id, int paymentAmount) async => await _executeQuery((connection) async {
    await connection.execute(
      Sql.named("update users set balance = balance + @paymentAmount where id = @id"),
      parameters: {"id": id, "paymentAmount": paymentAmount}
    );
  });

  Future<void> updateLastPaymentDate(int id) async => await _executeQuery((connection) async {
    await connection.execute(
      Sql.named("update users set lastPaymentDate = now() where id = @id"),
      parameters: {"id": id}
    );
  });

  Future<String> getUserInfo(int id) async => await _executeQuery<String>((connection) async {
    final Result result = await connection.execute(
      Sql.named("select fullname, balance, createdAt from users where id = @id"),
      parameters: {"id": id}
    );

    return "<b>Id:</b> $id\n<b>Firstname:</b> ${result.first[0]}\n"
        "<b>Umumiy balance:</b> ${result.first[1]}\n"
        "<b>Registratsiya vaqti:</b> ${result.first[2]}\n\n";
  });

  Future<bool> subscribersIsActive(int id) async => await _executeQuery((connection) async {
    final String query = "select floor(extract(epoch from age(now(), lastPaymentDate)) / 3600) from users where id = @id";
    final Result result = await connection.execute(Sql.named(query), parameters: {"id": id});
    final int? hoursSinceLastPayment = int.tryParse(result.first.first.toString());
    return hoursSinceLastPayment != null && Constants.subscriptionPeriod >= hoursSinceLastPayment;
  });
}
