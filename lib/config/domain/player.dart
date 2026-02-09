class Player {
  final String id;
  final String name;
  final String number;
  final String position;
  final String photoPath;
  // Para la alineación en el campo
  final double? top;
  final double? left;
  final double? right;

  const Player({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    required this.photoPath,
    this.top,
    this.left,
    this.right,
  });

  /// Abreviación corta de la posición para mostrar en el campo.
  String get positionAbbr {
    switch (position) {
      case 'Portero':
        return 'PT';
      case 'Lateral Izquierdo':
        return 'LI';
      case 'Lateral Derecho':
        return 'LD';
      case 'Central':
        return 'DFC';
      case 'Defensa':
        return 'DEF';
      case 'Mediocampista':
        return 'MC';
      case 'Mediocampista Central':
        return 'MC';
      case 'Mediocampista Ofensivo':
        return 'MCO';
      case 'Extremo Izquierdo':
        return 'EI';
      case 'Extremo Derecho':
        return 'ED';
      case 'Delantero':
        return 'DC';
      case 'Delantero Centro':
        return 'DC';
      default:
        // Tomar las iniciales de cada palabra
        return position
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join()
            .toUpperCase();
    }
  }

  /// Grupo de posición para agrupar en la lista.
  String get positionGroup {
    final p = position.toLowerCase();
    if (p.contains('portero')) return 'PORTERO';
    if (p.contains('lateral') || p.contains('central') || p.contains('defensa')) {
      return 'DEFENSAS';
    }
    if (p.contains('mediocampista') || p.contains('medio')) return 'MEDIOCAMPISTAS';
    if (p.contains('delantero') || p.contains('extremo')) return 'DELANTEROS';
    return 'OTROS';
  }
}
