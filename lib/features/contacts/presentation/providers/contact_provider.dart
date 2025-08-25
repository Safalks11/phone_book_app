import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/contact_remote_datasource.dart';
import '../../data/models/contact_model.dart';

final contactProvider = StateNotifierProvider<ContactNotifier, AsyncValue<List<ContactModel>>>(
  (ref) => ContactNotifier(ContactRemoteDataSource()),
);

class ContactNotifier extends StateNotifier<AsyncValue<List<ContactModel>>> {
  final ContactRemoteDataSource remoteDataSource;

  ContactNotifier(this.remoteDataSource) : super(const AsyncLoading()) {
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    try {
      final contacts = await remoteDataSource.getContacts();
      state = AsyncData(contacts);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addContact(ContactModel contact) async {
    await remoteDataSource.addContact(contact);
    fetchContacts();
  }

  Future<void> updateContact(ContactModel contact) async {
    await remoteDataSource.updateContact(contact);
    fetchContacts();
  }

  Future<void> deleteContact(String id) async {
    await remoteDataSource.deleteContact(id);
    fetchContacts();
  }
}
