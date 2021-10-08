import 'package:bytebank2/screens/contacts_list.dart';
import 'package:bytebank2/screens/transactions_list.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
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
          SingleChildScrollView( //ListView tambem funcionaria
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
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
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showContactList(BuildContext context) {
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
