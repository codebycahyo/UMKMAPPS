import 'package:equatable/equatable.dart';

enum ServiceUnit { pcs, porsi, paket, kg, liter, box, unit, lusin }

extension ServiceUnitExtension on ServiceUnit {
  String get value {
    switch (this) {
      case ServiceUnit.pcs:
        return 'pcs';
      case ServiceUnit.porsi:
        return 'porsi';
      case ServiceUnit.paket:
        return 'paket';
      case ServiceUnit.kg:
        return 'kg';
      case ServiceUnit.liter:
        return 'liter';
      case ServiceUnit.box:
        return 'box';
      case ServiceUnit.unit:
        return 'unit';
      case ServiceUnit.lusin:
        return 'lusin';
    }
  }

  String get displayName {
    switch (this) {
      case ServiceUnit.pcs:
        return 'Pieces (Pcs)';
      case ServiceUnit.porsi:
        return 'Porsi';
      case ServiceUnit.paket:
        return 'Paket';
      case ServiceUnit.kg:
        return 'Kilogram (Kg)';
      case ServiceUnit.liter:
        return 'Liter';
      case ServiceUnit.box:
        return 'Box / Dus';
      case ServiceUnit.unit:
        return 'Unit';
      case ServiceUnit.lusin:
        return 'Lusin';
    }
  }

  static ServiceUnit fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'pcs':
        return ServiceUnit.pcs;
      case 'porsi':
        return ServiceUnit.porsi;
      case 'paket':
        return ServiceUnit.paket;
      case 'kg':
      case 'kilogram':
        return ServiceUnit.kg;
      case 'liter':
      case 'lt':
        return ServiceUnit.liter;
      case 'box':
      case 'dus':
        return ServiceUnit.box;
      case 'unit':
        return ServiceUnit.unit;
      case 'lusin':
        return ServiceUnit.lusin;
      default:
        return ServiceUnit.pcs;
    }
  }
}

class Service extends Equatable {
  final int? id;
  final String name;
  final ServiceUnit unit;
  final int price;
  final int durationDays;
  final bool isActive;
  final DateTime? createdAt;

  const Service({
    this.id,
    required this.name,
    this.unit = ServiceUnit.pcs,
    required this.price,
    this.durationDays = 1,
    this.isActive = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit.value,
      'price': price,
      'duration_days': durationDays,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as int?,
      name: map['name'] as String,
      unit: ServiceUnitExtension.fromString(map['unit'] as String),
      price: map['price'] as int,
      durationDays: (map['duration_days'] as int?) ?? 3,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Service copyWith({
    int? id,
    String? name,
    ServiceUnit? unit,
    int? price,
    int? durationDays,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    unit,
    price,
    durationDays,
    isActive,
    createdAt,
  ];
}
