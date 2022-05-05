import 'package:appcenter_companion/environment.dart';
import 'package:appcenter_companion/repositories/dto/dto.dart';
import 'package:dio/dio.dart';

class GitHubRepository {
  GitHubRepository({required Environment environment, Dio? dio})
      : _http = dio ?? Dio(BaseOptions(baseUrl: environment.githubRepoApiUrl));

  final Dio _http;

  Future<GitHubLatestReleaseDto> getLatestRelease() async {
    final response = await _http.get('releases/latest');
    return GitHubLatestReleaseDto.fromJson(response.data);
  }
}
