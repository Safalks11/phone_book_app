import 'package:flutter/material.dart';

import '../../data/models/contact_model.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({super.key, required this.contact, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('Delete Contact'),
        ],
      ),
      content: Text(
        'Are you sure you want to delete ${contact.name}? This action cannot be undone.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
