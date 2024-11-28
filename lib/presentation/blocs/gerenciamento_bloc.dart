import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guaruba/domain/entidades/blobo_base.dart';
import 'package:guaruba/domain/entidades/bloco_calculo.dart';
import 'package:guaruba/domain/entidades/bloco_enquanto.dart';
import 'package:guaruba/domain/entidades/bloco_leia.dart';
import 'package:guaruba/domain/entidades/bloco_mostre.dart';
import 'package:guaruba/domain/entidades/bloco_se.dart';
import 'package:guaruba/domain/entidades/bloco_variavel.dart';
import 'gerenciamento_evento.dart';
import 'gerenciamento_estado.dart';


class BlocoBloc extends Bloc<GerenciamentoEvento, GerenciamentoEstado> {
  List<BlocoBase> blocosAdicionados = [];
  BlocoBase? blocoSelecionado;
  String? areaSelecionada;

  BlocoBloc() : super(EstadoInicial()) {
    on<AdicionarBloco>(_onAdicionarBloco);
    on<SelecionarBloco>(_onSelecionarBloco);
    on<SelecionarArea>(_onSelecionarArea);
    on<AtualizarBlocoSe>(_onAtualizarBlocoSe);
    on<AtualizarBlocoMostre>(_onAtualizarBlocoMostre);
    on<AtualizarBlocoLeia>(_onAtualizarBlocoLeia);
    on<AtualizarBlocoVariavel>(_onAtualizarBlocoVariavel);
    on<ExcluirBloco>(_onExcluirBloco);
    on<ExcluirTodosBlocos>(_onExcluirTodosBlocos);
    on<AtualizarBlocoCalculo>(_onAtualizarBlocoCalculo);
    on<AtualizarBlocoEnquanto>(_onAtualizarBlocoEnquanto);
    on<AtualizarSelecaoAreaBlocoSe>(_onAtualizarSelecaoAreaBlocoSe);
    on<MoverBlocoParaCima>(_onMoverBlocoParaCima);
    on<MoverBlocoParaBaixo>(_onMoverBlocoParaBaixo);
  }
  void _onAtualizarSelecaoAreaBlocoSe(
      AtualizarSelecaoAreaBlocoSe event, Emitter<GerenciamentoEstado> emit) {
    blocoSelecionado = event.blocoSeAtualizado;
    blocosAdicionados =
        _atualizarBlocoNaLista(blocosAdicionados, event.blocoSeAtualizado);
    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }

  void _onAdicionarBloco(AdicionarBloco event, Emitter<GerenciamentoEstado> emit) {
    print('--- Evento AdicionarBloco recebido ---');
    print('ID do Bloco: ${event.bloco.id}');
    print('Tipo do Bloco: ${event.bloco.runtimeType}');

    if (blocoSelecionado != null && areaSelecionada != null) {
      print('Bloco Selecionado: ${blocoSelecionado!.id} (${blocoSelecionado.runtimeType})');
      print('Área Selecionada: $areaSelecionada');

      if (blocoSelecionado is BlocoSe) {
        BlocoSe blocoSeSelecionado = blocoSelecionado as BlocoSe;
        List<BlocoBase> blocosEntao = List.from(blocoSeSelecionado.blocosEntao);
        List<BlocoBase> blocosSenao = List.from(blocoSeSelecionado.blocosSenao);

        if (areaSelecionada == 'ENTAO') {
          blocosEntao.add(event.bloco);
          print('Bloco ${event.bloco.id} adicionado à seção ENTÃO do BlocoSe ${blocoSeSelecionado.id}');
        } else if (areaSelecionada == 'SENAO') {
          blocosSenao.add(event.bloco);
          print('Bloco ${event.bloco.id} adicionado à seção SENÃO do BlocoSe ${blocoSeSelecionado.id}');
        }

        BlocoSe blocoSeAtualizado = blocoSeSelecionado.copyWith(
          blocosEntao: blocosEntao,
          blocosSenao: blocosSenao,
        );

        print('Atualizando BlocoSe: ${blocoSeAtualizado.id}');
        print('Número de blocos ENTÃO: ${blocoSeAtualizado.blocosEntao.length}');
        print('Número de blocos SENÃO: ${blocoSeAtualizado.blocosSenao.length}');

        blocosAdicionados = _atualizarBlocoNaLista(blocosAdicionados, blocoSeAtualizado);
        blocoSelecionado = blocoSeAtualizado;
      } else if (blocoSelecionado is BlocoEnquanto) {
        BlocoEnquanto blocoEnquantoSelecionado = blocoSelecionado as BlocoEnquanto;
        List<BlocoBase> blocosInternos = List.from(blocoEnquantoSelecionado.blocosInternos);

        if (areaSelecionada == 'INTERNOS') {
          print('Antes de adicionar: blocosInternos.length = ${blocosInternos.length}');
          blocosInternos.add(event.bloco);
          print('Bloco ${event.bloco.id} adicionado à área INTERNOS do BlocoEnquanto ${blocoEnquantoSelecionado.id}');
          print('Depois de adicionar: blocosInternos.length = ${blocosInternos.length}');
        } else {
          print('Área selecionada não é INTERNOS, é $areaSelecionada');
        }

        BlocoEnquanto blocoEnquantoAtualizado = blocoEnquantoSelecionado.copyWith(
          blocosInternos: blocosInternos,
        );

        print('Atualizando BlocoEnquanto: ${blocoEnquantoAtualizado.id}');
        print('Número de blocos INTERNOS: ${blocoEnquantoAtualizado.blocosInternos.length}');

        blocosAdicionados = _atualizarBlocoNaLista(blocosAdicionados, blocoEnquantoAtualizado);
        blocoSelecionado = blocoEnquantoAtualizado;
      } else {
        blocosAdicionados.add(event.bloco);
        print('Bloco ${event.bloco.id} adicionado à lista principal');
        areaSelecionada = null;
      }

      emit(EstadoBlocosAtualizados(
        List.from(blocosAdicionados),
        blocoSelecionado: blocoSelecionado,
        areaSelecionada: areaSelecionada,
      ));
      print('--- Estado Emitido ---');
      print('Blocos adicionados: ${blocosAdicionados.length}');
      print('Bloco selecionado: ${blocoSelecionado?.id ?? 'Nenhum'}');
      print('Área selecionada: ${areaSelecionada ?? 'Nenhuma'}');
      print('------------------------');
    } else {
      blocosAdicionados.add(event.bloco);
      print('Bloco ${event.bloco.id} adicionado à lista principal (sem área selecionada)');
      emit(EstadoBlocosAtualizados(
        List.from(blocosAdicionados),
        blocoSelecionado: blocoSelecionado,
        areaSelecionada: areaSelecionada,
      ));
      print('--- Estado Emitido ---');
      print('Blocos adicionados: ${blocosAdicionados.length}');
      print('Bloco selecionado: ${blocoSelecionado?.id ?? 'Nenhum'}');
      print('Área selecionada: ${areaSelecionada ?? 'Nenhuma'}');
      print('------------------------');
    }
  }
  void _onSelecionarBloco(
      SelecionarBloco event, Emitter<GerenciamentoEstado> emit) {
    if (blocoSelecionado == event.bloco) {
      // Se o bloco já está selecionado, desmarque-o
      blocoSelecionado = null;
      areaSelecionada = null;
    } else {
      // Caso contrário, selecione o novo bloco
      blocoSelecionado = event.bloco;
      areaSelecionada = event.area; // Pode ser null ou um valor (e.g., 'ENTAO')
    }
    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }

  void _onSelecionarArea(
      SelecionarArea event, Emitter<GerenciamentoEstado> emit) {
        print('Evento SelecionarArea recebido: Bloco ${event.bloco.id}, Área: ${event.area}');
    if (event.bloco is BlocoSe || event.bloco is BlocoEnquanto) {
      areaSelecionada = event.area;
      blocoSelecionado = event.bloco;
    } else {
      // Caso contrário, não define a área selecionada
      areaSelecionada = null;
      blocoSelecionado = event.bloco;
    }

    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
     print('Estado emitido: Bloco selecionado = ${blocoSelecionado?.id}, Área selecionada = $areaSelecionada');
  }


