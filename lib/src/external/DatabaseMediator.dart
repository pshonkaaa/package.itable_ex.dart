import 'DatabaseExecutor.dart';
import 'IConnectionParams.dart';

typedef OnConfigureFunction = Future<void> Function();
typedef OnOpenFunction = Future<void> Function();
typedef OnCreateFunction = Future<void> Function(int version);
typedef OnUpgradeFunction = Future<void> Function(int oldVersion, int newVersion);
typedef OnDowngradeFunction = Future<void> Function(int oldVersion, int newVersion);

abstract class DatabaseMediator implements DatabaseExecutor {
  /// The path of the database
  // String get path;

  bool get connected;

  Future<bool> connect({
    required IConnectionParams connectionParams,
    required OnConfigureFunction onConfigure,
    required OnOpenFunction onOpen,
    required OnCreateFunction onCreate,
    required OnUpgradeFunction onUpgrade,
    required OnDowngradeFunction onDowngrade,
  });

  /// Close the database. Cannot be accessed anymore
  Future<bool> close();

  /// Calls in action must only be done using the transaction object
  /// using the database will trigger a dead-lock.
  ///
  /// ```
  /// await database.transaction((txn) async {
  ///   // Ok
  ///   await txn.execute('CREATE TABLE Test1 (id INTEGER PRIMARY KEY)');
  ///
  ///   // DON'T  use the database object in a transaction
  ///   // this will deadlock!
  ///   await database.execute('CREATE TABLE Test2 (id INTEGER PRIMARY KEY)');
  /// });
  // Future<T> transaction<T>(Future<T> Function(Transaction txn) action,
  //     {bool? exclusive});

  ///
  /// Get the database inner version
  ///
  Future<int> getVersion();

  ///
  /// Set the database inner version
  /// Used internally for open helpers and automatic versioning
  ///
  // Future<void> setVersion(int version);
}