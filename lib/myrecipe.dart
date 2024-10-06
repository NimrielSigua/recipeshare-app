import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipeshare/addingrecipe.dart';
import 'package:recipeshare/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyRecipesPage extends StatefulWidget {
  final int userId;

  const MyRecipesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MyRecipesPageState createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  List<dynamic> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(
          // 'http://192.168.155.63/recipeapp/recipeshare/api/accfuntionality.php?operation=getUserRecipes&user_id=${widget.userId}'));
          'http://localhost/recipeapp/recipeshare/api/accfuntionality.php?operation=getUserRecipes&user_id=${widget.userId}'));

      if (response.statusCode == 200) {
        setState(() {
          _recipes = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load recipes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Recipes', style: AppTheme.logoStyle.copyWith(fontSize: 24)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _recipes.isEmpty
              ? _buildEmptyState()
              : _buildRecipeGrid(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 100, color: AppTheme.primaryColor.withOpacity(0.5)),
          SizedBox(height: 24),
          Text(
            'No recipes found',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Add some delicious recipes!',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement add new recipe functionality
            },
            child: Text('Add Your First Recipe'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return _buildRecipeCard(recipe, context);
      },
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe, currentUserId: widget.userId)),
        ),
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
                    SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        recipe['description'],
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: AppTheme.primaryColor),
                        SizedBox(width: 2),
                        Text(
                          recipe['cooking_time'],
                          style: TextStyle(fontSize: 11, color: AppTheme.primaryColor),
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
}