import 'dart:typed_data';

import 'package:itable_ex/src/external/ITableEx.dart';
import 'package:itable_ex/src/external/RawTable/RawTable.dart';
import 'package:itable_ex/src/external/RawTable/results/RawDeleteRequestResult.dart';
import 'package:itable_ex/src/external/RawTable/results/RawInsertRequestResult.dart';
import 'package:itable_ex/src/external/RawTable/results/RawQueryRequestResult.dart';
import 'package:itable_ex/src/external/RawTable/results/RawUpdateRequestResult.dart';
import 'package:itable_ex/src/external/RawTable/results/RequestDetails.dart';
import 'package:json_ex/library.dart';
import 'package:logger_ex/library.dart';
import 'package:sqflite/sqflite.dart';
import 'package:true_core/library.dart';

import 'SqlBuilder.dart';

class RawTableImpl extends RawTable {
  static const String PROFILER_BUILDER    = "building";
  static const String PROFILER_EXECUTE    = "requesting";

  @override
  final String name;

  @override
  int lastTransactionId = 0;
  
  @override
  bool disposed = false;

  final Database db;
  final ITableEx table;

  RawTableImpl({
    required this.name,
    required this.db,
    required this.table,
  });

  

  Future<void> initState() async {
  }

  Future<void> dispose() async {
    disposed = true;
  }


  @override
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

