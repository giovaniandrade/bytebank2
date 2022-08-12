import 'dart:async';

import 'package:bytebank2/components/localization.dart';
import 'package:bytebank2/components/theme.dart';
import 'package:bytebank2/screens/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  // Primeiro avisa o Flutter que vamos executar um método assíncrono antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Médido Assíncrono ants do runApp
  await Firebase.initializeApp();

  if (kDebugMode) {
    // desabilita o envio de erros para o Firebase Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    // Setar o ID do usuário do App, para ser possível identificar pelo banco de dados
    FirebaseCrashlytics.instance.setUserIdentifier('Giovani123');
    // Envia todos os erros para o Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  // Captura erros que vem do Dart e não do Flutter
  // Poe ter varias zonas, uma por tela por exemplo, mas nao foi explicado
  runZonedGuarded<Future<void>>(() async {
    runApp(const BytebankApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));

  // print(Uuid().v1());

  // save(Transaction(200.0, Contact(0, 'Gui', 2003))).then((transaction) => print(transaction));

  // findAll().then((transactions) => print('new transactions $transactions'));

  // save(Contact(0, 'Giovani', 1000)).then((id){
  //   findAll().then((contacts) => debugPrint(contacts.toString()));
  // });
}

class LogObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    print('${bloc.runtimeType} > $change');
    super.onChange(bloc, change);
  }
}

class BytebankApp extends StatelessWidget {
  const BytebankApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Bloc.observer = LogObserver();

    return MaterialApp(
      theme: bytebankTheme,
      home: LocalizationContainer(
        child: DashboardContainer(),
      ),
    );
  }
}
