import 'dart:async';
import 'dart:io';

import 'package:bytebank2/components/container.dart';
import 'package:bytebank2/components/error.dart';
import 'package:bytebank2/components/progress.dart';
import 'package:bytebank2/components/response_dialog.dart';
import 'package:bytebank2/components/transaction_auth_dialog.dart';
import 'package:bytebank2/http/webclients/transaction_webclient.dart';
import 'package:bytebank2/models/contact.dart';
import 'package:bytebank2/models/transaction.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:giffy_dialog/giffy_dialog.dart';
//import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';

@immutable
abstract class TransactionFormState {
  const TransactionFormState();
}

@immutable
class SendingFormState extends TransactionFormState {
  const SendingFormState();
}

@immutable
class ShowFormState extends TransactionFormState {
  const ShowFormState();
}

@immutable
class SentFormState extends TransactionFormState {
  const SentFormState();
}

@immutable
class FatalErrorTransactionFormState extends TransactionFormState {
  final String _message;
  const FatalErrorTransactionFormState(this._message);
}

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit() : super(const ShowFormState());

  void save(Transaction transactionCreated, String password, BuildContext context) async {
    emit(const SendingFormState());
    Transaction transaction = await _sendWebApi(
      transactionCreated,
      password,
      context,
    );
    emit(const SentFormState());
  }

  _sendWebApi(Transaction transactionCreated, String password, BuildContext context) async {
    await TransactionWebClient()
        .save(
          transactionCreated,
          password,
        )
        .then((transactionReceived) => emit(SentFormState()))
        .catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        // Envia o erro para o Firebase Crashlyticts
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance.setCustomKey('http_code', e.statusCode);
        FirebaseCrashlytics.instance.setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e, null);
      }

      print('ERRO: $e');
      // _showFailureMessage(context, message: e.message); // nesse primeiro erro pega a mensagem que vem do HttpException
      emit(FatalErrorTransactionFormState(e.message));
    }, test: (e) => e is HttpException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance.setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e, null);
      }

      emit(FatalErrorTransactionFormState('API não respondendo - Timeout'));
      // _showFailureMessage(context, message: 'API não respondendo - Timeout'); // Erro específico Timeout
    }, test: (e) => e is TimeoutException).catchError((e) {
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance.setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e, null);
      }

      // _showFailureMessage(context, message: 'API não encontrada'); // Erro específico IP incorreto
      emit(FatalErrorTransactionFormState('API não encontrada'));
    }, test: (e) => e is SocketException).catchError((e) {
      // Essa linha testa de realmente o valor passado é uma SocketException!
      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance.setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e, null);
      }

      // _showFailureMessage(context);
      emit(FatalErrorTransactionFormState(e.message));
    }, test: (e) => e is Exception);

    // _showSuccessMessage(transactionReceived, context);
  }
}

class TransactionFormContainer extends BlocContainer {
  final Contact _contact;

  TransactionFormContainer(this._contact);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionFormCubit>(
      create: (BuildContext context) {
        return TransactionFormCubit();
      },
      child: BlocListener<TransactionFormCubit, TransactionFormState>(
        // Esse listener fica escutando
        listener: (context, state) {
          if (state is SentFormState) {
            // e quando altera o status fecha a tela (pop)
            Navigator.pop(context);
          }
        },
        child: TransactionFormStateless(_contact),
      ),
    );
  }
}

class TransactionFormStateless extends StatelessWidget {
  final Contact _contact;

  TransactionFormStateless(this._contact);

  @override
  Widget build(BuildContext context) {
    // print(transactionId);
    return BlocBuilder<TransactionFormCubit, TransactionFormState>(
      builder: (context, state) {
        if (state is ShowFormState) {
          return _BasicForm(_contact);
        }

        if (state is SendingFormState) {
          return ProgressView();
        }

        if (state is SentFormState) {
          // Durante a renderizacao nao pode fazer esse pop
          // Navigator.pop(context);
          return ProgressView();
        }

        if (state is FatalErrorTransactionFormState) {
          return ErrorView(state._message);
        }

        return ErrorView('Erro desconhecido');
      },
    );
  }
}

class _BasicForm extends StatelessWidget {
  final TextEditingController _valueController = TextEditingController();
  final String transactionId = Uuid().v4();
  final Contact _contact;
  _BasicForm(this._contact);

  @override
  Widget build(BuildContext context) {
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
              Text(
                _contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _contact.accountNumber.toString(),
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
            _contact,
          );
          showDialog(
              context: context,
              builder: (contextDialog) {
                // Importante: o método save precisa do contexto do form e o que é retornado aqui é o contexto do Dialog
                return TransactionAuthDialog(
                  onConfirm: (String password) {
                    BlocProvider.of<TransactionFormCubit>(context).save(transactionCreated, password, context);
                    // _save(transactionCreated, password, context);
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

  // void _save(
  //   Transaction transactionCreated,
  //   String password,
  //   BuildContext context,
  // ) async {
  //   await _sendWebApi(
  //     transactionCreated,
  //     password,
  //     context,
  //   );
  // }

  void _showFailureMessage(BuildContext context, {String message = 'Erro desconhecido'}) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _showSuccessMessage(Transaction transactionReceived, BuildContext context) async {
    if (transactionReceived != null) {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            // Essas mensagens poderiam ser Snackbar tambem
            return SuccessDialog('Successful transaction');
          });
      Navigator.pop(context); // essa linha sempre aguarda a linha de cima por causa do await
    }
  }
}
