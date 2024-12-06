import 'dart:convert';
import 'package:receita/estado.dart';
import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:toast/toast.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DetalhesState();
  }
}

enum _EstadoReceita { naoVerificado, temReceita, semReceita }

class _DetalhesState extends State<Detalhes> {
  late dynamic _feedEstatico;
  late dynamic _comentariosEstaticos;
  _EstadoReceita _temReceita = _EstadoReceita.naoVerificado;
  dynamic _receita; // Can be null initially
  List<dynamic> _comentarios = [];
  bool _carregandoComentarios = false;
  bool _temComentarios = false;
  late TextEditingController _controladorNovoComentario;
  late PageController _controladorSlides;
  late int _slideSelecionado;
  bool _curtiu = false;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _lerFeedEstatico();
    _iniciarSlides();
    _controladorNovoComentario = TextEditingController();
  }

  void _iniciarSlides() {
    _slideSelecionado = 0;
    _controladorSlides = PageController(initialPage: _slideSelecionado);
  }

  Future<void> _lerFeedEstatico() async {
    String conteudoJson =
        await rootBundle.loadString("lib/recursos/json/feed.json");
    _feedEstatico = await json.decode(conteudoJson);
    conteudoJson =
        await rootBundle.loadString("lib/recursos/json/comentarios.json");
    _comentariosEstaticos = await json.decode(conteudoJson);
    _carregarReceita();
    _carregarComentarios();
  }

  void _carregarReceita() {
    setState(() {
      _receita = _feedEstatico['receitas'].firstWhere(
          (receita) => receita["_id"] == estadoApp.idReceita,
          orElse: () => null);
      _temReceita = _receita != null
          ? _EstadoReceita.temReceita
          : _EstadoReceita.semReceita;
    });
  }

  void _carregarComentarios() {
    setState(() {
      _carregandoComentarios = true;
    });

    var maisComentarios = [];
    _comentariosEstaticos["comentarios"].where((item) {
      return item["feed"] == estadoApp.idReceita;
    }).forEach((item) {
      maisComentarios.add(item);
    });

    setState(() {
      _carregandoComentarios = false;
      _comentarios = maisComentarios;
      _temComentarios = _comentarios.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ensure that _receita is not null before calling _exibirReceita
    if (_receita == null) {
      return Scaffold(
        body:
            Center(child: CircularProgressIndicator()), // Show loading spinner
      );
    }

    return _exibirReceita(); // Calls your method to display the recipe UI
  }

  Widget _exibirReceita() {
    bool usuarioLogado = estadoApp.usuario != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Row(
              children: [
                Image.asset('lib/recursos/imagens/time.png', width: 38),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                  child: Text(
                    _receita["company"]["time"],
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                estadoApp.mostrarReceitas();
              },
              child: const Icon(Icons.arrow_back, size: 30),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 230,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: 3,
                    controller: _controladorSlides,
                    onPageChanged: (slide) {
                      setState(() {
                        _slideSelecionado = slide;
                      });
                    },
                    itemBuilder: (context, pagePosition) {
                      return Image.asset(
                        'lib/recursos/imagens/receita.jpeg',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: [
                        usuarioLogado
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (_curtiu) {
                                      _receita['likes'] -= 1;
                                      _curtiu = false;
                                    } else {
                                      _receita['likes'] += 1;
                                      _curtiu = true;
                                    }
                                  });
                                  Toast.show(
                                    "Obrigado pela avaliação",
                                    duration: Toast.lengthLong,
                                    gravity: Toast.bottom,
                                  );
                                },
                                icon: Icon(
                                  _curtiu
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                                color: Colors.red,
                                iconSize: 26,
                              )
                            : const SizedBox.shrink(),
                        IconButton(
                          onPressed: () {
                            final texto =
                                '${_receita["recipe"]["name"]} disponível no Cozinha Ágil.\n\n\nBaixe o Cozinha Ágil na PlayStore!';
                            FlutterShare.share(
                              title: "Cozinha Ágil",
                              text: texto,
                            );
                          },
                          icon: const Icon(Icons.share),
                          color: Colors.blue,
                          iconSize: 26,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: PageViewDotIndicator(
                currentItem: _slideSelecionado,
                count: 3,
                unselectedColor: Colors.black26,
                selectedColor: Colors.blue,
                duration: const Duration(milliseconds: 200),
                boxShape: BoxShape.circle,
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      _receita["recipe"]["name"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      _receita["recipe"]["description"],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      _receita["recipe"]["ingredients"],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      _receita["recipe"]["instructions"],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Text(
                            "Marca: ${_receita["company"]["time"]}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("Comentários", style: TextStyle(fontSize: 16)),
            ),
            _temComentarios
                ? Column(
                    children: _comentarios.map((comentario) {
                      return ListTile(
                        title: Text(comentario["user"]["name"] ?? 'Anônimo'),
                        subtitle: Text(comentario["content"] ?? 'Anônimo'),
                      );
                    }).toList(),
                  )
                : _carregandoComentarios
                    ? const CircularProgressIndicator()
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text("Nenhum comentário ainda"),
                      ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
