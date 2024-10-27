import 'package:flutter/material.dart';

class AddActivityDialog extends StatefulWidget {
  final List<String> defaultTypes;

  AddActivityDialog(this.defaultTypes);

  @override
  _AddActivityDialogState createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.defaultTypes.isNotEmpty ? widget.defaultTypes[0] : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Activity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Activity Name'),
          ),
          DropdownButtonFormField<String>(
            value: selectedType,
            items: widget.defaultTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedType = value;
              });
            },
            decoration: InputDecoration(labelText: 'Activity Type'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog without action
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Ensure the name and type are non-null and non-empty
            if (_nameController.text.isNotEmpty && selectedType != null) {
              Navigator.of(context).pop({
                'name': _nameController.text,
                'type': selectedType!,
              });
            } else {
              // Show a message if either field is empty
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill out all fields')),
              );
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
