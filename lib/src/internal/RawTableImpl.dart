import 'dart:typed_data';

import 'package:ientity/library.dart';
import 'package:itable_ex/src/external/DatabaseExecutor.dart';
import 'package:itable_ex/src/external/ISqlBuilder.dart';
import 'package:itable_ex/src/external/ITableEx.dart';
import 'package:itable_ex/src/external/RawTable/RawTable.dart';
import 'package:itable_ex/src/external/RawTable/results/RawDeleteRequestResult.dart';
import 'package:itable_ex/src/external/RawTable/results/RawDropTableRequestResult.dart';
import 'package:itable_ex/src/external/RawTable/results/RawInsertRequestResult.dart';
import 'package:itable_ex/src/external/RawTable/results/RawQueryRequestResult.dart';
import 'package:itable_ex/src/external/RawTable/results/RawUpdateRequestResult.dart';
import 'package:itable_ex/src/external/RawTable/results/RequestDetails.dart';
import 'package:logger_ex/library.dart';
import 'package:true_core/library.dart';

class RawTableImpl extends RawTable {
  static const String PROFILER_BUILDER    = "building";
  static const String PROFILER_EXECUTE    = "requesting";

  @override
  final String name;

  @override
  int lastTransactionId = 0;
  
  @override
  bool disposed = false;

  final DatabaseExecutor database;
  final ITableEx table;

