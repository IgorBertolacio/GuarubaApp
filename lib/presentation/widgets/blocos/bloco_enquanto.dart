import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guaruba/domain/entidades/blobo_base.dart';
import 'package:guaruba/domain/entidades/bloco_calculo.dart';
import 'package:guaruba/domain/entidades/bloco_enquanto.dart';
import 'package:guaruba/domain/entidades/bloco_leia.dart';
import 'package:guaruba/domain/entidades/bloco_mostre.dart';
import 'package:guaruba/domain/entidades/bloco_se.dart';
import 'package:guaruba/domain/entidades/bloco_variavel.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_bloc.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_estado.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_evento.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_calculo.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_leia.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_mostre.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_se.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_variavel.dart';
import '../../../domain/entidades/bloco_pare.dart';
import '../../../domain/entidades/origem_bloco.dart';
import '../../../domain/usecases/criar_variavel/criar_variavel.dart';
import 'bloco_pare.dart';

class WidgetBlocoEnquanto extends StatefulWidget {
  final BlocoEnquanto blocoEnquanto;
  final String? area;

  const WidgetBlocoEnquanto({
    super.key,
    required this.blocoEnquanto,
    required this.area,
  });

  @override
  _WidgetBlocoEnquantoState createState() => _WidgetBlocoEnquantoState();
}

class _WidgetBlocoEnquantoState extends State<WidgetBlocoEnquanto> {
  late TextEditingController variavelController;
  late TextEditingController valorComparacaoController;
  late TextEditingController valorIncrementoController;

  String operadorComparacaoSelecionado = '<';
  String operadorIncrementoSelecionado = '+';

  late FocusNode variavelFocusNode;

  @override
  void initState() {
    super.initState();
    variavelController = TextEditingController(text: widget.blocoEnquanto.variavel);
    valorComparacaoController = TextEditingController(text: widget.blocoEnquanto.valorComparacao);
    valorIncrementoController = TextEditingController(text: widget.blocoEnquanto.valorIncremento);
    operadorComparacaoSelecionado = widget.blocoEnquanto.operadorComparacao;
    operadorIncrementoSelecionado = widget.blocoEnquanto.operadorIncremento;
    variavelFocusNode = FocusNode();
    variavelFocusNode.addListener(_onVariavelFocusChange);
  }

  @override
  void didUpdateWidget(covariant WidgetBlocoEnquanto oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualizar os controladores se o blocoEnquanto mudar
    if (!const DeepCollectionEquality().equals(oldWidget.blocoEnquanto, widget.blocoEnquanto)) {
      variavelController.text = widget.blocoEnquanto.variavel;
      valorComparacaoController.text = widget.blocoEnquanto.valorComparacao;
      valorIncrementoController.text = widget.blocoEnquanto.valorIncremento;
      operadorComparacaoSelecionado = widget.blocoEnquanto.operadorComparacao;
      operadorIncrementoSelecionado = widget.blocoEnquanto.operadorIncremento;
    }
  }

  @override
  void dispose() {
    variavelController.dispose();
    valorComparacaoController.dispose();
    valorIncrementoController.dispose();
    variavelFocusNode.removeListener(_onVariavelFocusChange);
    variavelFocusNode.dispose();
    super.dispose();
  }

  void _onVariavelFocusChange() {
    if (!variavelFocusNode.hasFocus) {
      // Campo perdeu o foco, realizar a validação
      String nomeVariavel = variavelController.text.trim();
      if (nomeVariavel.startsWith('@')) {
        nomeVariavel = nomeVariavel.substring(1);
      }

      // Verificar se a variável já foi declarada
      bool variavelExiste = verificarVariavelDeclarada(nomeVariavel);

      if (!variavelExiste) {
        // Exibir a mensagem de aviso
        mostrarAvisoVariavelNaoDeclarada(context, nomeVariavel);
      }
    }
  }

  Color _getBackgroundColor() {

    return const Color.fromARGB(255, 224, 145, 1);

  }

  @override
  Widget build(BuildContext context) {
    bool avisoExibido = false;
    print('Construindo WidgetBlocoEnquanto: ${widget.blocoEnquanto.id}');
    print('Blocos internos: ${widget.blocoEnquanto.blocosInternos.length} blocos');

    // Verificar se este bloco está selecionado
    final estado = context.watch<BlocoBloc>().state;
    BlocoBase? blocoSelecionado;
    String? areaSelecionada;

    if (estado is EstadoBlocosAtualizados) {
      areaSelecionada = estado.areaSelecionada;
      blocoSelecionado = estado.blocoSelecionado;
    }

    bool isSelecionado = blocoSelecionado == widget.blocoEnquanto;
    bool isAreaSelecionada = blocoSelecionado == widget.blocoEnquanto &&
        areaSelecionada == 'INTERNOS';

    return GestureDetector(
      onTap: () {
        context.read<BlocoBloc>().add(SelecionarBloco(widget.blocoEnquanto, area: widget.area));
      },
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12.0),
          border: isSelecionado
              ? Border.all(color: Colors.yellowAccent, width: 2.0)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primeira Fileira: Ícone e Nome do Bloco
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(Icons.loop, color: Colors.white),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Enquanto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Segunda Fileira: Variável, Operador e Valor de Comparação
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: variavelController,
                    focusNode: variavelFocusNode, // Adicionar o FocusNode aqui
                    decoration: const InputDecoration(
                      hintText: '@Variável',
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (value) {
                      // Sanitizar o nome da variável
                      String nomeVariavel = value.trim();
                      if (nomeVariavel.startsWith('@')) {
                        nomeVariavel = nomeVariavel.substring(1);
                      }

                      // Atualizar o bloco com o nome da variável sanitizado
                      final blocoAtualizado = widget.blocoEnquanto.copyWith(
                        variavel: nomeVariavel,
                      );
                      context.read<BlocoBloc>().add(AtualizarBlocoEnquanto(blocoAtualizado));
                    },
                  ),
            ),
            const SizedBox(width: 8.0),

