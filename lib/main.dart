import 'package:bytebank2/http/webclient.dart';
import 'package:bytebank2/models/contact.dart';
import 'package:bytebank2/models/transaction.dart';
import 'package:bytebank2/screens/dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BytebankApp());
  // save(Transaction(200.0, Contact(0, 'Gui', 2003))).then((transaction) => print(transaction));

  // findAll().then((transactions) => print('new transactions $transactions'));

  // save(Contact(0, 'Giovani', 1000)).then((id){
  //   findAll().then((contacts) => debugPrint(contacts.toString()));
  // });
}

class BytebankApp extends StatelessWidget {
  const BytebankApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green[900],
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green
        ).copyWith(
            secondary: Colors.blueAccent[700]), // cor secundaria do tema
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent[700],
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: Dashboard(),
    );
  }
}


