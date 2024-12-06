// ignore_for_file: unnecessary_getters_setters

import 'package:receita/usuario.dart';
import 'package:flutter/material.dart';

enum Situacao { mostrandoReceitas, mostrandoDetalhes }

class EstadoApp extends ChangeNotifier {
  Situacao _situacao = Situacao.mostrandoReceitas;
  Situacao get situacao => _situacao;

  late int _idReceita;
  int get idReceita => _idReceita;

  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  set usuario(Usuario? usuario) {
    _usuario = usuario;
  }

  void mostrarReceitas() {
    _situacao = Situacao.mostrandoReceitas;

    notifyListeners();
  }

  void mostrarDetalhes(int idReceita) {
    _situacao = Situacao.mostrandoDetalhes;
    _idReceita = idReceita;

    notifyListeners();
  }

  void onLogin(Usuario? usuario) {
    _usuario = usuario;

    notifyListeners();
  }

  void onLogout() {
    _usuario = null;

    notifyListeners();
  }
}

late EstadoApp estadoApp;
