import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  List _listatarefas = [];

  TextEditingController _controllerCompra = TextEditingController();

  Future<File> _getFile() async{

    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/lista.json");

  }

  _salvarCompra(){
    String textoDigitado = _controllerCompra.text;
    Map<String, dynamic> compra = Map();
    compra["titulo"] = textoDigitado;
    compra["realizada"] = false;

    setState(() {
      _listatarefas.add(compra);
    });
    _salvarArquivo();
    _controllerCompra.text= "";

  }

  _salvarArquivo() async{

    var arquivo = await _getFile();


    String lista = json.encode(_listatarefas);
    arquivo.writeAsString(lista);
    //print("Caminho: " + diretorio.path);

  }

  _lerArquivo() async{

    try{

      final arquivo = await _getFile();
      return arquivo.readAsString();

    }catch(e){
      return null;
    }


  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados){
      setState(() {
        _listatarefas = json.decode(dados);
      });
    });

  }
  
  @override
  Widget build(BuildContext context) {
    //_salvarArquivo();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("Lista de tarefas"),
      ),
      body: Column(
        children: <Widget>[
           Expanded(
             child: ListView.builder(
               itemCount: _listatarefas.length,
                 itemBuilder: (context, index){


                 return Dismissible(
                   background: Container(
                     color: Colors.purple,
                     padding: EdgeInsets.all(16),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: <Widget>[
                         Icon(
                         Icons.delete,
                       color: Colors.white,
                     )
                       ],
                     ),
                   ),
                   direction: DismissDirection.endToStart,
                   onDismissed: (direction){
                      setState(() {
                        _listatarefas.removeAt(index);
                      });
                      _salvarArquivo();
                   },
                   key: Key(_listatarefas[index]['titulo']),
                   child: CheckboxListTile(
                     title: Text(_listatarefas[index]['titulo']),
                     value: _listatarefas[index]['realizada'],
                     onChanged: (valorAlterado){
                       setState(() {
                         _listatarefas[index]['realizada'] = valorAlterado;
                       });
                       _salvarArquivo();
                     },
                   ),
                 );


                /* return ListTile(
                   title: Text(_listatarefas[index]['titulo']),
                 );*/
                 }
             ),
           )
        ],
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
      //floatingActionButton: FloatingActionButton.extended(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 6,
       //icon: Icon(Icons.add_shopping_cart),
       //label: Text("Adicionar"),
       /*shape: BeveledRectangleBorder(
         borderRadius: BorderRadius.circular(20)
       ),*/
       // mini: true,
        child: Icon(Icons.add),
          onPressed: (){
            showDialog(
                context: context,
              builder: (context){
                  return AlertDialog(
                    title: Text("Adicionar Tarefa"),
                    content: TextField(
                      controller: _controllerCompra,
                      decoration: InputDecoration(
                         labelText: "Digite sua tarefa"
                      ),
                      onChanged: (text){

                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Cancelar"),
                        onPressed: ()=> Navigator.pop(context),
                      ),
                      FlatButton(
                        child: Text("Salvar"),
                        onPressed: (){
                          _salvarCompra();
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
              }
            );
          }
      ),
     /* bottomNavigationBar: BottomAppBar(
        //shape: CircularNotchedRectangle(),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.add),
            )
          ],
        ),
      ),*/
    );
  }
}