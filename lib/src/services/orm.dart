import 'package:postgres/postgres.dart';

abstract class DB {
  Map<String, dynamic> get toJson;

  Future<Connection> connectionOpen() async => await Connection.open(
    Endpoint(
      host: "localhost",
      database: "vet_advice_bot",
      username: "postgres",
      password: "root"
    ),
    settings: ConnectionSettings(
      sslMode: SslMode.disable
    )
  );


  Future<void> insert() async {
    final Connection connection = await connectionOpen();
    final String tableName = "${runtimeType.toString()[0].toLowerCase() + runtimeType.toString().substring(1)}s";
    final String columnNames = toJson.keys.join(", ");
    final String values = toJson.keys.map((e) => "@$e").join(", ");
    final String query  = "insert into $tableName ($columnNames) values ($values)";

    try {
      await connection.execute(Sql.named(query), parameters: toJson);
    } catch(e) {
      await connection.close();
      return Future.error(e);
    }

    await connection.close();
  }

  Future<void> select({List<String>? columns, List<String>? conditionsAnd, List<String>? conditionsOr, String? conditionsNamed}) async {
    final Connection connection = await connectionOpen();
    final String tableName = "${runtimeType.toString()[0].toLowerCase() + runtimeType.toString().substring(1)}s";
    final String columnNames = columns?.isNotEmpty == true ? columns!.join(", ") : "*";
    late final String conditions;

    if(conditionsAnd?.isNotEmpty == true) {
      conditions = conditionsAnd!.map((e) => "$e = @$e").join(" and ");
    } else if(conditionsOr?.isNotEmpty == true) {
      conditions = conditionsOr!.map((e) => "$e = @$e").join(" or ");
    } else if((conditionsNamed??"").isNotEmpty) {
      conditions = conditionsNamed!;
    } else {
      conditions = "";
    }

    /// eslatma: order by yozish kerak
    final String query  = "(select $columnNames from $tableName${conditions.isNotEmpty ? " where $conditions" : ""})";

    try {
      await connection.execute(Sql.named(query), parameters: toJson);
    } catch(e) {
      await connection.close();
      return Future.error(e);
    }

    await connection.close();
  }

  Future<void> update({List<String>? columns, List<String>? conditionsAnd, List<String>? conditionsOr, String? conditionsNamed}) async {
    final Connection connection = await connectionOpen();
    final String tableName = "${runtimeType.toString()[0].toLowerCase() + runtimeType.toString().substring(1)}s";
    final String columnNames = columns?.isNotEmpty == true ? columns!.map((e) => "$e = @$e").join(", ") : toJson.keys.map((e) => "$e = @$e").join(", ");
    late final String conditions;

    if(conditionsAnd?.isNotEmpty == true) {
      conditions = conditionsAnd!.map((e) => "$e = @$e").join(" and ");
    } else if(conditionsOr?.isNotEmpty == true) {
      conditions = conditionsOr!.map((e) => "$e = @$e").join(" or ");
    } else if((conditionsNamed??"").isNotEmpty) {
      conditions = conditionsNamed!;
    } else {
      return Future.error("No conditions");
    }

    final String query  = "update $tableName set $columnNames where $conditions";

    try {
      await connection.execute(Sql.named(query), parameters: toJson);
    } catch(e) {
      await connection.close();
      return Future.error(e);
    }

    await connection.close();
  }

  Future<void> delete({List<String>? conditionsAnd, List<String>? conditionsOr, String? conditionsNamed}) async {
    final Connection connection = await connectionOpen();
    final String tableName = "${runtimeType.toString()[0].toLowerCase() + runtimeType.toString().substring(1)}s";
    late final String conditions;

    if(conditionsAnd?.isNotEmpty == true) {
      conditions = conditionsAnd!.map((e) => "$e = @$e").join(" and ");
    } else if(conditionsOr?.isNotEmpty == true) {
      conditions = conditionsOr!.map((e) => "$e = @$e").join(" or ");
    } else if((conditionsNamed??"").isNotEmpty) {
      conditions = conditionsNamed!;
    } else {
      return Future.error("No conditions");
    }

    final String query  = "delete from $tableName where $conditions";

    try {
      await connection.execute(Sql.named(query), parameters: toJson);
    } catch(e) {
      await connection.close();
      return Future.error(e);
    }

    await connection.close();
  }





