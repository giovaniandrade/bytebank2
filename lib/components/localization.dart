// localization e internacionalization

import 'package:bytebank2/components/container.dart';
import 'package:bytebank2/components/error.dart';
import 'package:bytebank2/components/progress.dart';
import 'package:bytebank2/http/webclients/i18n_webclient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localstorage/localstorage.dart';

class LocalizationContainer extends BlocContainer {
  final Widget child;

  LocalizationContainer({required Widget this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CurrentLocaleCubit>(
      create: (context) => CurrentLocaleCubit(),
      child: this.child,
    );
  }
}

class CurrentLocaleCubit extends Cubit<String> {
  CurrentLocaleCubit() : super("en");
}

class ViewI18N {
  String _language = '';

  ViewI18N(BuildContext context) {
    this._language = BlocProvider.of<CurrentLocaleCubit>(context).state;
  }

  String? localize(Map<String, String> values) {
    // assert(values != null);
    assert(values.containsKey(_language), 'Língua não encontrada: ${_language}'); // retorna um erro se nao encontrar a lingua

    return values[_language];
  }
}

@immutable
abstract class I18NMessagesState {
  const I18NMessagesState();
}

@immutable
class LoadingI18NMessagesState extends I18NMessagesState {
  const LoadingI18NMessagesState();
}

@immutable
class InitI18NMessagesState extends I18NMessagesState {
  const InitI18NMessagesState();
}

@immutable
class LoadedI18NMessagesState extends I18NMessagesState {
  final I18NMessages _messages;

  const LoadedI18NMessagesState(this._messages);
}

class I18NMessages {
  final Map<String, dynamic> _messages;

  //Construtor
  I18NMessages(this._messages);

  //Pegando a mensagem pela chave
  String? get(String key) {
    assert(key != null);
    assert(_messages.containsKey(key));
    return _messages[key];
  }
}

@immutable
class FatalErrorI18NMessagesState extends I18NMessagesState {
  const FatalErrorI18NMessagesState();
}

// Isso é um alias, um tipo
typedef Widget I18NWidgetCreator(I18NMessages messages);

class I18NLoadingContainer extends BlocContainer {
  I18NWidgetCreator? creator;
  String? viewKey; // Essa viewkey é uma chave com o prefixo da tela

  I18NLoadingContainer({
    required String viewKey,
    required I18NWidgetCreator creator,
  }) {
    this.creator = creator;
    this.viewKey = viewKey;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<I18NMessagesCubit>(
      create: (BuildContext context) {
        final cubit = I18NMessagesCubit(this.viewKey);
        cubit.reload(I18NWebClient(this.viewKey));
        return cubit;
      },
      child: I18NLoadingView(this.creator),
    );
  }
}

class I18NLoadingView extends StatelessWidget {
  final I18NWidgetCreator? _creator;

  I18NLoadingView(this._creator);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<I18NMessagesCubit, I18NMessagesState>(
      builder: (context, state) {
        if (state is InitI18NMessagesState || state is LoadingI18NMessagesState) {
          return ProgressView(message: "Loading..."); //retorna que esta carregando ainda
        }
        if (state is LoadedI18NMessagesState) {
          final messages = state._messages;
          return _creator!.call(messages);
        }
        return ErrorView("Erro buscando mensagens da tela");
      },
    );
  }
}

class I18NMessagesCubit extends Cubit<I18NMessagesState> {
  // Criando cache local com LocalStorage
  final LocalStorage storage = new LocalStorage('local_unsecure_version_1.json');
  final String? _viewkey;
  I18NMessagesCubit(this._viewkey) : super(InitI18NMessagesState());

  reload(I18NWebClient client) async {
    // 3. Carregando da internet mas com cache (LocalStorage)
    // O cache implementado dessa forma nunca expira
    emit(LoadingI18NMessagesState()); // Carregando mensagens
    await storage.ready;
    final items = storage.getItem(_viewkey!);
    print("Loaded $_viewkey $items");
    if (items != null) {
      emit(LoadedI18NMessagesState(I18NMessages(items)));
      return; // Se encontrou pode parar
    }
    // Se encontrar tem que salvar as mensagens antes de emitir o novo status
    client.findAll().then(saveAndRefresh);

    // 2. Carregando direto da internet
    // emit(LoadingI18NMessagesState()); // Carregando mensagens
    // // Assincrono da internet (do gist)
    // client.findAll().then(
    //       (messages) => emit(LoadedI18NMessagesState(I18NMessages(messages))), // Mensagens carregadas
    //     );

    // 1. De forma fixa
    // emit(
    //   LoadedI18NMessagesState(I18NMessages({
    //     "transfer": "TANSFER",
    //     "transaction_feed": "TRANSACTION FEED",
    //     "change_name": "CHANGE NAME",
    //   })),
    // );

  }

  // Salva a mensagem no LocalStorage e emite um novo status
  saveAndRefresh(Map<String, dynamic> messages) {
    storage.setItem(_viewkey!, messages);
    print("saving $_viewkey $messages");
    final state = LoadedI18NMessagesState(I18NMessages(messages));
    emit(state);
  }
}
