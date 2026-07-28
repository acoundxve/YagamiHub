import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/api/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_providers.dart';
import 'features/auth/auth_providers.dart';

void main() {
  runApp(const ProviderScope(child: YagamiHubApp()));
}

class YagamiHubApp extends ConsumerWidget {
  const YagamiHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final backgroundUrl = resolveMediaUrl(ref.watch(authControllerProvider).tenant?.backgroundImageUrl);

    return MaterialApp.router(
      title: 'YagamiHub',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => _AppBackground(imageUrl: backgroundUrl, child: child ?? const SizedBox()),
    );
  }
}

class _AppBackground extends StatelessWidget {
  const _AppBackground({required this.imageUrl, required this.child});

  final String? imageUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Theme.of(context).colorScheme.surface),
        ),
        if (imageUrl != null)
          Positioned.fill(
            child: Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
          ),
        if (imageUrl != null)
          Positioned.fill(
            child: Container(color: (isDark ? Colors.black : Colors.white).withOpacity(0.55)),
          ),
        child,
      ],
    );
  }
}
