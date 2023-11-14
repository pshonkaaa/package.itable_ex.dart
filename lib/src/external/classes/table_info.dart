import 'package:ientity/library.dart';

class TableInfo {
  final String table;
  final List<ColumnInfo> columns;
  const TableInfo({
    required this.table,
    required this.columns,
  });
}