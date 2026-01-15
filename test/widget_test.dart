import 'package:flutter_test/flutter_test.dart';
import 'package:launcher/main.dart';

void main() {
  testWidgets('Launcher app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const LauncherApp());
    expect(find.text('Swipe up for apps'), findsOneWidget);
  });
}
