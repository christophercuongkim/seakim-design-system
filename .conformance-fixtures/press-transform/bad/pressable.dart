class Pressable extends StatelessWidget {
  final bool pressed;
  const Pressable({super.key, required this.pressed});
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pressed ? 0.97 : 1.0,
      duration: SkMotion.instant,
      child: const SizedBox(),
    );
  }
}
