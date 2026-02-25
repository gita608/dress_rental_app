import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dress_rental_app/core/providers/app_provider.dart';
import 'package:dress_rental_app/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('Login screen shows Sign In and Email fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AppProvider(),
          child: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
