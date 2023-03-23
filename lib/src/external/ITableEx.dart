import 'package:ientity/library.dart';
import 'package:itable_ex/src/internal/TableExecutorImpl.dart';

import 'DatabaseExecutor.dart';
import 'TableExecutor/TableExecutor.dart';

abstract class ITableEx extends ITable {
  late final TableExecutorImpl _executor;

  final DatabaseExecutor _database;

  ITableEx({
    required String name,
    required List<EntityColumnInfo> columns,

    required DatabaseExecutor database,
  }) : _database = database, super(
    name: name,
    columns: columns,
  );

  TableExecutor get executor => _executor;
  
  @override
  Future<void> initState() async {
    await super.initState();
    
    _executor = TableExecutorImpl(
      name: name,
      database: _database,
      table: this,
    );

    await _executor.initState();
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    
    await _executor.dispose();
  }
}
