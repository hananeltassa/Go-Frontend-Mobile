import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';

class ImageSelectorWidget extends StatelessWidget {
  final List<String> images;
  final String selectedImage;
  final Function(String) onImageSelected;
  final Function(String)? onImageAdded;
  final Function(String)? onImageRemoved;

  const ImageSelectorWidget({
    super.key,
    required this.images,
    required this.selectedImage,
    required this.onImageSelected,
    this.onImageAdded,
    this.onImageRemoved,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && onImageAdded != null) {
      onImageAdded!(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width * 0.7,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + (onImageAdded != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (onImageAdded != null && index == images.length) {
            return GestureDetector(
              onTap: () => _pickImage(context),
              child: Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withAlpha(77),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, color: AppColors.darkGreen),
              ),
            );
          }

          final image = images[index];
          final isSelected = selectedImage == image;

          return GestureDetector(
            onTap: () => onImageSelected(image),
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(100),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  if (onImageRemoved != null)
                    Positioned(
                      top: 3,
                      right: 3,
                      child: GestureDetector(
                        onTap: () => onImageRemoved!(image),
                        child: const CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 10,
                          child: Icon(
                            Icons.remove,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
