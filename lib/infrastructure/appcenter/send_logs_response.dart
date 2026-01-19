import 'package:flutter/foundation.dart';

@immutable
class SendLogsResponse {
  final String status;
  final List<String> validDiagnosticsIds;
  final List<String> throttledDiagnosticsIds;
  final String correlationId;

  const SendLogsResponse({
    required this.status,
    required this.validDiagnosticsIds,
    required this.throttledDiagnosticsIds,
    required this.correlationId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'validDiagnosticsIds': validDiagnosticsIds,
      'throttledDiagnosticsIds': throttledDiagnosticsIds,
      'correlationId': correlationId,
    };
  }

  SendLogsResponse.fromMap(Map<String, dynamic> map)
    : status = map['status'] ?? "unknown",
      validDiagnosticsIds = _convertToStringList(map['validDiagnosticsIds']),
      throttledDiagnosticsIds = _convertToStringList(
        map['throttledDiagnosticsIds'],
      ),
      correlationId = map['correlationId'] ?? "";

  static List<String> _convertToStringList(List<dynamic>? dynamicList) {
    if (dynamicList == null) {
      return [];
    }
    return dynamicList.map((e) => e.toString()).toList();
  }

  @override
  String toString() {
    return 'SendLogsResponse${toMap()}';
  }
}
