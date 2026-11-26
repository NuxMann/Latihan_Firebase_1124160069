
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login_firebase/firebase_options.dart';
import 'package:login_firebase/notification_detail_screen.dart';

/// Kunci global Navigator.
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

/// HANDLER BACKGROUND / TERMINATED
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('[FCM] Pesan BACKGROUND: ${message.messageId}');
  debugPrint('[FCM] Data: ${message.data}');
}

class NotificationService {
  NotificationService._();

  static Future<void>? _initialization;

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  /// Channel Android.
  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'Notifikasi Penting',
    description: 'Channel untuk notifikasi dari Firebase Cloud Messaging',
    importance: Importance.max,
  );

  /// Inisialisasi Notification Service.
  static Future<void> init() =>
      _initialization ??= _initialize();

  static Future<void> _initialize() async {
    // 1. Meminta izin notifikasi.
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      '[FCM] Status izin: ${settings.authorizationStatus}',
    );

    // 2. Inisialisasi local notifications.
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _localNotif.initialize(
      settings: const InitializationSettings(
        android: androidInit,
      ),
      onDidReceiveNotificationResponse:
          (NotificationResponse response) {
        if (response.payload != null) {
          _openDetail(
            jsonDecode(response.payload!)
                as Map<String, dynamic>,
          );
        }
      },
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Mengambil FCM Token.
    try {
      final token = await _messaging.getToken();
      debugPrint('[FCM] TOKEN: $token');
    } catch (e) {
      debugPrint('[FCM] Gagal mengambil token: $e');
    }

    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] TOKEN BARU: $newToken');
    });

    // 4. Tidak ada subscribe otomatis.
    // Subscribe / Unsubscribe dikendalikan melalui Dashboard.

    // 5. FOREGROUND.
    FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );

    // 6. BACKGROUND.
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint('[FCM] Dibuka dari BACKGROUND');
        _openDetail(_messageToMap(message));
      },
    );

    // 7. TERMINATED.
    final initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('[FCM] Dibuka dari kondisi MATI');
      _openDetail(_messageToMap(initialMessage));
    }

    // 8. Local notification saat aplikasi mati.
    final launchDetails =
        await _localNotif.getNotificationAppLaunchDetails();

    final payload =
        launchDetails?.notificationResponse?.payload;

    if ((launchDetails?.didNotificationLaunchApp ?? false) &&
        payload != null) {
      _openDetail(
        jsonDecode(payload) as Map<String, dynamic>,
      );
    }
  }

  /// SUBSCRIBE TOPIC KELAS.
  static Future<void> subscribeToKelas() async {
    try {
      await _messaging.subscribeToTopic('kelas');
      debugPrint('[FCM] Berhasil subscribe topic kelas');
    } catch (e) {
      debugPrint('[FCM] Gagal subscribe topic kelas: $e');
      rethrow;
    }
  }

  /// UNSUBSCRIBE TOPIC KELAS.
  static Future<void> unsubscribeFromKelas() async {
    try {
      await _messaging.unsubscribeFromTopic('kelas');
      debugPrint('[FCM] Berhasil unsubscribe topic kelas');
    } catch (e) {
      debugPrint('[FCM] Gagal unsubscribe topic kelas: $e');
      rethrow;
    }
  }

  /// Menampilkan notifikasi FOREGROUND.
  static Future<void> _showForegroundNotification(
    RemoteMessage message,
  ) async {
    debugPrint(
      '[FCM] Pesan FOREGROUND: ${message.notification?.title}',
    );

    final notification = message.notification;
    if (notification == null) return;

    await _localNotif.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(_messageToMap(message)),
    );
  }

  /// Menggabungkan title, body, dan data.
  static Map<String, dynamic> _messageToMap(
    RemoteMessage message,
  ) {
    return {
      'title': message.notification?.title ?? '-',
      'body': message.notification?.body ?? '-',
      ...message.data,
    };
  }

  /// Membuka halaman detail notifikasi.
  static void _openDetail(
    Map<String, dynamic> data,
  ) {
    void push() {
      final navigator = navigatorKey.currentState;

      if (navigator == null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => push(),
        );
        return;
      }

      navigator.push(
        MaterialPageRoute(
          builder: (_) =>
              NotificationDetailScreen(data: data),
        ),
      );
    }

    if (navigatorKey.currentState != null) {
      push();
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => push(),
      );
    }
  }
}
