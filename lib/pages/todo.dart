import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:project7/pages/todoform.dart';

class ToDo {
  String id;
  String title;
  DateTime? reminder;
  bool completed;

  ToDo({
    required this.id,
    required this.title,
    this.reminder,
    this.completed = false,
  });
}

class FirestoreService {
  final CollectionReference todosCollection =
      FirebaseFirestore.instance.collection('todos');

  Future<void> addTodo(ToDo todo) {
    return todosCollection.add({
      'title': todo.title,
      'reminder': todo.reminder,
      'completed': todo.completed,
    });
  }

  Stream<List<ToDo>> getTodos() {
    return todosCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ToDo(
          id: doc.id,
          title: data['title'] ?? '',
          reminder: data['reminder'] != null
              ? (data['reminder'] as Timestamp).toDate()
              : null,
          completed: data['completed'] ?? false,
        );
      }).toList();
    });
  }

  Future<void> deleteTodo(String todoId) {
    return todosCollection.doc(todoId).delete();
  }

  Future<void> updateTodoCompletion(String todoId, bool completed) {
    return todosCollection.doc(todoId).update({
      'completed': completed,
    });
  }
}

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final FirestoreService firestoreService = FirestoreService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeLocalNotifications();
  }

  void _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> _scheduleNotification(
      String title, DateTime scheduledTime) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id 6', // Change this to a unique channel ID
      'channel_name', // Change this to a unique channel name
      // 'Your Channel Description', // Change this to a unique channel description
      importance: Importance.high,
      priority: Priority.high,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      title,
      'It\'s time for your ToDo!', // Notification body
      tz.TZDateTime.from(scheduledTime, tz.local), // Scheduled date and time
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _showDialog(String title, DateTime reminderTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ToDo Reminder"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Task: $title"),
              Text("Reminder Time: ${reminderTime.toString()}"),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void addTodo(ToDo todo) {
    setState(() {
      firestoreService.addTodo(todo).then((_) {
        if (todo.reminder != null) {
          _scheduleNotification(todo.title, todo.reminder!);
          _showDialog(todo.title, todo.reminder!);
        }
      });
    });
  }

  void deleteTodo(String todoId) {
    firestoreService.deleteTodo(todoId);
  }

  void completeTodo(String todoId, bool completed) {
    firestoreService.updateTodoCompletion(todoId, completed);
  }

  void editTodo(ToDo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ToDoForm(
          addTodo,
          initialTodo: todo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo App'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ToDoForm(addTodo)),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ToDo>>(
        stream: firestoreService.getTodos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<ToDo> todos = snapshot.data!;

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              var todo = todos[index];
              return InkWell(
                onTap: () {
                  editTodo(todo);
                },
                child: Card(
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: todo.reminder != null
                        ? Text('Reminder: ${todo.reminder}')
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: todo.completed,
                          onChanged: (_) =>
                              completeTodo(todo.id, !todo.completed),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteTodo(todo.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


























// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:mailer/mailer.dart';
// import 'package:mailer/smtp_server.dart';

// class ToDo {
//   String title;
//   DateTime? reminder;
//   bool completed;

//   ToDo({
//     required this.title,
//     this.reminder,
//     this.completed = false,
//   });
// }

// class ToDoList extends StatefulWidget {
//   @override
//   _ToDoListState createState() => _ToDoListState();
// }

// class _ToDoListState extends State<ToDoList> {
//   List<ToDo> todos = [];

//   void addTodo(ToDo todo) {
//     setState(() {
//       todos.add(todo);
//     });
//   }

//   void deleteTodo(int index) {
//     setState(() {
//       todos.removeAt(index);
//     });
//   }

//   void completeTodo(int index) {
//     setState(() {
//       todos[index].completed = !todos[index].completed;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ToDo App'),
//       ),
//       body: ListView.builder(
//         itemCount: todos.length,
//         itemBuilder: (context, index) {
//           var todo = todos[index];
//           return ListTile(
//             title: Text(todo.title),
//             subtitle: todo.reminder != null ? Text('Reminder: ${todo.reminder}') : null,
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Checkbox(
//                   value: todo.completed,
//                   onChanged: (_) => completeTodo(index),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: () => deleteTodo(index),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => ToDoForm(addTodo)),
//           );
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

// class ToDoForm extends StatefulWidget {
//   final Function(ToDo) onFormSubmit;

//   ToDoForm(this.onFormSubmit);

//   @override
//   _ToDoFormState createState() => _ToDoFormState();
// }

// class _ToDoFormState extends State<ToDoForm> {
//   late TextEditingController titleController;
//   DateTime? selectedDate;
//   TimeOfDay? selectedTime;
//   String repeatOption = 'Never';
//   bool receiveEmail = false;

//   @override
//   void initState() {
//     super.initState();
//     titleController = TextEditingController();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null && picked != selectedTime) {
//       setState(() {
//         selectedTime = picked;
//       });
//     }
//   }

//  void _selectRepeatOption(String? option) {
//     if (option != null) {
//       setState(() {
//         repeatOption = option;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add ToDo'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: titleController,
//               decoration: InputDecoration(labelText: 'Title'),
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: () => _selectDate(context),
//                   child: Text('Select Date'),
//                 ),
//                 SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: () => _selectTime(context),
//                   child: Text('Select Time'),
//                 ),
//                 SizedBox(width: 16),
//                 Text(
//                   selectedDate != null && selectedTime != null
//                       ? 'DateTime: $selectedDate ${selectedTime?.format(context)}'
//                       : '',
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 Text('Repeat: '),
//                 DropdownButton<String>(
//                   value: repeatOption,
//                   onChanged:_selectRepeatOption,
//                   items: ['Never', 'Daily', 'Weekly', 'Monthly', 'Yearly', 'Custom']
//                       .map((option) {
//                     return DropdownMenuItem<String>(
//                       value: option,
//                       child: Text(option),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 Text('Receive Email Reminder: '),
//                 Switch(
//                   value: receiveEmail,
//                   onChanged: (value) {
//                     setState(() {
//                       receiveEmail = value;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 var newTodo = ToDo(
//                   title: titleController.text,
//                   reminder: selectedDate != null && selectedTime != null
//                       ? DateTime(
//                           selectedDate!.year,
//                           selectedDate!.month,
//                           selectedDate!.day,
//                           selectedTime!.hour,
//                           selectedTime!.minute,
//                         )
//                       : null,
//                 );
//                 widget.onFormSubmit(newTodo);
//                 Navigator.pop(context);
//               },
//               child: Text('Add ToDo'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }









