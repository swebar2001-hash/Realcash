import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realcash/main.dart';

void main() {
  testWidgets('RealCash app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RealCashApp()));
    expect(find.byType(RealCashApp), findsOneWidget);
  });
}
