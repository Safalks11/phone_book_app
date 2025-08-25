import '../../domain/entities/contact.dart';

class ContactModel extends Contact {
  ContactModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.isFavorite,
    required super.createdAt,
  });
  ContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      isFavorite: map['is_favorite'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
