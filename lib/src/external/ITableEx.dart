import 'package:ientity/library.dart';
import 'package:itable_ex/src/internal/TableExecutorImpl.dart';

import 'DatabaseExecutor.dart';
import 'TableExecutor/TableExecutor.dart';

abstract class ITableEx extends ITable {
  late final TableExecutorImpl _raw;

  final DatabaseExecutor _database;

  ITableEx({
    required String name,
    required List<EntityColumnInfo> columns,

    required DatabaseExecutor database,
  }) : _database = database, super(
    name: name,
    columns: columns,
  );

  TableExecutor get raw => _raw;
  
  @override
  Future<void> initState() async {
    await super.initState();
    
    final raw = TableExecutorImpl(
      name: name,
      database: _database,
      table: this,
    );

    await raw.initState();
    _raw = raw;
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    
    await _raw.dispose();
  }
}
