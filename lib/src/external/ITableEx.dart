import 'package:ientity/library.dart';
import 'package:itable/library.dart';
import 'package:itable_ex/src/internal/RawTableImpl.dart';
import 'package:sqflite/sqflite.dart';

import 'RawTable/RawTable.dart';

abstract class ITableEx<PARAM> extends ITable<PARAM> {
  late final RawTable _raw;

  final Database _db;

  ITableEx({
    required String name,
    required List<ColumnInfo<PARAM>> columns,

    required Database db,
  }) : _db = db, super(
    name: name,
    columns: columns,
  );

  RawTable get raw => _raw;
  
  @override
  Future<void> initState() async {
    await super.initState();
    
    final raw = RawTableImpl(
      name: name,
      db: _db,
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
