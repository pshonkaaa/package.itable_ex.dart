import 'package:pshondation/library.dart';

abstract class RequestDetails<T> {
  /// Transaction id
  final int transactionId;

  final StackTrace stackTrace;

  /// SQL request
  String? sql;

  /// Profiler of SQLBuilder
  late final Profiler pConvert;

  /// Request profiler
  late final Profiler pRequest;

  /// Total profilers
  List<Profiler> get profilers => [pConvert, pRequest];

  /// SQL result
  late final T output;
  
  RequestDetails({
    required this.transactionId,
    required this.stackTrace,
  });

  int getExecutionTime(TimeUnits timeUnit) {
    int total = 0;
    for(final p in profilers)
      total += p.time(timeUnit);
    return total;
  }

  String toDetails() {
    int convert = pConvert.time(TimeUnits.MILLISECONDS);
    int request = pRequest.time(TimeUnits.MILLISECONDS);

    final sb = new StringBuffer();
    sb.writeln("SQL: $sql");
    sb.writeln("Converting took $convert times in ${TimeUnits.MILLISECONDS}");
    sb.writeln("Request    took $request times in ${TimeUnits.MILLISECONDS}");
    if(output is List)
      sb.writeln("Amount: ${(output as List).length}");
    if(output is Map)
      sb.writeln("Amount: ${(output as Map).length}");
    sb.writeln("Transaction: #$transactionId");
    sb.writeln("Result: $output");
    sb.writeln("StackTrace:");
    sb.writeln(stackTrace.toString());
    return sb.toString();
  }
}