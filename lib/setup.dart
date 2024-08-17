import 'package:postgres/postgres.dart';
import 'core/constants.dart';

Future<void> setup() async {
  final Connection connection = await Connection.open(
    Endpoint(
      host: Constants.host,
      database: Constants.database,
      username: Constants.username,
      password: Constants.password
    ),
    settings: ConnectionSettings(
      sslMode: SslMode.disable
    )
  );

  await connection.execute(Sql.named("set timezone = 'Asia/Tashkent'"));
  await connection.execute(Sql.named("""
    create table if not exists users(
        id bigint unique not null,
        fullName varchar,
        state varchar(30),
        balance integer default 0 not null,
        createdAt timestamp default current_timestamp not null,
        lastPaymentDate timestamp
    )
  """));
  await connection.close();
}
