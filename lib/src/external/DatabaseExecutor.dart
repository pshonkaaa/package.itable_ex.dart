import 'package:ientity/library.dart';
import 'package:itable_ex/library.dart';

abstract class DatabaseExecutor {

  ISqlBuilder get sqlBuilder;

  Future<List<String>> getTables();
  
  Future<TableInfo> getTableInfo(String name);

  Object transformRuntimeType<T>(EntityColumnInfo column, T argument);

  /// Execute an SQL query with no return value.
  ///
  /// ```
  ///   await db.execute(
  ///   'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
  /// ```
  Future<Object> execute(String sql, [List<Object?>? arguments]);

  /// Executes a raw SQL INSERT query and returns the last inserted row ID.
  ///
  /// ```
  /// int id1 = await database.rawInsert(
  ///   'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
  /// ```
  ///
  /// 0 could be returned for some specific conflict algorithms if not inserted.
  Future<int> rawInsert(
    String sql, [
      List<Object?>? arguments,
  ]);

  // /// This method helps insert a map of [values]
  // /// into the specified [table] and returns the
  // /// id of the last inserted row.
  // ///
  // /// ```
  // ///    var value = {
  // ///      'age': 18,
  // ///      'name': 'value'
  // ///    };
  // ///    int id = await db.insert(
  // ///      'table',
  // ///      value,
  // ///      conflictAlgorithm: ConflictAlgorithm.replace,
  // ///    );
  // /// ```
  // ///
  // /// 0 could be returned for some specific conflict algorithms if not inserted.
  // Future<int> insert(String table, Map<String, Object?> values,
  //     {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm});

  // /// This is a helper to query a table and return the items found. All optional
  // /// clauses and filters are formatted as SQL queries
  // /// excluding the clauses' names.
  // ///
  // /// [table] contains the table names to compile the query against.
  // ///
  // /// [distinct] when set to true ensures each row is unique.
  // ///
  // /// The [columns] list specify which columns to return. Passing null will
  // /// return all columns, which is discouraged.
  // ///
  // /// [where] filters which rows to return. Passing null will return all rows
  // /// for the given URL. '?'s are replaced with the items in the
  // /// [whereArgs] field.
  // ///
  // /// [groupBy] declares how to group rows. Passing null
  // /// will cause the rows to not be grouped.
  // ///
  // /// [having] declares which row groups to include in the cursor,
  // /// if row grouping is being used. Passing null will cause
  // /// all row groups to be included, and is required when row
  // /// grouping is not being used.
  // ///
  // /// [orderBy] declares how to order the rows,
  // /// Passing null will use the default sort order,
  // /// which may be unordered.
  // ///
  // /// [limit] limits the number of rows returned by the query.
  // ///
  // /// [offset] specifies the starting index.
  // ///
  // /// ```
  // ///  List<Map> maps = await db.query(tableTodo,
  // ///      columns: ['columnId', 'columnDone', 'columnTitle'],
  // ///      where: 'columnId = ?',
  // ///      whereArgs: [id]);
  // /// ```
  // Future<List<Map<String, Object?>>> query(String table,
  //     {bool? distinct,
  //     List<String>? columns,
  //     String? where,
  //     List<Object?>? whereArgs,
  //     String? groupBy,
  //     String? having,
  //     String? orderBy,
  //     int? limit,
  //     int? offset});

  /// Executes a raw SQL SELECT query and returns a list
  /// of the rows that were found.
  ///
  /// ```
  /// List<Map> list = await database.rawQuery('SELECT * FROM Test');
  /// ```
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
      List<Object?>? arguments,
  ]);

  /// Executes a raw SQL UPDATE query and returns
  /// the number of changes made.
  ///
  /// ```
  /// int count = await database.rawUpdate(
  ///   'UPDATE Test SET name = ?, value = ? WHERE name = ?',
  ///   ['updated name', '9876', 'some name']);
  /// ```
  Future<int> rawUpdate(
    String sql, [
      List<Object?>? arguments,
  ]);

  // /// Convenience method for updating rows in the database. Returns
  // /// the number of changes made
  // ///
  // /// Update [table] with [values], a map from column names to new column
  // /// values. null is a valid value that will be translated to NULL.
  // ///
  // /// [where] is the optional WHERE clause to apply when updating.
  // /// Passing null will update all rows.
  // ///
  // /// You may include ?s in the where clause, which will be replaced by the
  // /// values from [whereArgs]
  // ///
  // /// [conflictAlgorithm] (optional) specifies algorithm to use in case of a
  // /// conflict. See [ConflictAlgorithm] docs for more details
  // ///
  // /// ```
  // /// int count = await db.update(tableTodo, todo.toMap(),
  // ///    where: '$columnId = ?', whereArgs: [todo.id]);
  // /// ```
  // Future<int> update(String table, Map<String, Object?> values,
  //     {String? where,
  //     List<Object?>? whereArgs,
  //     ConflictAlgorithm? conflictAlgorithm});

  /// Executes a raw SQL DELETE query and returns the
  /// number of changes made.
  ///
  /// ```
  /// int count = await database
  ///   .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
  /// ```
  Future<int> rawDelete(
    String sql, [
      List<Object?>? arguments,
  ]);

  // /// Convenience method for deleting rows in the database.
  // ///
  // /// Delete from [table]
  // ///
  // /// [where] is the optional WHERE clause to apply when updating. Passing null
  // /// will delete all rows.
  // ///
  // /// You may include ?s in the where clause, which will be replaced by the
  // /// values from [whereArgs]
  // ///
  // /// Returns the number of rows affected.
  // /// ```
  // ///  int count = await db.delete(tableTodo, where: 'columnId = ?', whereArgs: [id]);
  // /// ```
  // Future<int> delete(String table, {String? where, List<Object?>? whereArgs});

  // /// Creates a batch, used for performing multiple operation
  // /// in a single atomic operation.
  // ///
  // /// a batch can be commited using [Batch.commit]
  // ///
  // /// If the batch was created in a transaction, it will be commited
  // /// when the transaction is done
  // Batch batch();
}