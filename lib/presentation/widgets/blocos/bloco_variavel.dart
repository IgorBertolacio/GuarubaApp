import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guaruba/domain/entidades/bloco_variavel.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_bloc.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_evento.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_estado.dart';
import '../../../domain/entidades/blobo_base.dart';


class WidgetBlocoVariavel extends StatefulWidget {
  final BlocoVariavel blocoVariavel;
  final String? area;
  final int nestingLevel;

  const WidgetBlocoVariavel({
    super.key,
    required this.blocoVariavel,
    required this.area,
    this.nestingLevel = 0,
  });

  @override
  _WidgetBlocoVariavelState createState() => _WidgetBlocoVariavelState();
}

class _WidgetBlocoVariavelState extends State<WidgetBlocoVariavel> {
  final TextEditingController valorController = TextEditingController();
  late String nomeVariavel;

  @override
  void initState() {
    super.initState();
    valorController.text = widget.blocoVariavel.valor;
    nomeVariavel = widget.blocoVariavel.nomeVariavel;
  }

  @override
  void dispose() {
    valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<BlocoBloc>().state;
    BlocoBase? blocoSelecionado;

    if (estado is EstadoBlocosAtualizados) {
      blocoSelecionado = estado.blocoSelecionado;
    }

    bool isSelecionado = blocoSelecionado == widget.blocoVariavel;

    return GestureDetector(
      onTap: () {
        context.read<BlocoBloc>().add(SelecionarBloco(widget.blocoVariavel, area: widget.area));
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 178, 113),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(0.0, 1.0),
              blurRadius: 2.0,
            ),
          ],
          border: isSelecionado
              ? Border.all(
                  color: Colors.yellowAccent,
                  width: 2.0,
                )
              : null,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                _mostrarDialogoEditarVariavel(context);
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.code,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Variável ($nomeVariavel)',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, -1.0),
                      blurRadius: 2.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: TextField(
                  controller: valorController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Adicione um valor', // Placeholder
                  ),
                  onChanged: (value) {
                    // Atualizar o valor do bloco
                    final blocoVariavelAtualizado =
                        widget.blocoVariavel.copyWith(
                      valor: value,
                    );
                    context.read<BlocoBloc>().add(
                          AtualizarBlocoVariavel(blocoVariavelAtualizado),
                        );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEditarVariavel(BuildContext context) {
    final controlador = TextEditingController(text: nomeVariavel);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Variável'),
          content: TextField(
            controller: controlador,
            decoration: const InputDecoration(labelText: 'Nome da Variável'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final novoNome = controlador.text.trim();

                if (novoNome.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('O nome da variável não pode ser vazio.')),
                  );
                  return;
                }

                // Atualizar o nome da variável localmente
                setState(() {
                  nomeVariavel = novoNome;
                });

                // Atualizar o bloco
                final blocoVariavelAtualizado = widget.blocoVariavel.copyWith(
                  nomeVariavel: novoNome,
                );
                context.read<BlocoBloc>().add(
                      AtualizarBlocoVariavel(blocoVariavelAtualizado),
                    );

                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