                // Operador de Comparação
                DropdownButton<String>(
                  value: operadorComparacaoSelecionado,
                  dropdownColor: const Color.fromARGB(255, 224, 145, 1),
                  iconEnabledColor: Colors.white,
                  underline: Container(), // Remove underline
                  items: ['==', '!=', '>', '<', '>=', '<='].map((String valor) {
                    return DropdownMenuItem<String>(
                      value: valor,
                      child: Text(
                        valor,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (novoValor) {
                    setState(() {
                      operadorComparacaoSelecionado = novoValor!;
                    });
                    final blocoAtualizado = widget.blocoEnquanto.copyWith(
                      operadorComparacao: novoValor,
                    );
                    context.read<BlocoBloc>().add(AtualizarBlocoEnquanto(blocoAtualizado));
                  },
                ),
                const SizedBox(width: 8.0),

                // Valor de Comparação
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: valorComparacaoController,
                    decoration: const InputDecoration(
                      hintText: 'Valor',
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final blocoAtualizado = widget.blocoEnquanto.copyWith(
                        valorComparacao: value,
                      );
                      context.read<BlocoBloc>().add(AtualizarBlocoEnquanto(blocoAtualizado));
                    },
                  ),
                ),
              ],
            ),
          ),

          // Terceira Fileira: Atualizar Operador e Valor de Incremento
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const Text(
                  'Atualizar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8.0),

                // Operador de Incremento
                DropdownButton<String>(
                  value: operadorIncrementoSelecionado,
                  dropdownColor: const Color.fromARGB(255, 224, 145, 1),
                  iconEnabledColor: Colors.white,
                  underline: Container(),
                  items: ['+', '-', '*', '/'].map((String valor) {
                    return DropdownMenuItem<String>(
                      value: valor,
                      child: Text(
                        valor,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (novoValor) {
                    setState(() {
                      operadorIncrementoSelecionado = novoValor!;
                    });
                    final blocoAtualizado = widget.blocoEnquanto.copyWith(
                      operadorIncremento: novoValor,
                    );
                    context.read<BlocoBloc>().add(AtualizarBlocoEnquanto(blocoAtualizado));
                  },
                ),
                const SizedBox(width: 8.0),

                // Valor de Incremento
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: valorIncrementoController,
                    decoration: const InputDecoration(
                      hintText: 'Valor',
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final blocoAtualizado = widget.blocoEnquanto.copyWith(
                        valorIncremento: value,
                      );
                      context.read<BlocoBloc>().add(AtualizarBlocoEnquanto(blocoAtualizado));
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8.0),
          // Área para blocos internos
          GestureDetector(
            onTap: () {
              context.read<BlocoBloc>().add(SelecionarArea(
                  bloco: widget.blocoEnquanto, area: 'INTERNOS'));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: isAreaSelecionada
                    ? const Color.fromARGB(255, 182, 118, 0)
                    : const Color.fromARGB(255, 224, 145, 1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.white70,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Faça',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    constraints: const BoxConstraints(minHeight: 100),
                    child: _buildBlocos(widget.blocoEnquanto.blocosInternos, OrigemBloco.internos),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),

    ),
    );
  }

  Widget _buildBlocos(List<BlocoBase> blocos, OrigemBloco origem) {
    if (blocos.isEmpty) {
      return Container(
        width: double.infinity,
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
    } else {
      return SingleChildScrollView(
        child: Column(
          children: blocos.map((bloco) {
           return Padding(
             key: ValueKey(bloco.id),
              padding: const EdgeInsets.symmetric(vertical: 4.0),
             child: _construirWidgetBloco(bloco, origem.area),
            );
          }).toList(),
        ),
      );
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
      print('Tipo de bloco não reconhecido: ${bloco.runtimeType}');
      return const SizedBox.shrink();
    }
  }
  bool verificarVariavelDeclarada(String nomeVariavel) {
    // Aqui você deve acessar a lista de variáveis declaradas
    // Isso pode variar dependendo de como você está gerenciando as variáveis

    // Exemplo usando variaveisGlobais
    return variaveisGlobais.containsKey(nomeVariavel);
  }
  void mostrarAvisoVariavelNaoDeclarada(BuildContext context, String nomeVariavel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('A variável "$nomeVariavel" não foi declarada.'),
        backgroundColor: Colors.red,
      ),
    );
  }


}
