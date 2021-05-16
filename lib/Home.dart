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
  
  List _listaCompras = [];

  TextEditingController _controllerCompra = TextEditingController();
  TextEditingController _controllerValor = TextEditingController();



  Future<File> _getFile() async{

    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/lista.json");

  }

  _salvarCompra(){
    String textoDigitado = _controllerCompra.text;
    Map<String, dynamic> compra = Map();
    compra["titulo"] = textoDigitado;
    compra["valor"] = "";
    compra["realizada"] = false;

    setState(() {
      _listaCompras.add(compra);
    });
    _salvarArquivo();
    _controllerCompra.text= "";
    _controllerValor.text= "";

  }

  _salvarArquivo() async{

    var arquivo = await _getFile();


    String lista = json.encode(_listaCompras);
    arquivo.writeAsString(lista);

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
        _listaCompras = json.decode(dados);
      });
    });

  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("Lista de compras"),
      ),
      body: Column(
        children: <Widget>[
           Expanded(
             child: ListView.builder(
               itemCount: _listaCompras.length,
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
                        _listaCompras.removeAt(index);
                      });
                      _salvarArquivo();
                   },
                   key: Key(_listaCompras[index]['titulo']),
                   child: CheckboxListTile(
                     title: Text(_listaCompras[index]['titulo']),
                     subtitle: Text(_listaCompras[index]['valor']),
                     value: _listaCompras[index]['realizada'],
                     onChanged: (valorAlterado){
                       if(valorAlterado == true){
                         showDialog(
                             context: context,
                             builder: (context){
                               return AlertDialog(
                                 title: Text("Preço do Produto"),
                                 content: TextField(
                                   keyboardType: TextInputType.number,
                                   controller: _controllerValor,
                                   decoration: InputDecoration(
                                       labelText: "Ex: 5.55"
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
                                       setState(() {

                                         String textoValor = _controllerValor.text;
                                         _listaCompras[index]['valor'] = textoValor;
                                         _salvarArquivo();

                                       });
                                       Navigator.pop(context);
                                     },
                                   )
                                 ],
                               );
                             }
                         );
                       }else{
                         // tirar o valor da tela
                         _listaCompras[index]['valor'] = "";
                       }
                       setState(() {
                         _listaCompras[index]['realizada'] = valorAlterado;
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 6,
        child: Icon(Icons.add),
          onPressed: (){
            showDialog(
                context: context,
              builder: (context){
                  return AlertDialog(
                    title: Text("Adicionar produto"),
                    content: TextField(
                      controller: _controllerCompra,
                      decoration: InputDecoration(
                         labelText: "Digite o produto"
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
