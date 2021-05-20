import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  double _valor;
  double _total = 0.00;
  String _textoTotal = "0,00";

  List _listaCompras = [];
  Map<String, dynamic> _ultimoProdutoRemovido = Map();

  TextEditingController _controllerCompra = TextEditingController();
  TextEditingController _controllerValor = TextEditingController();
  TextEditingController _controllerQuantidade = TextEditingController();

  Future<File> _getFile() async{

    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/lista.json");

  }

  _salvarCompra(){
    String textoDigitado = _controllerCompra.text;
    Map<String, dynamic> compra = Map();
    compra["titulo"] = textoDigitado;
    compra["valor"] = "0,00";
    compra["quantidade"]="0";
    compra["realizada"] = false;

    setState(() {
      _listaCompras.add(compra);
    });
    _salvarArquivo();
    _controllerCompra.text= "";

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

  _totalCompra(){
    double _v;
    double _quantidade;
    _total = 0.00;
    setState(() {
      print(_listaCompras);
      for(int i =0; i< _listaCompras.length; i++) {
        _v = double.tryParse(_listaCompras[i]["valor"].replaceAll(',', '.'));
        _quantidade = double.tryParse(_listaCompras[i]["quantidade"].replaceAll(',', '.'));
        _total += _v * _quantidade;
        print(_total);
      }
      _textoTotal = _total.toStringAsFixed(2).replaceAll('.',',');
    });
  }

  Widget criarItemLista(context, index){

    String _quantidadeProduto = "";


    if(_listaCompras[index]["quantidade"] != "0"){
      _quantidadeProduto = "${_listaCompras[index]["quantidade"]}x  ${_listaCompras[index]['titulo']}";
    }else{
      _quantidadeProduto = "${_listaCompras[index]['titulo']}";
    }

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

        _ultimoProdutoRemovido = _listaCompras[index];

        _listaCompras.removeAt(index);
        _salvarArquivo();
        _totalCompra();

        final snackbar = SnackBar(
          content: Text("Produto removido!"),
          action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  _listaCompras.insert(index, _ultimoProdutoRemovido);
                });
                _salvarArquivo();
                _totalCompra();
              }
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      child: CheckboxListTile(
        title: Text(
            _quantidadeProduto,
          style: TextStyle(
            fontSize: 25
          ),
        ),
        subtitle: Text("R\$ ${_listaCompras[index]['valor']}"),
        value: _listaCompras[index]['realizada'],
        onChanged: (valorAlterado){
          if(valorAlterado == true){
            showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    title: Text("Preço do Produto"),
                    content: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          TextField(
                            keyboardType: TextInputType.number,
                            controller: _controllerValor,
                            decoration: InputDecoration(
                                labelText: "Valor unitário"
                            ),
                            onChanged: (text){

                            },
                          ),
                          TextField(
                            keyboardType: TextInputType.number,
                            controller: _controllerQuantidade,
                            decoration: InputDecoration(
                                labelText: "Quantidade de produtos"
                            ),
                            onChanged: (text){

                            },
                          )
                        ],
                      ),
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
                            _valor = double.tryParse( _controllerValor.text.replaceAll(',', '.')) + 0.00;
                            _controllerValor.text = _valor.toStringAsFixed(2).replaceAll('.',',');


                            String textoValor = _controllerValor.text;
                            String textoQuantidade = _controllerQuantidade.text;
                            _listaCompras[index]['valor'] = textoValor;
                            _listaCompras[index]['quantidade'] = textoQuantidade;
                            _salvarArquivo();
                            _controllerValor.text = "";
                            _controllerQuantidade.text = "";
                          });
                          Navigator.pop(context);
                          _totalCompra();
                          print(_total);
                        },
                      )
                    ],
                  );
                }
            );
          }else{
            // tirar o valor da tela
            _listaCompras[index]['quantidade'] = "0";
            _listaCompras[index]['valor'] = "0,00";
            _totalCompra();
          }
          setState(() {
            _listaCompras[index]['realizada'] = valorAlterado;
          });
          _salvarArquivo();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados){
      setState(() {
        _listaCompras = json.decode(dados);
        _totalCompra();
      });
    });
    //_totalCompra();
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
                 itemBuilder: criarItemLista
             ),
           )
        ],
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endDocked,
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

      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                  Icons.shopping_cart,
                size: 50,
              ),
            ),
            Text(
                "R\$ $_textoTotal",
              style: TextStyle(
                fontSize: 40,
              ),
            )
          ],
        ),
      ),
    );
  }
}
