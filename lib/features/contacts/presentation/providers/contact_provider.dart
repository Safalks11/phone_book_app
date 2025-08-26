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
    final inserted = await remoteDataSource.addContact(contact);
    state = state.whenData((list) => [...list, inserted]);
  }

  Future<void> updateContact(ContactModel contact) async {
    final updated = await remoteDataSource.updateContact(contact);
    state = state.whenData((list) => list
        .map((c) => c.id == updated.id ? updated : c)
        .toList());
  }

  Future<void> deleteContact(String id) async {
    final previous = state;
    state = state.whenData((list) => list.where((c) => c.id != id).toList());
    try {
      await remoteDataSource.deleteContact(id);
    } catch (e, st) {
      state = AsyncError(e, st);
      state = previous;
    }
  }
}
