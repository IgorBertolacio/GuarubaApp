import 'blobo_base.dart';

class BlocoLeia extends BlocoBase {
  final String nomeVariavel;
  final String mensagem;

  const BlocoLeia({
    required super.id,
    required this.nomeVariavel,
    required this.mensagem,
  });

 BlocoLeia copyWith({
    String? id,
    String? nomeVariavel,
    String? mensagem,
  }) {
    return BlocoLeia(
      id: id ?? this.id,
      nomeVariavel: nomeVariavel ?? this.nomeVariavel,
      mensagem: mensagem ?? this.mensagem,
    );
  }

  @override
  List<Object?> get props => [id, nomeVariavel, mensagem];
}