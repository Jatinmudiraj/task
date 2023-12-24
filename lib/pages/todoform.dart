import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:project7/pages/todo.dart';

class ToDoForm extends StatefulWidget {
  final Function(ToDo) onFormSubmit;
  final ToDo? initialTodo;

  ToDoForm(this.onFormSubmit, {this.initialTodo});

  @override
  _ToDoFormState createState() => _ToDoFormState();
}

class _ToDoFormState extends State<ToDoForm> {
  late TextEditingController titleController;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String repeatOption = 'Never';
  bool receiveEmail = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();

    if (widget.initialTodo != null) {
      titleController.text = widget.initialTodo!.title;
      selectedDate = widget.initialTodo!.reminder;
      if (selectedDate != null) {
        selectedTime = TimeOfDay.fromDateTime(selectedDate!);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _selectRepeatOption(String? option) {
    if (option != null) {
      setState(() {
        repeatOption = option;
      });
    }
  }

  void _editTodo() {
    if (widget.initialTodo != null) {
      // Delete the old todo
      FirestoreService().deleteTodo(widget.initialTodo!.id);
    }

    var editedTodo = ToDo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      reminder: selectedDate != null && selectedTime != null
          ? DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              selectedTime!.hour,
              selectedTime!.minute,
            )
          : null,
    );
    widget.onFormSubmit(editedTodo);
    Navigator.pop(context);
  }

  void _addTodo() {
    var newTodo = ToDo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      reminder: selectedDate != null && selectedTime != null
          ? DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              selectedTime!.hour,
              selectedTime!.minute,
            )
          : null,
    );
    widget.onFormSubmit(newTodo);
    titleController.clear();
    setState(() {
      selectedDate = null;
      selectedTime = null;
      repeatOption = 'Never';
      receiveEmail = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialTodo != null ? 'Edit ToDo' : 'Add ToDo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Select Time'),
                ),
              ],
            ),
            Text(
              selectedDate != null && selectedTime != null
                  ? 'DateTime: $selectedDate ${selectedTime?.format(context)}'
                  : '',
            ),
            Row(
              children: [
                Text('Repeat: '),
                DropdownButton<String>(
                  value: repeatOption,
                  onChanged: _selectRepeatOption,
                  items: [
                    'Never',
                    'Daily',
                    'Weekly',
                    'Monthly',
                    'Yearly',
                    'Custom'
                  ].map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Receive Email Reminder: '),
                Switch(
                  value: receiveEmail,
                  onChanged: (value) {
                    setState(() {
                      receiveEmail = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.initialTodo != null ? _editTodo : _addTodo,
              child: Text(widget.initialTodo != null ? 'Edit ToDo' : 'Add ToDo'),
            ),
          ],
        ),
      ),
    );
  }
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDayFormat Function({bool alwaysUse24HourFormat}) format(
      BuildContext context) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, this.hour, this.minute);
    final format = MaterialLocalizations.of(context).timeOfDayFormat;
    return format;
  }
}