  void _onAtualizarBlocoSe(
      AtualizarBlocoSe event, Emitter<GerenciamentoEstado> emit) {
    blocoSelecionado = event.blocoSeAtualizado;
    blocosAdicionados =
        _atualizarBlocoNaLista(blocosAdicionados, event.blocoSeAtualizado);
    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }


  void _onAtualizarBlocoMostre(
      AtualizarBlocoMostre event, Emitter<GerenciamentoEstado> emit) {
    blocosAdicionados =
        _atualizarBlocoNaLista(blocosAdicionados, event.blocoMostreAtualizado);
    if (blocoSelecionado is BlocoMostre &&
        blocoSelecionado?.id == event.blocoMostreAtualizado.id) {
      blocoSelecionado = event.blocoMostreAtualizado;
    }
    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }

  void _onExcluirBloco(ExcluirBloco event, Emitter<GerenciamentoEstado> emit) {
    // Remove the block from anywhere in the list
    blocosAdicionados = _removerBlocoDaLista(blocosAdicionados, event.bloco);

    // Deselect the block if it was the one deleted
    if (blocoSelecionado == event.bloco) {
      blocoSelecionado = null;
      areaSelecionada = null;
    }

    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }

  List<BlocoBase> _removerBlocoDaLista(
      List<BlocoBase> lista, BlocoBase blocoParaRemover) {
    List<BlocoBase> novaLista = [];

    for (var bloco in lista) {
      if (bloco.id == blocoParaRemover.id) {
        continue;
      } else if (bloco is BlocoSe) {
        final novosBlocosEntao =
            _removerBlocoDaLista(bloco.blocosEntao, blocoParaRemover);
        final novosBlocosSenao =
            _removerBlocoDaLista(bloco.blocosSenao, blocoParaRemover);

        BlocoSe blocoAtualizado = bloco.copyWith(
          blocosEntao: novosBlocosEntao,
          blocosSenao: novosBlocosSenao,
        );

        novaLista.add(blocoAtualizado);
      } else if (bloco is BlocoEnquanto) {
        final novosBlocosInternos =
            _removerBlocoDaLista(bloco.blocosInternos, blocoParaRemover);

        BlocoEnquanto blocoAtualizado = bloco.copyWith(
          blocosInternos: novosBlocosInternos,
        );

        novaLista.add(blocoAtualizado);
      } else {
        novaLista.add(bloco);
      }
    }

    return novaLista;
  }

  List<BlocoBase> _atualizarBlocoNaLista(List<BlocoBase> lista, BlocoBase blocoAtualizado) {
    return lista.map((bloco) {
      if (bloco.id == blocoAtualizado.id) {
        return blocoAtualizado;
      } else if (bloco is BlocoSe) {
        bool foundInEntao = _containsBloco(bloco.blocosEntao, blocoAtualizado.id);
        bool foundInSenao = _containsBloco(bloco.blocosSenao, blocoAtualizado.id);

        List<BlocoBase> blocosEntaoAtualizados = bloco.blocosEntao;
        List<BlocoBase> blocosSenaoAtualizados = bloco.blocosSenao;

        if (foundInEntao) {
          blocosEntaoAtualizados = _atualizarBlocoNaLista(bloco.blocosEntao, blocoAtualizado);
        }

        if (foundInSenao) {
          blocosSenaoAtualizados = _atualizarBlocoNaLista(bloco.blocosSenao, blocoAtualizado);
        }

        return bloco.copyWith(
          blocosEntao: blocosEntaoAtualizados != bloco.blocosEntao ? blocosEntaoAtualizados : null,
          blocosSenao: blocosSenaoAtualizados != bloco.blocosSenao ? blocosSenaoAtualizados : null,
        );
      } else if (bloco is BlocoEnquanto) {
        bool foundInInternos = _containsBloco(bloco.blocosInternos, blocoAtualizado.id);
        List<BlocoBase> blocosInternosAtualizados = bloco.blocosInternos;

        if (foundInInternos) {
          blocosInternosAtualizados = _atualizarBlocoNaLista(bloco.blocosInternos, blocoAtualizado);
        }
        return bloco.copyWith(
          blocosInternos: _atualizarBlocoNaLista(bloco.blocosInternos, blocoAtualizado),
        );
      } else {
        return bloco;
      }
    }).toList();
  }

