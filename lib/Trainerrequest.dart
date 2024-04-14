import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:special_scholar/myprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:special_scholar/payment.dart';
import 'package:special_scholar/rating.dart';
import 'package:special_scholar/trainer_course.dart';

class Trainerrequest extends StatefulWidget {
  const Trainerrequest({Key? key}) : super(key: key);

  @override
  State<Trainerrequest> createState() => _TrainerrequestState();
}

class _TrainerrequestState extends State<Trainerrequest> {
  List<Map<String, dynamic>> trainerRequests = [];
  List<Map<String, dynamic>> schoolRequests = [];
  Future<void> fetchTReqData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot userSnapshot = await firestore
          .collection('tbl_user')
          .where('user_id', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        String uDoc = userSnapshot.docs.first.id;

        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('tbl_request')
                .where('user_id', isEqualTo: uDoc) // Filter by user_id
                .get();

        List<Map<String, dynamic>> trainer = [];

        for (QueryDocumentSnapshot<Map<String, dynamic>> doc
            in querySnapshot.docs) {
          String trainerName = await fetchTrainer(doc['trainer_id']);
          trainer.add({
            'id': doc.id,
            'request_date': doc['request_date'].toString(),
            'request_status': doc['request_status'].toString(),
            'requestfrom_date': doc['requestfrom_date'].toString(),
            'requestto_date': doc['requestto_date'].toString(),
            'trainer_name': trainerName,
            'trainer_id':doc['trainer_id'].toString(),
          });
        }

        setState(() {
          trainerRequests = trainer;
        });
      } else {
        print('No user document found for the current user.');
      }
    } catch (e) {
      print('Error fetching children data: $e');
    }
  }

  Future<void> fetchSReqData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot userSnapshot = await firestore
          .collection('tbl_user')
          .where('user_id', isEqualTo: userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        String uDoc = userSnapshot.docs.first.id;

        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('tbl_schoolrequest')
                .where('user_id', isEqualTo: uDoc) // Filter by user_id
                .get();

        List<Map<String, dynamic>> school = [];

        for (QueryDocumentSnapshot<Map<String, dynamic>> doc
            in querySnapshot.docs) {
          String schoolName = await fetchSchool(doc['school_id']);
          school.add({
            'id': doc.id,
            'request_date': doc['request_date'].toString(),
            'request_status': doc['request_status'].toString(),
            'school_name': schoolName,
          });
        }

        setState(() {
          schoolRequests = school;
        });
      } else {
        print('No user document found for the current user.');
      }
    } catch (e) {
      print('Error fetching children data: $e');
    }
  }

  Future<String> fetchTrainer(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('tbl_trainer')
          .doc(id)
          .get();

      String subtypeName = doc['trainer_name'].toString();
      return subtypeName;
    } catch (e) {
      print('Error fetching subtype data: $e');
      return '';
    }
  }

  Future<String> fetchSchool(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('tbl_school')
          .doc(id)
          .get();

      String subtypeName = doc['school_name'].toString();
      return subtypeName;
    } catch (e) {
      print('Error fetching subtype data: $e');
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSReqData();
    fetchTReqData();
  }

  String _getTrainingStatusText(String status) {
    if (status == '0') {
      return 'Pending';
    } else if (status == '1') {
      return 'Accepted';
    } else if (status == '2') {
      return 'Rejected';
    } else {
      return 'Unknown';
    }
  }

  String _getSchoolStatusText(String status) {
    if (status == '0') {
      return 'Pending';
    } else if (status == '1') {
      return 'Make Payment';
    } else if (status == '2') {
      return 'Rejected';
    } else {
      return '';
    }
  }

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading for My Requests
            Text(
              'My Requests',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 20),
            // Previous Trainer Requests
            Text(
              'Previous Trainer Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            // List of previous trainer requests
            Expanded(
              child: ListView.builder(
                itemCount: trainerRequests.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = trainerRequests[index];

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(data['trainer_name']),
                      subtitle:
                          Text(_getTrainingStatusText(data['request_status'])),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (data['request_status'] == '1') // Pending status
                            ElevatedButton(
                              onPressed: () {
                                // Implement payment functionality
                                // This is just a placeholder
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentPage(id: data['id'],),));
                                print(
                                    'Payment button pressed for request ID: ${data['id']}');
                              },
                              child: Text('Pay'),
                            ),
                          if (data['request_status'] == '3') // Accepted status
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RatingReviewScreen(id: data['id']),));
                                // Implement view course functionality
                                // This is just a placeholder
                                print(
                                    'View course button pressed for request ID: ${data['id']}');
                              },
                              child: Text('Rating'),
                            ),
                          if (data['request_status'] == '3') // Accepted status
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => VideoListPage(trainerId:data['trainer_id'] ),));
                                // Implement view course functionality
                                // This is just a placeholder
                                print(
                                    'View course button pressed for request ID: ${data['id']}');
                              },
                              child: Text('Course'),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // School Requests
            Text(
              'School Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            // List of school requests
            Expanded(
              child: ListView.builder(
                itemCount: schoolRequests.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = schoolRequests[index];

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(data['school_name']),
                      subtitle:
                          Text(_getTrainingStatusText(data['request_status'])),
                      trailing: IconButton(
                        onPressed: () {
                          // Delete school request
                          FirebaseFirestore.instance
                              .collection('tbl_schoolrequest')
                              .doc(data['id'])
                              .delete();
                              fetchSReqData();
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder lists for trainerRequests, schoolRequests, and their corresponding document IDs

