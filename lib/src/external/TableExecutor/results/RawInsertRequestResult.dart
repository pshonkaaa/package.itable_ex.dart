import 'RequestDetails.dart';

class RawInsertRequestResult extends RequestDetails<int> {  
  RawInsertRequestResult({
    required int transactionId,
    required StackTrace stackTrace,
  }) : super(
    transactionId: transactionId,
    stackTrace: stackTrace,
  );
}