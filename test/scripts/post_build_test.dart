import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('post_build.dart release script', () {
    late Directory tempDir;
    late String scriptPath;
    late String packageConfig;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('post_build_test_');
      scriptPath = p.normalize(
        p.join(Directory.current.path, 'scripts', 'post_build.dart'),
      );
      packageConfig = p.normalize(
        p.join(Directory.current.path, '.dart_tool', 'package_config.json'),
      );
    });

    tearDown(() {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    Future<ProcessResult> runScript(Directory dir) {
      return Process.run(
        'dart',
        ['--packages=$packageConfig', scriptPath],
        workingDirectory: dir.path,
        runInShell: true,
      );
    }

    test('aborts with exit code 1 when worktree is dirty', () async {
      await Process.run('git', ['init'], workingDirectory: tempDir.path);
      await Process.run('git', [
        'config',
        'user.name',
        'Test User',
      ], workingDirectory: tempDir.path);
      await Process.run('git', [
        'config',
        'user.email',
        'test@example.com',
      ], workingDirectory: tempDir.path);

      // Create an untracked/dirty file
      File(p.join(tempDir.path, 'dirty.txt')).writeAsStringSync('dirty');

      final result = await runScript(tempDir);

      expect(result.exitCode, equals(1));
      expect(result.stderr.toString(), contains('worktree is dirty'));
    });

    test('aborts with exit code 1 when pubspec.yaml is missing', () async {
      await Process.run('git', ['init'], workingDirectory: tempDir.path);
      await Process.run('git', [
        'config',
        'user.name',
        'Test User',
      ], workingDirectory: tempDir.path);
      await Process.run('git', [
        'config',
        'user.email',
        'test@example.com',
      ], workingDirectory: tempDir.path);

      File(p.join(tempDir.path, 'init.txt')).writeAsStringSync('init');
      await Process.run('git', ['add', '.'], workingDirectory: tempDir.path);
      await Process.run('git', [
        'commit',
        '-m',
        'initial',
      ], workingDirectory: tempDir.path);

      final result = await runScript(tempDir);

      expect(result.exitCode, equals(1));
      expect(
        result.stderr.toString(),
        contains('post-build release tagging failed'),
      );
    });

    test(
      'aborts with exit code 1 when version is missing or empty in pubspec.yaml',
      () async {
        await Process.run('git', ['init'], workingDirectory: tempDir.path);
        await Process.run('git', [
          'config',
          'user.name',
          'Test User',
        ], workingDirectory: tempDir.path);
        await Process.run('git', [
          'config',
          'user.email',
          'test@example.com',
        ], workingDirectory: tempDir.path);

        File(
          p.join(tempDir.path, 'pubspec.yaml'),
        ).writeAsStringSync('name: test_app\n');
        await Process.run('git', ['add', '.'], workingDirectory: tempDir.path);
        await Process.run('git', [
          'commit',
          '-m',
          'add pubspec without version',
        ], workingDirectory: tempDir.path);

        final result = await runScript(tempDir);

        expect(result.exitCode, equals(1));
        expect(
          result.stderr.toString(),
          contains('invalid or missing version in pubspec.yaml'),
        );
      },
    );

    test(
      'aborts with exit code 1 when version is blank whitespace in pubspec.yaml',
      () async {
        await Process.run('git', ['init'], workingDirectory: tempDir.path);
        await Process.run('git', [
          'config',
          'user.name',
          'Test User',
        ], workingDirectory: tempDir.path);
        await Process.run('git', [
          'config',
          'user.email',
          'test@example.com',
        ], workingDirectory: tempDir.path);

        File(
          p.join(tempDir.path, 'pubspec.yaml'),
        ).writeAsStringSync('name: test_app\nversion: "   "\n');
        await Process.run('git', ['add', '.'], workingDirectory: tempDir.path);
        await Process.run('git', [
          'commit',
          '-m',
          'add pubspec with blank version',
        ], workingDirectory: tempDir.path);

        final result = await runScript(tempDir);

        expect(result.exitCode, equals(1));
        expect(
          result.stderr.toString(),
          contains('version in pubspec.yaml cannot be empty'),
        );
      },
    );
  });
}
