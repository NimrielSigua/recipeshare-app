import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:recipeshare/main.dart';
import 'package:recipeshare/addingrecipe.dart';
import 'package:recipeshare/theme.dart';
import 'package:recipeshare/myrecipe.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:recipeshare/visitpage.dart';

class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? username;
  String? fullname;
  String? profileImageUrl;
  List<dynamic> allRecipes = [];
  List<dynamic> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();
  int followerCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUserInfo();
    fetchAllRecipes();
    fetchFollowerCount();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> fetchAllRecipes() async {
    final response = await http.get(Uri.parse(
        'http://localhost/recipeapp/recipeshare/api/accfuntionality.php?operation=getAllRecipes'));

    if (response.statusCode == 200) {
      setState(() {
        allRecipes = json.decode(response.body);
        filteredRecipes = allRecipes;
      });
    } else {
      print('Failed to load recipes');
    }
  }

  Future<void> fetchFollowerCount() async {
    final response = await http.get(Uri.parse(
        'http://localhost/recipeapp/recipeshare/api/accfuntionality.php?operation=getFollowerCount&user_id=${widget.userId}'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        followerCount = data['follower_count'];
      });
    } else {
      print('Failed to load follower count');
    }
  }

  void filterRecipes(String query) {
    setState(() {
      filteredRecipes = allRecipes.where((recipe) {
        final username = recipe['username'].toString().toLowerCase();
        final fullname = recipe['fullname'].toString().toLowerCase();
        final recipeName = recipe['recipe_name'].toString().toLowerCase();
        final mealtype = recipe['mealtype'].toString().toLowerCase();
        final searchLower = query.toLowerCase();

        return username.contains(searchLower) ||
            fullname.contains(searchLower) ||
            recipeName.contains(searchLower) ||
            mealtype.contains(searchLower);
      }).toList();
    });
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
        title: Text('Recipe Share', style: AppTheme.logoStyle.copyWith(fontSize: 24)),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Recipes'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: AppTheme.backgroundColor,
          child: Column(
            children: [
              Container(
                height: 230,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Theme.of(context).primaryColor, Color(0xFFF7FFF7)],
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
                                          Row(
                                            children: [
                                              Text("Followers: $followerCount", style: TextStyle(color: Colors.white)),
                                              SizedBox(width: 10.0,),
                                              Text("Likes: 30", style: TextStyle(color: Colors.white))
                                            ],
                                          )
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
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyRecipesPage(userId: widget.userId),
                          ),
                        );
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllRecipesTab(),
          FollowingRecipesTab(userId: widget.userId),
        ],
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
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Add Recipe',
      ),
    );
  }

  Widget _buildAllRecipesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search recipes, users, or meal types...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: filterRecipes,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
              return _buildRecipeCard(recipe, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(recipe: recipe),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                'images/${recipe['recipe_image']}',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey[500]),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['recipe_name'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        recipe['description'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {  // Add async keyword
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VisitPage(
                                  userId: recipe['user_id'] != null ? int.parse(recipe['user_id'].toString()) : null,
                                  username: recipe['username'] ?? '',
                                  fullname: recipe['fullname'] ?? '',
                                  profileImage: recipe['profile_image'],
                                  currentUserId: widget.userId,
                                ),
                              ),
                            );
                            
                            // Check if the result contains updated follower count
                            if (result != null && result['updatedFollowerCount'] != null) {
                              setState(() {
                                followerCount = result['updatedFollowerCount'];
                              });
                            }
                          },
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: recipe['profile_image'] != null && recipe['profile_image'].isNotEmpty
                                ? AssetImage('assets/${recipe['profile_image']}')
                                : null,
                            child: recipe['profile_image'] == null || recipe['profile_image'].isEmpty
                                ? Icon(Icons.person, size: 16)
                                : null,
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recipe['fullname'],
                            style: TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['recipe_name'] ?? 'Recipe Details', style: AppTheme.logoStyle.copyWith(fontSize: 20)),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'images/${recipe['recipe_image'] ?? 'default_image.jpg'}',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[300],
                child: Icon(Icons.broken_image, size: 100, color: Colors.grey[500]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCreatorInfo(context, recipe['fullname'] ?? 'Unknown User', recipe['profile_image']),
                  SizedBox(height: 16),
                  _buildDetailItem(context, 'Description', recipe['description'] ?? 'No description', icon: Icons.description),
                  _buildDetailItem(context, 'Cooking Time', recipe['cooking_time'] ?? 'Not specified', icon: Icons.access_time),
                  _buildDetailItem(context, 'Meal Type', recipe['mealtype'] ?? 'Not specified', icon: Icons.category),
                  _buildIngredients(context, recipe['ingredients'] ?? ''),
                  _buildSteps(context, recipe['steps'] ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorInfo(BuildContext context, String fullname, String? profileImage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: profileImage != null && profileImage.isNotEmpty
                ? AssetImage('assets/$profileImage')
                : null,
            child: profileImage == null || profileImage.isEmpty ? Icon(Icons.person) : null,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Created by',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                fullname,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String title, String content, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppTheme.primaryColor),
                SizedBox(width: 8),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildIngredients(BuildContext context, String ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shopping_basket, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...ingredients.split(',').map((ingredient) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.fiber_manual_record, size: 12, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(ingredient.trim(), style: TextStyle(fontSize: 16)),
            ],
          ),
        )).toList(),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSteps(BuildContext context, String steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.format_list_numbered, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text(
              'Steps',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ...steps.split('||').asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                child: Text('${entry.key + 1}'),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                radius: 14,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  entry.value,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}

class FollowingRecipesTab extends StatefulWidget {
  final int userId;

  const FollowingRecipesTab({Key? key, required this.userId}) : super(key: key);

  @override
  _FollowingRecipesTabState createState() => _FollowingRecipesTabState();
}

class _FollowingRecipesTabState extends State<FollowingRecipesTab> {
  List<dynamic> followingRecipes = [];

  @override
  void initState() {
    super.initState();
    fetchFollowingRecipes();
  }

  Future<void> fetchFollowingRecipes() async {
    final response = await http.get(Uri.parse(
        'http://localhost/recipeapp/recipeshare/api/accfuntionality.php?operation=getFollowingRecipes&user_id=${widget.userId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        if (data is List) {
          followingRecipes = data;
        } else if (data is Map && data.containsKey('error')) {
          print('Error fetching following recipes: ${data['error']}');
          followingRecipes = [];
        } else {
          followingRecipes = [];
        }
      });
    } else {
      print('Failed to load following recipes. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return followingRecipes.isEmpty
        ? Center(child: Text('No recipes from followed users'))
        : GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: followingRecipes.length,
            itemBuilder: (context, index) {
              final recipe = followingRecipes[index];
              return _buildRecipeCard(recipe, context);
            },
          );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Check if all required fields are present before navigating
          if (recipe['recipe_name'] != null &&
              recipe['description'] != null &&
              recipe['recipe_image'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailPage(recipe: recipe),
              ),
            );
          } else {
            // Show an error message if required fields are missing
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Recipe details are incomplete')),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                'images/${recipe['recipe_image'] ?? 'default_image.jpg'}',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey[500]),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['recipe_name'] ?? 'Unnamed Recipe',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        recipe['description'] ?? 'No description',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VisitPage(
                                  userId: recipe['user_id'] != null ? int.parse(recipe['user_id'].toString()) : null,
                                  username: recipe['username'] ?? '',
                                  fullname: recipe['fullname'] ?? '',
                                  profileImage: recipe['profile_image'],
                                  currentUserId: widget.userId,
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: recipe['profile_image'] != null && recipe['profile_image'].isNotEmpty
                                ? AssetImage('assets/${recipe['profile_image']}')
                                : null,
                            child: recipe['profile_image'] == null || recipe['profile_image'].isEmpty
                                ? Icon(Icons.person, size: 16)
                                : null,
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recipe['fullname'] ?? 'Unknown User',
                            style: TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}