import 'dart:async';
import 'dart:io';

import 'package:bytebank2/components/message_info.dart';
import 'package:bytebank2/components/progress.dart';
import 'package:bytebank2/components/response_dialog.dart';
import 'package:bytebank2/components/transaction_auth_dialog.dart';
import 'package:bytebank2/http/webclient.dart';
import 'package:bytebank2/http/webclients/transaction_webclient.dart';
import 'package:bytebank2/models/contact.dart';
import 'package:bytebank2/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TransactionForm extends StatefulWidget {
  final Contact contact;

  TransactionForm(this.contact);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _valueController = TextEditingController();
  final TransactionWebClient _webClient = TransactionWebClient();
  final String transactionId = Uuid().v4();

  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    print(transactionId);
    return Scaffold(
      appBar: AppBar(
        title: Text('New transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Progress(
                    message: 'Enviando...',
                  ),
                ),
                visible: _sending,
              ),
              Text(
                widget.contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  widget.contact.accountNumber.toString(),
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _valueController,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: _transferButton(context),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton _transferButton(BuildContext context) {
    return ElevatedButton(
      child: Text('Transfer'),
      onPressed: () {
        final double? value = double.tryParse(_valueController.text);

        if (value != null) {
          final transactionCreated = Transaction(
            transactionId,
            value,
            widget.contact,
          );
          showDialog(
              context: context,
              builder: (contextDialog) {
                // Importante: o método save precisa do contexto do form e o que é retornado aqui é o contexto do Dialog
                return TransactionAuthDialog(
                  onConfirm: (String password) {
                    _save(transactionCreated, password, context);
                  },
                );
              });
        } else {
          print('Valor nao informado!');
          showDialog(
              context: context,
              builder: (contextDialog) {
                return FailureDialog('Value not informed!');
              });
        }
      },
    );
  }

  void _save(
    Transaction transactionCreated,
    String password,
    BuildContext context,
  ) async {
    await _sendWebApi(
      transactionCreated,
      password,
      context,
    );
  }

  Future<void> _sendWebApi(Transaction transactionCreated, String password,
      BuildContext context) async {
    setState(() {
      _sending = true;
    });
    final Transaction transactionReceived =
        await _webClient.save(transactionCreated, password).catchError((e) {
      print('ERRO: $e');
      _showFailureMessage(context,
          message: e
              .message); // nesse primeiro erro pega a mensagem que vem do HttpException
    }, test: (e) => e is HttpException).catchError((e) {
      _showFailureMessage(context,
          message: 'API não encontrada'); // Erro específico
    }, test: (e) => e is SocketException).catchError((e) {
      // Essa linha testa de realmente o valor passado é uma SocketException!
      _showFailureMessage(context);
    }, test: (e) => e is Exception).whenComplete(() {
      setState(() {
        _sending = false;
      });
      print('Completo');
    });

    _showSuccessMessage(transactionReceived, context);
  }

  void _showFailureMessage(BuildContext context,
      {String message = 'Erro desconhecido'}) {
    showDialog(
        context: context,
        builder: (contextDialog) {
          return FailureDialog(message);
        });
  }

  Future<void> _showSuccessMessage(
      Transaction transactionReceived, BuildContext context) async {
    if (transactionReceived != null) {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            // Essas mensagens poderiam ser Snackbar tambem
            return SuccessDialog('Successful transaction');
          });
      Navigator.pop(
          context); // essa linha sempre aguarda a linha de cima por causa do await
    }
  }
}
