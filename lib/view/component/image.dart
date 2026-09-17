import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class ProfileImagePicker extends StatefulWidget {
  final String? label;
  final Function(File file)? onImagePicked;
  const ProfileImagePicker({
    super.key,
    this.label,
    this.onImagePicked,
  });
  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}
class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? image;
  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageGallery =
        await picker.pickImage(source: ImageSource.gallery);
    if (imageGallery != null) {
      final file = File(imageGallery.path);
      setState(() {
        image = file;
      });
      if (widget.onImagePicked != null) {
        widget.onImagePicked!(file);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: getImage,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(255, 249, 249, 251),
          image: image != null
              ? DecorationImage(
                  image: FileImage(image!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt,
                      size: 40, color: Colors.grey[400]),
                  if (widget.label != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        widget.label!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              )
            : null,
      ),
    );
  }
}
