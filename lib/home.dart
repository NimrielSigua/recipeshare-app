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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
        // 'http://192.168.155.63/recipeapp/recipeshare/api/accfuntionality.php?operation=getUserInfo&user_id=${widget.userId}'));
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
        // 'http://192.168.155.63/recipeapp/recipeshare/api/accfuntionality.php?operation=getFollowerCount&user_id=${widget.userId}'));
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
              builder: (context) => RecipeDetailPage(
                recipe: recipe,
                currentUserId: widget.userId,
              ),
            ),
          ).then((_) => fetchAllRecipes());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                'assets/images/${recipe['recipe_image'] ?? 'default_image.jpg'}',
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
                          onTap: () async {
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
                            if (result != null && result['updatedFollowerCount'] != null) {
                              setState(() {
                                // Update follower count if needed
                              });
                            }
                          },
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: recipe['profile_image'] != null && recipe['profile_image'].isNotEmpty
                                ? AssetImage('${recipe['profile_image']}')
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
                    if (recipe['most_common_rating'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            RatingBarIndicator(
                              rating: double.parse(recipe['most_common_rating'].toString()),
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 14.0,
                              direction: Axis.horizontal,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '(${recipe['total_ratings']})',
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
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

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final int currentUserId;

  const RecipeDetailPage({
    Key? key, 
    required this.recipe, 
    required this.currentUserId
  }) : super(key: key);

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}


class _RecipeDetailPageState extends State<RecipeDetailPage> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _ratings = [];
  Map<String, dynamic>? _userRating;

  @override
  void initState() {
    super.initState();
    _fetchRatingsAndComments();
  }

  Future<void> _fetchRatingsAndComments() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/recipeapp/recipeshare/api/accfuntionality.php?operation=getRatingsAndComments&recipe_id=${widget.recipe['recipe_id']}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _ratings = List<Map<String, dynamic>>.from(data['ratings']);
          _userRating = _ratings.firstWhere(
            (rating) => rating['user_id'].toString() == widget.currentUserId.toString(),
            orElse: () => {},
          );
          if (_userRating != null && _userRating!.isNotEmpty) {
            _rating = _userRating!['rating'].toDouble();
            _commentController.text = _userRating!['comment'];
          }
        });
      } else {
        throw Exception('Failed to load ratings and comments');
      }
    } catch (e) {
      print('Error fetching ratings and comments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe['recipe_name'] ?? 'Recipe Details', style: AppTheme.logoStyle.copyWith(fontSize: 20)),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'images/${widget.recipe['recipe_image'] ?? 'default_image.jpg'}',
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
                  Text(
                    widget.recipe['recipe_name'] ?? 'Unnamed Recipe',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.recipe['description'] ?? 'No description',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text('Ingredients:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(widget.recipe['ingredients'] ?? 'No ingredients listed'),
                  SizedBox(height: 16),
                  Text('Cooking Time:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(widget.recipe['cooking_time'] ?? 'Not specified'),
                  SizedBox(height: 16),
                  Text('Meal Type:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(widget.recipe['mealtype'] ?? 'Not specified'),
                  SizedBox(height: 16),
                  Text('Cooking Steps:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildSteps(),
                  SizedBox(height: 24),
                  Text('Ratings and Comments:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildRatingsAndComments(),
                  SizedBox(height: 24),
                  Text(_userRating == null ? 'Rate this recipe:' : 'Update your rating:', 
                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitRatingAndComment,
                    child: Text(_userRating == null ? 'Submit Rating and Comment' : 'Update Rating and Comment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildSteps() {
    final steps = widget.recipe['steps'] as String? ?? '';
    final stepsList = steps.split('||');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        ...stepsList.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value.trim();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}. ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(step)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRatingsAndComments() {
    return Column(
      children: _ratings.map((rating) {
        bool isCurrentUserRating = rating['user_id'].toString() == widget.currentUserId.toString();
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: rating['profile_image'] != null
                          ? AssetImage('assets/${rating['profile_image']}')
                          : null,
                      child: rating['profile_image'] == null
                          ? Text(rating['username'][0].toUpperCase())
                          : null,
                    ),
                    SizedBox(width: 8),
                    Text(rating['username'], style: TextStyle(fontWeight: FontWeight.bold)),
                    if (isCurrentUserRating) Text(' (You)', style: TextStyle(fontStyle: FontStyle.italic)),
                    Spacer(),
                    RatingBarIndicator(
                      rating: rating['rating'].toDouble(),
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(rating['comment']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _submitRatingAndComment() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost/recipeapp/recipeshare/api/accfuntionality.php'),
        body: {
          'operation': 'addRatingAndComment',
          'recipe_id': widget.recipe['recipe_id'].toString(),
          'user_id': widget.currentUserId.toString(),
          'rating': _rating.toString(),
          'comment': _commentController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_userRating == null ? 'Rating and comment submitted successfully' : 'Rating and comment updated successfully')),
          );
          _fetchRatingsAndComments(); // Refresh the ratings and comments
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to submit rating and comment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
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
  int followerCount = 0;

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
        } else if (data is Map) {
          followingRecipes = [data];
        } else {
          followingRecipes = [];
        }
      });
    } else {
      print('Failed to load following recipes');
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(
                recipe: recipe,
                currentUserId: widget.userId,
              ),
            ),
          ).then((_) => fetchFollowingRecipes());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                'assets/images/${recipe['recipe_image'] ?? 'default_image.jpg'}',
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
                          onTap: () async {
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
                            if (result != null && result['updatedFollowerCount'] != null) {
                              setState(() {
                                followerCount = result['updatedFollowerCount'];
                              });
                            }
                          },
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: recipe['profile_image'] != null && recipe['profile_image'].isNotEmpty
                                ? AssetImage('${recipe['profile_image']}')
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
                    if (recipe['most_common_rating'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            RatingBarIndicator(
                              rating: double.parse(recipe['most_common_rating'].toString()),
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 14.0,
                              direction: Axis.horizontal,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '(${recipe['total_ratings']})',
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
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