import 'package:flutter_test/flutter_test.dart';
import 'package:workflow/main.dart';

void main() {
  testWidgets('WorkFlow app displays dashboard', (tester) async {
    await tester.pumpWidget(const WorkFlowApp());

    expect(find.text('Dashboard'), findsNWidgets(2));
    expect(find.text('Welcome to WorkFlow'), findsOneWidget);
  });
}