import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Placeholder(), // We'll replace this
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Placeholder(),
      ),
    ],
  );
}