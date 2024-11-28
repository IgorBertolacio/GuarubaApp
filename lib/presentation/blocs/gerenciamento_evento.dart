import 'package:equatable/equatable.dart';
import 'package:guaruba/domain/entidades/blobo_base.dart';
import 'package:guaruba/domain/entidades/bloco_calculo.dart';
import 'package:guaruba/domain/entidades/bloco_enquanto.dart';
import 'package:guaruba/domain/entidades/bloco_leia.dart';
import 'package:guaruba/domain/entidades/bloco_mostre.dart';
import 'package:guaruba/domain/entidades/bloco_se.dart';
import 'package:guaruba/domain/entidades/bloco_variavel.dart';

abstract class GerenciamentoEvento extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdicionarBloco extends GerenciamentoEvento {
  final BlocoBase bloco;

  AdicionarBloco(this.bloco);

  @override
  List<Object?> get props => [bloco];
}

class SelecionarBloco extends GerenciamentoEvento {
  final BlocoBase bloco;
  final String? area;

  SelecionarBloco(this.bloco, {this.area});

  @override
  List<Object?> get props => [bloco, area];
}

class SelecionarArea extends GerenciamentoEvento {
  final BlocoBase bloco;
  final String area;

  SelecionarArea({required this.bloco, required this.area});

  @override
  List<Object?> get props => [bloco, area];
}

class AtualizarBlocoSe extends GerenciamentoEvento {
  final BlocoSe blocoSeAtualizado;

  AtualizarBlocoSe(this.blocoSeAtualizado);

  @override
  List<Object?> get props => [blocoSeAtualizado];
}

class AtualizarBlocoMostre extends GerenciamentoEvento {
  final BlocoMostre blocoMostreAtualizado;

  AtualizarBlocoMostre(this.blocoMostreAtualizado);

  @override
  List<Object?> get props => [blocoMostreAtualizado];
}

class ExcluirBloco extends GerenciamentoEvento {
  final BlocoBase bloco;

  ExcluirBloco(this.bloco);

  @override
  List<Object?> get props => [bloco];
}

class ExcluirTodosBlocos extends GerenciamentoEvento {
  @override
  List<Object?> get props => [];
}

class AtualizarBlocoLeia extends GerenciamentoEvento {
  final BlocoLeia blocoLeiaAtualizado;

  AtualizarBlocoLeia(this.blocoLeiaAtualizado);

  @override
  List<Object?> get props => [blocoLeiaAtualizado];
}

class AtualizarBlocoVariavel extends GerenciamentoEvento {
  final BlocoVariavel blocoVariavelAtualizado;

  AtualizarBlocoVariavel(this.blocoVariavelAtualizado);

  @override
  List<Object?> get props => [blocoVariavelAtualizado];
}

class AtualizarBlocoCalculo extends GerenciamentoEvento {
  final BlocoCalculo blocoCalculoAtualizado;

  AtualizarBlocoCalculo(this.blocoCalculoAtualizado);

  @override
  List<Object?> get props => [blocoCalculoAtualizado];
}

class AtualizarBlocoEnquanto extends GerenciamentoEvento {
  final BlocoEnquanto blocoEnquantoAtualizado;

  AtualizarBlocoEnquanto(this.blocoEnquantoAtualizado);

  @override
  List<Object?> get props => [blocoEnquantoAtualizado];
}

class AtualizarSelecaoAreaBlocoSe extends GerenciamentoEvento {
  final BlocoSe blocoSeAtualizado;

  AtualizarSelecaoAreaBlocoSe(this.blocoSeAtualizado);
}
class MoverBlocoParaCima extends GerenciamentoEvento {
  final BlocoBase bloco;
  final String? area;

  MoverBlocoParaCima({required this.bloco, this.area});
}

class MoverBlocoParaBaixo extends GerenciamentoEvento {
  final BlocoBase bloco;
  final String? area;

  MoverBlocoParaBaixo({required this.bloco, this.area});
}
