import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen presenting app version, PokeAPI attribution, legal disclaimers, and open source licenses.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key, this.packageInfoFuture, this.urlLauncher});

  /// Optional injected [Future<PackageInfo>] for testing.
  final Future<PackageInfo>? packageInfoFuture;

  /// Optional injected URL launcher handler for testing.
  final Future<bool> Function(Uri url)? urlLauncher;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late Future<PackageInfo> _packageInfoFuture;

  static const String pokeApiUrl = 'https://pokeapi.co';
  static const String gitHubUrl = 'https://github.com/gabriarceus/pokefinder';
  static const String issuesUrl =
      'https://github.com/gabriarceus/pokefinder/issues';

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = widget.packageInfoFuture ?? _loadPackageInfo();
  }

  @override
  void didUpdateWidget(AboutPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageInfoFuture != widget.packageInfoFuture) {
      setState(() {
        _packageInfoFuture = widget.packageInfoFuture ?? _loadPackageInfo();
      });
    }
  }

  Future<PackageInfo> _loadPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (_) {
      return PackageInfo(
        appName: 'PokéFinder',
        packageName: 'com.gabriarceus.pokefinder',
        version: '—',
        buildNumber: '—',
      );
    }
  }

  Future<void> _openUrl(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) return;
    try {
      final launcher =
          widget.urlLauncher ??
          (u) => launchUrl(u, mode: LaunchMode.externalApplication);
      final launched = await launcher(uri);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(urlString),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(urlString),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.aboutPokeFinder,
          style: const TextStyle(color: AppPalette.onBrandRed),
        ),
        backgroundColor: AppPalette.brandRed,
        iconTheme: const IconThemeData(color: AppPalette.onBrandRed),
      ),
      body: FutureBuilder<PackageInfo>(
        future: _packageInfoFuture,
        builder: (context, snapshot) {
          final isWaiting = snapshot.connectionState == ConnectionState.waiting;
          final version = snapshot.data?.version;
          final buildNumber = snapshot.data?.buildNumber;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // Header with logo and app identity
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppPalette.brandRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.catching_pokemon,
                        size: 48,
                        color: AppPalette.brandRed,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'PokéFinder',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isWaiting)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        '${t.aboutVersion(version: version ?? '—')} (${t.aboutBuildNumber(buildNumber: buildNumber ?? '—')})',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      t.aboutAppDescription,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),

              // Section: Data & Attribution
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  t.aboutDataSource,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.cloud_download_outlined),
                  title: Text(t.aboutDataSourceDescription),
                  subtitle: Text(
                    pokeApiUrl,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                  onTap: () => _openUrl(context, pokeApiUrl),
                ),
              ),
              const Divider(),

              // Section: Disclaimer
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  t.aboutDisclaimer,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    t.aboutDisclaimerText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.4,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const Divider(),

              // Section: Legal & Licenses
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  t.aboutOpenSourceLicenses,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.policy_outlined),
                title: Text(t.aboutOpenSourceLicenses),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'PokéFinder',
                    applicationVersion: version != null && buildNumber != null
                        ? '$version+$buildNumber'
                        : null,
                    applicationIcon: const Icon(
                      Icons.catching_pokemon,
                      color: AppPalette.brandRed,
                      size: 40,
                    ),
                  );
                },
              ),
              const Divider(),

              // Section: Source Code & Community
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  t.aboutSourceCode,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.code_rounded),
                title: Text(t.aboutGitHubRepository),
                subtitle: const Text(gitHubUrl),
                trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                onTap: () => _openUrl(context, gitHubUrl),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: Text(t.aboutReportIssue),
                subtitle: const Text(issuesUrl),
                trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                onTap: () => _openUrl(context, issuesUrl),
              ),
            ],
          );
        },
      ),
    );
  }
}
