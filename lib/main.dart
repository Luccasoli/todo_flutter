import 'dart:convert';

import 'package:flutter/material.dart';
import 'models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final List<Item> items = new List<Item>();

  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = TextEditingController();

  void add() {
    if (newTaskController.text.isNotEmpty) {
      setState(() {
        widget.items.add(Item(
          title: newTaskController.text,
          isDone: false,
        ));
      });
      newTaskController.clear();
    }
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
    });
  }

  Future load() async {
    var pref = await SharedPreferences.getInstance();
    var data = pref.getString('data');
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
