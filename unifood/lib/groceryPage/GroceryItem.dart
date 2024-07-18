class GroceryItem
{
  int? id;
  String? name;
  int? quantity;

  GroceryItem({this.id, this.name, this.quantity});

  GroceryItem.fromMap(Map map)
  {
    id = map['id'];
    name = map['name'];
    quantity = map['quantity'];
  }

  Map<String, dynamic>toMap()
  {
    return {
      'id' : id,
      'name' : name,
      'quantity' : quantity
    };
  }

  @override
  String toString()
  {
    return "$name";
  }
}