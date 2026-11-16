import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sha_billing/main.dart';
import 'package:sha_billing/providers/app_state.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const ShaBillingApp(),
      ),
    );
  });
}
