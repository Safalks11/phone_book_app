import 'package:flutter/material.dart';

class ContactUtils {
  static Color avatarColor(String seed) {
    const colors = [
      Colors.green,
      Colors.orange,
      Colors.indigo,
      Colors.blue,
      Colors.teal,
      Colors.deepPurple,
      Colors.pink,
      Colors.cyan,
    ];
    if (seed.isEmpty) return Colors.grey;
    final code = seed.codeUnitAt(0);
    return colors[code % colors.length];
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

enum SortOption { name, recent, favorites }
