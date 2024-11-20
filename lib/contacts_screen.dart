import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({Key? key}) : super(key: key);

  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _requestContactsPermission();
  }

  Future<void> _requestContactsPermission() async {
    PermissionStatus status = await Permission.contacts.request();

    if (status.isGranted) {
      _loadContacts();
    } else {
      print("Доступ до контактів відмовлено");
    }
  }

  Future<void> _loadContacts() async {
    try {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      final filteredContacts = contacts.where((contact) {
        if (contact.familyName != null) {
          return contact.familyName!.startsWith('Т');
        }
        return false;
      }).toList();

      setState(() {
        _filteredContacts = filteredContacts;
      });
    } catch (e) {
      print("Не вдалося завантажити контакти: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Контакти'),
      ),
      body: _filteredContacts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                return ListTile(
                  title: Text(contact.displayName ?? 'Без імені'),
                );
              },
            ),
    );
  }
}
