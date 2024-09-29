import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:recipeshare/main.dart';
import 'package:recipeshare/addingrecipe.dart';

class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  String? fullname;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final response = await http.get(Uri.parse(
        'http://localhost/recipeapp/recipeshare/api/accfuntionality.php?operation=getUserInfo&user_id=${widget.userId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        username = data['username'];
        fullname = data['fullname'];
        profileImageUrl = data['profile_image'];
      });
    } else {
      print('Failed to load user info');
    }
  }

  Future<void> _handleLogout() async {
    // Clear user data (you might want to clear any stored tokens or user info)
    setState(() {
      username = null;
      fullname = null;
      profileImageUrl = null;
    });

    // Navigate to the login screen
   Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyApp(),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RecipeShare'),
        backgroundColor: Color(0xFFFF6B6B),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "RecipeShare",
                            style: GoogleFonts.pacifico(
                              fontSize: 24,
                              color: const Color(0xFFFF6B6B),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.white,
                                    child: profileImageUrl != null &&
                                            profileImageUrl!.isNotEmpty
                                        ? ClipOval(
                                            child: Image.asset(
                                              '$profileImageUrl',
                                              height: 90,
                                              width: 90,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 90,
                                                  width: 90,
                                                  color: Colors.grey[300],
                                                  child: Center(
                                                    child: Icon(Icons.error,
                                                        color: Colors.red),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Icon(Icons.person,
                                            size: 45, color: Color(0xFFFF6B6B)),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          fullname ?? 'User',
                                          style: GoogleFonts.firaSans(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '@${username ?? 'User'}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.home, color: Color(0xFFFF6B6B)),
                    title: Text('Home', style: TextStyle(fontSize: 16)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.book, color: Color(0xFFFF6B6B)),
                    title: Text('My Recipes', style: TextStyle(fontSize: 16)),
                    onTap: () {
                      // TODO: Implement My Recipes page navigation
                      Navigator.pop(context);
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.settings, color: Color(0xFFFF6B6B)),
                    title: Text('Settings', style: TextStyle(fontSize: 16)),
                    onTap: () {
                      // TODO: Implement Settings page navigation
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.help, color: Color(0xFFFF6B6B)),
                    title:
                        Text('Help & Feedback', style: TextStyle(fontSize: 16)),
                    onTap: () {
                      // TODO: Implement Help & Feedback page navigation
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Container(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.logout, color: Color(0xFFFF6B6B)),
                        title: Text('Logout', style: TextStyle(fontSize: 16)),
                        onTap: () {
                          _handleLogout();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddingRecipePage(userId: widget.userId),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFFF6B6B),
        tooltip: 'Add Recipe',
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Welcome to RecipeShare!',
              style: GoogleFonts.pacifico(
                fontSize: 24,
                color: Color(0xFFFF6B6B),
              ),
            ),
            SizedBox(height: 20.0),
            Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            width: 150,
                            height: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  child: Image.asset(
                                    '/images/recipe1.jpg',
                                    height: 100,
                                    width: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 100,
                                        width: 150,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Icon(Icons.error,
                                              color: Colors.red),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Recipe ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'A delicious recipe description',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            width: 150,
                            height: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  child: Image.asset(
                                    '/images/recipe1.jpg',
                                    height: 100,
                                    width: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 100,
                                        width: 150,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Icon(Icons.error,
                                              color: Colors.red),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Recipe ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'A delicious recipe description',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.0),
            // You can add more widgets here if needed
          ],
        ),
      ),
    );
  }
}
