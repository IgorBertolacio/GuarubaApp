// bloco_calculo.dart
import 'blobo_base.dart';

class BlocoCalculo extends BlocoBase {
  final String nomeVariavel;
  final List<String> numeros;
  final List<String> operadores;

  const BlocoCalculo({
    required super.id,
    required this.nomeVariavel,
    required this.numeros,
    required this.operadores,
  });

  BlocoCalculo copyWith({
    String? id,
    String? nomeVariavel,
    List<String>? numeros,
    List<String>? operadores,
  }) {
    return BlocoCalculo(
      id: id ?? this.id,
      nomeVariavel: nomeVariavel ?? this.nomeVariavel,
      numeros: numeros ?? this.numeros,
      operadores: operadores ?? this.operadores,
    );
  }

  @override
  List<Object?> get props => [id, nomeVariavel, numeros, operadores];
}
