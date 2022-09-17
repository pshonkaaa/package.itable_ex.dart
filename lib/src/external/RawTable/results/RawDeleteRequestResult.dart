import 'RequestDetails.dart';

class RawDeleteRequestResult extends RequestDetails<int> {  
  RawDeleteRequestResult({
    required int transactionId,
    required StackTrace stackTrace,
  }) : super(
    transactionId: transactionId,
    stackTrace: stackTrace,
  );
}