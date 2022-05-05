import 'package:appcenter_companion/repositories/repositories.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

part 'new_release_cubit.freezed.dart';

part 'new_release_state.dart';

class NewReleaseCubit extends Cubit<NewReleaseState> {
  NewReleaseCubit(GitHubRepository gitHubRepository)
      : _githubRepository = gitHubRepository,
        super(NewReleaseState.initial()) {
    _checkForNewRelease();
  }

  final GitHubRepository _githubRepository;

  void ignoreCurrentRelease({bool ignored = false}) {
    emit(
      state.maybeMap(
        availableVersion: (value) =>
            value.copyWith(currentReleaseIgnored: ignored),
        orElse: () => state,
      ),
    );
  }

  Future<void> _checkForNewRelease() async {
    final latestRelease = await _githubRepository.getLatestRelease();
    //final latestVersion = Version.parse(latestRelease.tagName);
    final latestVersion = Version.parse('1.8.0');
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion =
        Version.parse('${packageInfo.version}+${packageInfo.buildNumber}');
    if (currentVersion.compareTo(latestVersion) < 0) {
      emit(
        NewReleaseState.availableVersion(
          version: latestRelease.tagName,
          url: latestRelease.htmlUrl,
        ),
      );
    }
  }
}
