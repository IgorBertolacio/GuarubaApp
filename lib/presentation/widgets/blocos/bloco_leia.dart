import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guaruba/domain/entidades/blobo_base.dart';
import 'package:guaruba/domain/entidades/bloco_leia.dart';
import 'package:guaruba/domain/usecases/criar_variavel/criar_variavel.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_bloc.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_evento.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_estado.dart';


class WidgetBlocoLeia extends StatefulWidget {
  final BlocoLeia blocoLeia;
  final String? area;
  final int nestingLevel;

  const WidgetBlocoLeia({
    super.key,
    required this.blocoLeia,
    this.nestingLevel = 0,
    required this.area,
  });

  @override
  _WidgetBlocoLeiaState createState() => _WidgetBlocoLeiaState();
}

class _WidgetBlocoLeiaState extends State<WidgetBlocoLeia> {
  final TextEditingController mensagemController = TextEditingController();
  late String nomeVariavel;

  @override
  void initState() {
    super.initState();
    mensagemController.text = widget.blocoLeia.mensagem;
    nomeVariavel = widget.blocoLeia.nomeVariavel;
  }

  @override
  void dispose() {
    mensagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<BlocoBloc>().state;
    BlocoBase? blocoSelecionado;

    if (estado is EstadoBlocosAtualizados) {
      
      blocoSelecionado = estado.blocoSelecionado;
    }

    bool isSelecionado = blocoSelecionado == widget.blocoLeia;
    

    return GestureDetector(
      onTap: () {
        context.read<BlocoBloc>().add(SelecionarBloco(widget.blocoLeia, area: widget.area));
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 14, 46, 130), 
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
                    Icons.input_outlined,
                    color: Color.fromARGB(255, 225, 225, 225),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Leia ($nomeVariavel)',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 225, 225, 225),
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
                  controller: mensagemController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Mensagem',
                  ),
                  onTap: () {
                    // Limpar o texto quando o usuário clicar no campo
                    if (mensagemController.text == 'Digite Algo') {
                      mensagemController.clear();
                    }
                  },
                  onChanged: (value) {
                    // Atualizar a mensagem do bloco
                    final blocoLeiaAtualizado = widget.blocoLeia.copyWith(
                      mensagem: value,
                    );
                    context.read<BlocoBloc>().add(
                          AtualizarBlocoLeia(blocoLeiaAtualizado),
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

                if (novoNome != nomeVariavel && variaveisGlobais.containsKey(novoNome)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Uma variável com esse nome já existe.')),
                  );
                  return;
                }

                // Atualizar o nome da variável localmente
                setState(() {
                  nomeVariavel = novoNome;
                });

                // Atualizar o bloco
                final blocoLeiaAtualizado = widget.blocoLeia.copyWith(
                  nomeVariavel: novoNome,
                );
                context.read<BlocoBloc>().add(
                      AtualizarBlocoLeia(blocoLeiaAtualizado),
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
