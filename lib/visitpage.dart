import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recipeshare/theme.dart';

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

  @override
  void initState() {
    super.initState();
    fetchUserRecipes();
    fetchFollowerCount();
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
        // 'http://192.168.155.63/recipeapp/recipeshare/api/accfuntionality.php?operation=getUserRecipes&user_id=${widget.userId}'));
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

  Future<void> checkFollowStatus() async {
    final response = await http.get(Uri.parse(
        // 'http://192.168.155.63/recipeapp/recipeshare/api/accfuntionality.php?operation=checkFollowStatus&follower_id=${widget.currentUserId}&followed_id=${widget.userId}'));
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
      // Uri.parse('http://192.168.155.63/recipeapp/recipeshare/api/accfuntionality.php'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: widget.profileImage != null
                      ? AssetImage('assets/${widget.profileImage}')
                      : null,
                  child: widget.profileImage == null ? Icon(Icons.person, size: 40) : null,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fullname,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '@${widget.username}',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),

                    Row(
                      children: [
                        Text('Following: 30'),
                        SizedBox(width: 10.0,),
                        Text('Followers: $followerCount'),
                      ],
                    ),
                  ],
                  
                ),
              ],
            ),
          ),

          if (widget.currentUserId != widget.userId)
            ElevatedButton(
              onPressed: followUnfollowUser,
              child: Text(isFollowing ? "Unfollow" : "Follow"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey :  Color(0xFFFF6B6B),
                foregroundColor: isFollowing ?  Color(0xFFFF6B6B)  : Colors.white
              ),
            ),
          Expanded(
            child: userRecipes.isEmpty
                ? Center(child: Text('No recipes found'))
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: userRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = userRecipes[index];
                      return _buildRecipeCard(recipe, context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Navigate to recipe detail page
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