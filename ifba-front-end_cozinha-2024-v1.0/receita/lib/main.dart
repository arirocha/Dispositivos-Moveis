import 'package:receita/estado.dart';
import 'package:receita/telas/detalhes.dart';
import 'package:receita/telas/receitas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EstadoApp(),
      child: MaterialApp(
        title: "Cozinha Ágil",
        theme: ThemeData(
          colorScheme: const ColorScheme.light(),
          useMaterial3: true,
        ),
        home: const Tela(),
      ),
    );
  }
}

class Tela extends StatefulWidget {
  const Tela({super.key});

  @override
  State<Tela> createState() => _TelaState();
}

class _TelaState extends State<Tela> {
  void _exibirComoRetrato() {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
  }

  @override
  Widget build(BuildContext context) {
    _exibirComoRetrato();
    estadoApp = context.watch<EstadoApp>();

    Widget tela = const SizedBox.shrink();
    if (estadoApp.situacao == Situacao.mostrandoReceitas) {
      tela = const Receitas();
    } else if (estadoApp.situacao == Situacao.mostrandoDetalhes) {
      tela = const Detalhes();
    }

    return SafeArea(
        child: tela); // Garante que a tela não sobreponha a área segura.
  }
}
