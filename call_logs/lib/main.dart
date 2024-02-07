import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class CustomCallLog {
  final String name_caller;
  final String mobile_Number;
  final String duration;
  final DateTime? timestamp;

  CustomCallLog ({
    required this.name_caller,
    required this.mobile_Number,
    required this.duration,
    required this.timestamp,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessing Call Logs',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Accessing Call Logs'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CustomCallLog> callLogs = [];
  List<CustomCallLog> filteredCallLogs = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Add default entries
    callLogs.addAll([
      CustomCallLog(
        name_caller: 'Shaziya',
        mobile_Number: '9989149387',
        duration: '7 minutes',
        timestamp: DateTime.now(),
      ),
      CustomCallLog(
        name_caller: 'Shabana',
        mobile_Number: '9494826162',
        duration: '9 minutes',
        timestamp: DateTime.now(),
      ),
      CustomCallLog(
        name_caller: 'Tasleem',
        mobile_Number: '9876543213',
        duration: '8 minutes',
        timestamp: DateTime.now(),
      ),
      CustomCallLog(
        name_caller: 'Asif',
        mobile_Number: '6304236781',
        duration: '5 minutes',
        timestamp: DateTime.now(),
      ),
      CustomCallLog(
        name_caller: 'Sowda',
        mobile_Number: '9656321470',
        duration: '10 minutes',
        timestamp: DateTime.now(),
      ),
      CustomCallLog(
        name_caller: 'Kaleem',
        mobile_Number: '975413820',
        duration: '6 minutes',
        timestamp: DateTime.now(),
      ),
      CustomCallLog(
        name_caller: 'Salma',
        mobile_Number: '6541239871',
        duration: '2 minutes',
        timestamp: DateTime.now(),
      ),
      // Add more call logs as needed
    ]);

    _retrieveCallLogs();
  }

  Future<void> _retrieveCallLogs() async {
    try {
      // Check and request permissions only if not running on the web
      if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isIOS) {
          var status = await Permission.contacts.status;
          if (!status.isGranted) {
            // Request permission and handle denial
            var result = await Permission.contacts.request();
            if (result.isDenied) {
              // User denied the permission, handle it accordingly
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Permission denied. Please grant access in settings.'),
                ),
              );
              return;
            }
          }
        }
      }

      // Retrieve call log entries only if callLogs is empty
      if (callLogs.isEmpty) {
        Iterable<CallLogEntry> entries = await CallLog.query();

        setState(() {
          callLogs = entries.map((entry) {
            return CustomCallLog(
              name_caller: entry.name ?? 'Unknown Caller',
              mobile_Number: entry.number ?? 'Unknown Number',
              duration: entry.duration.toString(),
              timestamp: DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0),
            );
          }).toList();

          filteredCallLogs = List.from(callLogs);
        });
      }
    } catch (e) {
      print('Error retrieving call logs: $e');
      // Handle the error gracefully (show a message to the user, log it, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error retrieving call logs. Please try again.'),
        ),
      );
    }
  }

  void _sortCallLogs() {
    setState(() {
      callLogs.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
      filteredCallLogs = List.from(callLogs);
    });
  }

  void _searchCallLogs(String query) {
    setState(() {
      filteredCallLogs = callLogs
          .where((log) =>
      log.name_caller.toLowerCase().contains(query.toLowerCase()) ||
          log.mobile_Number.contains(query))
          .toList();
    });
  }

  void _addNewCallLog(String newCallerName, String newPhoneNumber, String newCallDuration) {
    CustomCallLog newCallLog = CustomCallLog(
      name_caller: newCallerName,
      mobile_Number: newPhoneNumber,
      duration: newCallDuration,
      timestamp: DateTime.now(),
    );

    setState(() {
      callLogs.add(newCallLog);
      filteredCallLogs = List.from(callLogs);
    });
  }

  void _showAddCallLogDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController phoneController = TextEditingController();
        TextEditingController durationController = TextEditingController();

        return AlertDialog(
          title: Text('Add New Call Log'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Caller Name',
                  icon: Icon(Icons.person),
                
                ),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  icon: Icon(Icons.phone),
                ),
              ),
              TextField(
                controller: durationController,
                decoration: InputDecoration(
                  labelText: 'Call Duration',
                  icon: Icon(Icons.timer),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addNewCallLog(
                  nameController.text,
                  phoneController.text,
                  durationController.text,
                );
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.title),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _sortCallLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: searchController,
              onChanged: _searchCallLogs,
              decoration: InputDecoration(
                labelText: 'Search a Contact',
                
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.red,
                    ),
                ),
              ),
            ),
          ),
          Expanded(
            child: CallLogList(callLogs: filteredCallLogs),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCallLogDialog();
        },
        tooltip: 'Add New Call Log',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CallLogList extends StatelessWidget {
  final List<CustomCallLog> callLogs;

  CallLogList({required this.callLogs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: callLogs.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 7.0,
          margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) {
              // Change color when hovering
              // Here's an example of changing to a light blue color
              (context as Element).markNeedsBuild();
            },
            onExit: (_) {
              // Restore the original color when not hovering
              (context as Element).markNeedsBuild();
            },
          child: ListTile(
            title: Text(callLogs[index].name_caller),
            subtitle: Text(callLogs[index].mobile_Number),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(callLogs[index].duration),
                Text(
                  DateFormat('HH:mm').format(callLogs[index].timestamp!),
                ),
              ],
            ),
            onTap: () {
                // Handle onTap event here
            },
            
          ),
            
          ),
        );
      },
    );
  }
}