import 'package:itable_ex/src/external/DatabaseExecutor.dart';
import 'package:itable_ex/src/external/ISqlBuilder.dart';
import 'package:json_ex/library.dart';
import 'package:logger_ex/library.dart';

import 'results/RawDeleteRequestResult.dart';
import 'results/RawDropTableRequestResult.dart';
import 'results/RawInsertRequestResult.dart';
import 'results/RawQueryRequestResult.dart';
import 'results/RawUpdateRequestResult.dart';

abstract class TableExecutor {
  /// Table name
  String get name;

  /// Last id of SQL QUERY/INSERT/UPDATE/REMOVE operation
  int get lastTransactionId;

  /// true if executor has been disposed
  bool get disposed;

  /// Executes SQL SELECT
  /// 
  /// Returns rows
  Future<RawQueryRequestResult> query({
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    LoggerContext? logger,
  });

  /// Executes SQL SELECT
  /// 
  /// Returns rows
  Future<RawQueryRequestResult> rawQuery(
    String sql, {
      List<Object?>? arguments,
      LoggerContext? logger,
  });

  /// Executes SQL INSERT
  /// 
  /// Returns [PRIMARY_KEY]
  Future<RawInsertRequestResult> insert(
    JsonObject values, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,
      LoggerContext? logger,
  });

  /// Executes SQL INSERT INTO
  /// 
  /// Returns [PRIMARY_KEY] of last inserted
  Future<RawInsertRequestResult> insertAll(
    List<String> columns,
    List<List<Object?>> list, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,

      DatabaseExecutor? database,
      LoggerContext? logger,
  });


  /// Executes INSERT INTO ON CONFLICT() DO UPDATE SET
  /// 
  /// Returns number of changed rows
  Future<RawUpdateRequestResult> update(
    Map<String, dynamic> values, {
      String? where,
      List<Object?>? whereArgs,
      ConflictAlgorithm? conflictAlgorithm,
      LoggerContext? logger,
  });

  /// Executes SQL UPDATE
  /// 
  /// Returns number of changed rows
  Future<RawInsertRequestResult> updateAll(
    List<String> columns,
    List<List<Object?>> list, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,

      DatabaseExecutor? database,
      LoggerContext? logger,
  });

  Future<RawUpdateRequestResult> rawUpdate(
    String sql, {
      List<Object?>? arguments,

      DatabaseExecutor? database,
      LoggerContext? logger,
  });
  
  /// Executes SQL DELETE
  /// 
  /// Returns amount of deleted rows
  Future<RawDeleteRequestResult> delete({
    String? where,
    List<Object?>? whereArgs,
    LoggerContext? logger,
  });

  /// Executes SQL DROP TABLE
  /// 
  /// Dropping table
  Future<RawDropTableRequestResult> drop();

  /// Executes SQL SELECT
  Future<List<String>> toStringTable({
    int size = 999,
    offset = 0,
  });
}