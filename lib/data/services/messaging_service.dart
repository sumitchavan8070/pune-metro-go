import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pune_metro_guide/app/utils/app_logger.dart';
import 'package:pune_metro_guide/data/firebase/firebase_options.dart';

const campaignTopic = 'campaigns';
const campaignChannelId = 'campaigns';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
}

class MessagingService {
  MessagingService(this._logger);

  final AppLogger _logger;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  bool _started = false;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    try {
      await _prepareNotifications();
      await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      await FirebaseMessaging.instance.register();
      await FirebaseMessaging.instance.subscribeToTopic(campaignTopic);
      FirebaseMessaging.instance.onRegistered.listen((_) {
        FirebaseMessaging.instance.subscribeToTopic(campaignTopic);
      });
      FirebaseMessaging.onMessage.listen(_showForeground);
      _logger.info('Cloud messaging is ready on topic $campaignTopic.');
    } catch (error, stackTrace) {
      _started = false;
      _logger.error('Cloud messaging could not start.', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _prepareNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(settings: const InitializationSettings(android: android));
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            campaignChannelId,
            'Campaigns',
            description: 'Messages sent to Pune Transit Guide',
            importance: Importance.high,
          ),
        );
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'];
    final body = message.notification?.body ?? message.data['body'];
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }
    await _local.show(
      id: message.hashCode & 0x7fffffff,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          campaignChannelId,
          'Campaigns',
          channelDescription: 'Messages sent to Pune Transit Guide',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
