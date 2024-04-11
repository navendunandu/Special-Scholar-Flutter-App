// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:special_scholar/myprofile.dart';

class AddChild extends StatefulWidget {
  const AddChild({super.key});

  @override
  State<AddChild> createState() => _AddChildState();
}

class _AddChildState extends State<AddChild> {
  // Controller for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _needsController = TextEditingController();

  List<Map<String, dynamic>> typeList = [];
  List<Map<String, dynamic>> subList = [];
  List<Map<String, dynamic>> relationList = [];

  // Variables to hold dropdown values
  String? _selectedType;
  String? _selectedSubtype;
  String? _selectedRelation;
  DateTime? _selectedDate;
  XFile? _selectedImage;
  String? _imageUrl;
  late ProgressDialog _progressDialog;

  Future<void> fetchData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('tbl_type').get();

      List<Map<String, dynamic>> type = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['type_name'].toString(),
              })
          .toList();

      setState(() {
        typeList = type;
      });
    } catch (e) {
      print('Error fetching type data: $e');
    }
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('tbl_relation').get();

      List<Map<String, dynamic>> relation = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['relation_name'].toString(),
              })
          .toList();

      setState(() {
        relationList = relation;
      });
    } catch (e) {
      print('Error fetching relation data: $e');
    }
  }

  Future<void> fetchsubData(id) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot1 =
          await FirebaseFirestore.instance
              .collection('tbl_subtype')
              .where('type_id', isEqualTo: id)
              .get();

      List<Map<String, dynamic>> sub = querySnapshot1.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['subtype_name'].toString(),
              })
          .toList();

      setState(() {
        subList = sub;
      });
    } catch (e) {
      print('Error fetching sub data: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> _storeChildData() async {
  try {
    _progressDialog.show();
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot studentSnapshot = await firestore
        .collection('tbl_user')
        .where('user_id', isEqualTo: userId)
        .get();

    if (studentSnapshot.docs.isNotEmpty) {
      String uDoc = studentSnapshot.docs.first.id;
      DocumentReference newDocumentRef = await firestore.collection('tbl_child').add({
        'child_name': _nameController.text,
        'child_dob': _dobController.text,
        'child_photo': '',
        'subtype_id': _selectedSubtype,
        'child_relation': _selectedRelation,
        'child_needs': _nameController.text,
        'user_id': uDoc,
      });
      String documentId = newDocumentRef.id;

      await _uploadImage(documentId);
      _progressDialog.hide();
      Fluttertoast.showToast(
        msg: "Registration Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    } else {
      throw Exception("No student document found for the current user.");
    }
  } catch (e) {
    _progressDialog.hide();
    Fluttertoast.showToast(
      msg: "Registration Failed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    print("Error storing user data: $e");
  }
}


  Future<void> _uploadImage(String id) async {
    try {
      if (_selectedImage != null) {
        Reference ref = FirebaseStorage.instance.ref().child('Child/$id.jpg');
        UploadTask uploadTask = ref.putFile(File(_selectedImage!.path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('tbl_child')
            .doc(id) // Use doc() to reference the document by its ID
            .update({
          'child_photo': imageUrl,
        }).then((_) {
          print('Document updated successfully.');
        }).catchError((error) {
          print("Error updating document: $error");
        });
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _progressDialog = ProgressDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPECIAL SCHOLAR'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyProfile(),
                    ));
              },
              icon: const Icon(Icons.person))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xff4c505b),
                      backgroundImage: _selectedImage != null
                          ? FileImage(File(_selectedImage!.path))
                          : _imageUrl != null
                              ? NetworkImage(_imageUrl!)
                              : const AssetImage('assets/pic_11.png')
                                  as ImageProvider,
                      child: _selectedImage == null && _imageUrl == null
                          ? const Icon(
                              Icons.add,
                              size: 40,
                              color: Color.fromARGB(255, 41, 39, 39),
                            )
                          : null,
                    ),
                    if (_selectedImage != null || _imageUrl != null)
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Child Name'),
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              value: _selectedType,
              hint: const Text('Select Type'),
              onChanged: (newValue) {
                setState(() {
                  _selectedType = newValue;
                });
                fetchsubData(newValue);
              },
              isExpanded: true,
              items: typeList.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> type) {
                  return DropdownMenuItem<String>(
                    value: type['id'],
                    child: Text(type['name']),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              value: _selectedSubtype,
              hint: const Text('Select Subtype'),
              onChanged: (newValue) {
                setState(() {
                  _selectedSubtype = newValue;
                });
              },
              isExpanded: true,
              items: subList.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> sub) {
                  return DropdownMenuItem<String>(
                    value: sub['id'],
                    child: Text(sub['name']),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              value: _selectedRelation,
              hint: const Text('Select Relation'),
              onChanged: (newValue) {
                setState(() {
                  _selectedRelation = newValue;
                });
              },
              isExpanded: true,
              items: relationList.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> relation) {
                  return DropdownMenuItem<String>(
                    value: relation['id'],
                    child: Text(relation['name']),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              controller: _needsController,
              decoration: const InputDecoration(labelText: "Child's Needs"),
              maxLines: 3,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _storeChildData();
                // Handle form submission here
                // Access form field values using _nameController.text, _dobController.text, etc.
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
