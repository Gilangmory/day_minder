import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import '../../database_manager.dart';
import './note_model.dart';
import 'package:intl/intl.dart';

class NotifService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid, iOS: null);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Fungsi untuk menampilkan notifikasi
  Future<void> showNotification(Note note) async {
    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'channelDescription',
      importance: Importance.max,
      priority: Priority.high,
    );

    var generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: null);

    await flutterLocalNotificationsPlugin.show(
      note.id ?? 0, // ID unik untuk notifikasi
      'Reminder: ${note.title}',
      'Your task is due tomorrow: ${note.dueDate}',
      generalNotificationDetails,
    );
  }

  // Fungsi untuk memeriksa catatan di database
  Future<void> checkNotes() async {
    final db = await DatabaseManager().database;
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    final result = await db.query(
      'notes',
      where: "due_date = ?",
      whereArgs: [DateFormat('yyyy-MM-dd').format(tomorrow)],
    );

    for (var map in result) {
      final note = Note.fromMap(map);
      await showNotification(note);
    }
  }

  // Fungsi untuk memulai tugas latar belakang
  void startBackgroundTask() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    Workmanager().registerPeriodicTask(
      'check_notes_task',
      'checkNotes',
      frequency: Duration(hours: 1),
    );
  }

  // Dispatcher untuk Workmanager
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      final service = NotifService();
      await service.checkNotes();
      return Future.value(true);
    });
  }
}
