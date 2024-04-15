// BecomeCounsellor.dart
import 'dart:developer';

import 'package:com.while.while_app/feature/counsellor/controller/counseller_contoller.dart';
import 'package:com.while.while_app/feature/counsellor/models/categories_info.dart';
import 'package:com.while.while_app/feature/counsellor/widgets/categories_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dummy_data.dart';
// Import the CategoryInput widget

class BecomeCounsellor extends ConsumerStatefulWidget {
  const BecomeCounsellor({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BecomeCounsellorState();
}

class _BecomeCounsellorState extends ConsumerState<BecomeCounsellor> {
  List<Widget> categoryInputs = [];
  List<CategoryInfo> allCategoriesInfo = []; // Store all category inputs

  @override
  void initState() {
    super.initState();
    addNewCategoryInput();
  }

  void addNewCategoryInput() {
    categoryInputs.add(CategoryInput(
      key: UniqueKey(),
      categories: availableCategories,
      onCategoryAdded: (categoryInfo) {
        allCategoriesInfo.add(
            categoryInfo); // Add to the list whenever a new category is added
        // print(categoryInfo.toString());  // Optional: print each addition immediately
      },
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...categoryInputs,
              ElevatedButton(
                onPressed: addNewCategoryInput,
                child: const Text('Add Another Category'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Print all collected category info when 'Save All' is pressed
                  log("requesting");
                  ref
                      .read(counsellorContollerProvider.notifier)
                      .submitCounsellerRequest(allCategoriesInfo);
                },
                child: const Text('Save All'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
