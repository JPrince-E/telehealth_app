import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telehealth_app/globals.dart';

class ViewMedicalRecords extends StatefulWidget {
  const ViewMedicalRecords({Key? key}) : super(key: key);

  @override
  State<ViewMedicalRecords> createState() => _ViewMedicalRecordsState();
}

class _ViewMedicalRecordsState extends State<ViewMedicalRecords> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;
  Future<List<Map<String, dynamic>>>? _recordsFuture;

  bool isLoading = true; // Add a loading flag

  Future<void> _initialize() async {
    user = _auth.currentUser!;

    // Fetch user role (assume this is fetched from Firestore or user metadata)
    final userRoleSnapshot = await FirebaseFirestore.instance
        .collection('medical_records')
        .doc(user.uid)
        .get();

    if (userRoleSnapshot.exists) {
      isNurse = userRoleSnapshot.data()?['isNurse'] ?? false;
    }

    setState(() {
      _recordsFuture = _fetchRecords();
      isLoading = false; // Once data is initialized, stop loading
    });
  }

  Future<List<Map<String, dynamic>>> _fetchRecords() async {
    try {
      if (isNurse) {
        // Fetch all medical records if the user is a nurse
        final querySnapshot = await FirebaseFirestore.instance
            .collection('medical_records')
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'name': data['Name'], // Add a name field to identify records
            'age': data['Age'],
            'bloodGroup': data['BloodGroup'],
            'genotype': data['Genotype'],
            'weight': data['Weight'],
            'ailment': data['Ailment'],
            'prescription': data['Prescription'],
            'createdAt': data['CreatedAt'],
          };
        }).toList();
      } else {
        // Fetch medical records for the current patient
        final docSnapshot = await FirebaseFirestore.instance
            .collection('medical_records')
            .doc(user.uid)
            .get();

        if (!docSnapshot.exists) {
          throw Exception('No records found for this user.');
        }

        final data = docSnapshot.data()!;
        return [
          {
            'name': data['Name'],
            'age': data['Age'],
            'bloodGroup': data['BloodGroup'],
            'genotype': data['Genotype'],
            'weight': data['Weight'],
            'ailment': data['Ailment'],
            'prescription': data['Prescription'],
            'createdAt': data['CreatedAt'],
          }
        ];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching records: $e')),
      );
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNurse ? 'All Medical Records' : 'My Medical Records', style: GoogleFonts.lato()),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : FutureBuilder<List<Map<String, dynamic>>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No medical records found.'));
          }

          final records = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  isNurse ? 'Patient: ${record['name'] ?? 'Unknown'}' : 'Medical Record',
                  style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Ailment: ${record['ailment'] ?? 'N/A'}',
                  style: GoogleFonts.lato(),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicalRecordDetailScreen(record: record),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class MedicalRecordDetailScreen extends StatelessWidget {
  final Map<String, dynamic> record;

  const MedicalRecordDetailScreen({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Record Details', style: GoogleFonts.lato()),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Age: ${record['age'] ?? 'N/A'}',
              style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Blood Group: ${record['bloodGroup'] ?? 'N/A'}',
              style: GoogleFonts.lato(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Genotype: ${record['genotype'] ?? 'N/A'}',
              style: GoogleFonts.lato(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Weight: ${record['weight'] ?? 'N/A'}',
              style: GoogleFonts.lato(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Ailment: ${record['ailment'] ?? 'N/A'}',
              style: GoogleFonts.lato(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Prescription: ${record['prescription'] ?? 'N/A'}',
              style: GoogleFonts.lato(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Record Created At: ${record['createdAt'] != null ? (record['createdAt'] as Timestamp).toDate().toString() : 'N/A'}',
              style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
