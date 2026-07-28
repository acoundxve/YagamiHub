import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
          data: (business) => _PublicBusinessContent(business: business),
        ),
      ),
    );
  }
}

class _PublicBusinessContent extends StatelessWidget {
  const _PublicBusinessContent({required this.business});

  final PublicBusiness business;

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveMediaUrl(business.backgroundImageUrl);

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
          if (imageUrl != null)
            Container(color: Colors.black.withOpacity(0.45)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.storefront, size: 64, color: imageUrl != null ? Colors.white : null),
                  const SizedBox(height: 24),
                  Text(
                    business.businessName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: imageUrl != null ? Colors.white : null,
                        ),
                  ),
                  if (business.businessType != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      business.businessType!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: imageUrl != null ? Colors.white70 : null,
                          ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Text(
                    'Sitio impulsado por YagamiHub',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: imageUrl != null ? Colors.white60 : null,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
