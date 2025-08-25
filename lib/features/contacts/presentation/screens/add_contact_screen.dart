import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/contact_model.dart';
import '../providers/contact_provider.dart';

class AddContactScreen extends ConsumerStatefulWidget {
  const AddContactScreen({super.key});

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Wrap(
            runSpacing: 16,
            children: [
              Text("Add Contact", style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? "Enter phone number" : null,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green)),
                  label: const Text("Save"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final contact = ContactModel(
                        id: "",
                        name: _nameCtrl.text,
                        phone: _phoneCtrl.text,
                        isFavorite: false,
                        createdAt: DateTime.now(),
                      );
                      ref.read(contactProvider.notifier).addContact(contact);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
