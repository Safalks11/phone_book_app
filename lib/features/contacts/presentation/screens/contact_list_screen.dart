import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/contact_utils.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../data/models/contact_model.dart';
import '../providers/contact_provider.dart';
import '../widgets/contacts_searchbar_section.dart';

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
      setState(() => query = value.toLowerCase());
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
    DialogUtils.showSortOptions(
      context,
      currentSort: currentSort,
      onSortSelected: (option) => setState(() => currentSort = option),
    );
  }

  void _showDeleteConfirmation(ContactModel contact) {
    DialogUtils.showDeleteConfirmation(
      context,
      contact: contact,
      onConfirm: () {
        ref.read(contactProvider.notifier).deleteContact(contact.id);
        DialogUtils.showSnackBar(context, '${contact.name} deleted');
      },
    );
  }

  void _editContact(ContactModel contact) {
    DialogUtils.showEditContact(context, contact);
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts', style: TextStyle(fontWeight: FontWeight.w400)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final mode = ref.watch(themeModeProvider);
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
                icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(contactProvider.notifier).fetchContacts(),
          ),
        ],
      ),
      body: Column(
        children: [
          ContactSearchBar(
            searchController: _searchController,
            query: query,
            currentSort: currentSort,
            onSearchChanged: _onSearchChanged,
            onClearSearch: () {
              _searchController.clear();
              setState(() => query = "");
            },
            onSortPressed: _showSortOptions,
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
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          query.isNotEmpty ? "No contacts found for '$query'" : "No contacts yet",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        ),
                        if (query.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Tap + to add your first contact",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final contact = filtered[index];
                    final color = ContactUtils.avatarColor(contact.name);

                    return Dismissible(
                      key: ValueKey(contact.id),
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
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
                      confirmDismiss: (_) async {
                        _showDeleteConfirmation(contact);
                        return false;
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            child: Text(ContactUtils.initials(contact.name)),
                          ),
                          title: Row(
                            children: [
                              Expanded(child: Text(contact.name)),
                              if (contact.isFavorite)
                                const Icon(Icons.star, size: 18, color: Colors.amber),
                            ],
                          ),
                          subtitle: Text(contact.phone),
                          trailing: PopupMenuButton<String>(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  DialogUtils.showSnackBar(
                                    context,
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
                    FilledButton(
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
        label: const Text("Add"),
        onPressed: () => DialogUtils.showAddContact(context),
      ),
    );
  }
}
