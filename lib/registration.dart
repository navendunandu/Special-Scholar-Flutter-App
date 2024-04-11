import 'dart:io';
import 'package:special_scholar/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  State<Registration> createState() => RegistrationState();
}

class RegistrationState extends State<Registration> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  XFile? _selectedImage;
  String? _imageUrl;
  String? filePath;
  late ProgressDialog _progressDialog;
  @override
  void initState() {
    super.initState();
    _progressDialog = ProgressDialog(context);
    fetchDistricts();
  }

  String? selectedDistrict;
  String? selectedPlace;

  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> places = [];

  final _formKey = GlobalKey<FormState>();

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

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          filePath = result.files.single.path;
        });
      } else {
        // User canceled file picking
        print('File picking canceled.');
      }
    } catch (e) {
      // Handle exceptions
      print('Error picking file: $e');
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

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      try {
        _progressDialog.show();
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential != null) {
          await _storeUserData(userCredential.user!.uid);
          Fluttertoast.showToast(
            msg: "Registration Successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          _progressDialog.hide();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
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
        print("Error registering user: $e");
      }
    }
  }

  Future<void> _storeUserData(String userId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('tbl_user').add({
        'user_name': _nameController.text,
        'user_email': _emailController.text,
        'user_contact': _contactController.text,
        'user_address': _addressController.text,
        'user_password': _passwordController.text,
        'user_id': userId,
      });

      await _uploadImage(userId);
    } catch (e) {
      print("Error storing user data: $e");
      // Handle error, show message or take appropriate action
    }
  }

  Future<void> _uploadImage(String userId) async {
    try {
      if (_selectedImage != null) {
        Reference ref =
            FirebaseStorage.instance.ref().child('User_Photo/$userId.jpg');
        UploadTask uploadTask = ref.putFile(File(_selectedImage!.path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        Map<String, dynamic> newData = {
          'user_photo': imageUrl,
        };
        await FirebaseFirestore.instance
            .collection('tbl_user')
            .where('user_id', isEqualTo: userId) // Filtering by user_id
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            // For each document matching the query, update the data
            doc.reference.update(newData);
          });
        }).catchError((error) {
          print("Error updating user: $error");
        });
      }

    } catch (e) {
      print("Error uploading image: $e");
      // Handle error, show message or take appropriate action
    }
  }

  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.person),
            SizedBox(width: 8),
            Text('User Registration'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Center(
                  child: Text(
                    'User Registration',
                    style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 25),
                _buildIconTextField(Icons.person, _nameController, 'Name'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildIconTextField(Icons.phone, _contactController, 'Contact'),
                const SizedBox(height: 10),
                _buildIconTextField(Icons.home, _addressController, 'Address',
                    multiline: true),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
               
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.security),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Password must contain at least one uppercase letter';
                    }
                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return 'Password must contain at least one lowercase letter';
                    }
                    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                      return 'Password must contain at least one special character';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Password must contain at least one digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: register,
                  child: const Text('Register'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconTextField(
      IconData icon, TextEditingController controller, String labelText,
      {bool obscureText = false, bool multiline = false}) {
    return TextFormField(
      maxLines: multiline ? null : 1,
      keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildIconDropdownField(IconData icon, String? value, String hintText,
      List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}