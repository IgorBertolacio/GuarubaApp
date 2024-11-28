import 'package:flutter/material.dart';
import 'package:guaruba/domain/entidades/blobo_base.dart';
import 'package:guaruba/domain/usecases/criar_variavel/executar_blocos.dart';
import 'package:guaruba/presentation/blocs/estado_execucao.dart';
import 'package:provider/provider.dart';

class TelaDepuracao extends StatefulWidget {
  final ExecutorDeBlocos executor;
  final List<BlocoBase> blocos;

  const TelaDepuracao({
    super.key,
    required this.executor,
    required this.blocos,
  });

  @override
  _TelaDepuracaoState createState() => _TelaDepuracaoState();
}

class _TelaDepuracaoState extends State<TelaDepuracao> {
  late EstadoExecucao estadoExecucao;

  @override
  void initState() {
    super.initState();
    estadoExecucao = Provider.of<EstadoExecucao>(context, listen: false);
    print('TelaDepuracao estadoExecucao hashCode: ${estadoExecucao.hashCode}');
    // Iniciar a execução dos blocos após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.executor.executarBlocos(widget.blocos);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Build TelaDepuracao');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela de Depuração'),
      ),
      body: Consumer<EstadoExecucao>(
        builder: (context, estado, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: estado.widgets,
            ),
          );
        },
      ),
    );
  }
}
