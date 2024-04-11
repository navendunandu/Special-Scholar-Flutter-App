import 'package:flutter/material.dart';
import 'package:special_scholar/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();
    gotoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
    home: Scaffold(
        body:Center(child: Text('SPECIAL SCHOLAR',style:TextStyle(fontSize:40,fontStyle:FontStyle.italic,fontWeight:FontWeight.bold, color:Colors.black) ,)) 
        ),
    );
  }

  void gotoLogin(){
      Future.delayed(const Duration(seconds: 3), (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Login(),));
      });
    }
}