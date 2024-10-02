import 'package:firebase_database/firebase_database.dart';

class PatientAppointmentDao {
  late DatabaseReference _appointmentsRef;
  final String doctorId;

  PatientAppointmentDao(this.doctorId) {
    _appointmentsRef = FirebaseDatabase.instance
        .ref('appointments')
        .child(doctorId);
  }

  Query getPatientAppointmentQuery() {
    return _appointmentsRef;
  }
}
