import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:timesheet_1/btnButtomFeatures/settings.dart';
import 'package:timesheet_1/calendar_page.dart';
import 'package:timesheet_1/help.dart';
import 'package:timesheet_1/update_time.dart';
import 'package:intl/intl.dart'; // Import the package responsible for formatting dates

class DropdownItem {
  final String displayText;
  final String value;

  DropdownItem(this.displayText, this.value);
}

class Second extends StatefulWidget {
  const Second({Key? key}) : super(key: key);

  @override
  State<Second> createState() => _SecondState();
}

class _SecondState extends State<Second> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  bool _isRunning = false;
  int _selectedIndex = 0;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? _selectedProject;
  String? _selectedClient;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(Duration(milliseconds: 30), _updateTime);
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _updateTime(Timer timer) {
    if (_isRunning) {
      String elapsedTime = TimerUtil.formatTime(_stopwatch.elapsedMilliseconds);
      _showNotification('Stopwatch Running', 'Elapsed Time: $elapsedTime');
      setState(() {});
    }
  }

  void _showNotification(String title, String body) async {
    String elapsedTime = TimerUtil.formatTime(_stopwatch.elapsedMilliseconds);
    //body = '$body\nElapsed Time: $elapsedTime';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '1',
      'Timesheet App',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      enableVibration: false,
      playSound: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("want_to_stop".tr,
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel".tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _stopwatch.stop();
                _stopwatch.reset();
                _isRunning = false;
                setState(() {});
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UpdateTime(selectedProject: _selectedProject),
                  ),
                );
              },
              child: Text("confirm".tr),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown(String label) {
    List<DropdownItem> items = [];
    String? selectedValue;

    if (label == 'project'.tr) {
      items = [
        DropdownItem('Hourly Rate', 'hourly_rate'),
        DropdownItem('Flat Rate', 'flat_rate'),
        DropdownItem('Overtime', 'overtime'),
        DropdownItem('Night Shift', 'night_shift'),
        DropdownItem('Holiday', 'holiday'),
        DropdownItem('Unpaid Leave', 'unpaid_leave'),
      ];
      selectedValue = _selectedProject;
    } else if (label == 'client'.tr) {
      items = [DropdownItem('Default Client', 'default_client')];
      selectedValue = _selectedClient;
    }

    return DropdownButton<String>(
      value: selectedValue,
      items: items.map((DropdownItem item) {
        return DropdownMenuItem<String>(
          value: item.value,
          child: Text(item.displayText),
        );
      }).toList(),
      hint: Text(label),
      onChanged: (String? value) {
        setState(() {
          if (label == 'project'.tr) {
            _selectedProject = value;
          } else if (label == 'client'.tr) {
            _selectedClient = value;
          }
        });
      },
    );
  }

  Widget _buildCounter(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18)),
        SizedBox(
            height: MediaQuery.of(context).size.height *
                0.01), // Adjust spacing between items using MediaQuery
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = TimerUtil.formatTime(_stopwatch.elapsedMilliseconds);
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 18, 19, 18),
        title: Text('timesheet'.tr, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage()),
              );
            },
            icon: Icon(Icons.calendar_today, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              setState(() {});
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Help()),
              );
            },
            icon: Icon(Icons.help, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 224, 228, 230),
              Color.fromARGB(255, 228, 229, 233),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: EdgeInsets.all(isLargeScreen ? 40 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Card(
                  margin: EdgeInsets.all(8),
                  color: const Color.fromARGB(255, 29, 29, 28),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      isLargeScreen ? 120 : 70, // زيادة حجم padding
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(right: isLargeScreen ? 130 : 0),
                          child: Text(
                            currentDate,
                            style: const TextStyle(
                              backgroundColor: Colors.grey,
                              fontSize: 18, // زيادة حجم النص
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 78 : 48, // زيادة حجم النص
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isLargeScreen ? 40 : 20),
                Padding(
                  padding: EdgeInsets.all(isLargeScreen ? 40 : 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1, // تحديد نسبة العرض للزر
                        child: Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.lightGreen,
                              elevation: 10,
                            ),
                            onPressed: _toggleTimer,
                            child: Icon(
                              _isRunning ? Icons.pause : Icons.play_arrow,
                              size: isLargeScreen ? 45 : 36,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1, // تحديد نسبة العرض للزر
                        child: Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.redAccent,
                              elevation: 10,
                            ),
                            onPressed: _resetTimer,
                            child: Icon(
                              Icons.stop,
                              size: isLargeScreen ? 48 : 36,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isLargeScreen ? 40 : 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDropdown('project'.tr),
                _buildDropdown('client'.tr),
              ],
            ),
            SizedBox(height: isLargeScreen ? 40 : 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: _buildCounter('day'.tr, '00:00h'),
                  ),
                ),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: _buildCounter('month'.tr, '00:00h'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
        ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              tabs: [
                GButton(
                  icon: Icons.access_time,
                  text: 'Time'.tr,
                  textStyle: TextStyle(
                    color: const Color.fromARGB(255, 3, 35, 61),
                  ),
                  backgroundColor: Color.fromARGB(255, 7, 230, 238),
                  onPressed: () {},
                ),
                GButton(
                  icon: Icons.bar_chart,
                  text: 'statistics'.tr,
                  textStyle: TextStyle(
                    color: const Color.fromARGB(255, 3, 35, 61),
                  ),
                  backgroundColor: Color.fromARGB(255, 7, 230, 238),
                  onPressed: () {},
                ),
                GButton(
                  icon: Icons.receipt,
                  text: 'invoice'.tr,
                  textStyle: TextStyle(
                    color: const Color.fromARGB(255, 3, 35, 61),
                  ),
                  backgroundColor: Color.fromARGB(255, 7, 230, 238),
                  onPressed: () {},
                ),
                GButton(
                  icon: Icons.settings,
                  text: 'settings'.tr,
                  textStyle: TextStyle(
                    color: const Color.fromARGB(255, 3, 35, 61),
                  ),
                  backgroundColor: Color.fromARGB(255, 7, 230, 238),
                  onPressed: () {
                    setState(() {});
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => settings()),
                    );
                  },
                ),
                GButton(
                  icon: Icons.data_usage,
                  text: 'data'.tr,
                  textStyle: TextStyle(
                    color: const Color.fromARGB(255, 3, 35, 61),
                  ),
                  backgroundColor: Color.fromARGB(255, 7, 230, 238),
                  onPressed: () {},
                ),
                GButton(
                  icon: Icons.exit_to_app,
                  text: 'exit'.tr,
                  textStyle: TextStyle(
                    color: const Color.fromARGB(255, 3, 35, 61),
                  ),
                  backgroundColor: Color.fromARGB(255, 7, 230, 238),
                  onPressed: () => exit(0),
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TimerUtil {
  static String formatTime(int milliseconds) {
    int seconds = (milliseconds ~/ 1000) % 60;
    int minutes = (milliseconds ~/ (1000 * 60)) % 60;
    int hours = (milliseconds ~/ (1000 * 60 * 60)) % 24;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }
}
