import 'package:appcenter_companion/repositories/github_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';

import 'models/new_release.dart';

class ReleaseRepository {
  ReleaseRepository({
    required GitHubRepository githubRepository,
  }) : _githubRepository = githubRepository;

  final GitHubRepository _githubRepository;

  Future<SharedPreferences> get _sharedPreferences =>
      SharedPreferences.getInstance();

  Future<List<String>> get _ignoredVersions => _sharedPreferences
      .then((prefs) => prefs.getStringList(_keyIgnoredVersions) ?? []);

  Future<bool> _setIgnoredVersions(List<String> ignoredVersions) =>
      _sharedPreferences.then(
        (prefs) => prefs.setStringList(_keyIgnoredVersions, ignoredVersions),
      );

  final _keyIgnoredVersions = 'ignoredVersions';

  Future<NewRelease?> newVersionAvailable() async {
    final latestRelease = await _githubRepository.getLatestRelease();
    final latestVersion = Version.parse(latestRelease.tagName);
    final ignoredVersions = await _ignoredVersions;

    if (ignoredVersions.contains(latestVersion.toString())) {
      return null;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion =
        Version.parse('${packageInfo.version}+${packageInfo.buildNumber}');
    if (currentVersion.compareTo(latestVersion) < 0) {
      return NewRelease(
        version: latestVersion.toString(),
        downloadUrl: latestRelease.htmlUrl,
      );
    }
    return null;
  }

  Future<void> ignoreRelease({
    bool ignored = true,
    required String version,
  }) async {
    final ignoredVersions = await _ignoredVersions;
    if (ignored && !ignoredVersions.contains(version)) {
      ignoredVersions.add(version);
    }
    if (!ignored && ignoredVersions.contains(version)) {
      ignoredVersions.remove(version);
    }
    await _setIgnoredVersions(ignoredVersions);
  }
}
