import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_providers.dart';
import 'public_business.dart';
import 'public_repository.dart';

final publicRepositoryProvider = Provider((ref) => PublicRepository(ref.watch(apiClientProvider)));

final publicBusinessProvider = FutureProvider.family<PublicBusiness, String>(
  (ref, slug) => ref.watch(publicRepositoryProvider).fetchBySlug(slug),
);

class PublicBusinessScreen extends ConsumerWidget {
  const PublicBusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slug = GoRouterState.of(context).pathParameters['slug']!;
    final businessAsync = ref.watch(publicBusinessProvider(slug));

    return Scaffold(
      body: Center(
        child: businessAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront_outlined, size: 56),
                const SizedBox(height: 16),
                Text('Este sitio no está disponible', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'El negocio no existe o todavía no ha publicado su sitio.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          data: (business) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront, size: 64),
                const SizedBox(height: 24),
                Text(
                  business.businessName,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                if (business.businessType != null) ...[
                  const SizedBox(height: 8),
                  Text(business.businessType!, style: Theme.of(context).textTheme.bodyLarge),
                ],
                const SizedBox(height: 32),
                Text(
                  'Sitio impulsado por YagamiHub',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
