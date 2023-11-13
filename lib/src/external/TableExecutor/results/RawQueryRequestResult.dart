import 'RequestDetails.dart';

class RawQueryRequestResult extends RequestDetails<List<Map<String, dynamic>>> {  
  RawQueryRequestResult({
    required int transactionId,
    required StackTrace stackTrace,
  }) : super(
    transactionId: transactionId,
    stackTrace: stackTrace,
  );
}