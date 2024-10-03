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
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    var basicInfo = snap.data() as Map<String, dynamic>;

    isDoctor = basicInfo['role'] == 'doctor' ? true : false;
    print('isDoctor : $isDoctor');

    isNurse = basicInfo['role'] == 'nurse' ? true : false;
    print('isNurse : $isNurse');

    isPatient = basicInfo['role'] == 'patient' ? true : false;
    print('isPatient : $isPatient');

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
        : isPatient
        ? const MainPagePatient()
        : const MainPageDoctor();
  }
}
