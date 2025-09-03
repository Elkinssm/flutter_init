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
}
