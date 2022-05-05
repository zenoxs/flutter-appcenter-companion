import 'package:appcenter_companion/repositories/repositories.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_release_cubit.freezed.dart';
part 'new_release_state.dart';

class NewReleaseCubit extends Cubit<NewReleaseState> {
  NewReleaseCubit(ReleaseRepository releaseRepository)
      : _releaseRepository = releaseRepository,
        super(NewReleaseState.initial()) {
    _checkForNewRelease();
  }

  final ReleaseRepository _releaseRepository;

  Future<void> ignoreCurrentRelease({bool ignored = false}) async {
    final currentState = state;
    if (currentState is NewReleaseStateAvailableVersion) {
      await _releaseRepository.ignoreRelease(
        version: currentState.version,
        ignored: ignored,
      );
      emit(
        currentState.copyWith(currentReleaseIgnored: ignored),
      );
    }
  }

  Future<void> _checkForNewRelease() async {
    final newVersion = await _releaseRepository.newVersionAvailable();
    if (newVersion != null) {
      emit(
        NewReleaseState.availableVersion(
          version: newVersion.version,
          downloadUrl: newVersion.downloadUrl,
        ),
      );
    }
  }
}
