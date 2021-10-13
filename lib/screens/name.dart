import 'package:bytebank2/components/container.dart';
import 'package:bytebank2/models/name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameContainer extends BlocContainer {
  @override
  Widget build(BuildContext context) {
    return NameView();
  }
}

class NameView extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Não usou um blocbuilder aqui porque não precisa rebuildar o widget
    _nameController.text = context.read<NameCubit>().state;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Alterar nome'),
        ),
        body: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Apelido"),
              style: TextStyle(fontSize: 24.0),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  child: Text('Alterar'),
                  onPressed: () {
                    // Oculta o teclado pra nao ficar dando erro de renderização
                    FocusScope.of(context).unfocus();
                    final name = _nameController.text;
                    context.read<NameCubit>().change(name);
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          ],
        ));
  }
}
