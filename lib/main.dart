import 'dart:convert';

import 'package:flutter/material.dart';
import 'models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

const STORAGE_KEY = '@data';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  List<Item> items = new List<Item>();

  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = TextEditingController();

  _HomePageState() {
    this.load();
  }

  void add() {
    if (newTaskController.text.isNotEmpty) {
      setState(() {
        widget.items.add(Item(
          title: newTaskController.text,
          isDone: false,
        ));
      });
      newTaskController.clear();
      this.save();
    }
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      this.save();
    });
  }

  Future load() async {
    var pref = await SharedPreferences.getInstance();
    var data = pref.getString(STORAGE_KEY);

    if (data != null) {
      List<dynamic> json = jsonDecode(data);
      List<Item> result = json.map((item) => Item.fromJson(item)).toList();
      print(result);
      setState(() {
        widget.items = result;
      });
    }
  }

  void save() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setString(STORAGE_KEY, jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
            onEditingComplete: this.add,
            controller: newTaskController,
            decoration: InputDecoration(
                labelText: 'Criar Tarefa',
                labelStyle: TextStyle(color: Colors.white)),
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];
          return Dismissible(
            onDismissed: (DismissDirection direction) => this.remove(index),
            background: Container(
              padding: EdgeInsets.all(10),
              color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'Excluir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            key: Key(item.title),
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.isDone,
              onChanged: (bool value) {
                setState(() {
                  item.isDone = value;
                  this.save();
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: this.add,
      ),
    );
  }
}
