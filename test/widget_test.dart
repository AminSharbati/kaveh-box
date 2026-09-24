import 'package:flutter_test/flutter_test.dart';
import 'package:kaveh_box/app/kaveh_app.dart';

void main() {
  testWidgets('Kaveh app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const KavehApp());

    expect(find.byType(KavehApp), findsOneWidget);
  });
}