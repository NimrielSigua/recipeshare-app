import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddingRecipePage extends StatefulWidget {
  final int userId;

  const AddingRecipePage({Key? key, required this.userId}) : super(key: key);

  @override
  _AddingRecipePageState createState() => _AddingRecipePageState();
}

class _AddingRecipePageState extends State<AddingRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _recipeName = TextEditingController();
  final _ingredients = TextEditingController();
  final _cookingTime = TextEditingController();
  List<TextEditingController> _steps = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Recipe'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _recipeName,
                decoration: InputDecoration(labelText: 'Recipe Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ingredients,
                decoration: InputDecoration(labelText: 'Ingredients'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the ingredients';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _cookingTime,
                decoration: InputDecoration(labelText: 'Cooking Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the cooking time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text('Steps', style: Theme.of(context).textTheme.titleMedium),
              ..._buildStepFields(),
              ElevatedButton(
                onPressed: _addStep,
                child: Text('Add Step'),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Save Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStepFields() {
    return _steps.asMap().entries.map((entry) {
      int idx = entry.key;
      TextEditingController controller = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Step ${idx + 1}'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter step ${idx + 1}';
            }
            return null;
          },
        ),
      );
    }).toList();
  }

  void _addStep() {
    setState(() {
      _steps.add(TextEditingController());
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Prepare the data
      Map<String, dynamic> recipeData = {
        'operation': 'addRecipe',
        'recipe_name': _recipeName.text,
        'cooking_time': _cookingTime.text,
        'ingredients': _ingredients.text,
        'user_id': widget.userId,
        'steps': _steps.map((controller) => controller.text).toList(),
      };

      // Send the data to the server
      final response = await http.post(
        Uri.parse('http://localhost/recipeapp/recipeshare/api/accfuntionality.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(recipeData),
      );

      print('Raw response: ${response.body}'); // Add this line

      if (response.statusCode == 200) {
        try {
          final result = json.decode(response.body);
          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Recipe added successfully')),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add recipe: ${result['message']}')),
            );
          }
        } catch (e) {
          print('Error decoding JSON: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error processing server response')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add recipe: Server error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _recipeName.dispose();
    _ingredients.dispose();
    _cookingTime.dispose();
    for (var controller in _steps) {
      controller.dispose();
    }
    super.dispose();
  }
}