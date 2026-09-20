import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/surface_card.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

const _kSadAzurillAsset = 'assets/images/sad_azurill.png';

class DetailFailure extends StatelessWidget {
  const DetailFailure({
    super.key,
    required this.state,
    this.pokemonName,
    this.onRetry,
    this.onEditSearch,
  });

  final PokemonBlocFailure state;
  final String? pokemonName;
  final VoidCallback? onRetry;
  final VoidCallback? onEditSearch;

  IconData _iconForFailure(PokemonFailure failure) {
    return switch (failure) {
      PokemonNotFoundFailure() => Icons.search_off_rounded,
      NetworkUnavailableFailure() => Icons.wifi_off_rounded,
      RequestTimeoutFailure() => Icons.timer_off_outlined,
      RateLimitedFailure() => Icons.speed_rounded,
      ServerFailure() => Icons.cloud_off_rounded,
      InvalidResponseFailure() => Icons.data_object_rounded,
      StorageFailure() => Icons.storage_rounded,
      UnauthorizedFailure() => Icons.lock_outline_rounded,
      BadRequestFailure() => Icons.error_outline_rounded,
      RequestCancelledFailure() => Icons.cancel_outlined,
      UnexpectedFailure() => Icons.error_outline_rounded,
    };
  }

  void _handleRetry(BuildContext context) {
    if (onRetry != null) {
      onRetry!();
      return;
    }
    if (pokemonName != null && pokemonName!.isNotEmpty) {
      context.read<PokemonBloc>().add(FetchPokemonEvent(pokemonName!));
    }
  }

  void _handleEditSearch(BuildContext context) {
    if (onEditSearch != null) {
      onEditSearch!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      final query = pokemonName ?? '';
      context.go(
        query.isNotEmpty ? '/?query=${Uri.encodeComponent(query)}' : '/',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final icon = _iconForFailure(state.failure);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: t.backButton,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(_kSadAzurillAsset, scale: 2),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SurfaceCard(
                borderRadius: 24,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        state.failure.localizedMessage(context),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleRetry(context),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(t.retryButton),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleEditSearch(context),
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(t.editSearchButton),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