  RawTableImpl({
    required this.name,
    required this.database,
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

    DatabaseExecutor? database,
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

    database ??= this.database;

    p1.start();
    {
      whereArgs = _fixWhereArgs(whereArgs);
      
      final builder = database.sqlBuilder.query(
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
      sql = builder.sql;
      arguments = builder.arguments;
      
      result.sql = sql = _parseSql(sql, arguments: arguments, whereArgsLength: whereArgs?.length ?? 0);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await database.rawQuery(sql, arguments);
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

      DatabaseExecutor? database,
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

    database ??= this.database;

    p1.start();
    {
      result.sql = sql = _parseSql(sql, arguments: arguments);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await database.rawQuery(sql, arguments);
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
    Map<String, dynamic> values, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,

      DatabaseExecutor? database,
      LoggerContext? logger,
  }) async {
    _throwIfDisposed();

    if(values.keys.contains(table.primaryKey.name))
      // values.remove(table.primaryKey.name);
      throw(Exception("values contains PK ${table.primaryKey}"));

    final result = new RawInsertRequestResult(
      transactionId: ++lastTransactionId,
      stackTrace: StackTrace.current,
    );
    String sql;
    final List<Object?>? arguments;
    final Profiler p1, p2;

    p1 = new Profiler(PROFILER_BUILDER);
    p2 = new Profiler(PROFILER_EXECUTE);

    database ??= this.database;

    p1.start();
    {
      _transformRuntimeType(values);
      
      final builder = database.sqlBuilder.insert(
        name,
        values,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm,
      );
      sql = builder.sql;
      arguments = builder.arguments;
      
      result.sql = sql = _parseSql(sql, arguments: arguments, doNotParse: true);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await database.rawInsert(sql, arguments);
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

      DatabaseExecutor? database,
      LoggerContext? logger,
  }) async {
    _throwIfDisposed();

    if(columns.contains(table.primaryKey.name))
      columns.remove(table.primaryKey.name);
      // throw(Exception("columns contains PK ${table.primaryKey}"));


    final result = new RawInsertRequestResult(
      transactionId: ++lastTransactionId,
      stackTrace: StackTrace.current,
    );
    String sql;
    final List<Object?>? arguments;
    final Profiler p1, p2;

    p1 = new Profiler(PROFILER_BUILDER);
    p2 = new Profiler(PROFILER_EXECUTE);

    database ??= this.database;

    p1.start();
    {
      {
        final cols = columns.map((e) => table.columns.firstWhere((e2) => e2.name == e)).toList();
        for(int i = 0; i < list.length; i++) {
          _transformRuntimeType2(cols, list[i]);
        }
      }
      
      final builder = database.sqlBuilder.insertAll(
        name,
        columns,
        list,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm,
      );
      sql = builder.sql;
      arguments = builder.arguments;

      result.sql = sql = _parseSql(sql, arguments: arguments, doNotParse: true);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await database.rawInsert(sql, arguments);
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

      DatabaseExecutor? database,
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

    database ??= this.database;

    p1.start();
    {
      _transformRuntimeType(values);
      
      final builder = database.sqlBuilder.update(
        name,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm,
      );
      sql = builder.sql;
      arguments = builder.arguments;
      
      result.sql = sql = _parseSql(sql, arguments: arguments, doNotParse: true);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await database.rawUpdate(sql, arguments);
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

      DatabaseExecutor? database,
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

    database ??= this.database;

    p1.start();
    {
      {
        final cols = columns.map((e) => table.columns.firstWhere((e2) => e2.name == e)).toList();
        for(int i = 0; i < list.length; i++) {
          _transformRuntimeType2(cols, list[i]);
        }
      }
      
      final builder = database.sqlBuilder.updateAll(
        name,
        columns,
        list,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm,
      );
      sql = builder.sql;
      arguments = builder.arguments;

      result.sql = sql = _parseSql(sql, arguments: arguments, doNotParse: true);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await database.rawInsert(sql, arguments);
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

      DatabaseExecutor? database,
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

    database ??= this.database;

    p1.start();
    {
      result.sql = sql = _parseSql(sql, arguments: arguments);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await database.rawUpdate(sql, arguments);
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

    DatabaseExecutor? database,
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

    database ??= this.database;

    p1.start();
    {
      whereArgs = _fixWhereArgs(whereArgs);

      final builder = database.sqlBuilder.delete(
        name,
        where: where,
        whereArgs: whereArgs,
      );
      sql = builder.sql;
      arguments = builder.arguments;
      
      result.sql = sql = _parseSql(sql, arguments: arguments, whereArgsLength: whereArgs?.length ?? 0);
      result.pConvert = p1;
      result.pRequest = p2;
    }
    p1.stop();

    p2.start();
    result.output = await database.rawDelete(sql, arguments);
    p2.stop();
    
    _debugRequest(
      sql: sql,
      result: result,
      logger: logger,
    );
    return result;
  }

  @override
  Future<RawDropTableRequestResult> drop({
    
    DatabaseExecutor? database,
  }) async {
    _throwIfDisposed();

    final result = new RawDropTableRequestResult(
      transactionId: ++lastTransactionId,
      stackTrace: StackTrace.current,
    );

    database ??= this.database;

    await database.execute("DROP TABLE IF EXISTS $name");
    result.output = true;
    
    // _debugRequest(
    //   sql: sql,
    //   result: result,
    //   pConvert: p1,
    //   pRequest: p2,
    //   logger: logger,
    // );
    dispose();
    return result;
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
  String toString() => "RawTable(name = $name, database = $database)";


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

  void _transformRuntimeType(Map<String, dynamic> map) {
    for(final entry in map.entries) {
      final column = table.columns.firstWhere((e) => e.name == entry.key);
      map[entry.key] = database.transformRuntimeType(column, entry.value);
    }
  }

  void _transformRuntimeType2(List<EntityColumnInfo> columns, List<Object?> arguments) {
    for(int i = 0; i < arguments.length; i++) {
      final value = arguments[i];
      arguments[i] = database.transformRuntimeType(columns[i], value);
    }
  }

  // Map<String, dynamic> _tra(Map<String, dynamic> map) {
  //   final Map<String, dynamic> out = {};
  //   for(final entry in map.entries) {
  //     final k = entry.key;
  //     final v = entry.value;
  //     if(v is bool)
  //       out[k] = v ? 1 : 0;
  //     else if(v is String || v is int || v is num || v == null)
  //       out[k] = v;
  //     else if(v is Uint8List)
  //       out[k] = v;
  //     else throw(new Exception("Wrong type of value; map[$k] = instance of ${v.runtimeType}"));
  //   } return out;
  // }

  String _parseSql(
    String sql, {
      int whereArgsLength = 0,
      bool doNotParse = false,
      required List<Object?>? arguments,
  }) {
    if(arguments?.isEmpty ?? true)
      return sql;
    // arguments = arguments!.getRange(whereArgsLength, arguments.length).toList();
    arguments!;

    int i = -1;
    sql = sql.replaceAllMapped("?", (match) {
      final argument = arguments[++i];
      if(i + 1 <= whereArgsLength)
        return argument!.toString();
      
      // if(doNotParse)
      //   return argument!.toString();
      final value = _parseArg(argument);
      if(value == null)
        return "NULL"; //argument.runtimeType.toString();
      // throw(Exception("Unknown type of argument; instance of ${argument.runtimeType}"));
      return value.toString();
    });
    if(i >= 0)
      arguments.removeRange(0, i + 1);
    return sql;
  }

  static Object? _parseArg(
    Object? arg, {
      bool allowedNestedList = true,
  }) {
    if(arg == null)
      return "NULL";
    else if(arg is String)
      return "'$arg'";
    else if(arg is int || arg is num)
      return arg.toString();
    else if(arg is Uint8List)
      return null;
    else if(arg is List) {
      if(allowedNestedList) {
        final sb = new StringBuffer();
        final last = arg.length - 1;
        for(int i = 0; i < arg.length; i++) {
          sb.write(_parseArg(arg[i], allowedNestedList: false));
          if(i < last)
            sb.write(", ");
        } return sb.toString();
      } else throw(new Exception("Multiple nested list $arg"));
    } else throw(new Exception("Wrong type of argument; instance of ${arg.runtimeType}"));
  }

  // static Object? _parseArgument(Object? arg) {
  //   if(arg == null)
  //     return "NULL";
  //   else if(arg is String)
  //     return "'$arg'";
  //   else if(arg is int || arg is num)
  //     return arg.toString();
  //   else if(arg is Uint8List)
  //     return null;
  //   else if(arg is List) {
  //     return _parseCustomArgument(arg);
  //   } else throw(new Exception("Wrong type of argument; instance of ${arg.runtimeType}"));
  // }

  // static String _parseCustomArgument(Object? arg) {
  //   if(arg == null)
  //     return "NULL";
  //   else if(arg is String)
  //     return "'$arg'";
  //   else if(arg is int || arg is num)
  //     return arg.toString();
  //   else if(arg is List) {
  //     final sb = new StringBuffer();
  //     final last = arg.length - 1;
  //     for(int i = 0; i < arg.length; i++) {
  //       sb.write(_parseCustomArgument(arg[i]));
  //       if(i < last)
  //         sb.write(", ");
  //     } return sb.toString();
  //   } else throw(new Exception("Wrong type of argument; instance of ${arg.runtimeType}"));
  // }




  // Converting:
  // - bool -> int
  // static Map<String, dynamic> _convertMap2DbMap(Map<String, dynamic> map) {
  //   final Map<String, dynamic> out = {};
  //   for(final entry in map.entries) {
  //     final k = entry.key;
  //     final v = entry.value;
  //     if(v is bool)
  //       out[k] = v ? 1 : 0;
  //     else if(v is String || v is int || v is num || v == null)
  //       out[k] = v;
  //     else if(v is Uint8List)
  //       out[k] = v;
  //     else throw(new Exception("Wrong type of value; map[$k] = instance of ${v.runtimeType}"));
  //   } return out;
  // }

  // static List<dynamic> _convertList2DbList(List<dynamic> list) {
  //   final List<dynamic> out = [];
  //   for(int i = 0; i < list.length; i++) {
  //     final v = list[i];
  //     if(v is bool)
  //       out.add(v ? 1 : 0);
  //     else if(v is String || v is int || v is num || v == null)
  //       out.add(v);
  //     else if(v is Uint8List)
  //       out.add(v);
  //     else throw(new Exception("Wrong type of value; list[$i] = instance of ${v.runtimeType}"));
  //   } return out;
  // }

  static List<Object?>? _fixWhereArgs(List<Object?>? args) {
    if(args == null)
      return null;
      
    final List<Object?> output = [];
    for(int i = 0; i < args.length; i++) {
      final arg = args[i];
      if(arg is List) {
        // final List<Object> list = [];
        
        // for(final v in arg) {
        //   if(v == null)
        //     list.add("NULL");
        //   else if(v is String)
        //     list.add(v);
        //   else if(v is int || arg is num)
        //     list.add(v.toString());
        //   else throw(Exception("Unknown whereArgs type ${v.runtimeType}"));
        // }
        output.add(_parseArg(arg));
      } else if(arg is String) {
        output.add("'$arg'");
      } else output.add(arg);
    } return output;
  }
}