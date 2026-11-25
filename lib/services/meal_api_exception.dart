/// Typed failures raised by the remote data source.
///
/// The ViewModel maps these to a small UI-facing failure enum, so widgets
/// never have to inspect HTTP status codes or parser errors themselves.
sealed class MealDataSourceException implements Exception {
  const MealDataSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The device could not reach the API (offline, DNS, timeout, ...).
final class MealNetworkException extends MealDataSourceException {
  const MealNetworkException()
      : super('Unable to reach the recipe service. Check your connection.');
}

/// The API answered, but with a non-success HTTP status.
final class MealServerException extends MealDataSourceException {
  final int statusCode;

  const MealServerException(this.statusCode)
      : super('The recipe service returned HTTP $statusCode.');
}

/// The response was successful but could not be decoded into recipes.
final class MealResponseException extends MealDataSourceException {
  const MealResponseException([String? message])
      : super(message ?? 'The recipe service returned an unexpected response.');
}
