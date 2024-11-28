import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guaruba/domain/entidades/blobo_base.dart';
import 'package:guaruba/domain/entidades/bloco_calculo.dart';
import 'package:guaruba/domain/entidades/bloco_enquanto.dart';
import 'package:guaruba/domain/entidades/bloco_leia.dart';
import 'package:guaruba/domain/entidades/bloco_mostre.dart';
import 'package:guaruba/domain/entidades/bloco_pare.dart';
import 'package:guaruba/domain/entidades/bloco_se.dart';
import 'package:guaruba/domain/entidades/bloco_variavel.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_calculo.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_enquanto.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_leia.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_mostre.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_variavel.dart';
import '../../../domain/entidades/origem_bloco.dart';
import '../../blocs/gerenciamento_bloc.dart';
import '../../blocs/gerenciamento_evento.dart';
import '../../blocs/gerenciamento_estado.dart';
import 'bloco_pare.dart';

class WidgetBlocoSe extends StatefulWidget {
  final BlocoSe blocoSe;
  final String? area;

  const WidgetBlocoSe({
    super.key,
    required this.blocoSe,
    required this.area,
  });

  @override
  _WidgetBlocoSeState createState() => _WidgetBlocoSeState();
}


Color _getBackgroundColor() {
  return const Color.fromARGB(255, 238, 203, 1); // Cor padrão
}
class _WidgetBlocoSeState extends State<WidgetBlocoSe> {
  final TextEditingController esquerdaController = TextEditingController();
  final TextEditingController direitaController = TextEditingController();
  String operadorSelecionado = '==';

  @override
  void initState() {
    super.initState();
    esquerdaController.text = widget.blocoSe.expressaoEsquerda;
    direitaController.text = widget.blocoSe.expressaoDireita;
    operadorSelecionado = widget.blocoSe.operador;
  }

