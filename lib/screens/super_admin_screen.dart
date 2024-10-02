import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telehealth_app/screens/sign_in.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({Key? key}) : super(key: key);

  @override
  _SuperAdminScreenState createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _passkeyController = TextEditingController();

  int role = -1; // 0 for doctor, 1 for nurse
  bool isSuperAdmin = true; // This screen is for SuperAdmin

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();
  FocusNode f5 = FocusNode();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _passkeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
                    child: _signUp(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signUp() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: Text(
                'Register',
                style: GoogleFonts.lato(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Passkey field
            if (isSuperAdmin) _buildPasskeyField(),
            const SizedBox(height: 25.0),
            // Display name field
            _buildTextField(
              focusNode: f1,
              controller: _displayNameController,
              hintText: 'Name',
              nextFocusNode: f2,
            ),
            const SizedBox(height: 25.0),
            // Email field
            _buildTextField(
              focusNode: f2,
              controller: _emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              nextFocusNode: f3,
              validator: emailValidate,
            ),
            const SizedBox(height: 25.0),
            // Password field
            _buildTextField(
              focusNode: f3,
              controller: _passwordController,
              hintText: 'Password',
              obscureText: true,
              nextFocusNode: f4,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the Password';
                } else if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(height: 25.0),
            // Confirm password field
            _buildTextField(
              focusNode: f4,
              controller: _passwordConfirmController,
              hintText: 'Confirm Password',
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please confirm the Password';
                } else if (value.compareTo(_passwordController.text) != 0) {
                  return 'Passwords do not match';
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(height: 20),
            // Account role selection (only for super admins)
            if (isSuperAdmin) _buildAccountTypeSelection(),
            // Register button
            _buildRegisterButton(),
            // Divider
            _buildDivider(),
            // Sign-in option
            _buildSignInOption(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasskeyField() {
    return TextFormField(
      focusNode: f5,
      controller: _passkeyController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(90.0)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[350],
        hintText: 'Passkey',
        hintStyle: GoogleFonts.lato(
          color: Colors.black26,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      obscureText: true,
      validator: (value) {
        if (value != '1111') {
          return 'Invalid passkey';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hintText,
    FocusNode? nextFocusNode,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(90.0)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[350],
        hintText: hintText,
        hintStyle: GoogleFonts.lato(
          color: Colors.black26,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      onFieldSubmitted: (value) {
        focusNode.unfocus();
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        }
      },
      textInputAction: nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
      validator: validator,
    );
  }

  Widget _buildAccountTypeSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAccountTypeButton(
          text: "doctor",
          selected: role == 0,
          onPressed: () => setState(() => role = 0),
        ),
        const SizedBox(
          height: 50,
          child: Center(
            child: Text(
              'or',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        _buildAccountTypeButton(
          text: "nurse",
          selected: role == 1,
          onPressed: () => setState(() => role = 1),
        ),
      ],
    );
  }

  Widget _buildAccountTypeButton({
    required String text,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2.5,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: Colors.grey[350],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          side: BorderSide(
            width: 5.0,
            color: Colors.black38,
            style: selected ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.lato(
            color: selected ? Colors.black38 : Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      padding: const EdgeInsets.only(top: 25),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                // Create user in Firebase Auth
                final userCredential = await _auth.createUserWithEmailAndPassword(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );

                // Update Firestore with user details and role
                await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                  'displayName': _displayNameController.text.trim(),
                  'email': _emailController.text.trim(),
                  'role': role == 0 ? 'doctor' : 'nurse',
                  'uid': userCredential.user!.uid,
                });

                // Navigate to sign-in screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignIn()),
                );
              } catch (e) {
                print(e);
                // Handle errors, e.g., show a dialog or snackbar
              }
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: Colors.green[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
          ),
          child: Text(
            'Register',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 1,
            width: MediaQuery.of(context).size.width * 0.8,
            color: Colors.black26,
          ),
        ],
      ),
    );
  }

  Widget _buildSignInOption() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      },
      child: Text(
        'Sign in',
        style: GoogleFonts.lato(
          color: Colors.green[700],
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String? emailValidate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null; // If the email is valid
  }
}
