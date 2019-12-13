import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/todo.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  StreamController<List<Todo>> streamController =
      StreamController(); // 데이터를 받아들이는 스트림.
  Future<List<Todo>> getTodo() async {
    String url =
        "https://jsonplaceholder.typicode.com/todos"; // http request를 보낼 url
    http.Client _client = http.Client(); // http 클라이언트 사용
    List<Todo> list = [];
    await _client
        .get(url) // http 리퀘스트를 보낸다.
        .then((res) => res.body) // http 응답을 받으면, 그 중에서 body만 가져옴
        .then(json.decode) // json을 형태로 파싱하고
        .then((todos) => todos.forEach((todo) =>
                list.add(Todo.fromJson(todo))) // json을 클래스 형태로 바꿔서 리스트에 더해준다.
            );
    return list;
  }

  Widget _buildListTile(AsyncSnapshot snapshot, int index) {
    // 리스트 뷰에 들어갈 타일(작은 리스트뷰)를 만든다.
    var id = snapshot.data[index].id;
    var title = snapshot.data[index].title;
    bool completed = snapshot.data[index].completed;
    return ListTile(
      leading: Text("$id"),
      title: Text("$title"),
      subtitle: Text(
        "completed ",
        style: TextStyle(color: completed ? Colors.lightBlue : Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Todo List")),
        body: Column(
          children: <Widget>[
            Center(
              child: RaisedButton(
                child: Text("Load"),
                color: Colors.lightBlueAccent,
                textColor: Colors.white,
                onPressed: () {
                  // 버튼을 누르면 서버에서 데이터를 가져옴

                  getTodo().then((todos) {
                    streamController.add(todos); // 스트림 컨트롤러에 데이터가 추가된다.
                  });
                },
              ),
            ),
            Flexible(
              child: StreamBuilder(
                stream: streamController.stream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    // 스냅샷에 데이터가 없으면 그냥 텍스트를 그린다.
                    return Text("no data");
                  } else {
                    // 스냅샷에 데이터가 있으면, 즉 스트림에 데이터가 추가되면 리스트뷰를 그린다.
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      // 스냅샷의 데이터 크기만큼 뷰 크기를 정한다.
                      itemBuilder: (context, index) =>
                          _buildListTile(snapshot, index),
                    );
                  }
                },
              ),
            ),
          ],
        ));
  }
}
