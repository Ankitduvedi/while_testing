
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const uuid = Uuid();

class AddCommunityScreen {
  XFile? image;
  void addCommunityDialog(BuildContext context) {
    String name = '';
    String type = '';
    String domain = '';
    String about = '';

    showDialog(
      useSafeArea: true,
      context: context,
      barrierDismissible:
          false, // Prevents closing the dialog by tapping outside of it
      builder: (_) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        scrollable: true,

        elevation: 5, // Increased elevation for a more pronounced shadow
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 24), // Adjusted for a bit more space

        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)), // Rounded corners

        //title with updated icon color
        title: const Row(
          children: [
            Icon(
              Icons.person_add,
              color: Colors.blueAccent, // Changed color to blue
              size: 28,
            ),
            SizedBox(width: 15),
            Expanded(
              // Added to ensure the title text fits within the available space
              child: Text(
                'Create Community',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.blue, // Changed color to match the theme
                ),
              ),
            ),
          ],
        ),

        //content with adjusted layout for a bigger dialog appearance
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Similar content with adjusted prefixIcon color to blue
            TextFormField(
              onChanged: (value) => name = value,
              decoration: InputDecoration(
                  hintText: 'Name',
                  prefixIcon: const Icon(Icons.group,
                      color: Colors
                          .blueAccent), // Icon changed to group and color to blue
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) => about = value,
              decoration: InputDecoration(
                  hintText: 'About',
                  prefixIcon: const Icon(Icons.info_outline,
                      color: Colors
                          .blueAccent), // Icon changed for semantic purposes and color to blue
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) => domain = value,
              decoration: InputDecoration(
                  hintText: 'Domain',
                  prefixIcon: const Icon(Icons.domain,
                      color: Colors
                          .blueAccent), // Icon changed to domain and color to blue
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) => type = value,
              decoration: InputDecoration(
                  hintText: 'Primary/Secondary',
                  prefixIcon: const Icon(Icons.swap_horiz,
                      color: Colors
                          .blueAccent), // Icon changed for semantic purposes and color to blue
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 20), // Added more spacing before buttons
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              // Button styles adjusted with new colors
              _buildButton(context, 'Camera', Icons.camera_alt_rounded,
                  ImageSource.camera),
              _buildButton(
                  context, 'Gallery', Icons.photo, ImageSource.gallery),
            ]),
          ],
        ),

        //actions layout adjusted for better spacing and appearance
        actions: [
          // Buttons layout adjusted for a unified look
          _actionButton(context, 'Discard', Colors.red, () {
            Navigator.pop(context);
          }),
          const SizedBox(width: 10),
          _actionButton(context, 'Create', Colors.green, () async {
            if (type.isNotEmpty && name.isNotEmpty && image != null) {
              // Create community logic
            }
          }),
        ],
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String label, IconData icon, ImageSource source) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: Colors.blueGrey[100], // Uniform color for buttons
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      icon:
          Icon(icon, color: Colors.blueAccent, size: 24), // Icon color to blue
      onPressed: () async {
        final ImagePicker picker = ImagePicker();
        image = await picker.pickImage(
            source:
                label == 'Gallery' ? ImageSource.gallery : ImageSource.camera,
            imageQuality: 70);
        // Pick an image
      },
    );
  }

  Widget _actionButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 120, // Unified width for action buttons
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Use dynamic color based on the button role
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onPressed: onPressed,
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
