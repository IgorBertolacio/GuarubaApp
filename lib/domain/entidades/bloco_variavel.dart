import 'blobo_base.dart';

class BlocoVariavel extends BlocoBase {
  final String nomeVariavel;
  final String valor;

  const BlocoVariavel({
    required super.id,
    required this.nomeVariavel,
    required this.valor,
  });

  BlocoVariavel copyWith({
    String? id,
    String? nomeVariavel,
    String? valor,
  }) {
    return BlocoVariavel(
      id: id ?? this.id,
      nomeVariavel: nomeVariavel ?? this.nomeVariavel,
      valor: valor ?? this.valor,
    );
  }

  @override
  List<Object?> get props => [id, nomeVariavel, valor];
}
