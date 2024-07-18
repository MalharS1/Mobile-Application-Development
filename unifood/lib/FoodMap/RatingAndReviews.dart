class RatingData {
  // Class for charts and table
  final int rating;
  final int frequency;

  RatingData(this.rating, this.frequency);
}
class Review {
  // Class for reviews
  int rating;
  String comment;
  String title;
  String address;

  Review({required this.rating, required this.comment, required this.title, required this.address});
  // Maps the reviews so they can be stored in firebase
  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'comment': comment,
      'title': title,
      'address': address,
    };
  }
}