class ApiBases {
  static const main = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static const timeline = String.fromEnvironment(
    'TIMELINE_API_BASE_URL',
    defaultValue: 'http://localhost:8001/api/v1',
  );

  static const recommendation = String.fromEnvironment(
    'RECOMMENDATION_API_BASE_URL',
    defaultValue: 'http://localhost:8002/api/v1',
  );
}
