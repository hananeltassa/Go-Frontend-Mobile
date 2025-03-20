final class ApiRoutes {
  static const String login = "/login";
  static const String register = "/register";
  static const String categories = "/categories";
  static const String updateProfile = "/profile/edit";
  static const String destinations = "/destinations";

  static String categoryDestinations(String category) {
    return "/destinations/category/$category";
  }

  static const String rateDestination = "/activity/rate";
}
