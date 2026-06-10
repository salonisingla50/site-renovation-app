import 'package:flutter_test/flutter_test.dart';
import 'package:school_site_tracker/main.dart';

void main() {
  testWidgets('shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SchoolSiteTrackerApp());

    expect(find.text('School Site Tracker'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Forgot'), findsOneWidget);
  });
}
