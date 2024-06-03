import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/game_provider.dart';
import '../widgets/animated_button.dart';
import 'register_screen.dart';


class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedButton(
                text: 'Comenzar Juego',
                onPressed: () => context.push('/register'),
      
              ),
              AnimatedButton(
                text: 'Personalizar',
                onPressed: () {
                  // Customization logic
                },
              ),
              AnimatedButton(
                text: 'Salir',
                onPressed: () {
                  // Exit logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
