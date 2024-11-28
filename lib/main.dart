import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_bloc.dart';
import 'package:guaruba/presentation/guaruba.dart';

void main() {
  runApp(
    BlocProvider<BlocoBloc>(
      create: (context) => BlocoBloc(),
      child: const Guaruba(),
    ),
  );
}