  @override
  void dispose() {
    esquerdaController.dispose();
    direitaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verificar se este bloco está selecionado
    final estado = context.watch<BlocoBloc>().state;
    BlocoBase? blocoSelecionado;
    String? areaSelecionada;

    if (estado is EstadoBlocosAtualizados) {
      areaSelecionada = estado.areaSelecionada;
      blocoSelecionado = estado.blocoSelecionado;
    }

    bool isSelecionado = blocoSelecionado == widget.blocoSe;
    bool isEntaoSelecionado =
        blocoSelecionado == widget.blocoSe && areaSelecionada == 'ENTAO';
    bool isSenaoSelecionado =
        blocoSelecionado == widget.blocoSe && areaSelecionada == 'SENAO';

    return GestureDetector(
      onTap: () {
        context.read<BlocoBloc>().add(SelecionarBloco(widget.blocoSe, area: widget.area));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8.0),
          border: isSelecionado
              ? Border.all(color: Colors.yellowAccent, width: 2.0)
              : null,
        ),
        child: Column(
          children: [
            // Linha com Ícone e Nome "Se"
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.black),
                  SizedBox(width: 8.0),
                  Text(
                    'Se',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ],
              ),
            ),
            // Linha Condição com Expressões e Operador
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Expressão 1 com borda
                  Expanded(
                    child: TextField(
                      controller: esquerdaController,
                      decoration: const InputDecoration(
                        hintText: 'Expressão 1',
                        hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      onChanged: (value) {
                        final blocoAtualizado = widget.blocoSe.copyWith(
                          expressaoEsquerda: value,
                        );
                        context
                            .read<BlocoBloc>()
                            .add(AtualizarBlocoSe(blocoAtualizado));
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Operador
                  DropdownButton<String>(
                    value: operadorSelecionado,
                    dropdownColor: const Color.fromARGB(255, 238, 203, 1),
                      underline: Container(),
                    items: ['==', '!=', '>', '<', '>=', '<='].map((String valor) {
                      return DropdownMenuItem<String>(
                        value: valor,
                        child: Text(
                          valor,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (novoValor) {
                      setState(() {
                        operadorSelecionado = novoValor!;
                      });
                      final blocoAtualizado = widget.blocoSe.copyWith(
                        operador: novoValor,
                      );
                      context
                          .read<BlocoBloc>()
                          .add(AtualizarBlocoSe(blocoAtualizado));
                    },
                  ),
                  const SizedBox(width: 8.0),
                  // Expressão 2 com borda
                  Expanded(
                    child: TextField(
                      controller: direitaController,
                      decoration: const InputDecoration(
                        hintText: 'Expressão 2',
                        hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      onChanged: (value) {
                        final blocoAtualizado = widget.blocoSe.copyWith(
                          expressaoDireita: value,
                        );
                        context
                            .read<BlocoBloc>()
                            .add(AtualizarBlocoSe(blocoAtualizado));
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            // Seção Então
            GestureDetector(
              onTap: () {
                context
                    .read<BlocoBloc>()
                    .add(SelecionarArea(bloco: widget.blocoSe, area: 'ENTAO'));
              },
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                  color: isEntaoSelecionado
                      ? const Color.fromARGB(255, 84, 92, 0)
                      : const Color.fromARGB(255, 104, 115, 0),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.black54,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text('Então', style: TextStyle(color: Colors.white70, fontSize: 16,
                        )),
                      Container(
                        constraints: const BoxConstraints(minHeight: 100),
                        child: _buildBlocos(
                            widget.blocoSe.blocosEntao, OrigemBloco.entao),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Seção Senão
            GestureDetector(
              onTap: () {
                context
                    .read<BlocoBloc>()
                    .add(SelecionarArea(bloco: widget.blocoSe, area: 'SENAO'));
              },
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: isSenaoSelecionado
                        ? const Color.fromARGB(255, 36, 48, 0)
                        : const Color.fromARGB(255, 56, 68, 0),
                      borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.black54,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text('Senão', style: TextStyle(color: Colors.white70, fontSize: 16
                       )),
                      Container(
                        constraints: const BoxConstraints(minHeight: 100),
                        child: _buildBlocos(
                            widget.blocoSe.blocosSenao, OrigemBloco.senao),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlocos(List<BlocoBase> blocos, OrigemBloco origem) {
  if (blocos.isEmpty) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 31, 31, 31),
        border: Border.all(color: Colors.white70),
        borderRadius: BorderRadius.circular(8.0),
      ),
      height: 100,
      child: const Center(
        child: Text(
          'Clique para adicionar blocos',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }  else {
    return Column(
      children: blocos.map((bloco) {
        return Padding(
          key: ValueKey(bloco.id),
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _construirWidgetBloco(bloco, origem.area),
        );
      }).toList(),
    );
  }
}

}
Widget _construirWidgetBloco(BlocoBase bloco, String area) {
  if (bloco is BlocoMostre) {
    return WidgetBlocoMostre(
      blocoMostre: bloco,
      area: area,
    );
  } else if (bloco is BlocoLeia) {
    return WidgetBlocoLeia(
      blocoLeia: bloco,
      area: area,
    );
  } else if (bloco is BlocoVariavel) {
    return WidgetBlocoVariavel(
      blocoVariavel: bloco,
      area: area,
    );
  } else if (bloco is BlocoCalculo) {
    return WidgetBlocoCalculo(
      blocoCalculo: bloco,
      area: area,
    );
  } else if (bloco is BlocoPare) {
    return WidgetBlocoPare(
      blocoPare: bloco,
      area: area,
    );
  } else if (bloco is BlocoSe) {
    return WidgetBlocoSe(
      blocoSe: bloco,
      area: area,
    );
  } else if (bloco is BlocoEnquanto) {
    return WidgetBlocoEnquanto(
      blocoEnquanto: bloco,
      area: area,
    );
  } else {
    return const SizedBox.shrink();
  }
}


