import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/text_styles.dart';
import '../theme/colors.dart';

class DetailedDestinationScreen extends StatefulWidget {
  const DetailedDestinationScreen({super.key});

  @override
  State<DetailedDestinationScreen> createState() =>
      _DetailedDestinationScreenState();
}

class _DetailedDestinationScreenState extends State<DetailedDestinationScreen> {
  late String selectedImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final extra = GoRouterState.of(context).extra;
    final destination = (extra is Map<String, dynamic>) ? extra : {};

    List<String> images =
        destination["images"] ??
        [
          destination["imageUrl"] ??
              "https://images.pexels.com/photos/2990603/pexels-photo-2990603.jpeg?auto=compress&cs=tinysrgb&w=600",
        ];

    selectedImage = images.first;
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final destination = (extra is Map<String, dynamic>) ? extra : {};

    List<String> images =
        destination["images"] ??
        [
          destination["imageUrl"] ??
              "https://images.pexels.com/photos/2990603/pexels-photo-2990603.jpeg?auto=compress&cs=tinysrgb&w=600",
          "https://images.pexels.com/photos/2990603/pexels-photo-2990603.jpeg?auto=compress&cs=tinysrgb&w=600",
        ];

    return Scaffold(
      backgroundColor: AppColors.lightGreen,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          destination["name"] ?? "Destination",
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: 28,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "- ${destination["address"] ?? "Address"}",
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: 14,
                            color: AppColors.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.location_pin,
                    color: AppColors.darkGreen,
                    size: 30,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  selectedImage,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedImage == images[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImage = images[index];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                images[index],
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
                                  color: Colors.grey.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
