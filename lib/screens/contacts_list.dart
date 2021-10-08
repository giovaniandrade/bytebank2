import 'package:bytebank2/components/progress.dart';
import 'package:bytebank2/database/dao/contact_dao.dart';
import 'package:bytebank2/models/contact.dart';
import 'package:bytebank2/screens/contact_form.dart';
import 'package:bytebank2/screens/transaction_form.dart';
import 'package:flutter/material.dart';

class ContactList extends StatefulWidget {
  // final List<Contact> contacts = [];

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final ContactDao _dao = ContactDao();

  @override
  Widget build(BuildContext context) {
    // contacts.add(Contact(0, 'Giovani', 8000));
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer'),
      ),
      body: FutureBuilder<List<Contact>>(
        initialData: [],
        future: Future.delayed(Duration(seconds: 4))
            .then((value) => _dao.findAll()),
        builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              // Ainda nao executado.
              break;
            case ConnectionState.waiting:
              // Carregando.
              return Progress();
              break;
            case ConnectionState.active:
              // Tem dados, mas ainda não foi finalizado. Usado num download por exemplo
              break;
            case ConnectionState.done:
              if (snapshot.hasData) {
                // Finalizado.
                // FIXME não sei isso esta exatamente correto
                final List<Contact> contacts = snapshot.data!;
                return ListView.builder(
                  // se fosse uma lista estatica poderia apenas um ListView mesmo (sem o FutureBuilder)
                  itemBuilder: (context, index) {
                    final Contact contact = contacts[index];
                    return _ContactItem(contact, onClick: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TransactionForm(contact),
                        ),
                      );
                    });
                  },
                  itemCount: contacts.length,
                );
              }
              break;
          }
          return Text('Unknow error');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => ContactForm(),
            ),
          )
              .then((value) {
            setState(() {
              debugPrint('Isso acontece quando desempilha');
            });
          });
          // .then((newContact) => debugPrint('$newContact'));
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final Contact contact;
  final Function? onClick;

  _ContactItem(
    this.contact, {
    @required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => onClick!(),
        title: Text(
          contact.name,
          style: TextStyle(fontSize: 24.0),
        ),
        subtitle: Text(
          contact.accountNumber.toString(),
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
