import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:convert';

const String url = "https://api.hgbrasil.com/finance?key=e5d7009f";


Future<Map> request() async{
  http.Response response = await http.get(Uri.parse(url));
  var req = response.body;
  var map = json.decode((req.toString()));
  return map;
}


void main() async {

  var data = await request();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(
        hintColor: Colors.greenAccent,
        primaryColor: Colors.greenAccent,
      )
    );

  }

}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  late double dollar;
  late double euro;


  void _realChanged(String text){
    if (text.isEmpty){
      dollarController.text = "";
      euroController.text = "";
    }else {
      double real = double.parse(text);
      dollarController.text = (real / dollar).toStringAsFixed(2);
      euroController.text = (real / euro).toStringAsFixed(2);
    }

  }

  void _dollarChanged(String text){

    if (text.isEmpty){
      realController.text = "";
      euroController.text = "";
    }else {
      double dollar = double.parse(text);
      realController.text = (dollar * this.dollar).toStringAsFixed(2);
      euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
    }

  }

  void _euroChanged(String text){

    if (text.isEmpty){
      realController.text = "";
      euroController.text = "";
    }else {
      double euro = double.parse(text);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dollarController.text = (euro * this.euro / dollar).toStringAsFixed(2);
    }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text(
          "Coin Convert",
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Map>(
        future: request(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text("Loading Data...",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 25
                  ),
                  textAlign: TextAlign.center,
                ),

              );

            default:
              if (snapshot.hasError){
                return const Center(
                  child: Text("Error Loading Data :(",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 25,
                    ),

                    textAlign: TextAlign.center,
                  ),
                );
              }
              else{
                dollar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 110,
                        color: Colors.greenAccent,

                      ),

                      buildTextField("Reais", "R\$", realController, _realChanged),
                      const Divider(),
                      buildTextField("Dollars", "\$", dollarController, _dollarChanged),
                      const Divider(),
                      buildTextField("Euros", "Є", euroController, _euroChanged)

                    ],
                  ),

                );
              }

          }
        },
      ),
    );
  }
}

// "R\$" - Reais
// "Є" - Euros
//"\$" - Dollars

Widget buildTextField(String label, String prefix, TextEditingController controller,
    Function onChange){

  return TextField(
      controller: controller,
      decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
      color: Colors.greenAccent,
      fontSize: 20,
  ),
  border: const OutlineInputBorder(),
  prefixText: "$prefix ",
  prefixStyle: const TextStyle(
  color: Colors.greenAccent,
  )
  ),
    onChanged: (String s){
        onChange(s);
    },
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );

}





