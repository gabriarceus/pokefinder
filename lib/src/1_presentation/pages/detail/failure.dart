import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
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

  final PokemonDetailFailure state;
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
      UnexpectedFailure() => Icons.error_outline_rounded,
    };
  }

  void _handleRetry(BuildContext context) {
    if (onRetry != null) {
      onRetry!();
      return;
    }
    if (pokemonName != null && pokemonName!.isNotEmpty) {
      context.read<PokemonDetailBloc>().add(FetchPokemonEvent(pokemonName!));
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
      context.go(AppRoutes.homeWithQuery(pokemonName ?? ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final icon = _iconForFailure(state.failure);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: t.backButton,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Image.asset(_kSadAzurillAsset, height: 120),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  borderRadius: 24,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
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
                          child: FilledButton.icon(
                            onPressed: () => _handleRetry(context),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(t.retryButton),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _handleEditSearch(context),
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(t.editSearchButton),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
