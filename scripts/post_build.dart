// ignore_for_file: avoid_print script messages

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as yaml;

/// post build hook.
///
/// - compose and push a git tag with the app version
///
/// Exits with a non-zero code as soon as a step fails.
Future<void> main(List<String> args) async {
  try {
    await _ensureCleanWorktree();
    final version = await _version();
    if (version.trim().isEmpty) {
      _abort('version in pubspec.yaml cannot be empty');
    }
    await _createAndPushGitTag(version, version);
  } catch (error) {
    _abort('post-build release tagging failed: $error');
  }
}

/// Verifies that the Git worktree is clean before tagging a release.
Future<void> _ensureCleanWorktree() async {
  final result = await Process.run('git', ['status', '--porcelain']);
  if (result.exitCode != 0) {
    _abort('unable to verify git status: ${result.stderr}');
  }

  final output = (result.stdout as String).trim();
  if (output.isNotEmpty) {
    _abort(
      'worktree is dirty. Commit or stash changes before tagging a release.',
    );
  }
}

/// return the `pubspec.yaml`
Future<yaml.YamlMap> _readPubspec() async {
  final yamlStr = await File(
    p.joinAll([Directory.current.path, 'pubspec.yaml']),
  ).readAsString();

  return yaml.loadYaml(yamlStr) as yaml.YamlMap;
}

Future<String> _version() async {
  final pubspec = await _readPubspec();
  final version = pubspec['version'];
  if (version == null || version is! String) {
    _abort('invalid or missing version in pubspec.yaml');
  }
  return version;
}

/// Creates the annotated tag [tagName] and pushes it to `origin`.
Future<void> _createAndPushGitTag(String tagName, String commitMessage) async {
  if (await _tagExists(tagName)) {
    _abort('tag $tagName already exists, bump the version in pubspec.yaml');
  }

  await _git([
    'tag',
    '-a',
    tagName,
    '-m',
    commitMessage,
  ], 'create tag $tagName');
  await _git(['push', 'origin', tagName], 'push tag $tagName');

  print('Pushed tag $tagName');
}

/// Whether a local tag named [tagName] is already present.
Future<bool> _tagExists(String tagName) async {
  final result = await Process.run('git', ['tag', '--list', tagName]);
  if (result.exitCode != 0) {
    _abort('unable to list tags: ${result.stderr}');
  }

  return (result.stdout as String).trim().isNotEmpty;
}

/// Runs a git command, aborting when it exits non-zero.
///
/// [description] names the attempted action in the error message.
Future<void> _git(List<String> args, String description) async {
  final result = await Process.run('git', args);
  if (result.exitCode != 0) {
    _abort('failed to $description: ${result.stderr}');
  }
}

/// Reports [message] on stderr and terminates with a non-zero exit code.
Never _abort(String message) {
  stderr.writeln('post_build: $message');
  exit(1);
}
