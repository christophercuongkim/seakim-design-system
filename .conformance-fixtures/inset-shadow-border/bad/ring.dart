class Ring extends StatelessWidget {
  const Ring({super.key});
  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[BoxShadow(color: c.surfaceCard, spreadRadius: 2)],
      ),
    );
  }
}
