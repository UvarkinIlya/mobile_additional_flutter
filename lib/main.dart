import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swagger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Swagger'),
    );
  }
}

class API {
  String url;
  String method;
  Body body;
  Response? response;

  API({required this.url, required this.method, required this.body, this.response});

  factory API.fromJson(Map<String, dynamic> json){
    return API(
      url: json['url'],
      method: json['method'],
      body: Body.fromJson(json['example_body']),
    );
  }
}

class Body{
  int? id;
  String? name;
  String? password;

  Body({required this.id, required this.name, required this.password});

  factory Body.fromJson(Map<String, dynamic> json){
    return Body(
      id: json['id'],
      name: json['name'],
      password: json['password'],
    );
  }

  @override
  String toString() {
    return '{\n"id": "$id",\n "name": "$name",\n "password": "$password"\n}\n';
   }

  String getParams(){
    return '?${id == null ? "" : "id=$id&"}${name == null ? "" : "id=$name&"}${password == null ? "" : "id=$password&"}';
  }

  Map <String, String> postParams(){
    var map = <String, String>{};
    if (id != null){
      map["id"] = id.toString();
    }

    if (name != null){
      map["name"] = name.toString();
    }

    if (password != null) {
      map["password"] = name.toString();
    }

    return map;
  }
}

class Response{
  int statusCode;
  String body;

  Response({required this.statusCode, required this.body});

  @override
  String toString() {
    return 'Response{statusCode: $statusCode, body: $body}';
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<API> api = [];
  List<TextEditingController> controllers = [];
  
  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/api.json').then((value) {
      List<dynamic> list = json.decode(value);
      api = List<API>.from(list.map((model) => API.fromJson(model))).toList();


      controllers = List.generate(api.length, (index){
        var controller = TextEditingController();
        controller.text = api[index].body.toString();
        return controller;
      });
      setState(() {});
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(
              leading: Text(api[index].method),
              title: Text(api[index].url),
              subtitle: Column(
                children: [
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: controllers[index],
                  ),
                  Text(api[index].response == null ? "" : api[index].response.toString()),
                  TextButton(
                    onPressed: (){
                      switch(api[index].method){
                        case "GET":{
                          http.get(Uri.parse(api[index].url+api[index].body.getParams())).then((response) {
                            api[index].response = Response(statusCode: response.statusCode, body: response.body);
                            setState(() {});
                          });
                        }
                        break;
                        case "POST":{
                          http.post(Uri.parse(api[index].url), body: api[index].body.postParams()).then((response) {
                            api[index].response = Response(statusCode: response.statusCode, body: response.body);
                            setState(() {});
                          });
                        }
                        break;
                        case "PUT":{
                          http.put(Uri.parse(api[index].url), body: api[index].body.postParams()).then((response) {
                            api[index].response = Response(statusCode: response.statusCode, body: response.body);
                            setState(() {});
                          });
                        }
                        break;
                      }
                    },
                    child: const Text("Send"),
                  )
                ],
              )
            );
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: api.length,
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
