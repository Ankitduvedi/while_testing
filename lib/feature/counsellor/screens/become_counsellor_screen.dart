// BecomeCounsellor.dart
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
        // Handle the added category info here
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
          // Wrap Column in a ConstrainedBox to give it a maximum height
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
                  // Implement saving logic here
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
