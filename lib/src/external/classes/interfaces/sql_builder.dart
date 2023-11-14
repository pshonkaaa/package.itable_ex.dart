import 'package:itable_ex/library.dart';

abstract class ISqlBuilder {
  /// Build an SQL query string from the given clauses.
  ///
  /// @param distinct true if you want each row to be unique, false otherwise.
  /// @param table The table names to compile the query against.
  /// @param columns A list of which columns to return. Passing null will
  ///            return all columns, which is discouraged to prevent reading
  ///            data from storage that isn't going to be used.
  /// @param where A filter declaring which rows to return, formatted as an SQL
  ///            WHERE clause (excluding the WHERE itself). Passing null will
  ///            return all rows for the given URL.
  /// @param groupBy A filter declaring how to group rows, formatted as an SQL
  ///            GROUP BY clause (excluding the GROUP BY itself). Passing null
  ///            will cause the rows to not be grouped.
  /// @param having A filter declare which row groups to include in the cursor,
  ///            if row grouping is being used, formatted as an SQL HAVING
  ///            clause (excluding the HAVING itself). Passing null will cause
  ///            all row groups to be included, and is required when row
  ///            grouping is not being used.
  /// @param orderBy How to order the rows, formatted as an SQL ORDER BY clause
  ///            (excluding the ORDER BY itself). Passing null will use the
  ///            default sort order, which may be unordered.
  /// @param limit Limits the number of rows returned by the query,
  ///            formatted as LIMIT clause. Passing null denotes no LIMIT clause.
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
  });

  /// Convenience method for inserting a row into the database.
  /// Parameters:
  /// @table the table to insert the row into
  /// @nullColumnHack optional; may be null. SQL doesn't allow inserting a completely empty row without naming at least one column name. If your provided values is empty, no column names are known and an empty row can't be inserted. If not set to null, the nullColumnHack parameter provides the name of nullable column name to explicitly insert a NULL into in the case where your values is empty.
  /// @values this map contains the initial column values for the row. The keys should be the column names and the values the column values
  SqlRequest insert(
    String table,
    Map<String, Object?> values, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,
  });

  SqlRequest insertAll(
    String table,
    List<String> columns,
    List<List<Object?>> list, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,
  });

  /// Convenience method for updating rows in the database.
  ///
  /// @param table the table to update in
  /// @param values a map from column names to new column values. null is a
  ///            valid value that will be translated to NULL.
  /// @param whereClause the optional WHERE clause to apply when updating.
  ///            Passing null will update all rows.
  /// @param whereArgs You may include ?s in the where clause, which
  ///            will be replaced by the values from whereArgs. The values
  ///            will be bound as Strings.
  /// @param conflictAlgorithm for update conflict resolver
  SqlRequest update(
    String table,
    Map<String, Object?> values, {
      String? where,
      List<Object?>? whereArgs,
      ConflictAlgorithm? conflictAlgorithm,
  });

  SqlRequest updateAll(
    String table,
    List<String> columns,
    List<List<Object?>> list, {
      String? nullColumnHack,
      ConflictAlgorithm? conflictAlgorithm,
  });

  /// Convenience method for deleting rows in the database.
  ///
  /// @param table the table to delete from
  /// @param where the optional WHERE clause to apply when deleting.
  ///            Passing null will delete all rows.
  /// @param whereArgs You may include ?s in the where clause, which
  ///            will be replaced by the values from whereArgs. The values
  ///            will be bound as Strings.
  SqlRequest delete(
    String table, {
      String? where,
      List<Object?>? whereArgs,
  });
}


final Set<String> escapeNames = {
  'add',
  'all',
  'alter',
  'and',
  'as',
  'autoincrement',
  'between',
  'case',
  'check',
  'collate',
  'commit',
  'constraint',
  'create',
  'default',
  'deferrable',
  'delete',
  'distinct',
  'drop',
  'else',
  'escape',
  'except',
  'exists',
  'foreign',
  'from',
  'group',
  'having',
  'if',
  'in',
  'index',
  'insert',
  'intersect',
  'into',
  'is',
  'isnull',
  'join',
  'limit',
  'not',
  'notnull',
  'null',
  'on',
  'or',
  'order',
  'primary',
  'references',
  'select',
  'set',
  'table',
  'then',
  'to',
  'transaction',
  'union',
  'unique',
  'update',
  'using',
  'values',
  'when',
  'where'
};

/*
All keywords kept here for reference

Set<String> _allKeywords = new Set.from([
  'abort',
  'action',
  'add',
  'after',
  'all',
  'alter',
  'analyze',
  'and',
  'as',
  'asc',
  'attach',
  'autoincrement',
  'before',
  'begin',
  'between',
  'by',
  'cascade',
  'case',
  'cast',
  'check',
  'collate',
  'column',
  'commit',
  'conflict',
  'constraint',
  'create',
  'cross',
  'current_date',
  'current_time',
  'current_timestamp',
  'database',
  'default',
  'deferrable',
  'deferred',
  'delete',
  'desc',
  'detach',
  'distinct',
  'drop',
  'each',
  'else',
  'end',
  'escape',
  'except',
  'exclusive',
  'exists',
  'explain',
  'fail',
  'for',
  'foreign',
  'from',
  'full',
  'glob',
  'group',
  'having',
  'if',
  'ignore',
  'immediate',
  'in',
  'index',
  'indexed',
  'initially',
  'inner',
  'insert',
  'instead',
  'intersect',
  'into',
  'is',
  'isnull',
  'join',
  'key',
  'left',
  'like',
  'limit',
  'match',
  'natural',
  'no',
  'not',
  'notnull',
  'null',
  'of',
  'offset',
  'on',
  'or',
  'order',
  'outer',
  'plan',
  'pragma',
  'primary',
  'query',
  'raise',
  'recursive',
  'references',
  'regexp',
  'reindex',
  'release',
  'rename',
  'replace',
  'restrict',
  'right',
  'rollback',
  'row',
  'savepoint',
  'select',
  'set',
  'table',
  'temp',
  'temporary',
  'then',
  'to',
  'transaction',
  'trigger',
  'union',
  'unique',
  'update',
  'using',
  'vacuum',
  'values',
  'view',
  'virtual',
  'when',
  'where',
  'with',
  'without'
]);
*/