import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_laundry_offline_app/main.dart';

void main() {
  testWidgets('App smoke test - initializes MyApp', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(showOnboarding: false));

    // Verify MyApp widget builds successfully
    expect(find.byType(MyApp), findsOneWidget);
  });
}
