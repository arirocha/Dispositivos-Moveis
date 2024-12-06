import 'dart:convert';

import 'package:receita/usuario.dart';
import 'package:receita/componentes/receitacard.dart';
import 'package:receita/estado.dart';
import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class Receitas extends StatefulWidget {
  const Receitas({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ReceitasState();
  }
}

const int tamanhoPagina = 4;

class _ReceitasState extends State<Receitas> {
  late dynamic _feedEstatico;
  List<dynamic> _receitas = [];

  int _proximaPagina = 1;
  bool _carregando = false;

  late TextEditingController _controladorFiltragem;
  String _filtro = "";

  @override
  void initState() {
    super.initState();

    ToastContext().init(context);

    _controladorFiltragem = TextEditingController();
    _lerFeedEstatico();
  }

  Future<void> _lerFeedEstatico() async {
    final String conteudoJson =
        await rootBundle.loadString("lib/recursos/json/feed.json");
    _feedEstatico = await json.decode(conteudoJson);

    _carregarReceitas();
  }

  void _carregarReceitas() {
    setState(() {
      _carregando = true;
    });

    var maisReceitas = [];
    if (_filtro.isNotEmpty) {
      _feedEstatico["receitas"].where((item) {
        String nome = item["recipe"]["name"];

        return nome.toLowerCase().contains(_filtro.toLowerCase());
      }).forEach((item) {
        maisReceitas.add(item);
      });
    } else {
      maisReceitas = _receitas;

      final totalReceitasParaCarregar = _proximaPagina * tamanhoPagina;
      if (_feedEstatico["receitas"].length >= totalReceitasParaCarregar) {
        maisReceitas =
            _feedEstatico["receitas"].sublist(0, totalReceitasParaCarregar);
      }
    }

    setState(() {
      _receitas = maisReceitas;
      _proximaPagina = _proximaPagina + 1;

      _carregando = false;
    });
  }

  Future<void> _atualizarReceitas() async {
    _receitas = [];
    _proximaPagina = 1;

    _carregarReceitas();
  }

  @override
  Widget build(BuildContext context) {
    bool usuarioLogado = estadoApp.usuario != null;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 60, right: 20),
                    child: TextField(
                      controller: _controladorFiltragem,
                      onSubmitted: (descricao) {
                        _filtro = descricao;

                        _atualizarReceitas();
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search)),
                    ))),
            usuarioLogado
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        estadoApp.onLogout();
                      });

                      Toast.show("Você não está mais conectado",
                          duration: Toast.lengthLong, gravity: Toast.bottom);
                    },
                    icon: const Icon(Icons.logout))
                : IconButton(
                    onPressed: () {
                      Usuario usuario =
                          Usuario("luis paulo", "luispscarvalho@gmail.com");

                      setState(() {
                        estadoApp.onLogin(usuario);
                      });

                      Toast.show("Você foi conectado com sucesso",
                          duration: Toast.lengthLong, gravity: Toast.bottom);
                    },
                    icon: const Icon(Icons.login))
          ],
        ),
        body: FlatList(
            data: _receitas,
            numColumns: 2,
            loading: _carregando,
            onRefresh: () {
              _filtro = "";
              _controladorFiltragem.clear();

              return _atualizarReceitas();
            },
            onEndReached: () => _carregarReceitas(),
            buildItem: (item, int indice) {
              return SizedBox(height: 400, child: ReceitaCard(receita: item));
            }));
  }
}
