import 'package:flutter/material.dart';
import 'package:go_frontend_mobile/providers/auth_provider.dart';
import 'package:go_frontend_mobile/providers/saved_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/destination_provider.dart';
import '../theme/text_styles.dart';
import '../theme/colors.dart';
import '../widgets/destination_card.dart';

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  DestinationsScreenState createState() => DestinationsScreenState();
}

class DestinationsScreenState extends State<DestinationsScreen> {
  String? category;
  bool hasFetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDestinations();

      final savedProvider = Provider.of<SavedProvider>(context, listen: false);
      savedProvider.fetchSavedDestinations();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!hasFetched) {
      hasFetched = true;
    }
  }

  void _fetchDestinations() {
    final extra = GoRouterState.of(context).extra;
    final selectedCategory =
        (extra is Map<String, dynamic>) ? extra["category"] as String? : null;

    final destinationProvider = Provider.of<DestinationProvider>(
      context,
      listen: false,
    );

    if (selectedCategory != null) {
      category = selectedCategory;
      destinationProvider.fetchDestinationsByCategory(category!);
    } else {
      destinationProvider.fetchRecommendedDestinations();
      destinationProvider.fetchAllDestinations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinationProvider = Provider.of<DestinationProvider>(context);
    final destinations = destinationProvider.destinations;
    final isLoading = destinationProvider.isLoading;
    final bool showCategory = category?.isNotEmpty ?? false;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isGuest = authProvider.isGuest;

    return Scaffold(
      backgroundColor: AppColors.lightGreen,
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : destinations.isEmpty
              ? const Center(child: Text("No destinations found"))
              : CustomScrollView(
                slivers: [
                  if (showCategory || !isGuest)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15,
                          left: 15,
                          bottom: 10,
                        ),
                        child: Text(
                          showCategory ? category! : "Recommended",
                          style: AppTextStyles.bodyLarge.copyWith(fontSize: 24),
                        ),
                      ),
                    ),

                  if (!showCategory) ...[
                    if (!isGuest) ...[
                      destinationProvider.isLoadingRecommendations
                          ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                          : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final recommended =
                                      destinationProvider
                                          .recommendedDestinations;
                                  if (index >= recommended.length) return null;

                                  final destination = recommended[index];

                                  return DestinationCard(
                                    imageUrl:
                                        destination["main_img"] ??
                                        "https://cdn.spruceindustries.com/images/no_image_available.png",
                                    name:
                                        destination["business_name"] ??
                                        "Unknown",
                                    description:
                                        destination["description"] ??
                                        "No description available",
                                    rating:
                                        (destination["rating"] as num?)
                                            ?.toDouble() ??
                                        0.0,
                                    isGuest: isGuest,
                                    district: destination["district"],
                                    userid: destination["user_id"],
                                  );
                                },
                                childCount:
                                    destinationProvider
                                        .recommendedDestinations
                                        .length,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 0.95,
                                  ),
                            ),
                          ),
                    ],
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15,
                          left: 16,
                          bottom: 12,
                        ),
                        child: Text(
                          "All Destinations",
                          style: AppTextStyles.bodyLarge.copyWith(fontSize: 24),
                        ),
                      ),
                    ),
                  ],

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final destination = destinations[index];
                        return DestinationCard(
                          imageUrl:
                              destination["main_img"] ??
                              "https://cdn.spruceindustries.com/images/no_image_available.png",
                          name: destination["business_name"] ?? "Unknown",
                          description:
                              destination["description"] ??
                              "No description available",
                          rating:
                              (destination["rating"] as num?)?.toDouble() ??
                              0.0,

                          district: destination['district'],
                          userid: destination['user_id'],
                          isGuest: isGuest,
                        );
                      }, childCount: destinations.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.95,
                          ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              ),
    );
  }
}
