import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import '../models/grocery_item.dart';
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems=[];
  var _isLoading=true;
  String? _error;
  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }
  void _loadItems() async{

    final url=Uri.https(
        'flutter-prep-9e413-default-rtdb.firebaseio.com',
        'shopping-list.json'
    );
    final response =await http.get(url);
    if(response.statusCode>=400){
      setState(() {
        _error="failed to Fetch Data Try Again";
      });
    }
    if(response.body==null) {
      setState(() {
        _isLoading=false;
      });


    }
    final Map<String,dynamic>listData=json.decode(response.body);
    final List<GroceryItem> loadedItems=[];

      for(final item in listData.entries){
        final category=
            categories.entries.firstWhere(
                    (catItem)=>catItem.value.name==item.value['category']).value;
        loadedItems.add(GroceryItem(
            id: item.key,
            name:  item.value['name'],
            quantity: item.value['quantity'],
            category: category));

      }
    setState(() {
      _groceryItems=loadedItems;
      _isLoading=false;
    });
  }


  void _addItem() async{
    final newItem=await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
        builder: (ctx)=>const NewItem(),
    ));
  if(newItem==null){
    return;
  }
  setState(() {
    _groceryItems.add(newItem);
  });



  }
  void _removeItem(GroceryItem item) async {
    setState(() {
      _groceryItems.remove(item);
    });
    final url=Uri.https(
        'flutter-prep-9e413-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json'
    );
    final response=await http.delete(url);

    final index=_groceryItems.indexOf(item);
    if(response.statusCode>=400){
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
    /*ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
       duration: const Duration(seconds: 3),
       content: const Text("Item Deleted"),
       action: SnackBarAction(
         label: "Undo",
         onPressed: (){
           setState(() {
             _groceryItems.insert(index, item);
           });
         },
       ),
      )
    );*/
  }

  @override
  Widget build(BuildContext context) {

    Widget nothing=const Center(
      child: Text("No data Present! Enter Some Data"),
    );
    if(_isLoading){
      nothing= const Center(child: CircularProgressIndicator(),);
    }
    if(_groceryItems.isNotEmpty){
      nothing=ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx,index)=>
              Dismissible(
                key: ValueKey(_groceryItems[index].id),
                onDismissed:(direction){
                  _removeItem(_groceryItems[index]);
                },
                child: ListTile(
                  title:Text(_groceryItems[index].name) ,
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _groceryItems[index].category.color,
                  ),
                  trailing: Text(
                      _groceryItems[index].quantity.toString()
                  ),

                ),
              ),


      );
    }

    if(_error!=null){
      nothing= Center(child: Text('$_error'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add))
        ],
      ),
      body: nothing,
    );
  }
}
