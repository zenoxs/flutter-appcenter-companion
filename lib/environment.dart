class Environment {
  final String appcenterApiUrl;
  final String githubRepoApiUrl;

  Environment({
    required this.appcenterApiUrl,
    required this.githubRepoApiUrl,
  });

  factory Environment.fromEnvironment() {
    return Environment(
      appcenterApiUrl: const String.fromEnvironment(
        'APPCENTER_API_URL',
        defaultValue: 'https://api.appcenter.ms/v0.1/',
      ),
      githubRepoApiUrl: const String.fromEnvironment(
        'GITHUB_REPO_API_URL',
        defaultValue:
            'https://api.github.com/repos/zenoxs/appcenter-companion/',
      ),
    );
  }
}
