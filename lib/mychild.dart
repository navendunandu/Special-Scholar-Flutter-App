import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:special_scholar/addchild.dart';

class ChildDetails extends StatefulWidget {
  const ChildDetails({Key? key}) : super(key: key);

  @override
  _ChildDetailsState createState() => _ChildDetailsState();
}

class _ChildDetailsState extends State<ChildDetails> {
  List<Map<String, dynamic>> childList = [];

  @override
  void initState() {
    super.initState();
    fetchChildrenData();
  }

  Future<void> fetchChildrenData() async {
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
                .collection('tbl_child')
                .where('user_id', isEqualTo: uDoc) // Filter by user_id
                .get();

        List<Map<String, dynamic>> children = [];

        for (QueryDocumentSnapshot<Map<String, dynamic>> doc
            in querySnapshot.docs) {
          String subtype = await fetchSubtypeData(doc['subtype_id']);
          String relation = await fetchRelationData(doc['child_relation']);

          children.add({
            'child_id': doc.id,
            'child_name': doc['child_name'].toString(),
            'child_dob': doc['child_dob'].toString(),
            'subtype': subtype,
            'relation': relation,
            'image': doc['child_photo'].toString(),
            // Add more fields as needed
          });
        }

        setState(() {
          childList = children;
        });
      } else {
        print('No user document found for the current user.');
      }
    } catch (e) {
      print('Error fetching children data: $e');
    }
  }

  Future<String> fetchSubtypeData(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('tbl_subtype')
          .doc(id)
          .get();

      String typeId = doc['type_id'].toString();
      String typeName = await fetchTypeName(typeId);
      String subtypeName = doc['subtype_name'].toString();
      return '$typeName - $subtypeName';
    } catch (e) {
      print('Error fetching subtype data: $e');
      return '';
    }
  }

  Future<String> fetchTypeName(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await FirebaseFirestore.instance.collection('tbl_type').doc(id).get();

      return doc['type_name'].toString();
    } catch (e) {
      print('Error fetching type name: $e');
      return '';
    }
  }

  Future<String> fetchRelationData(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('tbl_relation')
          .doc(id)
          .get();

      return doc['relation_name'].toString();
    } catch (e) {
      print('Error fetching relation data: $e');
      return '';
    }
  }

  Future<void> deleteChild(String childId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tbl_child')
          .doc(childId)
          .delete();
      setState(() {
        // Remove the deleted child from the list
        childList.removeWhere((child) => child['child_id'] == childId);
      });
      print('Child deleted successfully.');
    } catch (e) {
      print('Error deleting child: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Details'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddChild()),
              );
            },
            icon: Icon(Icons.person_add_alt_1),
          )
        ],
      ),
      body: childList.isEmpty
          ? Center(
              child: Text('No children data available'),
            )
          : ListView.builder(
              itemCount: childList.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(childList[index]['image']),
                    ),
                    title: Text(childList[index]['child_name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date of Birth: ${childList[index]['child_dob']}'),
                        Text('Type: ${childList[index]['subtype']}'),
                        Text('Relation: ${childList[index]['relation']}'),
                        // Add more details here as needed
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete Child'),
                              content: Text(
                                  'Are you sure you want to delete this child?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deleteChild(childList[index]['child_id']);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
