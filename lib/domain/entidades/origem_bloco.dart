enum OrigemBloco { principal, aninhado, entao, senao, internos, }

extension OrigemBlocoExtension on OrigemBloco {
  String get area {
    switch (this) {
      case OrigemBloco.entao:
        return 'ENTAO';
      case OrigemBloco.senao:
        return 'SENAO';
      case OrigemBloco.internos:
        return 'INTERNOS';
      default:
        return '';
    }
  }
}
