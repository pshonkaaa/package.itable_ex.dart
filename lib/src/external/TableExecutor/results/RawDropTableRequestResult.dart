import 'RequestDetails.dart';

class RawDropTableRequestResult extends RequestDetails<bool> {
  RawDropTableRequestResult({
    required int transactionId,
    required StackTrace stackTrace,
  }) : super(
    transactionId: transactionId,
    stackTrace: stackTrace,
  );
}