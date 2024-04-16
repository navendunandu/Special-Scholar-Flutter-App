import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:special_scholar/TrainerDetails.dart';
import 'package:special_scholar/myprofile.dart';

class Searchtrainer extends StatefulWidget {
  const Searchtrainer({Key? key}) : super(key: key);

  @override
  State<Searchtrainer> createState() => _SearchtrainerState();
}

class _SearchtrainerState extends State<Searchtrainer> {
  List<Map<String, dynamic>> trainers = []; // List to store trainer data
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> places = [];
  List<Map<String, dynamic>> types = [];
  List<Map<String, dynamic>> subtypes = [];
  String? selectedDistrict;
  String? selectedPlace;
  String? selectedType;
  String? selectedSubType;
  List<Map<String, dynamic>> originalTrainers = []; // Store the original list of trainers

  @override
  void initState() {
    super.initState();
    fetchTrainers(); // Fetch trainers data when the widget is initialized
    fetchDistricts();
    fetchType();
  }

  Future<void> fetchTrainers() async {
    try {
      QuerySnapshot trainerSnapshot = await FirebaseFirestore.instance.collection('tbl_trainer').get();

      setState(() {
        // Convert QuerySnapshot to a list of maps
        trainers = trainerSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        originalTrainers = trainers; // Store the original list of trainers
      });
    } catch (e) {
      print('Error fetching trainers: $e');
      // Handle error
    }
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
    } catch (e) {
      print('Error fetching district data: $e');
    }
  }

  Future<void> fetchType() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('tbl_type').get();

      List<Map<String, dynamic>> temptypes = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['type_name'].toString(),
              })
          .toList();

      setState(() {
        types = temptypes;
      });
    } catch (e) {
      print('Error fetching type data: $e');
    }
  }

  Future<void> fetchPlaceData(id) async {
    places = [];
    try {
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
    } catch (e) {
      print('Error fetching place data: $e');
    }
  }

  Future<void> fetchSubtypeData(id) async {
    print(id);
    places = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot1 =
          await FirebaseFirestore.instance
              .collection('tbl_subtype')
              .where('type_id', isEqualTo: id)
              .get();

      List<Map<String, dynamic>> place = querySnapshot1.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['subtype_name'].toString(),
              })
          .toList();

      setState(() {
        subtypes = place;
      });
    } catch (e) {
      print('Error fetching place data: $e');
    }
  }

  Future<void> searchTrainers() async {
    try {
      QuerySnapshot trainerSnapshot = await FirebaseFirestore.instance
          .collection('tbl_trainer')
          .where('place_id', isEqualTo: selectedPlace)
          .where('subtype_id', isEqualTo: selectedSubType)
          .get();

      setState(() {
        trainers = trainerSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error searching trainers: $e');
      // Handle error
    }
  }

  void resetSearch() {
    setState(() {
      trainers = originalTrainers;
      selectedDistrict = null;
      selectedPlace = null;
      selectedType = null;
      selectedSubType = null;
    });
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedDistrict,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on),
                      labelText: 'District',
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.document_scanner),
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String? newValue) {
                      fetchSubtypeData(newValue);
                      setState(() {
                        selectedType = newValue;
                      });
                    },
                    isExpanded: true,
                    items: types.map<DropdownMenuItem<String>>(
                      (Map<String, dynamic> district) {
                        return DropdownMenuItem<String>(
                          value: district['id'],
                          child: Text(district['name']),
                        );
                      },
                    ).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.document_scanner),
                      labelText: 'Sub Type',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedSubType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSubType = newValue;
                        searchTrainers();
                      });
                    },
                    isExpanded: true,
                    items: subtypes.map<DropdownMenuItem<String>>(
                      (Map<String, dynamic> place) {
                        return DropdownMenuItem<String>(
                          value: place['id'],
                          child: Text(place['name']),
                        );
                      },
                    ).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a sub type';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10,),
                      ElevatedButton(
                        onPressed: resetSearch,
                        child: Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
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
                              width: 10,
                            ),
                            Flexible(
                              child: Column(
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