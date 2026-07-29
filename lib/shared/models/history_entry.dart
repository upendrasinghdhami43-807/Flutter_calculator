/// A single logged calculation, shared across Basic, Pro, and Advanced modes.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.mode,
    required this.expression,
    required this.result,
    required this.timestamp,
    this.isPinned = false,
  });

  final String id;
  final String mode;
  final String expression;
  final String result;
  final DateTime timestamp;
  final bool isPinned;

  HistoryEntry copyWith({bool? isPinned}) => HistoryEntry(
    id: id,
    mode: mode,
    expression: expression,
    result: result,
    timestamp: timestamp,
    isPinned: isPinned ?? this.isPinned,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'mode': mode,
    'expression': expression,
    'result': result,
    'timestamp': timestamp.toIso8601String(),
    'isPinned': isPinned,
  };

  factory HistoryEntry.fromJson(Map<String, Object?> json) => HistoryEntry(
    id: json['id']! as String,
    mode: json['mode']! as String,
    expression: json['expression']! as String,
    result: json['result']! as String,
    timestamp: DateTime.parse(json['timestamp']! as String),
    isPinned: json['isPinned'] as bool? ?? false,
  );
}