  bool _containsBloco(List<BlocoBase> blocos, String id) {
    for (var bloco in blocos) {
      if (bloco.id == id) {
        return true;
      } else if (bloco is BlocoSe) {
        if (_containsBloco(bloco.blocosEntao, id) || _containsBloco(bloco.blocosSenao, id)) {
          return true;
        }
      } else if (bloco is BlocoEnquanto) {
        if (_containsBloco(bloco.blocosInternos, id)) {
          return true;
        }
      }
    }
    return false;
  }


  void _onExcluirTodosBlocos(
      ExcluirTodosBlocos event, Emitter<GerenciamentoEstado> emit) {
    blocosAdicionados.clear();
    blocoSelecionado = null;
    areaSelecionada = null;

    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }

  void _onAtualizarBlocoLeia(
      AtualizarBlocoLeia event, Emitter<GerenciamentoEstado> emit) {
    blocosAdicionados =
        _atualizarBlocoNaLista(blocosAdicionados, event.blocoLeiaAtualizado);
    if (blocoSelecionado is BlocoLeia &&
        blocoSelecionado?.id == event.blocoLeiaAtualizado.id) {
      blocoSelecionado = event.blocoLeiaAtualizado;
    }
    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }

  void _onAtualizarBlocoVariavel(
      AtualizarBlocoVariavel event, Emitter<GerenciamentoEstado> emit) {
    blocosAdicionados = _atualizarBlocoNaLista(
        blocosAdicionados, event.blocoVariavelAtualizado);
    if (blocoSelecionado is BlocoVariavel &&
        blocoSelecionado?.id == event.blocoVariavelAtualizado.id) {
      blocoSelecionado = event.blocoVariavelAtualizado;
    }
    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }

  void _onAtualizarBlocoCalculo(
      AtualizarBlocoCalculo event, Emitter<GerenciamentoEstado> emit) {
    blocosAdicionados =
        _atualizarBlocoNaLista(blocosAdicionados, event.blocoCalculoAtualizado);
    if (blocoSelecionado is BlocoCalculo &&
        blocoSelecionado?.id == event.blocoCalculoAtualizado.id) {
      blocoSelecionado = event.blocoCalculoAtualizado;
    }
    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }

  void _onAtualizarBlocoEnquanto(
      AtualizarBlocoEnquanto event, Emitter<GerenciamentoEstado> emit) {
    print('Updating BlocoEnquanto with ID: ${event.blocoEnquantoAtualizado.id}');

    blocosAdicionados = _atualizarBlocoNaLista(
        blocosAdicionados, event.blocoEnquantoAtualizado);

    // Debugging: Print the updated blocosAdicionados
    print('Updated blocosAdicionados: $blocosAdicionados');

    if (blocoSelecionado is BlocoEnquanto &&
        blocoSelecionado?.id == event.blocoEnquantoAtualizado.id) {
      blocoSelecionado = event.blocoEnquantoAtualizado;
    }
    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }

  void _onMoverBlocoParaCima(MoverBlocoParaCima event, Emitter<GerenciamentoEstado> emit) {
    if (event.area == null) {
      // Contexto principal
      _moverBlocoParaCimaNaLista(blocosAdicionados, event.bloco);
    } else {
      // Contexto interno
      blocosAdicionados = _atualizarBlocoMovido(blocosAdicionados, event.bloco, event.area!, moverParaCima: true);
    }

    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }


