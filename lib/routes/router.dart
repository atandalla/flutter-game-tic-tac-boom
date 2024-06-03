import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/game_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/register_screen.dart';


final goRouterProvider = Provider((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const MenuScreen();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/game',
        builder: (BuildContext context, GoRouterState state) {
          return GameScreen();
        },
      ),
      GoRoute(
        path: '/score',
        builder: (BuildContext context, GoRouterState state) {
          return ScoresScreen();
        },
      ),
      GoRoute(
        path: '/confirm_card',
        builder: (BuildContext context, GoRouterState state) {
          return ConfirmCardScreen();
        },
      ),
      GoRoute(
        path: '/reveal_card',
        builder: (BuildContext context, GoRouterState state) {
          return RevealCardScreen();
        },
      ),
      GoRoute(
        path: '/dice',
        builder: (BuildContext context, GoRouterState state) {
          return DiceScreen();
        },
      ),
      GoRoute(
        path: '/play',
        builder: (BuildContext context, GoRouterState state) {
          return PlayScreen();
        },
      ),
    ],
    debugLogDiagnostics: true,
  );
});