import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/contact_model.dart';

class ContactRemoteDataSource {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<ContactModel>> getContacts() async {
    final response = await client.from('contacts').select().order('created_at');
    return (response as List).map((e) => ContactModel.fromMap(e)).toList();
  }

  Future<void> addContact(ContactModel contact) async {
    await client.from('contacts').insert(contact.toMap());
  }

  Future<void> updateContact(ContactModel contact) async {
    await client.from('contacts').update(contact.toMap()).eq('id', contact.id);
  }

  Future<void> deleteContact(String id) async {
    await client.from('contacts').delete().eq('id', id);
  }
}