  void _onMoverBlocoParaBaixo(MoverBlocoParaBaixo event, Emitter<GerenciamentoEstado> emit) {
    if (event.area == null) {
      // Contexto principal
      _moverBlocoParaBaixoNaLista(blocosAdicionados, event.bloco);
    } else {
      // Contexto interno
      blocosAdicionados = _atualizarBlocoMovido(blocosAdicionados, event.bloco, event.area!, moverParaCima: false);
    }

    emit(EstadoBlocosAtualizados(
      List.from(blocosAdicionados),
      blocoSelecionado: blocoSelecionado,
      areaSelecionada: areaSelecionada,
    ));
  }

  void _moverBlocoParaCimaNaLista(List<BlocoBase> lista, BlocoBase bloco) {
    int index = lista.indexWhere((b) => b.id == bloco.id);
    if (index > 0) {
      var temp = lista[index - 1];
      lista[index - 1] = lista[index];
      lista[index] = temp;
    }
  }
  void _moverBlocoParaBaixoNaLista(List<BlocoBase> lista, BlocoBase bloco) {
    int index = lista.indexWhere((b) => b.id == bloco.id);
    if (index < lista.length - 1) {
      var temp = lista[index + 1];
      lista[index + 1] = lista[index];
      lista[index] = temp;
    }
  }
  List<BlocoBase> _atualizarBlocoMovido(List<BlocoBase> lista, BlocoBase blocoParaMover, String area, {required bool moverParaCima}) {
    return lista.map((bloco) {
      if (bloco is BlocoSe) {
        if (bloco.blocosEntao.contains(blocoParaMover) && area == 'ENTAO') {
          List<BlocoBase> blocosEntaoAtualizados = List.from(bloco.blocosEntao);
          if (moverParaCima) {
            _moverBlocoParaCimaNaLista(blocosEntaoAtualizados, blocoParaMover);
          } else {
            _moverBlocoParaBaixoNaLista(blocosEntaoAtualizados, blocoParaMover);
          }
          return bloco.copyWith(blocosEntao: blocosEntaoAtualizados);
        } else if (bloco.blocosSenao.contains(blocoParaMover) && area == 'SENAO') {
          List<BlocoBase> blocosSenaoAtualizados = List.from(bloco.blocosSenao);
          if (moverParaCima) {
            _moverBlocoParaCimaNaLista(blocosSenaoAtualizados, blocoParaMover);
          } else {
            _moverBlocoParaBaixoNaLista(blocosSenaoAtualizados, blocoParaMover);
          }
          return bloco.copyWith(blocosSenao: blocosSenaoAtualizados);
        } else {
          // Recursão
          BlocoSe blocoAtualizado = bloco.copyWith(
            blocosEntao: _atualizarBlocoMovido(bloco.blocosEntao, blocoParaMover, area, moverParaCima: moverParaCima),
            blocosSenao: _atualizarBlocoMovido(bloco.blocosSenao, blocoParaMover, area, moverParaCima: moverParaCima),
          );
          return blocoAtualizado;
        }
      } else if (bloco is BlocoEnquanto) {
        if (bloco.blocosInternos.contains(blocoParaMover) && area == 'INTERNOS') {
          List<BlocoBase> blocosInternosAtualizados = List.from(bloco.blocosInternos);
          if (moverParaCima) {
            _moverBlocoParaCimaNaLista(blocosInternosAtualizados, blocoParaMover);
          } else {
            _moverBlocoParaBaixoNaLista(blocosInternosAtualizados, blocoParaMover);
          }
          return bloco.copyWith(blocosInternos: blocosInternosAtualizados);
        } else {
          // Recursão
          BlocoEnquanto blocoAtualizado = bloco.copyWith(
            blocosInternos: _atualizarBlocoMovido(bloco.blocosInternos, blocoParaMover, area, moverParaCima: moverParaCima),
          );
          return blocoAtualizado;
        }
      } else {
        return bloco;
      }
    }).toList();
  }


}

