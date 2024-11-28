import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guaruba/domain/entidades/blobo_base.dart';
import 'package:guaruba/domain/entidades/bloco_calculo.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_bloc.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_evento.dart';
import 'package:guaruba/presentation/blocs/gerenciamento_estado.dart';

class WidgetBlocoCalculo extends StatefulWidget {
  final BlocoCalculo blocoCalculo;
  final String? area;
  final int nestingLevel;

  const WidgetBlocoCalculo({
    super.key,
    required this.blocoCalculo,
    required this.area,
    this.nestingLevel = 0,
  });

  @override
  _WidgetBlocoCalculoState createState() => _WidgetBlocoCalculoState();
}

class _WidgetBlocoCalculoState extends State<WidgetBlocoCalculo> {
  List<TextEditingController> numeroControllers = [];
  List<String> operadoresSelecionados = [];
  late String nomeVariavel;

  @override
  void initState() {
    super.initState();
    nomeVariavel = widget.blocoCalculo.nomeVariavel;

    // Inicializar controllers e operadores a partir do bloco
    for (var numero in widget.blocoCalculo.numeros) {
      numeroControllers.add(TextEditingController(text: numero));
    }

    operadoresSelecionados = List.from(widget.blocoCalculo.operadores);
  }

  @override
  void dispose() {
    for (var controller in numeroControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<BlocoBloc>().state;
    BlocoBase? blocoSelecionado;

    if (estado is EstadoBlocosAtualizados) {
      blocoSelecionado = estado.blocoSelecionado;
    }

    bool isSelecionado = blocoSelecionado == widget.blocoCalculo;

    return GestureDetector(
      onTap: () {
        context.read<BlocoBloc>().add(SelecionarBloco(widget.blocoCalculo, area: widget.area));
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 102, 136, 9),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 6.0,
            ),
          ],
          border: isSelecionado
              ? Border.all(
            color: Colors.yellowAccent,
            width: 2.0,
          )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do Bloco
            GestureDetector(
              onTap: () {
                _mostrarDialogoEditarVariavel(context);
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.calculate_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Cálculo ($nomeVariavel)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            // Lista de campos de números e operadores
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: numeroControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      // Se não for o primeiro número, exibe o operador anterior
                      if (index > 0)
                        DropdownButton<String>(
                          value: operadoresSelecionados[index - 1],
                          dropdownColor: const Color.fromARGB(255, 102, 136, 9),
                          underline: Container(),
                          items: ['+', '-', '*', '/'].map((String valor) {
                            return DropdownMenuItem<String>(
                              value: valor,
                              child: Text(
                                valor,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (novoValor) {
                            setState(() {
                              operadoresSelecionados[index - 1] = novoValor!;
                            });
                            _atualizarBlocoCalculo();
                          },
                        ),
                      // Campo do número
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextField(
                            controller: numeroControllers[index],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Num ou @Variável',
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) {
                              _atualizarBlocoCalculo();
                            },
                          ),
                        ),
                      ),
                      // Botão para remover este número e operador
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            if (numeroControllers.length > 1) {
                              numeroControllers.removeAt(index);
                              if (index > 0) {
                                operadoresSelecionados.removeAt(index - 1);
                              } else if (operadoresSelecionados.isNotEmpty) {
                                operadoresSelecionados.removeAt(0);
                              }
                            }
                          });
                          _atualizarBlocoCalculo();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12.0),
            // Botão para adicionar mais números e operadores
            Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8.0), // corresponder ao formato do botão
                ),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      numeroControllers.add(TextEditingController());
                      operadoresSelecionados.add('+'); // Operador padrão
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Adicionar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.greenAccent.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _atualizarBlocoCalculo() {
    final novosNumeros = numeroControllers.map((controller) => controller.text).toList();
    final novosOperadores = List<String>.from(operadoresSelecionados);

    final blocoAtualizado = widget.blocoCalculo.copyWith(
      numeros: novosNumeros,
      operadores: novosOperadores,
    );
    context.read<BlocoBloc>().add(
      AtualizarBlocoCalculo(blocoAtualizado),
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
                final blocoAtualizado = widget.blocoCalculo.copyWith(
                  nomeVariavel: novoNome,
                );
                context.read<BlocoBloc>().add(
                  AtualizarBlocoCalculo(blocoAtualizado),
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
