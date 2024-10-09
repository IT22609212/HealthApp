import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditMedicineScreen extends StatefulWidget {
  final DocumentSnapshot medicine;

  const EditMedicineScreen({required this.medicine});

  @override
  _EditMedicineScreenState createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  final TextEditingController medicineNameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  TimeOfDay? selectedTime;
  String selectedMedicineType = '';

  @override
  @override
  void initState() {
    super.initState();
    medicineNameController.text = widget.medicine['medicine_name'] ?? '';
    dosageController.text = widget.medicine['dosage'] ?? '';
    selectedMedicineType = widget.medicine['medicine_type'] ?? '';

    try {
      // Check if reminder_time is valid and parse it safely
      String reminderTime = widget.medicine['reminder_time'] ?? '';
      if (reminderTime.isNotEmpty && reminderTime.contains(":")) {
        List<String> timeParts = reminderTime.split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        // Set the selectedTime if parsing is successful
        selectedTime = TimeOfDay(hour: hour, minute: minute);
      } else {
        // Set a default time if reminder_time is invalid or empty
        selectedTime = TimeOfDay.now();
      }
    } catch (e) {
      // Handle any parsing errors by setting a default time
      print('Error parsing reminder_time: $e');
      selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    medicineNameController.dispose();
    dosageController.dispose();
    super.dispose();
  }

  Future<void> _updateMedicine() async {
    // Update the medicine data in Firestore
    await FirebaseFirestore.instance
        .collection('medicines')
        .doc(widget.medicine.id)
        .update({
      'medicine_name': medicineNameController.text,
      'dosage': dosageController.text,
      'medicine_type': selectedMedicineType,
      'reminder_time': selectedTime!.format(context),
    });

    Navigator.of(context).pop(); // Close the screen after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Medicine'),
        backgroundColor: const Color(0xFF377DE6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
            color: const Color.fromARGB(137, 139, 138, 138),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(
                    controller: medicineNameController,
                    decoration:
                        const InputDecoration(labelText: 'Medicine Name'),
                  ),
                  TextField(
                    controller: dosageController,
                    decoration: const InputDecoration(labelText: 'Dosage'),
                  ),
                  // Add other fields like TimePicker, MedicineType picker here
                  SizedBox(
                    height: 16.0,
                  ),
                  ElevatedButton(
                    onPressed: _updateMedicine,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
