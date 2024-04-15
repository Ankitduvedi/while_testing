// CategoryInput.dart

import 'dart:developer';

import 'package:com.while.while_app/feature/counsellor/models/category.dart';
import 'package:com.while.while_app/feature/counsellor/models/categories_info.dart';
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
              log(newValue.toString());
              selectedCategory = newValue;
            });
          },
          items:
              widget.categories.map<DropdownMenuItem<String>>((Category value) {
            return DropdownMenuItem<String>(
              value: value.title,
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
        ElevatedButton(
          onPressed: submitData,
          child: const Text("Submit"),
        )
      ],
    );
  }

  void submitData() {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a category")));
      return;
    }
    CategoryInfo categoryInfo = CategoryInfo(
      category: selectedCategory!,
      yearsOfExperience: int.tryParse(_yearsOfExperienceController.text) ?? 0,
      organisation: _organisationController.text,
      customersCatered: int.tryParse(_customersCateredController.text) ?? 0,
    );
    widget.onCategoryAdded(categoryInfo);
  }
}
