class Shelf {
  final int? id;
  final String name;
  final String? description;
  final int order;

  const Shelf({
    this.id,
    required this.name,
    this.description,
    this.order = 0,
  });
}