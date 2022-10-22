class ShopItem {
  int id;
  String title;
  int done;

  ShopItem({required this.id ,required this.title, required this.done});

  toJSONEncodable() {
    Map<String, dynamic> map = {
      'id': id,
      'title': title,
      'done': done,
    };
    return map;
  }

  @override
  toString() {
    return ('$id -  $title - $done\n');
  }
}


class ShopList {
  List<ShopItem> items = [];

  toJSONEncodable() {
    return items.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}