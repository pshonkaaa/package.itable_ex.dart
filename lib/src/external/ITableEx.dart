import 'package:ientity/library.dart';
import 'package:itable_ex/src/internal/RawTableImpl.dart';

import 'DatabaseExecutor.dart';
import 'RawTable/RawTable.dart';

abstract class ITableEx extends ITable {
  late final RawTable _raw;

  final DatabaseExecutor _database;

  ITableEx({
    required String name,
    required List<EntityColumnInfo> columns,

    required DatabaseExecutor database,
  }) : _database = database, super(
    name: name,
    columns: columns,
  );

  RawTable get raw => _raw;
  
  @override
  Future<void> initState() async {
    await super.initState();
    
    final raw = RawTableImpl(
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
    
    final raw = this.raw as RawTableImpl;
    await raw.dispose();
  }
}
