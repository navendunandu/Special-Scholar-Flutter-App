import 'package:flutter/material.dart';
import 'package:special_scholar/myprofile.dart';

class Schoolrequest extends StatefulWidget {
  const Schoolrequest({super.key});

  @override
  State<Schoolrequest> createState() => _SchoolrequestState();
}

class _SchoolrequestState extends State<Schoolrequest> {
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
            Center(child: Text('SCHOOL REQUEST',style: TextStyle(fontSize: 30,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,color:Colors.lightBlue),)),
             const SizedBox(
                    height: 20,
                  ),
            Container(
              padding: const EdgeInsets.all(20.0),
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color:Colors.greenAccent,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Text('SCHOOL'),
                  const SizedBox(
                    width: 20,
                  ),
                      Text('STATUS'),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(onPressed: (){
              }, child:Text('ACTION')
              ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
                      ),
            Container(
              padding: const EdgeInsets.all(20.0),
              width: 300,
              height:200,
              decoration: BoxDecoration(
                color:Colors.greenAccent,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Text('TRAINER'),
                  const SizedBox(
                    width: 20,
                  ),
                      Text('STATUS'),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(onPressed: (){
              }, child:Text('ACTION')
              ),
                ],
              ),
            ),
          ],
      ),
    ),
    );
    
  }
  }
  