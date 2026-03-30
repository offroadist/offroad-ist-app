import 'package:flutter_test/flutter_test.dart';
import 'package:offroad_ist/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OffroadApp());
    expect(find.byType(OffroadApp), findsOneWidget);
  });
}
