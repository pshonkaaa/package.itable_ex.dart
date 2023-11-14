import 'package:itable_ex/library.dart';

/// SQL command builder.
class DefaultSqlBuilder implements ISqlBuilder {
  @override
  SqlRequest query(
    String table, {
      bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset,
  }) {
    if(groupBy == null && having != null)
      throw ArgumentError('HAVING clauses are only permitted when using a groupBy clause');
      
    checkWhereArgs(whereArgs);

    final StringBuffer buffer = StringBuffer();
    final List<Object?> arguments = [];

    buffer.write('SELECT ');

    if(distinct == true)
      buffer.write('DISTINCT ');
      
    if(columns == null || columns.isEmpty) {
      buffer.write('* ');
    } else {
      writeColumns(buffer, columns);
    }
    
    buffer.write('FROM ');
    buffer.write(escapeName(table));
    
    writeClause(buffer, ' WHERE ', where);
    writeClause(buffer, ' GROUP BY ', groupBy);
    writeClause(buffer, ' HAVING ', having);
    writeClause(buffer, ' ORDER BY ', orderBy);
    writeClause(buffer, ' LIMIT ', limit?.toString());
    writeClause(buffer, ' OFFSET ', offset?.toString());

    if(whereArgs != null)
      arguments.addAll(whereArgs);

    return SqlRequest(
      sql: buffer.toString(),
      arguments: arguments,
    );
  }
  
  @override
  SqlRequest insert(
    String table,
    Map<String, Object?> values, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,
  }) {
    if(values.isEmpty)
      throw ArgumentError('values shouldnt be empty');

    final StringBuffer buffer = StringBuffer();
    final List<Object?> arguments = [];
    
    buffer.write('INSERT');
    
    if(conflictAlgorithm != null)
      buffer.write(' ${conflictAlgorithm.convert()}');

    buffer.write(' INTO ');
    buffer.write(escapeName(table));

    arguments.addAll(writeValues(buffer, values.keys.toList(), [values.values.toList()]));

    return SqlRequest(
      sql: buffer.toString(),
      arguments: arguments,
    );
  }
  
  @override
  SqlRequest insertAll(
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


    arguments.addAll(writeValues(buffer, columns, values));

    return SqlRequest(
      sql: buffer.toString(),
      arguments: arguments,
    );
  }
  
  @override
  SqlRequest update(String table, Map<String, Object?> values,
      {String? where,
      List<Object?>? whereArgs,
      ConflictAlgorithm? conflictAlgorithm}) {
    if(values.isEmpty) {
      throw ArgumentError('Empty values');
    }
    checkWhereArgs(whereArgs);

    final StringBuffer buffer = StringBuffer();
    final List<Object?> arguments = [];

    buffer.write('UPDATE');

    if(conflictAlgorithm != null)
      buffer.write(' ${conflictAlgorithm.convert()}');
      
    buffer.write(' ${escapeName(table)}');
    buffer.write(' SET ');

    int i = 0;

    for (var colName in values.keys) {
      buffer.write((i++ > 0) ? ', ' : '');
      buffer.write(escapeName(colName));
      final value = values[colName];
      if(value != null) {
        checkNonNullValue(value);
        arguments.add(value);
        buffer.write(' = ?');
      } else {
        buffer.write(' = NULL');
      }
    }

    writeClause(buffer, ' WHERE ', where);

    if(whereArgs != null)
      arguments.addAll(whereArgs);

    return SqlRequest(
      sql: buffer.toString(),
      arguments: arguments,
    );
  }
  
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


    arguments.addAll(writeValues(buffer, columns, values));

    buffer.write(" AS new");

    {
      buffer.write(" ON DUPLICATE KEY UPDATE ");
      
      for(int i = 0; i < columns.length; i++) {
        final column = columns[i];
        if(i > 0)
          buffer.write(", ");
        buffer.write("$column=new.$column");
      }
    }

    return SqlRequest(
      sql: buffer.toString(),
      arguments: arguments,
    );
  }
  
  @override
  SqlRequest delete(String table, {String? where, List<Object?>? whereArgs}) {
    checkWhereArgs(whereArgs);

    final StringBuffer buffer = StringBuffer();
    final List<Object?> arguments = [];
    
    buffer.write('DELETE FROM ');
    buffer.write(escapeName(table));
    
    writeClause(buffer, ' WHERE ', where);

    if(whereArgs != null)
      arguments.addAll(whereArgs);

    return SqlRequest(
      sql: buffer.toString(),
      arguments: arguments,
    );
  }

  /// Add the names that are non-null in columns to s, separating
  /// them with commas.
  static void writeColumns(
    StringBuffer buffer,
    List<String> columns,
  ) {
    final length = columns.length;

    for (int i = 0; i < length; i++) {
      final column = columns[i];

      if(i > 0) {
        buffer.write(', ');
      } buffer.write(escapeName(column));
    } buffer.write(' ');
  }

  static List<Object?> writeValues(
    StringBuffer buffer,
    List<String> columns,
    List<List<Object?>> list
  ) {
    final List<Object> args = [];

    final tmpBuffer = StringBuffer();

    tmpBuffer.write(" (");
    for(int i = 0; i < columns.length; i++) {
      final column = columns[i];
      
      if(i > 0)
        tmpBuffer.write(", ");
      tmpBuffer.write(escapeName(column));
    } tmpBuffer.write(")");

    tmpBuffer.write(' VALUES ');

    for(int i = 0; i < list.length; i++) {
      final values = list[i];
      if(i > 0)
        tmpBuffer.write(', ');

      tmpBuffer.write("(");

      for(int i = 0; i < values.length; i++) {
        final value = values[i];
        if(i > 0)
          tmpBuffer.write(', ');

        if(value == null) {
          tmpBuffer.write('NULL');
        } else {
          checkNonNullValue(value);
          args.add(value);
          tmpBuffer.write('?');
        }
      } tmpBuffer.write(')');
    }
    
    buffer.write(tmpBuffer);

    return args;
  }

  static void writeClause(StringBuffer buffer, String name, String? clause) {
    if(clause != null) {
      buffer.write(name);
      buffer.write(clause);
    }
  }
}

