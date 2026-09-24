import 'package:flutter/material.dart';

class FloatingBurger extends StatefulWidget {
  const FloatingBurger({super.key});

  @override
  State<FloatingBurger> createState() => _FloatingBurgerState();
}

class _FloatingBurgerState extends State<FloatingBurger> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); 

    _animation = Tween<double>(begin: 5, end: -20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Container(
        alignment: Alignment.center,
        child: Image.asset('assets/burger-hero.png', fit: BoxFit.cover),
      ),
    );
  }
}