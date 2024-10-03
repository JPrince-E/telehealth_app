import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMedicalRecord extends StatefulWidget {
  const AddMedicalRecord({Key? key}) : super(key: key);

  @override
  State<AddMedicalRecord> createState() => _AddMedicalRecordState();
}

class _AddMedicalRecordState extends State<AddMedicalRecord> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _genotypeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ailmentController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? selectedPatientId;
  Map<String, String> patientNames = {}; // Store patientId and patientName

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;

  Future<void> _getUser() async {
    user = _auth.currentUser!;
  }

  @override
  void initState() {
    super.initState();
    _getUser().then((_) {
      _fetchPatients();
    });
  }

  Future<void> _fetchPatients() async {
    try {
      final doctorId = user.uid; // Current doctor's ID

      // Fetch the list of pending appointments for the doctor
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(doctorId)
          .collection('all')
          .get();

      print('Fetched ${querySnapshot.docs.length} appointment(s).');

      // Extract patient IDs from the appointments
      final patientIds = querySnapshot.docs.map((doc) {
        final patientId = doc['patientId'] as String;
        final patientName = doc['patientName'] as String;
        return patientId;
      }).toSet();

      print('Patient IDs: $patientIds');

      // Fetch patient details from the patients collection
      final patientDetails = await Future.wait(
        patientIds.map((patientId) => FirebaseFirestore.instance
            .collection('patient') // Adjusted to 'patients'
            .doc(patientId)
            .get()),
      );

      print('Fetched ${patientDetails.length} patient(s).');

      setState(() {
        patientNames = {
          for (var doc in patientDetails)
            doc.id: (doc.data()?['name'] ?? 'Unknown')
        };
        print('Patient Names: $patientNames'); // Debug print
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching patients: $e')),
      );
    }
  }

  Future<void> _saveMedicalRecord() async {
    if (_formKey.currentState!.validate() && selectedPatientId != null) {

      String patientName = patientNames[selectedPatientId!] ?? 'Unknown';

      await FirebaseFirestore.instance
          .collection('medical_records')
          .doc(selectedPatientId)
          .set({
        'Name': patientName,
        'Age': _ageController.text,
        'BloodGroup': _bloodGroupController.text,
        'Genotype': _genotypeController.text,
        'Weight': _weightController.text,
        'Ailment': _ailmentController.text,
        'Prescription': _prescriptionController.text,
        'CreatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical record added successfully!')),
      );
      _clearForm();
    } else if (selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
    }
  }

  void _clearForm() {
    _ageController.clear();
    _bloodGroupController.clear();
    _genotypeController.clear();
    _weightController.clear();
    _ailmentController.clear();
    _prescriptionController.clear();
    setState(() {
      selectedPatientId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medical Record', style: GoogleFonts.lato()),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // if (patientNames.isEmpty) ...[
              //   const Center(child: CircularProgressIndicator()), // Show loading indicator
              // ] else ...[
              const SizedBox(
                height: 30,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Patient',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: selectedPatientId,
                items: patientNames.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Column(children: [
                      if (patientNames.isEmpty) ...[
                        const Text('No Patient found'),
                        // const Center(child: CircularProgressIndicator()),
                        // Show loading indicator
                      ] else ...[
                        Text(entry.value),
                      ],
                    ]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPatientId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a patient';
                  }
                  return null;
                },
              ),
              // ],
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the patient age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bloodGroupController,
                decoration: InputDecoration(
                  labelText: 'Blood Group',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _genotypeController,
                decoration: InputDecoration(
                  labelText: 'Genotype',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ailmentController,
                decoration: InputDecoration(
                  labelText: 'Ailment',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prescriptionController,
                decoration: InputDecoration(
                  labelText: 'Prescription',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveMedicalRecord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.lato(fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
