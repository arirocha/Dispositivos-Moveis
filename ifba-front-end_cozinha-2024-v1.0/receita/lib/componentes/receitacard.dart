import 'package:receita/estado.dart';
import 'package:flutter/material.dart';

class ReceitaCard extends StatelessWidget {
  final dynamic receita;

  const ReceitaCard({super.key, required this.receita});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        estadoApp.mostrarDetalhes(receita["_id"]);
      },
      child: Card(
        child: Column(children: [
          Image.asset("lib/recursos/imagens/receita.jpeg"),
          Row(children: [
            CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset("lib/recursos/imagens/time.png")),
            Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(receita["company"]["time"],
                    style: const TextStyle(fontSize: 15))),
          ]),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Text(receita["recipe"]["name"],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 10),
            child: Text(
              receita["recipe"]["description"],
              maxLines: 3, // Define o número máximo de linhas.
              overflow: TextOverflow
                  .ellipsis, // Adiciona "..." caso o texto exceda o limite.
            ),
          ),
          const Spacer(),
          Row(children: [
            Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 5),
                child: Row(children: [
                  const Icon(Icons.favorite_rounded,
                      color: Colors.red, size: 18),
                  Text(receita["likes"].toString())
                ])),
          ])
        ]),
      ),
    );
  }
}
