import 'package:bytebank2/models/name.dart';
import 'package:bytebank2/screens/contacts_list.dart';
import 'package:bytebank2/screens/name.dart';
import 'package:bytebank2/screens/transactions_list.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardContainer extends StatelessWidget {
  const DashboardContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NameCubit("Giovani"),
      child: DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final name = context.read<NameCubit>().state;
    return Scaffold(
      appBar: AppBar(
        // Segundo o prof do curso isso não é legal porque mistura o observer com UI
        // no entanto nem ele conseguiu separar
        title: BlocBuilder<NameCubit, String>(
          builder: (context, name) {
            return Text('Welcome $name');
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // alinhamento vertical
        crossAxisAlignment: CrossAxisAlignment.start,
        // alinhamento horizontal
        children: <Widget>[
          // Imagem online
          // Image.network('https://cdn.pixabay.com/photo/2017/03/27/14/56/auto-2179220_960_720.jpg')
          // Imagem no projeto
          // Colar a imagem direto do explorer e adicionar no pubspec.yaml
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('images/bytebank_logo.png'),
          ),
          SingleChildScrollView(
            child: Container(
              height: 120,
              child:
                ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    _FeatureItem(
                      'Transfer',
                      Icons.monetization_on,
                      onClick: () {
                        _showContactList(context);
                      },
                    ),
                    _FeatureItem(
                      'Transaction Feed',
                      Icons.description,
                      onClick: () {
                        _showTransactionList(context);
                      },
                    ),
                    _FeatureItem(
                      'Change name',
                      Icons.person_outline,
                      onClick: () {
                        _showChangeName(context);
                      },
                    ),
                  ],
                )
            ),
          )
        ],
      ),
    );
  }

  // ATENÇÃO: aqui gera erro se não capturar o cubit do contexto antigo e repassar
  void _showChangeName(BuildContext blocContext) {
    Navigator.of(blocContext).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: BlocProvider.of<NameCubit>(blocContext),
          child: NameContainer(),
        ),
      ),
    );
  }

  void _showContactList(BuildContext context) {
    // Apenas para testar as exceções no Firebase
    // FirebaseCrashlytics.instance.crash();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactList(),
      ),
    );
  }

  void _showTransactionList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionsList(),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Function? onClick;

  // @required informa que esse parametro é esperado (apenas warning)
  // assert obriga a não ser null
  // _FeatureItem(this.name, this.icon, {@required this.onClick}) : assert(onClick != null);
  _FeatureItem(this.name, this.icon, {@required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      //GestureDetector = apenas isso funciona (no lugar de Material e Inkwell) mas nao tem o efeito de clique
      child: Material(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        child: InkWell(
          onTap: () => onClick!(),
          child: Container(
            padding: EdgeInsets.all(8.0),
            height: 100,
            width: 150,
            // retirado porque foi envolvido pelo InkWell
            // color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // alinhamento vertical
              crossAxisAlignment: CrossAxisAlignment.end,
              // alinhamento horizontal
              children: <Widget>[
                Icon(
                  icon,
                  color: Colors.tealAccent,
                  size: 24.0,
                ),
                Text(
                  name,
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
