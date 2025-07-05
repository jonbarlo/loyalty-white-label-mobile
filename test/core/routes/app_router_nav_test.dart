import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_mobile_app/core/routes/app_router.dart';
import 'package:loyalty_mobile_app/core/providers/auth_provider.dart';

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  final bool _isAdmin;
  FakeAuthProvider(this._isAdmin);
  @override
  bool get isAdmin => _isAdmin;
  // Implement only what's needed for the test
  @override
  bool get isAuthenticated => true;
  // ignore: no_override
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildWithAuthProvider(bool isAdmin) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: FakeAuthProvider(isAdmin),
      child: MaterialApp(
        home: MainScaffold(child: Container()),
      ),
    );
  }

  testWidgets('Businesses button is visible for admin', (WidgetTester tester) async {
    await tester.pumpWidget(buildWithAuthProvider(true));
    expect(find.text('Businesses'), findsOneWidget);
  });

  testWidgets('Businesses button is hidden for non-admin', (WidgetTester tester) async {
    await tester.pumpWidget(buildWithAuthProvider(false));
    expect(find.text('Businesses'), findsNothing);
  });
} 