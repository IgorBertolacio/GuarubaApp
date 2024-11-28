import 'blobo_base.dart';
import 'package:collection/collection.dart';

class BlocoSe extends BlocoBase {
  final String nomeVariavel; // Novo campo adicionado
  final String expressaoEsquerda;
  final String operador;
  final String expressaoDireita;
  final List<BlocoBase> blocosEntao;
  final List<BlocoBase> blocosSenao;
  final String selecaoArea;

  const BlocoSe({
    required super.id,
    required this.nomeVariavel, // Adicionado ao construtor
    required this.expressaoEsquerda,
    required this.operador,
    required this.expressaoDireita,
    required this.blocosEntao,
    required this.blocosSenao,
    required this.selecaoArea
  });

  BlocoSe copyWith({
    String? id,
    String? nomeVariavel,
    String? expressaoEsquerda,
    String? operador,
    String? expressaoDireita,
    List<BlocoBase>? blocosEntao,
    List<BlocoBase>? blocosSenao,
    String? selecaoArea,
  }) {
    return BlocoSe(
      id: id ?? this.id,
      nomeVariavel: nomeVariavel ?? this.nomeVariavel,
      expressaoEsquerda: expressaoEsquerda ?? this.expressaoEsquerda,
      operador: operador ?? this.operador,
      expressaoDireita: expressaoDireita ?? this.expressaoDireita,
      blocosEntao: blocosEntao ?? this.blocosEntao,
      blocosSenao: blocosSenao ?? this.blocosSenao,
      selecaoArea: selecaoArea ?? this.selecaoArea,
    );
  }



  @override
  List<Object?> get props => [
    id,
    nomeVariavel,
    expressaoEsquerda,
    operador,
    expressaoDireita,
    selecaoArea,
    const DeepCollectionEquality().hash(blocosEntao),
    const DeepCollectionEquality().hash(blocosSenao),
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final BlocoSe typedOther = other as BlocoSe;
    return id == typedOther.id &&
        nomeVariavel == typedOther.nomeVariavel && // Adicionado ao == operator
        expressaoEsquerda == typedOther.expressaoEsquerda &&
        operador == typedOther.operador &&
        expressaoDireita == typedOther.expressaoDireita &&
        const DeepCollectionEquality().equals(blocosEntao, typedOther.blocosEntao) &&
        const DeepCollectionEquality().equals(blocosSenao, typedOther.blocosSenao);
  }

  @override
  int get hashCode => Object.hash(
    id,
    nomeVariavel, // Incluído no hashCode
    expressaoEsquerda,
    operador,
    expressaoDireita,
    const DeepCollectionEquality().hash(blocosEntao),
    const DeepCollectionEquality().hash(blocosSenao),
  );
}
