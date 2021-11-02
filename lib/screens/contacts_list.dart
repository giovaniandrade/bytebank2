import 'package:bytebank2/components/container.dart';
import 'package:bytebank2/components/progress.dart';
import 'package:bytebank2/database/dao/contact_dao.dart';
import 'package:bytebank2/models/contact.dart';
import 'package:bytebank2/screens/contact_form.dart';
import 'package:bytebank2/screens/transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// O estado (ContactsListState) poderia ser uma classe com todas as propriedades possiveis
// lista, flag carregado, etc. Mas pra funcionar teria que ficar gerenciando com varios IFs
// ao inves disso foi trabalhado com polimorfismo
@immutable
abstract class ContactsListState {
  const ContactsListState();
}

@immutable
class LoadingContactsListState extends ContactsListState {
  const LoadingContactsListState();
}

@immutable
class InitContactsListState extends ContactsListState {
  const InitContactsListState();
}

@immutable
class LoadedContactsListState extends ContactsListState {
  final List<Contact> _contacts;

  const LoadedContactsListState(this._contacts);
}

@immutable
class FatalErrorContactsListState extends ContactsListState {
  const FatalErrorContactsListState();
}

class ContactsListCubit extends Cubit<ContactsListState> {
  ContactsListCubit() : super(InitContactsListState());

  void reload(ContactDao dao) async {
    emit(LoadingContactsListState());
    dao.findAll().then((contacts) => emit(LoadedContactsListState(contacts)));
  }
}

class ContactsListContainer extends BlocContainer {
  @override
  Widget build(BuildContext context) {
    final ContactDao dao = ContactDao();
    return BlocProvider<ContactsListCubit>(
        create: (BuildContext context) {
          final cubit = ContactsListCubit();
          cubit.reload(dao);
          return cubit;
        },
        child: ContactsList(dao));
  }
}

class ContactsList extends StatelessWidget {
  final ContactDao _dao;

  ContactsList(this._dao);

  @override
  Widget build(BuildContext context) {
    // contacts.add(Contact(0, 'Giovani', 8000));
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer'),
      ),
      body: BlocBuilder<ContactsListCubit, ContactsListState>(
        builder: (context, state) {
          if (state is InitContactsListState ||
              state is LoadingContactsListState) {
            return Progress();
          }

          if (state is LoadedContactsListState) {
            final contacts = state._contacts;
            return ListView.builder(
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return _ContactItem(contact, onClick: () {
                  push(context, TransactionFormContainer(contact));
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => TransactionFormContainer(contact),
                  //   ),
                  // );
                });
              },
              itemCount: contacts.length,
            );
          }

          return Text('Unknow error');
        },
      ),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => ContactForm(),
          ),
        );
        update(context);
        // .then((newContact) => debugPrint('$newContact'));
      },
      child: Icon(
        Icons.add,
      ),
    );
  }

  void update(BuildContext context) {
    context.read<ContactsListCubit>().reload(_dao);
  }
}

class _ContactItem extends StatelessWidget {
  final Contact contact;
  final Function? onClick;

  _ContactItem(this.contact, {
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
