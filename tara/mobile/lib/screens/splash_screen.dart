import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_storage.dart';
import '../state/auth_state.dart';
import '../state/profile_state.dart';
import 'menu_input_screen.dart';
import 'profile_screen.dart';
import '../widgets/tara_background.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/splash';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    var authState = ref.read(authControllerProvider);
    var attempts = 0;
    while (authState.isLoading && attempts < 10) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!mounted) {
        return;
      }
      authState = ref.read(authControllerProvider);
      attempts += 1;
    }
    final session = authState.valueOrNull;
    if (session != null) {
      await _navigateForSession();
    }
  }

  Future<void> _navigateForSession() async {
    try {
      await ref.read(profileControllerProvider.notifier).syncFromApi();
    } catch (_) {}
    if (!mounted) {
      return;
    }
    final profile = ref.read(profileControllerProvider);
    final routeName =
        profile.isComplete ? MenuInputScreen.routeName : ProfileScreen.routeName;
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthSession?>>(
      authControllerProvider,
      (previous, next) {
        if (!mounted) {
          return;
        }
        if (next.hasError) {
          final error = next.error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Falha no login: $error'),
            ),
          );
          return;
        }
        final session = next.valueOrNull;
        if (session != null) {
          _navigateForSession();
        }
      },
    );
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      body: TaraBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.92, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Image.asset(
                          'assets/icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tara',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pronto para montar sua refeição ideal?',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                if (authState.isLoading)
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  )
                else if (authState.valueOrNull == null)
                  SizedBox(
                    width: 220,
                    child: FilledButton.icon(
                      onPressed: () {
                        ref
                            .read(authControllerProvider.notifier)
                            .signInWithGoogle();
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Entrar com Google'),
                    ),
                  )
                else
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
