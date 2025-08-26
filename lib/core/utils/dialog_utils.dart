import 'package:flutter/material.dart';

import '../../features/contacts/data/models/contact_model.dart';
import '../../features/contacts/presentation/screens/add_contact_screen.dart';
import '../../features/contacts/presentation/widgets/delete_conf_dialog.dart';
import '../../features/contacts/presentation/widgets/sort_bottom_sheet.dart';
import 'contact_utils.dart';

class DialogUtils {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isError ? Colors.red[600] : Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static Future<void> showSortOptions(
    BuildContext context, {
    required SortOption currentSort,
    required Function(SortOption) onSortSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          SortBottomSheet(currentSort: currentSort, onSortSelected: onSortSelected),
    );
  }

  static Future<void> showDeleteConfirmation(
    BuildContext context, {
    required ContactModel contact,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(contact: contact, onConfirm: onConfirm),
    );
  }

  static Future<void> showAddContact(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddContactScreen(),
    );
  }

  static Future<void> showEditContact(BuildContext context, ContactModel contact) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddContactScreen(contact: contact),
    );
  }
}
