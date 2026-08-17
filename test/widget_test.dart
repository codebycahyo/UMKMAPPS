import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_laundry_offline_app/main.dart';

void main() {
  testWidgets('App smoke test - initializes MyApp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOneWidget);
  });
}
