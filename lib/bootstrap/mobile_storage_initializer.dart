import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path_provider/path_provider.dart';

/// Officially supported mobile target platforms for PokéFinder.
const Set<TargetPlatform> kSupportedPlatforms = {
  TargetPlatform.android,
  TargetPlatform.iOS,
};

/// Initializes application storage according to mobile data lifecycle requirements.
///
/// - Durable user state (such as language preferences via [HydratedBloc]) is placed
///   in the application documents directory to survive OS-level cache eviction.
/// - Disposable API response cache ([Hive]) is placed in the temporary directory
///   so that the OS can reclaim storage if space is constrained.
/// - Audio backend initialization ([JustAudioMediaKit]) is ensured for iOS audio support.
Future<void> initializeMobileStorage({
  Future<Directory> Function()? getDurableStorageDirectory,
  Future<Directory> Function()? getDisposableCacheDirectory,
  void Function()? initAudio,
}) async {
  final durableDir =
      await (getDurableStorageDirectory ?? getApplicationDocumentsDirectory)();
  final cacheDir =
      await (getDisposableCacheDirectory ?? getTemporaryDirectory)();

  // Initialize disposable Hive cache in temporary storage
  Hive.init(cacheDir.path);

  // Initialize media_kit as the audio backend for iOS OGG playback
  if (initAudio != null) {
    initAudio();
  } else {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      JustAudioMediaKit.ensureInitialized(iOS: true);
    }
  }

  // Initialize durable user preferences in documents storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(durableDir.path),
  );
}
