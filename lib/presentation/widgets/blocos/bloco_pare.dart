import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guaruba/domain/entidades/bloco_pare.dart';
import '../../../domain/entidades/blobo_base.dart';
import '../../blocs/gerenciamento_bloc.dart';
import '../../blocs/gerenciamento_evento.dart';
import '../../blocs/gerenciamento_estado.dart';

class WidgetBlocoPare extends StatefulWidget {
  final BlocoPare blocoPare;
  final String? area;
  final int nestingLevel;

  const WidgetBlocoPare({
    super.key,
    required this.blocoPare,
    required this.area,
    this.nestingLevel = 0,
  });

  @override
  _WidgetBlocoPareState createState() => _WidgetBlocoPareState();
}

class _WidgetBlocoPareState extends State<WidgetBlocoPare> {
  @override
  Widget build(BuildContext context) {
    // Verificar se este bloco está selecionado
    final estado = context.watch<BlocoBloc>().state;
    BlocoBase? blocoSelecionado;

    if (estado is EstadoBlocosAtualizados) {
      blocoSelecionado = estado.blocoSelecionado;
    }

    bool isSelecionado = blocoSelecionado == widget.blocoPare;

    return GestureDetector(
      onTap: () {
        context.read<BlocoBloc>().add(SelecionarBloco(widget.blocoPare, area: widget.area));
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.red, // Cor distinta para o bloco Pare
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 6.0,
            ),
          ],
          border: isSelecionado
              ? Border.all(color: Colors.yellowAccent, width: 2.0)
              : null,
        ),
        child: const Row(
          children: [
            Icon(
              Icons.stop_circle,
              color: Colors.white,
            ),
            SizedBox(width: 8.0),
            Text(
              'Pare',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
