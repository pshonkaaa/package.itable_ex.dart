import 'package:itable_ex/library.dart';

class RawUpdateRequestResult extends RequestDetails<int> {  
  RawUpdateRequestResult({
    required int transactionId,
    required StackTrace stackTrace,
  }) : super(
    transactionId: transactionId,
    stackTrace: stackTrace,
  );
}