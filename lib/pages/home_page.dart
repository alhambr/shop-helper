import 'dart:collection';

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
  int id = 0;
  bool initialized = false;
  TextEditingController controller = new TextEditingController();
  late FocusNode focusNode;


  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  _toggleItem(ShopItem item) {
    setState(() {
      item.done = item.done==0?1:0;
      _saveToStorage();
    });
  }

  _addItem(String title) {
    if(title.isNotEmpty) {
      setState(() {
        id++;
        list.items.add(ShopItem(id: id, title: title, done: 0));
        _saveToStorage();
      });
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  _saveToStorage() {
    storage.setItem('list', list.toJSONEncodable());
    storage.setItem('id', id);
    _sortList();
  }

  _clearStorage() async {
    await storage.clear();
    setState(() {
      list.items = storage.getItem('list') ?? [];
      id = storage.getItem('id') ?? 0;
    });
  }

  _sortList() {
    list.items.sort((a,b) {
      int cmp = a.done.compareTo(b.done);
      if (cmp != 0) return cmp;
      return b.id.compareTo(a.id);
    });
  }


  @override
  Widget build(BuildContext context) {

    const Color colorBlue = Color.fromRGBO(32, 113, 249, 1);

    focusNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(249, 250, 255, 1),
        title: const Text(
          'Shop Helper', style: TextStyle(color: Colors.black54),),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: _clearStorage, icon: Icon(Icons.delete, color: Colors.redAccent, size: 35.0,))
        ],
      ),
      body: SafeArea(
        child: Container(
          color: const Color.fromRGBO(249, 250, 255, 1),
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
                id = storage.getItem('id') ?? 0;
                if(items != null) {
                  list.items = List<ShopItem>.from(
                      (items as List).map((item) => ShopItem(
                          id: item['id'],
                          title: item['title'],
                          done: item['done']
                      )),
                  ).toList();
                  _sortList();
                }
                initialized = true;
              }
              return Column(
                children: [
                  SizedBox(height: 20,),
                  ListTile(
                    title: TextField(

                      focusNode: focusNode,
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Что купить?',
                      ),
                      onSubmitted: (_) {
                        _addItem(controller.text);
                        controller.clear();
                      },
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          _addItem(controller.text);
                          controller.clear();
                        },
                        icon: Icon(Icons.save, color: colorBlue, size: 35.0,)
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text('Список покупок'.toUpperCase(), style: TextStyle(fontSize: 20, color: Color.fromRGBO(131, 143, 178,1)), textAlign: TextAlign.left,),
                  SizedBox(height: 20,),
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
                            child: GestureDetector(
                              // onTap: _toggleItem(item),
                              onTap: () {
                                _toggleItem(item);
                              },
                              child: Container(
                                height: 60,
                                margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: ListTile(
                                  title: item.done == 0?
                                    Text('${item.title}', style: TextStyle(fontSize: 22, color: Color.fromRGBO(60, 66, 85, 1)),)
                                        :
                                    Text('${item.title}', style: TextStyle(fontSize: 22, color: Color.fromRGBO(60, 66, 85, 1), decoration: TextDecoration.lineThrough)),
                                  leading: IconButton(
                                      onPressed: () {
                                        // _toggleItem(item);
                                        /*NOP*/
                                      },
                                      icon: item.done == 0?
                                        Icon(Icons.circle_outlined, color: Color.fromRGBO(39, 108, 212, 1), size: 35,)
                                          :
                                        Icon(Icons.check_circle_rounded, color: Color.fromRGBO(202, 215, 249, 1), size: 35,)
                                  ),
                                    // trailing: Icon(Icons.remove_circle),
                                ),

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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: focusNode.requestFocus,
        child: const Icon(Icons.add, color: Colors.white,),
        backgroundColor: colorBlue,
      ),
    );
  }
}
