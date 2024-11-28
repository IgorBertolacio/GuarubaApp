import 'blobo_base.dart';

class BlocoMostre extends BlocoBase {
  final String nomeVariavel;
  final String mensagem;

  const BlocoMostre({
    required super.id,
    required this.nomeVariavel,
    required this.mensagem,
  });

  BlocoMostre copyWith({
    String? id,
    String? nomeVariavel,
    String? mensagem,
  }) {
    return BlocoMostre(
      id: id ?? this.id,
      nomeVariavel: nomeVariavel ?? this.nomeVariavel,
      mensagem: mensagem ?? this.mensagem,
    );
  }

  @override
  List<Object?> get props => [id, nomeVariavel, mensagem];
}
