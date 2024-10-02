import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telehealth_app/globals.dart';
import 'package:telehealth_app/screens/doctor/main_page_doctor.dart';
import 'package:telehealth_app/screens/patient/main_page_patient.dart';

class DoctorOrPatient extends StatefulWidget {
  const DoctorOrPatient({Key? key}) : super(key: key);

  @override
  State<DoctorOrPatient> createState() => _DoctorOrPatientState();
}

class _DoctorOrPatientState extends State<DoctorOrPatient> {
  bool _isLoading = true;
  void _setUser() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snap.exists && snap.data() != null) {
        var basicInfo = snap.data() as Map<String, dynamic>;

        // isDoctor = basicInfo['role'] == 'doctor';
        userRole = basicInfo['role'];
        print('userRole : $userRole');
      } else {
        // Handle the case where the document does not exist or has no data
        print('No user data found');
        // You could set a default value or navigate to an error screen, etc.
      }
    } else {
      // Handle the case where the user is null, possibly navigate to a login screen
      print('User is not logged in');
      // For example: Navigator.pushReplacementNamed(context, '/login');
    }

    setState(() {
      _isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    _setUser();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : userRole == 'doctor' || userRole == 'patient'
            ? const MainPageDoctor()
            : const MainPagePatient();
  }
}
