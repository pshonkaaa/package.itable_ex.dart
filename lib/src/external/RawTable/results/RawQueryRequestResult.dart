import 'package:json_ex/library.dart';

import 'RequestDetails.dart';

class RawQueryRequestResult extends RequestDetails<List<JsonObject>> {  
  RawQueryRequestResult({
    required int transactionId,
    required StackTrace stackTrace,
  }) : super(
    transactionId: transactionId,
    stackTrace: stackTrace,
  );
}