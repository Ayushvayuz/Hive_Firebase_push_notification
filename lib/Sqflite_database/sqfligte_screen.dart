import 'package:flutter/material.dart';
import 'package:sqflight_hive_database/Sqflite_database/services/db_helper.dart';
class SqfliteScreen extends StatefulWidget {
  const SqfliteScreen({Key? key}) : super(key: key);

  @override
  State<SqfliteScreen> createState() => _SqfliteScreenState();
}

class _SqfliteScreenState extends State<SqfliteScreen> {
  List<Map<String , dynamic>> _journals = [];
  bool isLoading = true;
  void _refreshjournals()async{
final data = await SqlHelper.getItems();
    setState(() {
      _journals = data;
      isLoading = false;
    });
  }
  
  Future<void> _deleteItem(int id) async{
    await SqlHelper.deleteItem(id);
    _refreshjournals();
  }
  
  Future<void> _addItems()async{
    await SqlHelper.createItem(_nameController.text, _discribeController.text);
    _refreshjournals();
  }
  Future<void> _updateItem(int id) async{
    await SqlHelper.updateItem(id, _nameController.text, _discribeController.text);
    _refreshjournals();
  }

  TextEditingController _nameController = TextEditingController();
  TextEditingController _discribeController = TextEditingController();
  void _showBottomSheet(int? id)async{
    if(id!=null){
      final existingJournals =
          _journals.firstWhere((element) => element['id']==id);
      _nameController.text = existingJournals['title'];
      _discribeController.text = existingJournals['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
      isScrollControlled: true,
      builder: (_)=>Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 15,
          right: 15,
          top: 15
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Name',
              ),
            ),
            SizedBox(height: 15,),
            TextField(
              controller: _discribeController,
              decoration: InputDecoration(
                hintText: 'Discribe',
              ),
            ),
            SizedBox(height: 15,),
            ElevatedButton(
                onPressed: ()async{
                  if(id==null){
                    await _addItems();
                  }
                  if(id!=null){
                    await _updateItem(id);
                  }
                  _nameController.text = '';
                  _discribeController.text = '';
                  Navigator.of(context).pop();
                },
                child: Text(id==null?"Create":"Update")
            )
          ],
        ),
      ),
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshjournals();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sqflite database"),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomSheet(null);
        },
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _journals.length,
          itemBuilder: (_ , index){
            return Card(
              elevation: 5,
              child: ListTile(
                title: Text(_journals[index]['title']),
                subtitle: Text(_journals[index]['description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: ()async{
                          _showBottomSheet(_journals[index]['id']);
                        },
                        icon: Icon(Icons.edit)
                    ),
                    IconButton(
                        onPressed: ()async{
                          _deleteItem(_journals[index]['id']);
                        },
                        icon: Icon(Icons.delete)
                    ),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}
