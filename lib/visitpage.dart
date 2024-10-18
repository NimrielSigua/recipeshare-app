import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recipeshare/theme.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class VisitPage extends StatefulWidget {
  final int? userId;
  final String username;
  final String fullname;
  final String? profileImage;
  final int currentUserId; // Add this line

  const VisitPage({
    Key? key,
    required this.userId,
    required this.username,
    required this.fullname,
    this.profileImage,
    required this.currentUserId, // Add this line
  }) : super(key: key);

  @override
  _VisitPageState createState() => _VisitPageState();
}

class _VisitPageState extends State<VisitPage> {
  List<dynamic> userRecipes = [];
  int followerCount = 0;
  bool isFollowing = false;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserRecipes();
    fetchFollowerCount();
    fetchFollowingCount();
    if (widget.currentUserId != widget.userId) {
      checkFollowStatus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch data again when the page is displayed
    fetchUserRecipes();
    fetchFollowerCount();
    fetchFollowingCount();
    if (widget.currentUserId != widget.userId) {
      checkFollowStatus();
    }
  }

  Future<void> fetchUserRecipes() async {
    if (widget.userId == null) {
      print('User ID is null');
      return;
    }
    
    final response = await http.get(Uri.parse(
        'http://localhost/recipeapp/recipeshare/api/accfuntionality.php?operation=getUserRecipes&user_id=${widget.userId}'));
    
    if (response.statusCode == 200) {
      setState(() {
        userRecipes = json.decode(response.body);
      });
    } else {
      print('Failed to load user recipes');
    }
  }

  Future<void> fetchFollowerCount() async {
    if (widget.userId == null) {
      print('User ID is null');
      return;
    }
    
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

  Future<void> checkFollowStatus() async {
    final response = await http.get(Uri.parse(
        'http://localhost/recipeapp/recipeshare/api/accfuntionality.php?operation=checkFollowStatus&follower_id=${widget.currentUserId}&followed_id=${widget.userId}'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        isFollowing = data['is_following'];
      });
    } else {
      print('Failed to check follow status');
    }
  }

  Future<void> followUnfollowUser() async {
    if (widget.currentUserId == widget.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You cannot follow your own account")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost/recipeapp/recipeshare/api/accfuntionality.php'),
      body: {
        'operation': 'followUnfollowUser',
        'follower_id': widget.currentUserId.toString(),
        'followed_id': widget.userId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          followerCount = data['follower_count'];
          isFollowing = data['is_following'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        Navigator.pop(context, {'updatedFollowerCount': followerCount});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } else {
      print('Failed to follow/unfollow user');
    }
  }

  Future<void> fetchFollowingCount() async {
    final response = await http.get(Uri.parse(
        'http://localhost/recipeapp/recipeshare/api/accfuntionality.php?operation=getFollowingCount&user_id=${widget.userId}'));

    if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
            followingCount = data['following_count']; // Assuming you have a followingCount variable
        });
    } else {
        print('Failed to load following count');
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.fullname, 
                style: AppTheme.logoStyle.copyWith(
                  fontSize: 20,
                  color: AppTheme.accentColor, // Ensure visibility
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: widget.profileImage != null
                        ? AssetImage('${widget.profileImage}')
                        : null,
                    child: widget.profileImage == null 
                      ? Icon(Icons.person, size: 60, color: AppTheme.primaryColor) 
                      : null,
                    backgroundColor: AppTheme.accentColor,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('@${widget.username}', 
                        style: AppTheme.subheadingStyle.copyWith(
                          color: AppTheme.primaryColor, // Ensure visibility
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatColumn('Following', '$followingCount'),
                          SizedBox(width: 32),
                          _buildStatColumn('Followers', '$followerCount'),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (widget.currentUserId != widget.userId)
                        ElevatedButton(
                          onPressed: followUnfollowUser,
                          child: Text(isFollowing ? "Unfollow" : "Follow"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing ? Colors.grey : AppTheme.primaryColor,
                            foregroundColor: AppTheme.accentColor,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Recipes', 
                    style: AppTheme.headingStyle.copyWith(
                      color: AppTheme.primaryColor, // Ensure visibility
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recipe = userRecipes[index];
                  return _buildRecipeCard(recipe, context);
                },
                childCount: userRecipes.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, 
          style: AppTheme.headingStyle.copyWith(
            fontSize: 20,
            color: AppTheme.primaryColor, // Ensure visibility
          ),
        ),
        Text(label, 
          style: AppTheme.bodyTextStyle.copyWith(
            color: AppTheme.primaryColor, // Ensure visibility
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
              builder: (context) => RecipeDetailPage(recipe: recipe, currentUserId: widget.currentUserId),
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
                  color: AppTheme.accentColor,
                  child: Icon(Icons.broken_image, size: 50, color: AppTheme.primaryColor),
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
                      style: AppTheme.subheadingStyle.copyWith(fontSize: 14, color: AppTheme.primaryColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        recipe['description'],
                        style: AppTheme.bodyTextStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          recipe['cooking_time'] ?? 'N/A',
                          style: AppTheme.bodyTextStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
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

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final int currentUserId;

  const RecipeDetailPage({Key? key, required this.recipe, required this.currentUserId}) : super(key: key);

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

  Widget _buildSteps() {
    // Implement this method to display cooking steps
    return Text(widget.recipe['cooking_steps'] ?? 'No steps provided');
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
                          ? AssetImage('assets/images/${rating['profile_image']}')
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
          _fetchRatingsAndComments();
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
}
