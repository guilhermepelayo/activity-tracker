import 'package:flutter/material.dart';
import '../models/activity.dart';

class AddTimeEntryDialog extends StatefulWidget {
  @override
  _AddTimeEntryDialogState createState() => _AddTimeEntryDialogState();
}

class _AddTimeEntryDialogState extends State<AddTimeEntryDialog> {
  final TextEditingController _hoursController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Time Entry'),
      content: TextField(
        controller: _hoursController,
        decoration: InputDecoration(labelText: 'Hours Spent'),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: () {
            final hours = double.tryParse(_hoursController.text);
            if (hours != null) {
              Navigator.of(context).pop(
                TimeEntry(
                  date: DateTime.now(),
                  hours: hours,
                ),
              );
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
