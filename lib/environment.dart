class Environment {
  final String appcenterApiUrl;

  Environment({
    required this.appcenterApiUrl,
  });

  factory Environment.fromEnvironment() {
    return Environment(
      appcenterApiUrl: const String.fromEnvironment('APPCENTER_API_URL', defaultValue: 'https://api.appcenter.ms/v0.1'),
    );
  }
}
