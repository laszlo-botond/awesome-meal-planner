import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal.dart';
import '../models/meal_fetch_result.dart';
import '../models/my_plate_recipe_dto.dart';
import 'meal_api_exception.dart';
import 'meal_data_source.dart';

/// HTTP implementation backed by the public MyPlate.food recipe API.
///
/// The list endpoint is cheap (no key, calories and image per recipe) but the
/// nutrient table, ingredients and directions live in the detail endpoint, so
/// the source orchestrates a small fan-out of detail requests. The client is
/// injected for testability and a hard cap keeps the fan-out bounded.
class MyPlateMealDataSource implements MealDataSource {
  static const String _baseUrl = 'https://myplate.food/api/v1';
  static const int _pageSize = 8;
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  MyPlateMealDataSource({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<MealFetchResult> getMeals({String query = ''}) async {
    final summaries = await _fetchSummaries(query);
    if (summaries.isEmpty) {
      return const MealFetchResult(meals: <Meal>[]);
    }

    final details = await Future.wait(
      summaries.map((summary) => _fetchDetail(summary.slug)),
      eagerError: true,
    );

    final meals = <Meal>[];
    for (var index = 0; index < details.length; index++) {
      final detail = details[index];
      if (detail != null) {
        meals.add(detail.toMeal(category: summaries[index].category));
      }
    }

    return MealFetchResult(meals: List<Meal>.unmodifiable(meals));
  }

  Future<List<({String slug, String category})>> _fetchSummaries(
    String query,
  ) async {
    final uri = Uri.parse('$_baseUrl/recipes').replace(
      queryParameters: <String, String>{
        'limit': '$_pageSize',
        if (query.isNotEmpty) 'q': query,
      },
    );

    final body = await _get(uri);
    final decoded = _decode(body);

    final results = decoded['results'];
    if (results is! List) {
      throw const MealResponseException('The recipe list had an invalid format.');
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => (
            slug: item['slug']?.toString() ?? '',
            category: item['category']?.toString() ?? '',
          ),
        )
        .where((summary) => summary.slug.isNotEmpty)
        .toList();
  }

  Future<MyPlateRecipeDetail?> _fetchDetail(String slug) async {
    final uri = Uri.parse('$_baseUrl/recipes/${Uri.encodeComponent(slug)}');

    try {
      final body = await _get(uri);
      return MyPlateRecipeDetail.fromJson(_decode(body));
    } on MealServerException catch (error) {
      // A single stale slug must not fail the whole feed.
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<String> _get(Uri uri) async {
    final http.Response response;

    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const MealNetworkException();
    } on http.ClientException {
      throw const MealNetworkException();
    } on Object catch (error) {
      throw MealResponseException('Could not complete the request: $error');
    }

    if (response.statusCode != 200) {
      throw MealServerException(response.statusCode);
    }
    return response.body;
  }

  Map<String, dynamic> _decode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } on Object {
      throw const MealResponseException('Could not decode the API response.');
    }
  }
}
