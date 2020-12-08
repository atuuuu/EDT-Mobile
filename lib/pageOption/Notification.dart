import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:theme_provider/theme_provider.dart';

class Notifications {
  bool notification;

  Notifications() {
    notification = true;
  }

  bool getNotification() => notification;

  void setNotification(bool val) => notification = val;

  void notifier() {
    _NotificationParams().envoyerNotification();
    if (notification) {
      ///TODO Implémenter les notifications si quelqu'un est motivé

    }
  }
}

class NotificationRow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationRowState();
}

class _NotificationRowState extends State<NotificationRow> {
  bool notification = true;

  _NotificationParams notifier = _NotificationParams();

  @override
  Widget build(BuildContext context) {
    return Row(
      //Ligne 'Notification' qui s'affiche sur la page option
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
          child: Text('Notification : ',
              style: TextStyle(
                color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 25, 35, 35),
          child: Switch(
            value: notification,
            onChanged: (value) {
              setState(() {
                Notifications().notification = value; //Update dans la case notification
                notification = value; //Update de l'affichage
              });
            },
          ),
        )
      ],
    );
  }
}

class _NotificationParams {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  final BehaviorSubject<ReminderNotification> didReceiveLocalNotificationSubject =
      BehaviorSubject<ReminderNotification>();

  final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

  Future<void> initNotifications(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReminderNotification(id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      selectNotificationSubject.add(payload);
    });
  }

  void envoyerNotification() async {

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    '0',
    'Reminder notifications',
    'Remember about it',
    icon: 'app_icon',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, 'Reminder', 'coucou', platformChannelSpecifics);
  }
}

class ReminderNotification {
  ReminderNotification({@required this.id, @required this.title, @required this.body, @required this.payload});

  final int id;
  final String title;
  final String body;
  final String payload;
}

//En dessous : un truc qui est supposé pouvoir gérer les notifications (nan ça marche pas nan, ce serait trop facile sinon) *l'import a été retiré*

/*

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  Future initialise() async {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    // If you want to test the push notification locally,
    // you need to get the token and input to the Firebase console
    // https://console.firebase.google.com/project/YOUR_PROJECT_ID/notification/compose
    String token = await _fcm.getToken();
    print("FirebaseMessaging token: $token");

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }
}
 */