  ///  ======================================================================================== \\\


  // Future<void> get({
  //   required String tableName,
  //   Map<String, dynamic>? json,
  //   List<String>? conditionsAnd,
  //   List<String>? conditionsOr,
  //   String? conditionsNamed
  // }) async {
  //   final Connection connection = await connectionOpen();
  //   final String columnNames = json?.keys.isNotEmpty == true ? json!.keys.join(", ") : "*";
  //   late final String conditions;
  //
  //   if(conditionsAnd?.isNotEmpty == true) {
  //     conditions = conditionsAnd!.map((e) => "$e = @$e").join(" and ");
  //   } else if(conditionsOr?.isNotEmpty == true) {
  //     conditions = conditionsOr!.map((e) => "$e = @$e").join(" or ");
  //   } else if((conditionsNamed??"").isNotEmpty) {
  //     conditions = conditionsNamed!;
  //   } else {
  //     conditions = "";
  //   }
  //
  //   /// eslatma: order by yozish kerak
  //   final String query  = "(select $columnNames from $tableName${conditions.isNotEmpty ? " where $conditions" : ""})";
  //
  //   try {
  //     await connection.execute(Sql.named(query), parameters: json);
  //   } catch(e) {
  //     await connection.close();
  //     return Future.error(e);
  //   }
  //
  //   await connection.close();
  // }
  //
  // Future<void> update({
  //   required String tableName,
  //   required Map<String, dynamic> json,
  //   List<String>? conditionsAnd,
  //   List<String>? conditionsOr,
  //   String? conditionsNamed
  // }) async {
  //   final Connection connection = await connectionOpen();
  //   final String columnNames = json.keys.map((e) => "$e = @$e").join(", ");
  //   late final String conditions;
  //
  //   if(conditionsAnd?.isNotEmpty == true) {
  //     conditions = conditionsAnd!.map((e) => "$e = @$e").join(" and ");
  //   } else if(conditionsOr?.isNotEmpty == true) {
  //     conditions = conditionsOr!.map((e) => "$e = @$e").join(" or ");
  //   } else if((conditionsNamed??"").isNotEmpty) {
  //     conditions = conditionsNamed!;
  //   } else {
  //     return Future.error("No conditions");
  //   }
  //
  //   final String query  = "update $tableName set $columnNames where $conditions";
  //
  //   try {
  //     await connection.execute(Sql.named(query), parameters: json);
  //   } catch(e) {
  //     await connection.close();
  //     return Future.error(e);
  //   }
  //
  //   await connection.close();
  // }
  //
  // Future<void> delete({
  //   required String tableName,
  //   required Map<String, dynamic> parameters,
  //   List<String>? conditionsAnd,
  //   List<String>? conditionsOr,
  //   String? conditionsNamed
  // }) async {
  //   final Connection connection = await connectionOpen();
  //   late final String conditions;
  //
  //   if(conditionsAnd?.isNotEmpty == true) {
  //     conditions = conditionsAnd!.map((e) => "$e = @$e").join(" and ");
  //   } else if(conditionsOr?.isNotEmpty == true) {
  //     conditions = conditionsOr!.map((e) => "$e = @$e").join(" or ");
  //   } else if((conditionsNamed??"").isNotEmpty) {
  //     conditions = conditionsNamed!;
  //   } else {
  //     return Future.error("No conditions");
  //   }
  //
  //   final String query  = "delete from $tableName where $conditions";
  //
  //   try {
  //     await connection.execute(Sql.named(query), parameters: parameters);
  //   } catch(e) {
  //     await connection.close();
  //     return Future.error(e);
  //   }
  //
  //   await connection.close();
  // }
}
