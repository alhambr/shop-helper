import 'package:flutter/material.dart';
import 'package:shop_helper/models/Shop.dart';
import 'package:localstorage/localstorage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ShopList list = ShopList();
  final LocalStorage storage = LocalStorage('shop_list');
  bool initialized = false;
  TextEditingController controller = new TextEditingController();


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _toggleItem(ShopItem item) {
    setState(() {
      item.done = !item.done;
      _saveToStorage();
    });
  }

  _addItem(String title) {
    setState(() {
      list.items.add(ShopItem(title: title, done: false));
      _saveToStorage();
    });
  }

  _saveToStorage() {
    storage.setItem('list', list.toJSONEncodable());
  }

  _clearStorage() async {
    await storage.clear();

    setState(() {
      list.items = storage.getItem('list') ?? [];
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(236, 238, 245, 1),
        title: const Text(
          'Shop Helper', style: TextStyle(color: Colors.black54),),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: _clearStorage, icon: Icon(Icons.delete, color: Colors.redAccent,))
        ],
      ),
      body: Container(
        color: const Color.fromRGBO(247, 248, 251, 1),
        constraints: const BoxConstraints.expand(),
        child: FutureBuilder(
          future: storage.ready,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(color: Colors.blue,),
              );
            }

            if(!initialized) {
              var items = storage.getItem('list');
              if(items != null) {
                list.items = List<ShopItem>.from(
                    (items as List).map((item) => ShopItem(
                        title: item['title'],
                        done: item['done'])
                    ),
                ).toList();
              }
              initialized = true;
            }
            return Column(
              children: [
                ListTile(
                  title: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Что надо купить?',
                      ),
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        _addItem(controller.text);
                        controller.clear();
                      },
                      icon: Icon(Icons.save, color: Colors.blue,)
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                      itemCount: list.items.length,
                      itemBuilder: (context, index) {
                        final item = list.items[index] as ShopItem;
                        return Dismissible(
                          background: Container(),
                          key: Key(item.title),
                          onDismissed: (direction) {
                            // Remove the item from the data source.
                            setState(() {
                              list.items.removeAt(index);
                              _saveToStorage();
                            });
                          },
                          // background: Container(color: Colors.red),
                          child: Card(
                            child: ListTile(
                              title: Text(item.title),
                              leading: IconButton(
                                  // onPressed: _toggleItem(item),
                                  onPressed: () {
                                    _toggleItem(item);
                                  },
                                  icon: !item.done?Icon(Icons.check_box_outline_blank):Icon(Icons.check_box)
                              ),
                              trailing: Icon(Icons.remove_circle),
                            ),
                          ),
                        );
                      }
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