    DatabaseExecutor? db,
    LoggerContext? logger,
  }) async {
    _throwIfDisposed();

    final result = new RawQueryRequestResult(
      transactionId: ++lastTransactionId,
      stackTrace: StackTrace.current,
    );
    String sql;
    final List<Object?>? arguments;
    final Profiler p1, p2;

    p1 = new Profiler(PROFILER_BUILDER);
    p2 = new Profiler(PROFILER_EXECUTE);

    db ??= this.db;

    p1.start();
    {
      whereArgs = _fixWhereArgs(whereArgs);
      final sqlBuilder = SqlBuilder.query(
        name,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      // _parseSqlBuilder(sqlBuilder);
      sql = sqlBuilder.sql;
      arguments = sqlBuilder.arguments;
      // if((arguments?.isNotEmpty ?? false)) {
      //   if(arguments![0] is String) {
      //     if((arguments[0] as String).contains(", "))
      //       arguments[0] = "1213 ";

      //   }
      // }
      result.sql = sql = _parseSql(sql, arguments);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await db.rawQuery(sql, arguments);
    p2.stop();
    
    _debugRequest(
      sql: sql,
      result: result,
      logger: logger,
    );
    return result;
  }

  @override
  Future<RawQueryRequestResult> rawQuery(
    String sql, {
      List<Object?>? arguments,

      DatabaseExecutor? db,
      LoggerContext? logger,
  }) async {
    _throwIfDisposed();

    final result = new RawQueryRequestResult(
      transactionId: ++lastTransactionId,
      stackTrace: StackTrace.current,
    );
    final Profiler p1, p2;

    p1 = new Profiler(PROFILER_BUILDER);
    p2 = new Profiler(PROFILER_EXECUTE);

    db ??= this.db;

    p1.start();
    {
      result.sql = sql = _parseSql(sql, arguments);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await db.rawQuery(sql, arguments);
    p2.stop();
    
    _debugRequest(
      sql: sql,
      result: result,
      logger: logger,
    );
    return result;
  }

  @override
  Future<RawInsertRequestResult> insert(
    JsonObject values, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,

      DatabaseExecutor? db,
      LoggerContext? logger,
  }) async {
    _throwIfDisposed();

    final result = new RawInsertRequestResult(
      transactionId: ++lastTransactionId,
      stackTrace: StackTrace.current,
    );
    String sql;
    final List<Object?>? arguments;
    final Profiler p1, p2;

    p1 = new Profiler(PROFILER_BUILDER);
    p2 = new Profiler(PROFILER_EXECUTE);

    db ??= this.db;

    p1.start();
    {
      values.remove(table.primaryKey);
      values = _convertMap2DbMap(values);
      
      final sqlBuilder = SqlBuilder.insert(
        name,
        values,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm,
      );
      // _parseSqlBuilder(sqlBuilder);
      sql = sqlBuilder.sql;
      arguments = sqlBuilder.arguments;
      
      result.sql = sql = _parseSql(sql, arguments);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await db.rawInsert(sql, arguments);
    p2.stop();
    
    _debugRequest(
      sql: sql,
      result: result,
      logger: logger,
    );
    return result;
  }

  @override
  Future<RawInsertRequestResult> insertAll(
    List<String> columns,
    List<List<Object?>> list, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,

      DatabaseExecutor? db,
      LoggerContext? logger,
  }) async {
    _throwIfDisposed();

    final result = new RawInsertRequestResult(
      transactionId: ++lastTransactionId,
      stackTrace: StackTrace.current,
    );
    String sql;
    final List<Object?> arguments = [];
    final Profiler p1, p2;

    p1 = new Profiler(PROFILER_BUILDER);
    p2 = new Profiler(PROFILER_EXECUTE);

    db ??= this.db;

    p1.start();
    {
      for(int i = 0; i < list.length; i++) {
        list[i].remove(table.primaryKey);
        list[i] = _convertList2DbList(list[i]);
      }
      
      {
        final sb = new StringBuffer();
        sb.write("INSERT INTO '$name'");

        {
          sb.write(" (");
          int i = 0;
          for(final column in columns) {
            if(i++ > 0)
              sb.write(", ");
            sb.write("'$column'");
          }
          sb.write(")");
        }

        sb.write(" VALUES");
        {
          int i = 0;
          for(final values in list) {
            if(i++ > 0)
              sb.write(", ");

            sb.write("(");
            int n = 0;
            for(final value in values) {
              if(n++ > 0)
                sb.write(", ");
              sb.write("?");
              arguments.add(value);
            }
            sb.write(")");
          }
        }
        sql = sb.toString();
      }
      result.sql = sql = _parseSql(sql, arguments);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await db.rawInsert(sql, arguments);
    p2.stop();
    
    _debugRequest(
      sql: sql,
      result: result,
      logger: logger,
    );
    return result;
  }

  @override
  Future<RawUpdateRequestResult> update(
    Map<String, dynamic> values, {
      String? where,
      List<Object?>? whereArgs,
      ConflictAlgorithm? conflictAlgorithm,

      DatabaseExecutor? db,
      LoggerContext? logger,
  }) async {
    _throwIfDisposed();

    final result = new RawUpdateRequestResult(
      transactionId: ++lastTransactionId,
      stackTrace: StackTrace.current,
    );
    String sql;
    final List<Object?>? arguments;
    final Profiler p1, p2;

    p1 = new Profiler(PROFILER_BUILDER);
    p2 = new Profiler(PROFILER_EXECUTE);

    db ??= this.db;

    p1.start();
    {
      values = _convertMap2DbMap(values);
      final sqlBuilder = SqlBuilder.update(
        name,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm,
      );
      // _parseSqlBuilder(sqlBuilder);
      sql = sqlBuilder.sql;
      arguments = sqlBuilder.arguments;
      
      result.sql = sql = _parseSql(sql, arguments);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await db.rawUpdate(sql, arguments);
    p2.stop();
    
    _debugRequest(
      sql: sql,
      result: result,
      logger: logger,
    );
    return result;
  }

  @override
  Future<RawInsertRequestResult> updateAll(
    List<String> columns,
    List<List<Object?>> list, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,

      DatabaseExecutor? db,
      LoggerContext? logger,
  }) async {
    _throwIfDisposed();

    final result = new RawInsertRequestResult(
      transactionId: ++lastTransactionId,
      stackTrace: StackTrace.current,
    );
    String sql;
    final List<Object?> arguments = [];
    final Profiler p1, p2;

    p1 = new Profiler(PROFILER_BUILDER);
    p2 = new Profiler(PROFILER_EXECUTE);

    db ??= this.db;

    p1.start();
    {
      for(int i = 0; i < list.length; i++) {
        list[i] = _convertList2DbList(list[i]);
      }
      
      {
        final sb = new StringBuffer();
        sb.write("INSERT INTO '$name'");

        {
          sb.write(" (");
          int i = 0;
          for(final column in columns) {
            if(i++ > 0)
              sb.write(", ");
            sb.write(column);
          }
          sb.write(")");
        }

        sb.write(" VALUES");
        {
          int i = 0;
          for(final values in list) {
            if(i++ > 0)
              sb.write(", ");

            sb.write("(");
            int n = 0;
            for(final value in values) {
              if(n++ > 0)
                sb.write(", ");
              sb.write("?");
              arguments.add(value);
              // sb.write((_parseArgument(value)));
            }
            sb.write(")");
          }
        }

        // sb.write(" ON DUPLICATE KEY UPDATE ");
        sb.write(" ON CONFLICT(${columns[0]}) DO UPDATE SET ");
        {
          int i = 0;
          for(final column in columns) {
            if(i++ > 0)
              sb.write(", ");
            // sb.write("$column=VALUES($column)");
            sb.write("$column=excluded.$column");
          }
        }



        sql = sb.toString();
      }

      result.sql = sql = _parseSql(sql, arguments);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await db.rawInsert(sql, arguments);
    p2.stop();
    
    _debugRequest(
      sql: sql,
      result: result,
      logger: logger,
    );
    return result;
  }

  @override
  Future<RawUpdateRequestResult> rawUpdate(
    String sql, {
      List<Object?>? arguments,

      DatabaseExecutor? db,
      LoggerContext? logger,
  }) async {
    _throwIfDisposed();

    final result = new RawUpdateRequestResult(
      transactionId: ++lastTransactionId,
      stackTrace: StackTrace.current,
    );
    final Profiler p1, p2;

    p1 = new Profiler(PROFILER_BUILDER);
    p2 = new Profiler(PROFILER_EXECUTE);

    db ??= this.db;

    p1.start();
    {
      result.sql = sql = _parseSql(sql, arguments);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await db.rawUpdate(sql, arguments);
    p2.stop();
    
    _debugRequest(
      sql: sql,
      result: result,
      logger: logger,
    );
    return result;
  }

  @override
  Future<RawDeleteRequestResult> delete({
    String? where,
    List<Object?>? whereArgs,

    DatabaseExecutor? db,
    LoggerContext? logger,
  }) async {
    _throwIfDisposed();

    final result = new RawDeleteRequestResult(
      transactionId: ++lastTransactionId,
      stackTrace: StackTrace.current,
    );
    String sql;
    final List<Object?>? arguments;
    final Profiler p1, p2;

    p1 = new Profiler(PROFILER_BUILDER);
    p2 = new Profiler(PROFILER_EXECUTE);

    db ??= this.db;

    p1.start();
    {
      whereArgs = _fixWhereArgs(whereArgs);
      final sqlBuilder = SqlBuilder.delete(
        name,
        where: where,
        whereArgs: whereArgs,
      );
      // _parseSqlBuilder(sqlBuilder);
      sql = sqlBuilder.sql;
      arguments = sqlBuilder.arguments;
      
      result.sql = sql = _parseSql(sql, arguments);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await db.rawDelete(sql, arguments);
    p2.stop();
    
    _debugRequest(
      sql: sql,
      result: result,
      logger: logger,
    );
    return result;
  }

  @override
  Future<bool> drop({
    
    DatabaseExecutor? db,
  }) async {
    _throwIfDisposed();

    db ??= this.db;

    await db.execute("DROP TABLE IF EXISTS $name");
    
    // _debugRequest(
    //   sql: sql,
    //   result: result,
    //   pConvert: p1,
    //   pRequest: p2,
    //   logger: logger,
    // );
    dispose();
    return true;
  }

  @override
  Future<List<String>> toStringTable({
    int size = 999,
    offset = 0,
  }) async {
    _throwIfDisposed();

    final List<String> out = [];
    final result = await query(
      limit: size,
      offset: offset
    );

    StringBuffer sb;
    for(final e in result.output) {
      sb = new StringBuffer();
      sb.writeln("[");
      e.forEach((k, v) {
        sb.writeln("\t" + k + ' = "' + v.toString() + '"');
      });
      sb.writeln("");
      out.add(sb.toString());
    }
    // StringBuffer sb = new StringBuffer();
    // list.forEach((e) {
    //   sb.writeln("[");
    //   e.forEach((k, v) {
    //     sb.writeln("\t" + k + ' = "' + v.toString() + '"');
    //   });
    //   sb.writeln("");
    // });
    return out;
  }


  void _throwIfDisposed() {
    if(disposed)
      throw(new Exception("Table was disposed"));
  }
  

  @override
  String toString() => "RawTable(name = $name, db = $db)";


  void _debugRequest({
    required String sql,
    required RequestDetails result,
    required LoggerContext? logger,
  }) {
    if(logger == null)
      return;
    logger.debug("", sql);
  }

  // static void _parseSqlBuilder(SqlBuilder builder) {
  //   // final arguments = builder.arguments;
  //   // for(int i = 0; i < (arguments?.length ?? 0); i++) {
  //   //   arguments![i] = _parseArgument(arguments[i]);
  //   // }
  //   final arguments = builder.arguments;
    
  //   if(arguments?.isEmpty ?? true)
  //     return;
  //   int length = arguments!.length;
  //   int i = 0;
  //   builder.sql = builder.sql.replaceAllMapped("?", (match) {
  //     if(i >= length)
  //       return "?";
  //     final value = _parseArgument(arguments[i++]);
  //     return value == null ? "?" : value.toString();
  //   });
  // }

  static String _parseSql(String sql, List<Object?>? arguments) {
    if(arguments?.isEmpty ?? true)
      return sql;
    arguments!;
    final List<Object?> toSave = List.filled(arguments.length, null);
    int argN = -1, listN = 0;
    // TODO REMOVE TEST
    // debugger(when: sql.contains("INSERT INTO 'strategyDatas' (qid, coinId, columnId, value) VALUES"));
    // debugger(when: sql.contains("SELECT qid FROM coins WHERE qid >"));
    sql = sql.replaceAllMapped("?", (match) {
      if(arguments.isEmpty)
        return "?";
      argN++;
      final value = _parseArgument(arguments[argN]);
      if(value == null) {
        toSave[listN++] = arguments[argN];
        return "?";
      } return value.toString();
    });
    arguments.clear();
    arguments.addAll(toSave.getRange(0, listN));
    return sql;
  }

  static Object? _parseArgument(Object? arg) {
    if(arg == null)
      return "NULL";
    else if(arg is String)
      return "'$arg'";
    else if(arg is int || arg is num)
      return arg.toString();
    else if(arg is Uint8List)
      return null;
    else if(arg is List) {
      return _parseCustomArgument(arg);
    } else throw(new Exception("Wrong type of argument; instance of ${arg.runtimeType}"));
  }

  static String _parseCustomArgument(Object? arg) {
    if(arg == null)
      return "NULL";
    else if(arg is String)
      return "'$arg'";
    else if(arg is int || arg is num)
      return arg.toString();
    else if(arg is List) {
      final sb = new StringBuffer();
      final last = arg.length - 1;
      for(int i = 0; i < arg.length; i++) {
        sb.write(_parseCustomArgument(arg[i]));
        if(i < last)
          sb.write(", ");
      } return sb.toString();
    } else throw(new Exception("Wrong type of argument; instance of ${arg.runtimeType}"));
  }




  // Converting:
  // - bool -> int
  static Map<String, dynamic> _convertMap2DbMap(Map<String, dynamic> map) {
    final Map<String, dynamic> out = {};
    for(final entry in map.entries) {
      final k = entry.key;
      final v = entry.value;
      if(v is bool)
        out[k] = v ? 1 : 0;
      else if(v is String || v is int || v is num || v == null)
        out[k] = v;
      else throw(new Exception("Wrong type of value; map[$k] = instance of ${v.runtimeType}"));
    } return out;
  }

  static List<dynamic> _convertList2DbList(List<dynamic> list) {
    final List<dynamic> out = [];
    for(int i = 0; i < list.length; i++) {
      final v = list[i];
      if(v is bool)
        out.add(v ? 1 : 0);
      else if(v is String || v is int || v is num || v == null)
        out.add(v);
      else if(v is Uint8List)
        out.add(v);
      else throw(new Exception("Wrong type of value; list[$i] = instance of ${v.runtimeType}"));
    } return out;
  }

  static List<Object?>? _fixWhereArgs(List<Object?>? list) {
    if(list == null)
      return null;
    list = list.toList();

    // MIGRATED TO _parseSql
    // Logger.d("in = " + list.toString());
    // for(int i = 0; i < list.length; i++) {
    //   if(list[i] is List) {
    //     list[i] = NeonDatabase.listToSqlList(list[i]! as List<Object>);
    //   }
    // }
    // Logger.d("out = " + list.toString());
    return list;
  }
  
  
}