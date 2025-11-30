import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/register_screen.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/project/project_screen.dart';
import '../../ui/screens/board/board_screen.dart';
import '../../ui/screens/task/task_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Forgot Password')),
        ),
      ),

      // Main Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Project Routes
      GoRoute(
        path: '/project/:projectId',
        name: 'project',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ProjectScreen(projectId: projectId);
        },
        routes: [
          GoRoute(
            path: 'board/:boardId',
            name: 'board',
            builder: (context, state) {
              final projectId = state.pathParameters['projectId']!;
              final boardId = state.pathParameters['boardId']!;
              return BoardScreen(projectId: projectId, boardId: boardId);
            },
          ),
        ],
      ),

      // Task Route
      GoRoute(
        path: '/task/:taskId',
        name: 'task',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          return TaskDetailScreen(taskId: taskId);
        },
      ),

      // Other Routes
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Notifications')),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile')),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings')),
        ),
      ),
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('My Tasks')),
        ),
      ),
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Calendar')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

