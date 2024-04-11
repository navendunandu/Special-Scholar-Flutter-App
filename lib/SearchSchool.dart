import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:special_scholar/myprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Searchschool extends StatefulWidget {
  const Searchschool({Key? key}) : super(key: key);

  @override
  State<Searchschool> createState() => _SearchschoolState();
}

class _SearchschoolState extends State<Searchschool> {
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
        padding: const EdgeInsets.all(5.0),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('tbl_school').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final schools = snapshot.data?.docs ?? [];

            return ListView.builder(
              itemCount: schools.length,
              itemBuilder: (context, index) {
                final schoolData =
                    schools[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SchoolDetails(schoolData: schoolData),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        children: [
                          Image.network(
                            schoolData['school_photo'] ??
                                'https://via.placeholder.com/150',
                            height: 150,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  child: Text(
                                    'School: ${schoolData?['school_name'] ?? 'Unknown'}',
                                    overflow: TextOverflow.visible,
                                    maxLines: 3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Location: ${schoolData?['school_address'] ?? 'Unknown'}',
                                  overflow: TextOverflow.visible,
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Contact: ${schoolData?['school_contact'] ?? 'Unknown'}',
                                  overflow: TextOverflow.visible,
                                  maxLines: 3,
                                ),
                              ],
                            ),
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
      ),
    );
  }
}

class SchoolDetails extends StatefulWidget {
  final Map<String, dynamic> schoolData;

  const SchoolDetails({Key? key, required this.schoolData}) : super(key: key);

  @override
  State<SchoolDetails> createState() => _SchoolDetailsState();
}

class _SchoolDetailsState extends State<SchoolDetails> {
  final TextEditingController _fromdateController = TextEditingController();
  final TextEditingController _todateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('School Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('School: ${widget.schoolData['school_name'] ?? 'Unknown'}'),
            const SizedBox(height: 10),
            Text(
                'Location: ${widget.schoolData['school_address'] ?? 'Unknown'}'),
            const SizedBox(height: 10),
            Text(
                'Contact: ${widget.schoolData['school_contact'] ?? 'Unknown'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Insert request data to Firestore
                insertRequestToFirestore();
              },
              child: Text('SEND REQUEST'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> insertRequestToFirestore() async {
    try {
      // Format the selected dates

      // Get school ID from the schoolData
      String schoolId = widget.schoolData['school_id'];
      
      // Retrieve the user ID
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot userSnapshot = await firestore
          .collection('tbl_user')
          .where('user_id', isEqualTo: userId)
          .get();
          String uDoc = userSnapshot.docs.first.id;

      if (userId != null) {
        // Insert request data to Firestore
        await FirebaseFirestore.instance.collection('tbl_schoolrequest').add({
          'request_date': DateTime.now(),
          'request_status': 0,
          'school_id': schoolId,
          'user_id': uDoc,
          // Add other fields as needed
        });
        // Show alert and navigate back to previous screen
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Request Sent'),
              content: Text('Your request has been sent successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
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
