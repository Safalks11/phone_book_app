import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/contact_helper.dart';
import '../../data/models/contact_model.dart';
import '../providers/contact_provider.dart';
import 'add_contact_screen.dart';

class ContactListScreen extends ConsumerStatefulWidget {
  const ContactListScreen({super.key});

  @override
  ConsumerState<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends ConsumerState<ContactListScreen> {
  String query = "";
  SortOption currentSort = SortOption.name;
  Timer? _debounceTimer;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        query = value.toLowerCase();
      });
    });
  }

  List<ContactModel> _sortContacts(List<ContactModel> contacts) {
    switch (currentSort) {
      case SortOption.name:
        return contacts..sort((a, b) => a.name.compareTo(b.name));
      case SortOption.recent:
        return contacts..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOption.favorites:
        return contacts..sort((a, b) {
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;
          return a.name.compareTo(b.name);
        });
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sort by',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...SortOption.values.map(
              (option) => ListTile(
                leading: Radio<SortOption>(
                  value: option,
                  groupValue: currentSort,
                  onChanged: (value) {
                    setState(() {
                      currentSort = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                title: Text(_getSortTitle(option)),
                onTap: () {
                  setState(() {
                    currentSort = option;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortTitle(SortOption option) {
    switch (option) {
      case SortOption.name:
        return 'Name (A-Z)';
      case SortOption.recent:
        return 'Recently Added';
      case SortOption.favorites:
        return 'Favorites First';
    }
  }

  void _showDeleteConfirmation(ContactModel contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(contactProvider.notifier).deleteContact(contact.id);
              _showSnackBar('${contact.name} deleted');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _editContact(ContactModel contact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddContactScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Contact'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(contactProvider.notifier).fetchContacts(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search contacts...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  query = "";
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                OutlinedButton(onPressed: _showSortOptions, child: const Icon(Icons.sort)),
              ],
            ),
          ),
          Expanded(
            child: contactsState.when(
              data: (contacts) {
                final sortedContacts = _sortContacts(contacts);
                final filtered = sortedContacts
                    .where((c) => c.name.toLowerCase().contains(query) || c.phone.contains(query))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          query.isNotEmpty ? Icons.search_off : Icons.contacts,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          query.isNotEmpty ? "No contacts found for '$query'" : "No contacts yet",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        if (query.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "Tap the + button to add your first contact",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final contact = filtered[index];
                    final color = ContactHelper.avatarColor(contact.name);

                    return Dismissible(
                      key: ValueKey(contact.id),
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        _showDeleteConfirmation(contact);
                        return false;
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              child: Text(ContactHelper.initials(contact.name)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          contact.name,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ),
                                      if (contact.isFavorite)
                                        const Icon(Icons.star, size: 16, color: Colors.amber),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    contact.phone,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _editContact(contact);
                                    break;
                                  case 'favorite':
                                    ref
                                        .read(contactProvider.notifier)
                                        .updateContact(
                                          contact.copyWith(isFavorite: !contact.isFavorite),
                                        );
                                    _showSnackBar(
                                      contact.isFavorite
                                          ? '${contact.name} removed from favorites'
                                          : '${contact.name} added to favorites',
                                    );
                                    break;
                                  case 'delete':
                                    _showDeleteConfirmation(contact);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'favorite',
                                  child: ListTile(
                                    leading: Icon(
                                      contact.isFavorite ? Icons.star : Icons.star_border,
                                    ),
                                    title: Text(contact.isFavorite ? 'Unfavorite' : 'Favorite'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete, color: Colors.red),
                                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text("Error loading contacts", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      err.toString(),
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(contactProvider.notifier).fetchContacts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Contact"),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => const AddContactScreen(),
          );
        },
      ),
    );
  }
}
