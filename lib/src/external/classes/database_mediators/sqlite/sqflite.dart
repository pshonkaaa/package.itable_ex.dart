import 'dart:io';
import 'dart:typed_data';

import 'package:ientity/library.dart';
import 'package:itable_ex/library.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite;
import 'package:true_core/library.dart';

import 'internal/sqlite_builder.dart';

abstract class SqliteColumnTypes {
  static const DATABASE_NAME = "sqlite";

  static const ALL = [
    integer,
    real,
    text,
    blob,
  ];

  static const integer  = ColumnType(database: DATABASE_NAME, name: "integer", sinceVersion: "0.1", deprecatedVersion: "");
  static const real     = ColumnType(database: DATABASE_NAME, name: "real", sinceVersion: "0.1", deprecatedVersion: "");
  static const text     = ColumnType(database: DATABASE_NAME, name: "text", sinceVersion: "0.1", deprecatedVersion: "");
  static const blob     = ColumnType(database: DATABASE_NAME, name: "blob", sinceVersion: "0.1", deprecatedVersion: "");
}

class SqfliteConnectionParams implements IConnectionParams {
  final String path;
  final int version;
  const SqfliteConnectionParams({
    required this.path,
    required this.version,
  });
}

class SqfliteMediator implements DatabaseMediator {
  sqflite.Database? _sqflite;
  SqfliteMediator();

  
  
  @override
  final ISqlBuilder sqlBuilder = SqliteBuilder();

  @override
  bool get connected => _sqflite?.isOpen ?? false;

  Future<bool> connect({
    required covariant SqfliteConnectionParams connectionParams,
    required OnConfigureFunction onConfigure,
    required OnOpenFunction onOpen,
    required OnCreateFunction onCreate,
    required OnUpgradeFunction onUpgrade,
    required OnDowngradeFunction onDowngrade,
  }) async {
    if(Platform.isWindows) {
      _sqflite = await sqflite.databaseFactoryFfi.openDatabase(
        connectionParams.path,
        options: sqflite.OpenDatabaseOptions(
          version: connectionParams.version,
          onConfigure: (db) {
            _sqflite = db;
            onConfigure();
          },
          onCreate: (db, version) => onCreate(version),
          onUpgrade: (db, oldVersion, newVersion) => onUpgrade(oldVersion, newVersion),
          onDowngrade: (db, oldVersion, newVersion) => onDowngrade(oldVersion, newVersion),
          onOpen: (db) => onOpen(),
        ),
      );
    } else {
      _sqflite = await sqflite.openDatabase(
        connectionParams.path,
        // options: sqflite.OpenDatabaseOptions(
          version: connectionParams.version,
          onConfigure: (db) {
            _sqflite = db;
            onConfigure();
          },
          onCreate: (db, version) => onCreate(version),
          onUpgrade: (db, oldVersion, newVersion) => onUpgrade(oldVersion, newVersion),
          onDowngrade: (db, oldVersion, newVersion) => onDowngrade(oldVersion, newVersion),
          onOpen: (db) => onOpen(),
        // ),
      );
    }
    return true;
  }

  @override
  Future<bool> close() async {
    await _sqflite?.close();
    return true;
  }

  @override
  Future<int> getVersion() {
    // TODO: implement getVersion
    throw UnimplementedError();
  }







  @override
  Future<List<String>> getTables() async {
    final List<String> tables = [];
    final rows = await _sqflite!.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
    for(final row in rows) {
      final name = row["name"] as String;
      tables.add(name);
    }
    return tables;
  }
  
  @override
  Future<TableInfo> getTableInfo(String name) async {
    final map = await rawQuery("PRAGMA table_info($name)");
    return TableInfo(
      table: name,
      columns: map.map((e) {
        final type = e["type"]! as String;
        return ColumnInfo(
          name: e["name"]! as String,
          type: SqliteColumnTypes.ALL.tryFirstWhere((e) => e.name == type) ?? ColumnType(
            database: SqliteColumnTypes.DATABASE_NAME,
            name: type,
            sinceVersion: "0.0",
            deprecatedVersion: "0.0",
          ),
          defaultValue: e["dflt_value"] as String?,
          isPrimaryKey: e["pk"]! as int == 1,
          isAutoIncrement: false,
          isNullable: e["notnull"]! == 0,
        );
      }).toList(),
    );
  }
  
  @override
  Object? transformRuntimeType<T>(EntityColumnInfo column, T v) {
    if(v == null)
      return null;
      
    if(v is bool)
      return (v ? 1 : 0).toString();
    else if(v is String || v is int || v is num)
      return v.toString();
    else if(v is Uint8List)
      return v;
    else throw(ArgumentError("Wrong value type; column = ${column.name}; runtimeType = ${v.runtimeType}"));
  }

  @override
  Future<Object> execute(String sql, [List<Object?>? arguments]) async {
    await _sqflite!.execute(sql, arguments);
    return {};
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    return await _sqflite!.rawInsert(sql, arguments);
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    return await _sqflite!.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    return await _sqflite!.rawUpdate(sql, arguments);
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    return await _sqflite!.rawDelete(sql, arguments);
  }
}