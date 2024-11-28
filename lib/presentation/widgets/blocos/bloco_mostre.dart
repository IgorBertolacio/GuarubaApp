import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guaruba/domain/entidades/blobo_base.dart';
import 'package:guaruba/domain/entidades/bloco_mostre.dart';
import 'package:guaruba/domain/usecases/criar_variavel/criar_variavel.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_bloc.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_evento.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_estado.dart';


class WidgetBlocoMostre extends StatefulWidget {
  final BlocoMostre blocoMostre;
  final String? area;
  final int nestingLevel;

  const WidgetBlocoMostre({
    super.key,
    required this.blocoMostre,
    required this.area,
    this.nestingLevel = 0,
  });

  @override
  _WidgetBlocoMostreState createState() => _WidgetBlocoMostreState();
}

class _WidgetBlocoMostreState extends State<WidgetBlocoMostre> {

  final TextEditingController messageController = TextEditingController();
  late String nomeVariavel;

  @override
  void initState() {
    super.initState();
    messageController.text = widget.blocoMostre.mensagem;
    nomeVariavel = widget.blocoMostre.nomeVariavel;
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<BlocoBloc>().state;
    BlocoBase? blocoSelecionado;
    if (estado is EstadoBlocosAtualizados) {
      blocoSelecionado = estado.blocoSelecionado;
    }

    bool isSelecionado = blocoSelecionado == widget.blocoMostre;

    return GestureDetector(
      onTap: () {
        context.read<BlocoBloc>().add(SelecionarBloco(
          widget.blocoMostre,
          area: widget.area,
        ));
      },


      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 29, 78, 10),
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
                    Icons.chat_outlined,
                    color: Color.fromARGB(255, 225, 225, 225),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Mostre ($nomeVariavel)',
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
                  controller: messageController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Mensagem',
                  ),
                  onTap: () {
                    // Limpar o texto quando o usuário clicar no campo
                    if (messageController.text == 'Olá Mundo') {
                      messageController.clear();
                    }
                  },
                  onChanged: (value) {
                    // Atualizar a mensagem do bloco
                    final blocoMostreAtualizado = widget.blocoMostre.copyWith(
                      mensagem: value,
                    );
                    context.read<BlocoBloc>().add(
                          AtualizarBlocoMostre(blocoMostreAtualizado),
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
                        content: Text('O nome da variável não pode ser vazio.')),
                  );
                  return;
                }

                if (novoNome != nomeVariavel && variaveisGlobais.containsKey(novoNome)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Uma variável com esse nome já existe.')),
                  );
                  return;
                }

                // Atualizar o nome da variável localmente
                setState(() {
                  nomeVariavel = novoNome;
                });

                // Atualizar o bloco
                final blocoMostreAtualizado = widget.blocoMostre.copyWith(
                  nomeVariavel: novoNome,
                );
                context.read<BlocoBloc>().add(
                      AtualizarBlocoMostre(blocoMostreAtualizado),
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
