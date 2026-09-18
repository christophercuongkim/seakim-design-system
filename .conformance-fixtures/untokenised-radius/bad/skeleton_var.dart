class Block extends StatelessWidget {
  const Block({super.key, required this.radius});
  final double radius;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
    );
  }
}
