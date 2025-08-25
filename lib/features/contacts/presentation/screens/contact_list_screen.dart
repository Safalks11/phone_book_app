import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/contact_provider.dart';

class ContactListScreen extends ConsumerWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsState = ref.watch(contactProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Phone Book")),
      body: contactsState.when(
        data: (contacts) => ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return ListTile(
              title: Text(contact.name),
              subtitle: Text(contact.phone),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => ref.read(contactProvider.notifier).deleteContact(contact.id),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add), onPressed: () {}),
    );
  }
}
