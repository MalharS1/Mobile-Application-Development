// Class for each Pantry Item
class PantryItem {
  String? name;
  int? count;
  String? userId;
  DateTime? selectedDate;

  PantryItem({this.name, this.count, this.userId, this.selectedDate});

  PantryItem.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    count = map['count'];
    userId = map['userid'];
    selectedDate =
        DateTime.tryParse(map['selectedDate']); // Parse selectedDate from map
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'count': count,
      'userId': userId,
      'selectedDate': selectedDate?.toIso8601String()       // Converts Date/Time object into a string
    };
  }

  @override
  String toString() {
    return 'PantryItem{name: $name, count: $count, userId: $userId, selectedDate: $selectedDate}';
  }
}
