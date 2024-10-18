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
  Uint8List? _webImageBytes;
 
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
          image: DecorationImage(
            image: AssetImage('images/loginbg.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
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
                    _buildLogo(),
                    SizedBox(height: 50),
                    _buildLoginCard(),
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
                    _buildRegisterButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _buildLogo() {
    return Column(
      children: [
        Icon(
          Icons.restaurant_menu,
          size: 80,
          color: Colors.white,
        ),
        SizedBox(height: 16),
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
        SizedBox(height: 8),
        Text(
          'Discover, Share, and Cook Together',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
 
  Widget _buildLoginCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _usernameController,
              icon: Icons.person,
              label: 'Username',
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              icon: Icons.lock,
              label: 'Password',
              isPassword: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: logIn,
              child: Text('Login', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }
 
  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: _showRegisterDialog,
      child: Text(
        'New to RecipeShare? Join our cooking community!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
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
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Join RecipeShare',
                      style: GoogleFonts.pacifico(
                        fontSize: 28,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start your culinary journey today!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildTextField(
                      icon: Icons.person,
                      label: 'Full Name',
                      controller: _fullNameupController,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      icon: Icons.account_circle,
                      label: 'Username',
                      controller: _usernameupController,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      icon: Icons.lock,
                      label: 'Password',
                      isPassword: true,
                      controller: _passwordupController,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      icon: Icons.lock_outline,
                      label: 'Confirm Password',
                      isPassword: true,
                      controller: _confirmPasswordController,
                    ),
                    SizedBox(height: 24),
                    _buildImagePicker(),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        register();
                        _animationController.reverse().then((_) {
                          Navigator.of(context).pop();
                        });
                      },
                      child: Text('Join Now', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _animationController.reverse().then((_) {
                          Navigator.of(context).pop();
                        });
                      },
                      child: Text('Cancel', style: TextStyle(fontSize: 16, color: AppTheme.primaryColor)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          child: _profileImageFile != null || _webImageBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: kIsWeb
                      ? Image.memory(
                          _webImageBytes!,
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
        if (kIsWeb) {
          pickedFile.readAsBytes().then((value) {
            _webImageBytes = value;
          });
        } else {
          _profileImageFile = File(pickedFile.path);
        }
      }
    });
  }
 
  void register() async {
    // Check if password and confirm password match
    if (_passwordupController.text != _confirmPasswordController.text) {
      setState(() {
        _msg = "Passwords do not match!";
      });
      return; // Exit the function if passwords do not match
    }
    String url = "http://localhost/recipeapp/recipeshare/api/aut.php";
    // String url = "http://192.168.95.63/recipeapp/recipeshare/api/aut.php";
    // String url = "http://10.0.0.57/recipeapp/recipeshare/api/aut.php";
 
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['operation'] = 'register';
    request.fields['username'] = _usernameupController.text;
    request.fields['password'] = _passwordupController.text;
    request.fields['fullname'] = _fullNameupController.text;
 
    if (kIsWeb) {
      if (_webImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'profile_image',
          _webImageBytes!,
          filename: 'profile_image.jpg',
        ));
      }
    } else {
      if (_profileImageFile != null) {
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
 
    String url = "http://localhost/recipeapp/recipeshare/api/aut.php";
    // String url = "http://192.168.95.63/recipeapp/recipeshare/api/aut.php";
    // String url = "http://10.0.0.57/recipeapp/recipeshare/api/aut.php";
 
    final Map<String, String> body = {
      "operation": "login",
      "username": _usernameController.text,
      "password": _passwordController.text,
    };
 
    try {
      http.Response response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: body);
 
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          // Convert the user_id to int
          int userId = int.parse(data[0]['user_id'].toString());
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
