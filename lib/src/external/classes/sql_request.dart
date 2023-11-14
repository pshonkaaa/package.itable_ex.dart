class SqlRequest {
  final String sql;
  final List<Object?> arguments;
  const SqlRequest({
    required this.sql,
    required this.arguments,
  });
}