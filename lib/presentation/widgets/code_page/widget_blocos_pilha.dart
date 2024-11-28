import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guaruba/domain/entidades/blobo_base.dart';
import 'package:guaruba/domain/entidades/bloco_calculo.dart';
import 'package:guaruba/domain/entidades/bloco_enquanto.dart';
import 'package:guaruba/domain/entidades/bloco_leia.dart';
import 'package:guaruba/domain/entidades/bloco_variavel.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_bloc.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_estado.dart';
import 'package:guaruba/domain/entidades/bloco_mostre.dart';
import 'package:guaruba/domain/entidades/bloco_se.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_calculo.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_enquanto.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_leia.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_mostre.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_se.dart';
import 'package:guaruba/presentation/widgets/blocos/bloco_variavel.dart';
import '../../../domain/entidades/bloco_pare.dart';
import '../../blocs/gerenciamento_evento.dart';
import '../blocos/bloco_pare.dart';

class WidgetBlocosPilha extends StatelessWidget {
  const WidgetBlocosPilha({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
          children: [
            Container(
              color: const Color.fromARGB(255, 31, 31, 31),
              child: BlocBuilder<BlocoBloc, GerenciamentoEstado>(
                builder: (context, state) {
                  if (state is EstadoBlocosAtualizados) {
                    final blocos = state.blocos;
                    return ListView.builder(
                      itemCount: blocos.length,
                      itemBuilder: (context, index) {
                        final bloco = blocos[index];
                        return _construirWidgetBloco(bloco, null, 0);
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'Nenhum bloco adicionado',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                },
              ),
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: Builder(
                builder: (context) {
                  final estado = context.watch<BlocoBloc>().state;
                  if (estado is EstadoBlocosAtualizados && estado.blocoSelecionado != null) {
                    BlocoBase blocoSelecionado = estado.blocoSelecionado!;
                    String? areaSelecionada = estado.areaSelecionada;

                    // Determinar o contexto atual e a lista de blocos nesse contexto
                    List<BlocoBase> contextBlocos = _obterBlocosDoContexto(estado, blocoSelecionado, areaSelecionada);

                    // Verificar se existem blocos suficientes para mover
                    if (contextBlocos.length < 2) {
                      return const SizedBox.shrink();
                    }

                    // Encontrar a posição do bloco selecionado
                    int index = contextBlocos.indexWhere((b) => b.id == blocoSelecionado.id);

                    // Determinar quais botões mostrar
                    bool mostrarBotaoCima = index > 0;
                    bool mostrarBotaoBaixo = index < contextBlocos.length - 1;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (mostrarBotaoCima)
                          FloatingActionButton(
                            heroTag: 'moveUpButton',
                            onPressed: () {
                              context.read<BlocoBloc>().add(MoverBlocoParaCima(
                                bloco: blocoSelecionado,
                                area: areaSelecionada,
                              ));
                            },
                            child: const Icon(Icons.arrow_upward),
                          ),
                        const SizedBox(height: 8.0),
                        if (mostrarBotaoBaixo)
                          FloatingActionButton(
                            heroTag: 'moveDownButton',
                            onPressed: () {
                              context.read<BlocoBloc>().add(MoverBlocoParaBaixo(
                                bloco: blocoSelecionado,
                                area: areaSelecionada,
                              ));
                            },
                            child: const Icon(Icons.arrow_downward),
                          ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ]
      ),
    );
  }
  List<BlocoBase> _obterBlocosDoContexto(GerenciamentoEstado estado, BlocoBase blocoSelecionado, String? areaSelecionada) {
    if (estado is EstadoBlocosAtualizados) {
      if (areaSelecionada == null) {
        // Contexto principal
        return estado.blocos;
      } else {
        // Contexto interno
        BlocoBase? blocoPai = _encontrarBlocoPai(estado.blocos, blocoSelecionado);
        if (blocoPai != null) {
          if (blocoPai is BlocoSe) {
            if (areaSelecionada == 'ENTAO') {
              return blocoPai.blocosEntao;
            } else if (areaSelecionada == 'SENAO') {
              return blocoPai.blocosSenao;
            }
          } else if (blocoPai is BlocoEnquanto) {
            if (areaSelecionada == 'INTERNOS') {
              return blocoPai.blocosInternos;
            }
          }
        }
      }
    }
    return [];
  }

  BlocoBase? _encontrarBlocoPai(List<BlocoBase> blocos, BlocoBase blocoProcurado) {
    for (var bloco in blocos) {
      if (bloco is BlocoSe) {
        if (bloco.blocosEntao.contains(blocoProcurado) || bloco.blocosSenao.contains(blocoProcurado)) {
          return bloco;
        }
        // Recursão para blocos aninhados
        BlocoBase? blocoPai = _encontrarBlocoPai(bloco.blocosEntao, blocoProcurado) ??
            _encontrarBlocoPai(bloco.blocosSenao, blocoProcurado);
        if (blocoPai != null) {
          return blocoPai;
        }
      } else if (bloco is BlocoEnquanto) {
        if (bloco.blocosInternos.contains(blocoProcurado)) {
          return bloco;
        }
        // Recursão para blocos aninhados
        BlocoBase? blocoPai = _encontrarBlocoPai(bloco.blocosInternos, blocoProcurado);
        if (blocoPai != null) {
          return blocoPai;
        }
      }
    }
    return null;
  }

  Widget _construirWidgetBloco(BlocoBase bloco, String? area, int nestingLevel) {
    Widget widgetBloco;

    if (bloco is BlocoMostre) {
      widgetBloco = WidgetBlocoMostre(
        blocoMostre: bloco,
        area: area,
      );
    } else if (bloco is BlocoLeia) {
      widgetBloco = WidgetBlocoLeia(
        blocoLeia: bloco,
        area: area,
      );
    } else if (bloco is BlocoVariavel) {
      widgetBloco = WidgetBlocoVariavel(
        blocoVariavel: bloco,
        area: area,
      );
    } else if (bloco is BlocoCalculo) {
      widgetBloco = WidgetBlocoCalculo(
        blocoCalculo: bloco,
        area: area,
      );
    } else if (bloco is BlocoPare) {
      widgetBloco = WidgetBlocoPare(
        blocoPare: bloco,
        area: area,
      );
    } else if (bloco is BlocoSe) {
      widgetBloco = WidgetBlocoSe(
        blocoSe: bloco,
        area: area,
      );
    } else if (bloco is BlocoEnquanto) {
      widgetBloco = WidgetBlocoEnquanto(
        blocoEnquanto: bloco,
        area: area,
      );
    } else {
      return const SizedBox();
    }

    return Padding(
      key: ValueKey(bloco.id),
      padding: const EdgeInsets.all(8.0),
      child: widgetBloco,
    );
  }
}
