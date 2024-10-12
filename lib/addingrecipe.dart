import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

import 'package:recipeshare/theme.dart';

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
  final _description = TextEditingController();
  List<TextEditingController> _steps = [TextEditingController()];
  File? _imageFile;
  Uint8List? _webImage;
  final picker = ImagePicker();

  Map<String, bool> _mealTypes = {
    'breakfast': false,
    'brunch': false,
    'elevenses': false,
    'lunch': false,
    'tea': false,
    'supper': false,
  };

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _webImage = null; // Reset web image
          pickedFile.readAsBytes().then((value) {
            setState(() {
              _webImage = value;
            });
          });
        } else {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Recipe', style: AppTheme.logoStyle.copyWith(fontSize: 24)),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).primaryColor, Color(0xFFF7FFF7)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(),
                SizedBox(height: 16),
                _buildTextField(_recipeName, 'Recipe Name', Icons.restaurant_menu),
                SizedBox(height: 16),
                _buildTextField(_ingredients, 'Ingredients', Icons.list, maxLines: 3),
                SizedBox(height: 16),
                _buildTextField(_cookingTime, 'Cooking Time', Icons.timer),
                SizedBox(height: 16),
                _buildTextField(_description, 'Description', Icons.description, maxLines: 3),
                SizedBox(height: 24),
                _buildSectionTitle('Meal Type'),
                ..._buildMealTypeCheckboxes(),
                SizedBox(height: 24),
                _buildSectionTitle('Steps'),
                ..._buildStepFields(),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addStep,
                    icon: Icon(Icons.add),
                    label: Text('Add Step'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Save Recipe'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          child: _imageFile != null || _webImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: kIsWeb
                      ? Image.memory(
                          _webImage!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _imageFile!,
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        ),
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  List<Widget> _buildMealTypeCheckboxes() {
    return _mealTypes.keys.map((String key) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        margin: EdgeInsets.only(bottom: 8),
        child: CheckboxListTile(
          title: Text(key.capitalize()),
          value: _mealTypes[key],
          onChanged: (bool? value) {
            setState(() {
              _mealTypes[key] = value!;
            });
          },
          activeColor: Theme.of(context).primaryColor,
          checkColor: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildStepFields() {
    return _steps.asMap().entries.map((entry) {
      int idx = entry.key;
      TextEditingController controller = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _buildTextField(controller, 'Step ${idx + 1}', Icons.format_list_numbered),
      );
    }).toList();
  }

  void _addStep() {
    setState(() {
      _steps.add(TextEditingController());
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null && _webImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image for the recipe')),
        );
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        // Uri.parse('http://192.168.155.63/recipeapp/recipeshare/api/accfuntionality.php'),
        Uri.parse('http://10.0.0.57/recipeapp/recipeshare/api/accfuntionality.php'),
        // Uri.parse('http://localhost/recipeapp/recipeshare/api/accfuntionality.php'),
      );

      request.fields['operation'] = 'addRecipe';
      request.fields['recipe_name'] = _recipeName.text;
      request.fields['cooking_time'] = _cookingTime.text;
      request.fields['ingredients'] = _ingredients.text;
      request.fields['description'] = _description.text;
      request.fields['user_id'] = widget.userId.toString();
      request.fields['mealtype'] = jsonEncode(_mealTypes.entries.where((entry) => entry.value).map((entry) => entry.key).toList());
      request.fields['steps'] = jsonEncode(_steps.map((controller) => controller.text).toList());

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'recipe_image',
          _webImage!,
          filename: 'recipe_image.jpg',
        ));
      } else {
        var file = await http.MultipartFile.fromPath('recipe_image', _imageFile!.path);
        request.files.add(file);
      }

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var result = json.decode(String.fromCharCodes(responseData));

      if (response.statusCode == 200 && result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe added successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add recipe: ${result['message']}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _recipeName.dispose();
    _ingredients.dispose();
    _cookingTime.dispose();
    _description.dispose();
    for (var controller in _steps) {
      controller.dispose();
    }
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}