import 'package:collection/collection.dart';
import 'blobo_base.dart';

class BlocoEnquanto extends BlocoBase {
  final String variavel;
  final String operadorComparacao;
  final String valorComparacao;
  final String operadorIncremento;
  final String valorIncremento;
  final List<BlocoBase> blocosInternos;

  const BlocoEnquanto({
    required super.id,
    required this.variavel,
    required this.operadorComparacao,
    required this.valorComparacao,
    required this.operadorIncremento,
    required this.valorIncremento,
    required this.blocosInternos,
  });

  BlocoEnquanto copyWith({
    String? id,
    String? variavel,
    String? operadorComparacao,
    String? valorComparacao,
    String? operadorIncremento,
    String? valorIncremento,
    List<BlocoBase>? blocosInternos,
  }) {
    return BlocoEnquanto(
      id: id ?? this.id,
      variavel: variavel ?? this.variavel,
      operadorComparacao: operadorComparacao ?? this.operadorComparacao,
      valorComparacao: valorComparacao ?? this.valorComparacao,
      operadorIncremento: operadorIncremento ?? this.operadorIncremento,
      valorIncremento: valorIncremento ?? this.valorIncremento,
      blocosInternos: blocosInternos ?? List.from(this.blocosInternos),
    );
  }



  @override
  List<Object?> get props => [
    id,
    variavel,
    operadorComparacao,
    valorComparacao,
    operadorIncremento,
    valorIncremento,
    const DeepCollectionEquality().hash(blocosInternos),
  ];
}
