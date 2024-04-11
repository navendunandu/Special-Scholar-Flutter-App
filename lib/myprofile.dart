import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:special_scholar/EditProfile.dart';
import 'package:special_scholar/forgot_password.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String name = 'Loading.....';
  String email = 'Loading.....';
  String contact = 'Loading.....';
  String address = 'Loading.....';
  String photo = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('tbl_user')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        name = querySnapshot.docs.first['user_name'];
        email = querySnapshot.docs.first['user_email'];
        contact = querySnapshot.docs.first['user_contact'];
        address = querySnapshot.docs.first['user_address'];
        photo = querySnapshot.docs.first['user_photo'];
      });
    } else {
      setState(() {
        name = 'Error Loading Data';
        email = 'Error Loading Data';
        contact = 'Error Loading Data';
        address = 'Error Loading Data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPECIAL SCHOLAR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          width: 500,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.0)),
          child: ListView(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                'My Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 216, 225, 233),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: (photo != ""
                    ? Image.network(
                        photo,
                        fit: BoxFit.cover,
                        height: 200,
                        width: 80,
                      )
                    : Image.asset('assets/pic_11.png',
                        height: 200, width: 80, fit: BoxFit.cover)),
              ),
              const SizedBox(
                height: 10,
              ),
              Text('Name: $name'),
              const SizedBox(
                height: 20,
              ),
              Text('Email: $email'),
              const SizedBox(
                height: 20,
              ),
              Text('Contact: $contact'),
              const SizedBox(
                height: 20,
              ),
              Text('Address: $address'),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceEvenly, // Adjust as per your preference
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfile(),
                        ),
                      );
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.edit), // Icon for editing profile
                        SizedBox(height: 5),
                        Text('Edit Profile'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPassword(title: 'Change Password',),
                        ),
                      );
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.lock), // Icon for changing password
                        SizedBox(height: 5),
                        Text('Change Password'),
                      ],
                    ),
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}