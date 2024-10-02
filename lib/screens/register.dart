import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telehealth_app/screens/sign_in.dart';

class Register extends StatefulWidget {
  final String? role;

  const Register({Key? key, this.role}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _displayName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  int role = -1; // 0 for doctor, 1 for Patient
  bool isSuperAdmin = false;

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayName.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Check if the user is a super admin
    isSuperAdmin = widget.role == 'SuperAdmin';
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
                'Sign up',
                style: GoogleFonts.lato(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Display name field
            _buildTextField(
              focusNode: f1,
              controller: _displayName,
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
          text: "Patient",
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
      padding: const EdgeInsets.only(top: 25.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() && (role != -1 || !isSuperAdmin)) {
              showLoaderDialog(context);
              await _registerAccount();
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.green[900],
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
          ),
          child: Text(
            isSuperAdmin ? "Register" : "Sign Up",
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
    return Container(
        padding: const EdgeInsets.only(top: 25, left: 10, right: 10),
    width: MediaQuery.of(context).size.width,
      child: Divider(
        color: Colors.black38,
        thickness: 1,
      ),
    );
  }

  Widget _buildSignInOption() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SignIn()),
          );
        },
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Already have an account? ",
                style: GoogleFonts.lato(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: "Sign In",
                style: GoogleFonts.lato(
                  color: Colors.green[900],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerAccount() async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(_displayName.text.trim());
        await user.reload();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'displayName': _displayName.text.trim(),
          'email': _emailController.text.trim(),
          'role': 'patient',
          // 'role': role == 0 ? 'doctor' : 'Patient',
          'createdAt': Timestamp.now(),
          // Additional user info can be added here
        });

        // Navigate to the sign-in screen after successful registration
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // Close the loading dialog
      _showErrorDialog(context, e.message ?? 'Registration failed. Please try again.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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


  void showLoaderDialog(BuildContext context) {
    AlertDialog alert = const AlertDialog(
      content: SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

