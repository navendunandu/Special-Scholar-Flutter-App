import 'package:flutter/material.dart';
import 'package:special_scholar/myprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Searchschool extends StatefulWidget {
  const Searchschool({Key? key}) : super(key: key);

  @override
  State<Searchschool> createState() => _SearchschoolState();
}

class _SearchschoolState extends State<Searchschool> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> schools = [];
  String? selectedDistrict;
  String? selectedPlace;

  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> places = [];

  @override
  void initState() {
    super.initState();
    fetchSchools();
    fetchDistricts();
  }

  Future<void> fetchSchools() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('tbl_school').where('school_status', isEqualTo: 1).get();
    setState(() {
      schools = snapshot.docs;
    });
  }

  Future<void> searchSchool() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('tbl_school').where('place_id', isEqualTo: selectedPlace).where('school_status', isEqualTo: 1).get();
    setState(() {
      schools = snapshot.docs;
    });
  }

  Future<void> fetchDistricts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('tbl_district').get();

      List<Map<String, dynamic>> tempDistricts = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['district_name'].toString(),
              })
          .toList();

      setState(() {
        districts = tempDistricts;
      });
      print(tempDistricts);
    } catch (e) {
      print('Error fetching district data: $e');
    }
  }

  

  Future<void> fetchPlaceData(id) async {
    places = [];
    try {
      // Replace 'tbl_course' with your actual collection name
      QuerySnapshot<Map<String, dynamic>> querySnapshot1 =
          await FirebaseFirestore.instance
              .collection('tbl_place')
              .where('district_id', isEqualTo: id)
              .get();

      List<Map<String, dynamic>> place = querySnapshot1.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['place_name'].toString(),
              })
          .toList();

      setState(() {
        places = place;
      });
      print(place);
    } catch (e) {
      print('Error fetching place data: $e');
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
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(5),
            child: Column(
              children: [
DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on),
                    hintText: 'District',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  onChanged: (String? newValue) {
                    fetchPlaceData(newValue);
                    setState(() {
                      selectedDistrict = newValue;
                    });
                  },
                  isExpanded: true,
                  items: districts.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> district) {
                      return DropdownMenuItem<String>(
                        value: district['id'],
                        child: Text(district['name']),
                      );
                    },
                  ).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a district';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on),
                    labelText: 'Place',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedPlace,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPlace = newValue;
                    });
                  },
                  isExpanded: true,
                  items: places.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> place) {
                      return DropdownMenuItem<String>(
                        value: place['id'],
                        child: Text(place['name']),
                      );
                    },
                  ).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a place';
                    }
                    return null;
                  },
                ),
                ElevatedButton(onPressed: (){
                  searchSchool();
                }, child: Text('Search')),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(onPressed: (){
                  fetchSchools();
                }, child: Text('Reset'))
              ],
            ),),
            Expanded(
              child: ListView.builder(
                itemCount: schools.length,
                itemBuilder: (context, index) {
                  final schoolData = schools[index].data();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SchoolDetails(schoolData: schoolData),
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
                                      'School: ${schoolData['school_name'] ?? 'Unknown'}',
                                      overflow: TextOverflow.visible,
                                      maxLines: 3,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Location: ${schoolData['school_address'] ?? 'Unknown'}',
                                    overflow: TextOverflow.visible,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Contact: ${schoolData['school_contact'] ?? 'Unknown'}',
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
              ),
            ),
          ],
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