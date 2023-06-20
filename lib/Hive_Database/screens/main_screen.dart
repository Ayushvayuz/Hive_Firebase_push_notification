import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sqflite/sqflite.dart';
class MainSccreen extends StatefulWidget {
  const MainSccreen({Key? key}) : super(key: key);

  @override
  State<MainSccreen> createState() => _MainSccreenState();
}

class _MainSccreenState extends State<MainSccreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  List<Map<String , dynamic>> _item = [];
  final _todoBox = Hive.box('todo_box');
  void _refreshItem(){
    final data = _todoBox.keys.map((key) {
      final item = _todoBox.get(key);
      return {'key':key , 'name':item['name'] , 'quantity':item['quantity']};
    }).toList();
    setState(() {
      _item = data.reversed.toList();
      print(_item.length);
    });
  }
  Future<void> _createItem(Map<String , dynamic> newItem)async {
    await _todoBox.add(newItem);
    _refreshItem();
  }
  Future<void> _deleteItem(int itemKey)async {
    await _todoBox.delete(itemKey);
    _refreshItem();
  }

  Future<void> _updateItem(int itemKey , Map<String , dynamic> item)async {
    await _todoBox.put(itemKey , item);
    _refreshItem();
  }
  void _showForm(BuildContext ctx , int? itemKey){
    if(itemKey!=null){
      final existingItem =
      _item.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem['name'];
      _quantityController.text = existingItem['quantity'];
    }
    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_)=>Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,left: 15,right: 15
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: 'Name'),
              ),
              SizedBox(height: 15,),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(hintText: 'Describe'),
              ),
              SizedBox(height: 15,),
              ElevatedButton(
                  onPressed: ()async{
                    if(itemKey==null){
                      _createItem({
                      'name' :_nameController.text,
                      'quantity':_quantityController.text
                    });}
                    if(itemKey!=null){
                      _updateItem(itemKey, {
                        'name':_nameController.text.trim(),
                        'quantity':_quantityController.text.trim()
                      });
                    }
                    _nameController.text='';
                    _quantityController.text='';
                    Navigator.of(context).pop();
                  },
                  child: Text(itemKey==null?'Create new':'Update')
              ),
              SizedBox(height: 15,),
            ],
          ),
        ),
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItem();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          _showForm(context, null);
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(title:Text("Hive Database"),backgroundColor: Colors.blue,),
      body: ListView.builder(
        itemCount: _item.length,
          itemBuilder: ( _ ,index){
          final currentItem = _item[index];
          return Card(
            color: Colors.indigo.shade200,
            margin: EdgeInsets.all(15),
            elevation: 3,
            child: ListTile(
              title: Text(currentItem['name']),
              subtitle: Text(currentItem['quantity'].toString()),
              trailing: Row(mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: (){
                        _showForm(context, currentItem['key']);
                      }, icon: Icon(Icons.edit)),
                  IconButton(
                      onPressed: (){
                        _deleteItem(currentItem['key']);
                      }, icon: Icon(Icons.delete))
                ],
              ),
            ),
          );
          }
      ),
    );
  }
}
