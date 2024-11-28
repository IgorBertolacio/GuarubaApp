import 'blobo_base.dart';

class BlocoPare extends BlocoBase {
  const BlocoPare({required super.id});

  BlocoPare copyWith({String? id}) {
    return BlocoPare(
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [id];
}
