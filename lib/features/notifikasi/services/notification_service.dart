import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/navigation_service.dart';
import '../models/notifikasi_model.dart';

/// Service untuk menangani push notification lokal dan realtime updates
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  RealtimeChannel? _realtimeChannel;
  bool _isInitialized = false;

  /// Inisialisasi notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Konfigurasi Android notification
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Konfigurasi iOS notification
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Inisialisasi plugin
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Buat channel untuk Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'eticketing_notifikasi',
      'E-Ticketing Notifications',
      description: 'Notifikasi untuk tiket dan update sistem',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
  }

  /// Subscribe ke realtime notifikasi dari Supabase
  void subscribeToRealtimeNotifications(String userId) {
    _unsubscribe();

    _realtimeChannel = Supabase.instance.client
        .channel('notifikasi_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifikasi',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'pengguna_id',
            value: userId,
          ),
          callback: (payload) {
            _handleNewNotification(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Unsubscribe dari realtime
  void _unsubscribe() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
  }

  /// Handle notifikasi baru dari database
  void _handleNewNotification(Map<String, dynamic> data) {
    final notifikasi = NotifikasiModel.fromJson(data);

    // Cek apakah app di foreground atau background
    final appState = NavigationService.currentState;

    if (appState == AppState.background) {
      // App di background: tampilkan push notification
      _showLocalNotification(notifikasi);
    }
    // Jika app di foreground, realtime listener di cubit akan handle UI update
  }

  /// Tampilkan local push notification
  Future<void> _showLocalNotification(NotifikasiModel notifikasi) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'eticketing_notifikasi',
      'E-Ticketing Notifications',
      channelDescription: 'Notifikasi untuk tiket dan update sistem',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: notifikasi.id.hashCode,
      title: notifikasi.judul,
      body: notifikasi.pesan,
      notificationDetails: platformDetails,
      payload: jsonEncode({
        'notifikasiId': notifikasi.id,
        'referensiId': notifikasi.referensiId,
        'tipe': notifikasi.tipe,
      }),
    );
  }

  /// Handle tap pada notification
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;

    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      final referensiId = data['referensiId'] as String?;

      if (referensiId != null) {
        // Navigate ke tiket detail
        NavigationService.navigateTo('/tiket/$referensiId');
      } else {
        // Navigate ke notifikasi list
        NavigationService.navigateTo('/notifikasi');
      }
    } catch (e) {
      // Fallback ke notifikasi list
      NavigationService.navigateTo('/notifikasi');
    }
  }

  /// Dispose service
  void dispose() {
    _unsubscribe();
  }
}
