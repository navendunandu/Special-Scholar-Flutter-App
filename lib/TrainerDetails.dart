import 'package:flutter/material.dart';
import 'package:special_scholar/myprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Trainerdetails extends StatefulWidget {
  final Map<String, dynamic> trainerData;

  const Trainerdetails({Key? key, required this.trainerData}) : super(key: key);

  @override
  State<Trainerdetails> createState() => _TrainerdetailsState();
}

class _TrainerdetailsState extends State<Trainerdetails> {
  final TextEditingController _fromdateController = TextEditingController();
  final TextEditingController _todateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SPECIAL SCHOLAR'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyProfile(),
                ),
              );
            },
            icon: Icon(Icons.person),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: widget.trainerData['trainer_photo'] != null
                  ? Image.network(
                      widget.trainerData['trainer_photo'],
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "assets/human.jpg",
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 40),
            Text(
              widget.trainerData['trainer_name'] ?? 'Name',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
                'Address: ${widget.trainerData['trainer_address'] ?? 'Unknown'}'),
            const SizedBox(height: 20),
            Text(
                'Contact: ${widget.trainerData['trainer_contact'] ?? 'Unknown'}'),
            const SizedBox(height: 20),
            Text('Email: ${widget.trainerData['trainer_email'] ?? 'Unknown'}'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20.0),
              width: 300,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _fromdateController,
                    decoration: InputDecoration(
                      hintText: 'From Date',
                    ),
                    onTap: () {
                      _selectFromDate(context);
                    },
                  ),
                  TextFormField(
                    controller: _todateController,
                    decoration: InputDecoration(
                      hintText: 'To Date',
                    ),
                    onTap: () {
                      _selectToDate(context);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Insert request data to Firestore
                      insertRequestToFirestore(context);
                    },
                    child: Text('SEND REQUEST'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fromdateController.text) {
      setState(() {
        _fromdateController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _todateController.text) {
      setState(() {
        _todateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> insertRequestToFirestore(BuildContext context) async {
    try {
      // Format the selected dates
      String fromDate = _fromdateController.text;
      String toDate = _todateController.text;

      // Get trainer ID and user ID from the trainerData
      String trainerId = widget.trainerData['trainer_id'];
      QuerySnapshot trainerSnapshot = await FirebaseFirestore.instance
        .collection('tbl_trainer')
        .where('trainer_id', isEqualTo: widget.trainerData['trainer_id'])
        .get();
String tDoc = trainerSnapshot.docs.first.id;
      // Retrieve the user ID
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection('tbl_user')
        .where('user_id', isEqualTo: userId)
        .get();

      if (studentSnapshot.docs.isNotEmpty) {
      String uDoc = studentSnapshot.docs.first.id;
        await FirebaseFirestore.instance.collection('tbl_request').add({
          'request_date': DateTime.now(),
          'request_status': 0,
          'requestfrom_date': fromDate,
          'requestto_date': toDate,
          'trainer_id': tDoc,
          'user_id': uDoc,
          // Add other fields as needed
        });

        // Show alert
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Request Inserted'),
              content: Text('Your request has been successfully submitted.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the alert dialog
                    Navigator.of(context)
                        .pop(); // Navigate back to the previous screen
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print('User ID is null');
        // Handle the case where user ID is not available
      }
    } catch (e) {
      print('Error inserting request to Firestore: $e');
      // Handle error
    }
  }
}
