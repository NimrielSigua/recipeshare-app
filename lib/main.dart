import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipeshare/home.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:recipeshare/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecipeShare',
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  String _msg = "";
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameupController = TextEditingController();
  final TextEditingController _passwordupController = TextEditingController();
  final TextEditingController _fullNameupController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  File? _profileImageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, AppTheme.accentColor],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'RecipeShare',
                      style: GoogleFonts.pacifico(
                        fontSize: 48,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person,
                                    color: Color(0xFFFF6B6B)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Color(0xFFFF6B6B), width: 2),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon:
                                    Icon(Icons.lock, color: Color(0xFFFF6B6B)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Color(0xFFFF6B6B), width: 2),
                                ),
                              ),
                              obscureText: true,
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: logIn,
                              child:
                                  Text('Login', style: TextStyle(fontSize: 18)),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFFFF6B6B),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _msg,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextButton(
                      onPressed: _showRegisterDialog,
                      child: Text(
                        'New user? Register here',
                        style: TextStyle(
                            color: const Color.fromARGB(235, 45, 0, 0),
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRegisterDialog() {
    _animationController.forward();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return SlideTransition(
          position: _slideAnimation,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Join RecipeShare',
                    style: GoogleFonts.pacifico(
                      fontSize: 24,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                      icon: Icons.person,
                      label: 'Full Name',
                      controller: _fullNameupController),
                  SizedBox(height: 15),
                  _buildTextField(
                      icon: Icons.account_circle,
                      label: 'Username',
                      controller: _usernameupController),
                  SizedBox(height: 15),
                  _buildTextField(
                      icon: Icons.lock,
                      label: 'Password',
                      isPassword: true,
                      controller: _passwordupController),
                  SizedBox(height: 15),
                  _buildTextField(
                      icon: Icons.lock_outline,
                      label: 'Confirm Password',
                      isPassword: true,
                      controller: _confirmPasswordController),
                  SizedBox(height: 15),
                  _buildImagePicker(),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        label: 'Cancel',
                        onPressed: () {
                          _animationController.reverse().then((_) {
                            Navigator.of(context).pop();
                          });
                        },
                        isPrimary: false,
                      ),
                      _buildButton(
                        label: 'Register',
                        onPressed: () {
                          register();
                          // Implement registration logic here
                          _animationController.reverse().then((_) {
                            Navigator.of(context).pop();
                          });
                        },
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    bool isPassword = false,
    required TextEditingController controller, // Add this line
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller, // Add this line
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFFFF6B6B)),
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildButton(
      {required String label,
      required VoidCallback onPressed,
      required bool isPrimary}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label, style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        foregroundColor: isPrimary ? Colors.white : Color(0xFFFF6B6B),
        backgroundColor: isPrimary ? Color(0xFFFF6B6B) : Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Color(0xFFFF6B6B)),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Choose from Gallery'),
                      onTap: () {
                        getImage(ImageSource.gallery);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_camera),
                      title: Text('Take a Photo'),
                      onTap: () {
                        getImage(ImageSource.camera);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: _profileImageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: kIsWeb
                      ? Image.network(
                          _profileImageFile!.path,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _profileImageFile!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                )
              : Icon(
                  Icons.add_a_photo,
                  size: 50,
                  color: Theme.of(context).primaryColor,
                ),
        ),
      ),
    );
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _profileImageFile = File(pickedFile.path);
      }
    });
  }

  void register() async {
    String url = "http://localhost/recipeapp/recipeshare/api/aut.php";
    // String url = "http://192.168.155.63/recipeapp/recipeshare/api/aut.php";

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['operation'] = 'register';
    request.fields['username'] = _usernameupController.text;
    request.fields['password'] = _passwordupController.text;
    request.fields['fullname'] = _fullNameupController.text;

    if (_profileImageFile != null) {
      if (kIsWeb) {
        Uint8List imageBytes = await _profileImageFile!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'profile_image',
          imageBytes,
          filename: 'profile_image.jpg',
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _profileImageFile!.path,
        ));
      }
    }

    try {
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var result = json.decode(String.fromCharCodes(responseData));

      if (response.statusCode == 200 && result['success']) {
        setState(() {
          _msg = "Registration successful!";
        });
      } else {
        setState(() {
          _msg = "Registration failed: ${result['message']}";
        });
      }
    } catch (error) {
      setState(() {
        _msg = "Error: $error";
      });
    }
  }

  void logIn() async {
    // Check if username or password is empty
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _msg = "Please enter both username and password";
      });
      return;
    }

      //  String url = "http://192.168.155.63/recipeapp/recipeshare/api/aut.php";
       String url = "http://localhost/recipeapp/recipeshare/api/aut.php";

    final Map<String, String> body = {
      "operation": "login",
      "username": _usernameController.text,
      "password": _passwordController.text,
    };

    try {
      http.Response response = await http.post(
  Uri.parse(url),
  headers: {"Content-Type": "application/x-www-form-urlencoded"},
  body: body
);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          int userId = data[0]['user_id'];
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(userId: userId),
            ),
          );
        } else {
          setState(() {
            _msg = "Invalid username or password";
          });
        }
      } else {
        setState(() {
          _msg = "Error: ${response.statusCode}";
        });
      }
    } catch (error) {
      setState(() {
        _msg = "Error: $error";
      });
    }
  }
}