class ExpenseEntry {
  final int? id;
  final String type;
  final String item;
  final int nominal;
  final DateTime tanggal;
  final String? supplier;
  final String source;
  final String? rawText;
  final DateTime createdAt;

  ExpenseEntry({
    this.id,
    required this.type,
    required this.item,
    required this.nominal,
    required this.tanggal,
    this.supplier,
    required this.source,
    this.rawText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'item': item,
      'nominal': nominal,
      'tanggal': tanggal.toIso8601String(),
      'supplier': supplier,
      'source': source,
      'raw_text': rawText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExpenseEntry.fromMap(Map<String, dynamic> map) {
    return ExpenseEntry(
      id: map['id'] as int?,
      type: map['type'] as String,
      item: map['item'] as String,
      nominal: map['nominal'] as int,
      tanggal: DateTime.parse(map['tanggal'] as String),
      supplier: map['supplier'] as String?,
      source: map['source'] as String,
      rawText: map['raw_text'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
