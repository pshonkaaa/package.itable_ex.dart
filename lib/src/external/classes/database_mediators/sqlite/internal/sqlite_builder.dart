import 'package:itable_ex/library.dart';

class SqliteBuilder extends DefaultSqlBuilder {
  @override
  SqlRequest updateAll(
    String table,
    List<String> columns,
    List<List<Object?>> values, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,
  }) {
    if(values.isEmpty || columns.isEmpty)
      throw ArgumentError('values and columns shouldnt be empty');
    for(int i = 0; i < values.length; i++) {
      if(values[i].length != columns.length)
        throw ArgumentError('values[$i] has different length');
    }

    final StringBuffer buffer = StringBuffer();
    final List<Object?> arguments = [];
    
    buffer.write('INSERT');
    
    if(conflictAlgorithm != null)
      buffer.write(' ${conflictAlgorithm.convert()}');

    buffer.write(' INTO ');
    buffer.write(escapeName(table));


    arguments.addAll(DefaultSqlBuilder.writeValues(buffer, columns, values));

    {
      buffer.write(" ON CONFLICT(${columns[0]}) DO UPDATE SET ");
      
      for(int i = 0; i < columns.length; i++) {
        final column = columns[i];
        if(i > 0)
          buffer.write(", ");
        buffer.write("$column=excluded.$column");
      }
    }

    return SqlRequest(
      sql: buffer.toString(),
      arguments: arguments,
    );
  }
}