import 'package:itable_ex/library.dart';

class RawDropTableRequestResult extends RequestDetails<bool> {
  RawDropTableRequestResult({
    required int transactionId,
    required StackTrace stackTrace,
  }) : super(
    transactionId: transactionId,
    stackTrace: stackTrace,
  );
}