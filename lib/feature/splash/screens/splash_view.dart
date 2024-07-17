import 'dart:async';
import 'package:com.while.while_app/feature/splash/screens/animation/splash_animation.dart';
import 'package:com.while.while_app/feature/splash/screens/controller/splash_controller.dart';
import 'package:com.while.while_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fadeAnimation;
  Animation<double>? _bounceAnimation;
  List<String> letters = ['W', 'H', 'I', 'L', 'E'];
  List<Widget> animatedLetters = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2)).then((value) async {
      ref.read(sizeProvider.notifier).state = MediaQuery.of(context).size;
      final splashInitilise = ref.read(splashControllerProvider);
      splashInitilise.intializeWhile(context);
      splashInitilise.checkCondition(context);
    });
    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Create scale and fade animations
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    @override
    void dispose() {
      _controller!.dispose();
      super.dispose();
    }

    // Create a bounce animation
    _bounceAnimation = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _controller!.forward();

    animateLetters();
  }

  void animateLetters() {
    if (_currentIndex < letters.length) {
      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          setState(() {
            animatedLetters.add(
              Text(
                letters[_currentIndex],
                style: const TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
            _currentIndex++;
          });

          animateLetters();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackgroundParticles(),
          Center(
            child: AnimatedBuilder(
              animation: _controller!,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation!.value,
                  child: Opacity(
                    opacity: _fadeAnimation!.value,
                    child: Transform.translate(
                      offset: Offset(0, -_bounceAnimation!.value),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: animatedLetters,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
