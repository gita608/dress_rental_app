import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dress_rental_app/core/providers/app_provider.dart';
import 'package:dress_rental_app/core/models/models.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppProvider initializes with default data', () async {
    final provider = AppProvider();
    await Future.delayed(const Duration(milliseconds: 100));
    expect(provider.dresses.length, greaterThanOrEqualTo(3));
    expect(provider.categories.length, greaterThanOrEqualTo(3));
    expect(provider.currentUser, isNotNull);
  });

  test('addDress increases dress count', () async {
    final provider = AppProvider();
    await Future.delayed(const Duration(milliseconds: 100));
    final initialCount = provider.dresses.length;
    provider.addDress(Dress(
      id: 'test-1',
      name: 'Test Dress',
      price: 999.0,
      description: 'Test',
      sizes: ['M'],
    ));
    expect(provider.dresses.length, initialCount + 1);
  });

  test('addCategory increases category count', () async {
    final provider = AppProvider();
    await Future.delayed(const Duration(milliseconds: 100));
    final initialCount = provider.categories.length;
    provider.addCategory(Category(
      id: 'test-cat',
      title: 'Test Category',
      description: 'Test desc',
    ));
    expect(provider.categories.length, initialCount + 1);
  });
}
