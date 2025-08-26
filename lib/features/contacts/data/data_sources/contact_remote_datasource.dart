import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/contact_model.dart';

class ContactRemoteDataSource {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<ContactModel>> getContacts() async {
    final response = await client.from('contacts').select().order('created_at');
    return (response as List).map((e) => ContactModel.fromMap(e)).toList();
  }

  Future<ContactModel> addContact(ContactModel contact) async {
    final inserted = await client.from('contacts').insert(contact.toMap()).select().single();
    return ContactModel.fromMap(inserted );
  }

  Future<ContactModel> updateContact(ContactModel contact) async {
    final updated = await client
        .from('contacts')
        .update(contact.toMap())
        .eq('id', contact.id)
        .select()
        .single();
    return ContactModel.fromMap(updated);
  }

  Future<void> deleteContact(String id) async {
    await client.from('contacts').delete().eq('id', id);
  }
}
