import 'dart:async';

import 'package:flutter/material.dart';
import 'package:BotPal/utility/asset_manager.dart';
import 'package:BotPal/view/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _sizeAnimation =
        Tween<double>(begin: 0.1, end: 1.0).animate(_animationController);
    _opacityAnimation =
        Tween<double>(begin: 0.1, end: 1.0).animate(_animationController);

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _sizeAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage(AssetsManager.appIcon),
                      width: 300,
                      height: 300,
                    ),
                    Text(
                      "BOTPAL",
                      style:
                          GoogleFonts.poppins(fontSize: 40, letterSpacing: 2),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
