import 'package:antibet/core/models/notification_model.dart'; // Assuming the model name
import 'package:antibet/core/notifiers/push_notification_notifier.dart';
import 'package:antibet/mobile/presentation/screens/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock class for the required dependency
class MockPushNotificationNotifier extends Mock implements PushNotificationNotifier {}

// Helper function to create a mock notification entry
NotificationModel createMockNotification(String title, bool isRead) {
  return NotificationModel(
    id: UniqueKey().toString(),
    title: title,
    body: 'This is the notification body.',
    timestamp: DateTime.now(),
    isRead: isRead,
  );
}

void main() {
  // Define mock instance
  MockPushNotificationNotifier mockNotificationNotifier;

  // Setup runs before each test
  setUp(() {
    mockNotificationNotifier = MockPushNotificationNotifier();

    // Configure mocks with some test data
    final mockNotifications = [
      createMockNotification('ROI atingiu 10%', false), // Unread
      createMockNotification('Nova Estratégia Recomendada', true), // Read
    ];
    
    when(mockNotificationNotifier.notifications).thenReturn(mockNotifications);
    when(mockNotificationNotifier.unreadCount).thenReturn(1);
    when(mockNotificationNotifier.isLoading).thenReturn(false);
  });

  // Helper function to pump the widget into the test environment with required providers
  Widget createNotificationsScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PushNotificationNotifier>.value(value: mockNotificationNotifier),
      ],
      child: const MaterialApp(
        home: NotificationsScreen(),
      ),
    );
  }

  group('NotificationsScreen Widget Tests', () {
    testWidgets('NotificationsScreen renders successfully and shows notification list', (WidgetTester tester) async {
      // Build the NotificationsScreen widget.
      await tester.pumpWidget(createNotificationsScreen());

      // Wait for all animations and frames to settle.
      await tester.pumpAndSettle();

      // Verification: Check if the AppBar title is present.
      expect(find.text('Notifications'), findsOneWidget);

      // Verification: Check if the mock notification titles are displayed.
      expect(find.text('ROI atingiu 10%'), findsOneWidget);
      expect(find.text('Nova Estratégia Recomendada'), findsOneWidget);
      
      // Verification: Check for a key action button, e.g., 'Mark All Read'.
      // Assuming there is an action to clear/mark all read, often an icon.
      expect(find.byIcon(Icons.mark_email_read_outlined), findsOneWidget); 

      // Verification: Ensure the loading indicator is not visible.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
    
    // testWidgets('NotificationsScreen shows "No new notifications" message when list is empty', (WidgetTester tester) async {
    //   // Reconfigure the mock for the empty state
    //   when(mockNotificationNotifier.notifications).thenReturn([]);
      
    //   await tester.pumpWidget(createNotificationsScreen());
    //   await tester.pumpAndSettle();

    //   // Verification: Check for the 'No notifications' message (assuming the screen has one).
    //   expect(find.text('You have no new notifications.'), findsOneWidget);
    // });
    
    // Future tests:
    // - testWidgets('NotificationsScreen marks notification as read on tap')
    // - testWidgets('NotificationsScreen updates unread badge after reading')
  });
}