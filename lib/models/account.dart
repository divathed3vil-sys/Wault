// lib/models/account.dart
// Account data model. Serializes to/from JSON for SharedPreferences storage.

import 'dart:convert';

class Account {
  final String id;
  final String label;
  final String accentColorHex;
  final int processSlot; // 0-4
  final int createdAt; // unix ms timestamp

  const Account({
    required this.id,
    required this.label,
    required this.accentColorHex,
    required this.processSlot,
    required this.createdAt,
  });

  Account copyWith({
    String? id,
    String? label,
    String? accentColorHex,
    int? processSlot,
    int? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      label: label ?? this.label,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      processSlot: processSlot ?? this.processSlot,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'accentColorHex': accentColorHex,
        'processSlot': processSlot,
        'createdAt': createdAt,
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        label: json['label'] as String,
        accentColorHex: json['accentColorHex'] as String,
        processSlot: json['processSlot'] as int,
        createdAt: json['createdAt'] as int,
      );

  static List<Account> listFromJson(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Account.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<Account> accounts) {
    return jsonEncode(accounts.map((a) => a.toJson()).toList());
  }

  @override
  String toString() =>
      'Account(id: $id, label: $label, slot: $processSlot, color: $accentColorHex)';
}