/// True if a name had been escaped already.
bool isEscapedName(String name) {
  if(name.length >= 2) {
    final codeUnits = name.codeUnits;
    if(_areCodeUnitsEscaped(codeUnits)) {
      return escapeNames
          .contains(name.substring(1, name.length - 1).toLowerCase());
    }
  }
  return false;
}

// The actual escape implementation
// We use double quote, although backtick could be used too
String _doEscape(String name) => '"$name"';

/// Escape a table or column name if necessary.
///
/// i.e. if it is an identified it will be surrounded by " (double-quote)
/// Only some name belonging to keywords can be escaped
String escapeName(String name) {
  if(escapeNames.contains(name.toLowerCase()))
    return _doEscape(name);
  return name;
}

/// Unescape a table or column name.
String unescapeName(String name) {
  if(isEscapedName(name)) {
    return name.substring(1, name.length - 1);
  }
  return name;
}

/// Escape a column name if necessary.
///
/// Only for insert and update keys
String escapeEntityName(String name) {
  if(_entityNameNeedEscape(name)) {
    return _doEscape(name);
  }
  return name;
}

const _lowercaseA = 0x61;
const _lowercaseZ = 0x7A;

const _underscore = 0x5F;
const _digit0 = 0x30;
const _digit9 = 0x39;

const _backtick = 0x60;
const _doubleQuote = 0x22;
const _singleQuote = 0x27;

const _uppercaseA = 0x41;
const _uppercaseZ = 0x5A;

/// Returns `true` if [codeUnit] represents a digit.
///
/// The definition of digit matches the Unicode `0x3?` range of Western
/// European digits.
bool _isDigit(int codeUnit) => codeUnit >= _digit0 && codeUnit <= _digit9;

/// Returns `true` if [codeUnit] represents matchs azAZ_.
bool _isAlphaOrUnderscore(int codeUnit) =>
    (codeUnit >= _lowercaseA && codeUnit <= _lowercaseZ) ||
    (codeUnit >= _uppercaseA && codeUnit <= _uppercaseZ) ||
    codeUnit == _underscore;

/// True if already escaped
bool _areCodeUnitsEscaped(List<int> codeUnits) {
  if(codeUnits.isNotEmpty) {
    final first = codeUnits.first;
    switch (first) {
      case _doubleQuote:
      case _backtick:
        final last = codeUnits.last;
        return last == first;
      case _singleQuote:
      // not yet
    }
  }
  return false;
}

bool _entityNameNeedEscape(String name) {
  /// We need to escape if not escaped yet and if not a valid keyword
  if(escapeNames.contains(name.toLowerCase())) {
    return true;
  }

  final codeUnits = name.codeUnits;

  // Must start with a alpha or underscode
  if(!_isAlphaOrUnderscore(codeUnits.first)) {
    return true;
  }
  for (var i = 1; i < codeUnits.length; i++) {
    final codeUnit = codeUnits[i];
    if(!_isAlphaOrUnderscore(codeUnit) && !_isDigit(codeUnit)) {
      return true;
    }
  }

  return false;
}

/// Unescape a table or column name.
String unescapeValueKeyName(String name) {
  final codeUnits = name.codeUnits;
  if(_areCodeUnitsEscaped(codeUnits)) {
    return name.substring(1, name.length - 1);
  }
  return name;
}










void _checkArg(dynamic arg) {
//   if((arg is! String) && (arg is! num) && (arg is! Uint8List)) {
//     final type = arg.runtimeType.toString();

//     final text = '''
// *** WARNING ***

// Invalid argument $arg with type $type.
// Only num, String and Uint8List are supported. See https://github.com/tekartik/sqflite/blob/master/sqflite/doc/supported_types.md for details

// This will throw an exception in the future. For now it is displayed once per type.

//     ''';
//     throw ArgumentError(text);
//   }
}

/// Check the value is valid. test for non null only;
void checkNonNullValue(dynamic value) {
  if(isDebug) {
    _checkArg(value);
  }
}

/// Check whether the args are valid in raw statement. null is supported here
void checkRawArgs(List<dynamic>? args) {
  if(isDebug && args != null) {
    for (var arg in args) {
      if(arg != null) {
        _checkArg(arg);
      }
    }
  }
}

/// Check whether the where args are valid. null is not supported here.
void checkWhereArgs(List<dynamic>? args) {
  // if(isDebug && args != null) {
  //   for (var arg in args) {
  //     _checkArg(arg);
  //   }
  // }
}



bool? _isRelease;

// http://stackoverflow.com/questions/29592826/detect-during-runtime-whether-the-application-is-in-release-mode-or-not

/// Check whether in release mode
bool get isRelease {
  if(_isRelease == null) {
    _isRelease = true;
    assert(() {
      _isRelease = false;
      return true;
    }());
  }
  return _isRelease!;
}

/// Check whether running in debug mode
bool get isDebug => !isRelease;
