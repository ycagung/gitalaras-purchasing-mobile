enum Environment { dev, staging, production }

class Config {
  final Environment environment;
  final String apiBaseUrl;

  const Config({required this.environment, required this.apiBaseUrl});

  // Get the current environment based on compile-time constants
  // You can change this by using --dart-define=ENV=staging or --dart-define=ENV=production
  static Environment getCurrentEnvironment() {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (env.toLowerCase()) {
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      case 'dev':
      default:
        return Environment.dev;
    }
  }

  // Factory constructor to create config based on current environment
  factory Config.fromEnvironment() {
    final env = getCurrentEnvironment();
    return Config.forEnvironment(env);
  }

  // Factory constructor to create config for a specific environment
  factory Config.forEnvironment(Environment environment) {
    switch (environment) {
      case Environment.dev:
        return const Config(
          environment: Environment.dev,
          apiBaseUrl: 'http://172.22.98.135:3000',
        );
      case Environment.staging:
        return const Config(
          environment: Environment.staging,
          apiBaseUrl:
              'https://api.gspro.seavihive.com', // TODO: Set staging API base URL
        );
      case Environment.production:
        return const Config(
          environment: Environment.production,
          apiBaseUrl: '', // TODO: Set production API base URL
        );
    }
  }

  // Static instance for easy access throughout the app
  static final Config instance = Config.fromEnvironment();
}
