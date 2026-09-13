import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// User preferences state for theme, measurements, audio, and cache metrics.
class PreferencesState extends Equatable {
  const PreferencesState({
    this.themeMode = ThemeMode.system,
    this.unitSystem = UnitSystem.metric,
    this.autoPlayCry = false,
    this.cryVolume = 1.0,
    this.cacheSizeBytes = 0,
  });

  /// Active application theme mode.
  final ThemeMode themeMode;

  /// Active measurement unit system.
  final UnitSystem unitSystem;

  /// Whether cries automatically play upon opening the detail view.
  final bool autoPlayCry;

  /// Playback volume for Pokémon cries (0.0 to 1.0).
  final double cryVolume;

  /// Approximate cache size in bytes.
  final int cacheSizeBytes;

  PreferencesState copyWith({
    ThemeMode? themeMode,
    UnitSystem? unitSystem,
    bool? autoPlayCry,
    double? cryVolume,
    int? cacheSizeBytes,
  }) {
    return PreferencesState(
      themeMode: themeMode ?? this.themeMode,
      unitSystem: unitSystem ?? this.unitSystem,
      autoPlayCry: autoPlayCry ?? this.autoPlayCry,
      cryVolume: cryVolume ?? this.cryVolume,
      cacheSizeBytes: cacheSizeBytes ?? this.cacheSizeBytes,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    unitSystem,
    autoPlayCry,
    cryVolume,
    cacheSizeBytes,
  ];
}

/// Manages persistent application settings and preferences.
@lazySingleton
class PreferencesCubit extends HydratedCubit<PreferencesState> {
  PreferencesCubit(
    this._logger,
    this._getCacheSizeUseCase,
    this._clearCacheUseCase,
  ) : super(const PreferencesState());

  static const _prefix = 'PreferencesCubit';
  final EnLogger _logger;
  final GetCacheSizeUseCase _getCacheSizeUseCase;
  final ClearCacheUseCase _clearCacheUseCase;

  /// Sets the application theme mode.
  void setThemeMode(ThemeMode mode) {
    _logger.info('Setting theme mode: $mode', prefix: _prefix);
    emit(state.copyWith(themeMode: mode));
  }

  /// Sets the measurement unit system.
  void setUnitSystem(UnitSystem unit) {
    _logger.info('Setting unit system: $unit', prefix: _prefix);
    emit(state.copyWith(unitSystem: unit));
  }

  /// Sets whether cries should automatically play on detail view load.
  void setAutoPlayCry(bool autoPlay) {
    _logger.info('Setting auto-play cry: $autoPlay', prefix: _prefix);
    emit(state.copyWith(autoPlayCry: autoPlay));
  }

  /// Sets the Pokémon cry playback volume.
  void setCryVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    emit(state.copyWith(cryVolume: clamped));
  }

  /// Refreshes the approximate cache size.
  Future<void> refreshCacheSize() async {
    final result = await _getCacheSizeUseCase();
    result.fold(
      (failure) =>
          _logger.error('Failed to get cache size: $failure', prefix: _prefix),
      (bytes) => emit(state.copyWith(cacheSizeBytes: bytes)),
    );
  }

  /// Clears repository cache and refreshes cache size.
  Future<void> clearCache() async {
    _logger.info('Clearing application cache', prefix: _prefix);
    final result = await _clearCacheUseCase();
    result.fold(
      (failure) =>
          _logger.error('Failed to clear cache: $failure', prefix: _prefix),
      (_) {
        emit(state.copyWith(cacheSizeBytes: 0));
        refreshCacheSize();
      },
    );
  }

  @override
  PreferencesState fromJson(Map<String, dynamic> json) {
    final themeIndex = json['themeMode'] as int?;
    final themeMode =
        (themeIndex != null &&
            themeIndex >= 0 &&
            themeIndex < ThemeMode.values.length)
        ? ThemeMode.values[themeIndex]
        : ThemeMode.system;

    final unitIndex = json['unitSystem'] as int?;
    final unitSystem =
        (unitIndex != null &&
            unitIndex >= 0 &&
            unitIndex < UnitSystem.values.length)
        ? UnitSystem.values[unitIndex]
        : UnitSystem.metric;

    final autoPlayCry = json['autoPlayCry'] as bool? ?? false;
    final cryVolume = (json['cryVolume'] as num?)?.toDouble() ?? 1.0;

    return PreferencesState(
      themeMode: themeMode,
      unitSystem: unitSystem,
      autoPlayCry: autoPlayCry,
      cryVolume: cryVolume.clamp(0.0, 1.0),
    );
  }

  @override
  Map<String, dynamic> toJson(PreferencesState state) => {
    'themeMode': state.themeMode.index,
    'unitSystem': state.unitSystem.index,
    'autoPlayCry': state.autoPlayCry,
    'cryVolume': state.cryVolume,
  };
}
