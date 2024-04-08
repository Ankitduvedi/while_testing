// CategoryInput.dart
import 'package:com.while.while_app/feature/counsellor/models/category.dart';
import 'package:com.while.while_app/feature/counsellor/screens/categories_info.dart';
import 'package:flutter/material.dart';
// Import the CategoryInfo model

class CategoryInput extends StatefulWidget {
  final List<Category> categories;
  final Function(CategoryInfo) onCategoryAdded;

  const CategoryInput({
    Key? key,
    required this.categories,
    required this.onCategoryAdded,
  }) : super(key: key);

  @override
  CategoryInputState createState() => CategoryInputState();
}

class CategoryInputState extends State<CategoryInput> {
  String? selectedCategory;
  final TextEditingController _yearsOfExperienceController =
      TextEditingController();
  final TextEditingController _organisationController = TextEditingController();
  final TextEditingController _customersCateredController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedCategory,
          hint: const Text('Select Category'),
          onChanged: (newValue) {
            setState(() {
              selectedCategory = newValue;
            });
          },
          items:
              widget.categories.map<DropdownMenuItem<String>>((Category value) {
            return DropdownMenuItem<String>(
              value: value.id,
              child: Text(value.title),
            );
          }).toList(),
        ),
        TextField(
          controller: _yearsOfExperienceController,
          decoration: const InputDecoration(labelText: 'Years of Experience'),
        ),
        TextField(
          controller: _organisationController,
          decoration: const InputDecoration(labelText: 'Organisation Name'),
        ),
        TextField(
          controller: _customersCateredController,
          decoration: const InputDecoration(labelText: 'Customers Catered'),
        ),
        // Consider adding a submit button here to capture the input data
      ],
    );
  }

  // Add any additional logic or methods needed to handle the input data
}
