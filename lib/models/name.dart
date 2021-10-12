import 'package:flutter_bloc/flutter_bloc.dart';

// Nesse caso o estado é uma única string
// mas poderia ser uma classe Profile por exemplo
class NameCubit extends Cubit<String> {
  NameCubit(String name) : super(name);

  void change(String name) => emit(name);
}