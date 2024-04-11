import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:special_scholar/TrainerDetails.dart';
import 'package:special_scholar/myprofile.dart';

class Searchtrainer extends StatefulWidget {
  const Searchtrainer({Key? key}) : super(key: key);

  @override
  State<Searchtrainer> createState() => _SearchtrainerState();
}

class _SearchtrainerState extends State<Searchtrainer> {
  List<Map<String, dynamic>> trainers = []; // List to store trainer data

  @override
  void initState() {
    super.initState();
    fetchTrainers(); // Fetch trainers data when the widget is initialized
  }

  Future<void> fetchTrainers() async {
    try {
      QuerySnapshot trainerSnapshot = await FirebaseFirestore.instance.collection('tbl_trainer').get();

      setState(() {
        // Convert QuerySnapshot to a list of maps
        trainers = trainerSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error fetching trainers: $e');
      // Handle error
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
        padding: const EdgeInsets.all(5.0),
        child: ListView.builder(
          itemCount: trainers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Trainerdetails(trainerData: trainers[index]),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    children: [
                      // Display trainer photo if available, else show default asset photo
                      trainers[index]['trainer_photo'] != null
                          ? Image.network(
                              trainers[index]['trainer_photo'],
                              height: 150,
                              width: 120,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "assets/default_photo.jpg",
                              height: 150,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${trainers[index]['trainer_name']}'),
                          const SizedBox(
                            height: 10,
                          ),
                          Text('Contact: ${trainers[index]['trainer_contact']}'),
                          const SizedBox(
                            height: 10,
                          ),
                          Text('Location: ${trainers[index]['trainer_address']}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
