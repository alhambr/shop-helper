class ShopItem {
  String title;
  bool done;

  ShopItem({required this.title, required this.done});

  toJSONEncodable() {
    Map<String, dynamic> map = {};
    map['title'] = title;
    map['done'] = done;
    return map;
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