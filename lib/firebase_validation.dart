import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'funcoes.dart';
// import 'package:liberacaoremota/politica.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  TextEditingController _edtCodigoText = TextEditingController();
  TextEditingController _edtUsuarioText = TextEditingController();
  TextEditingController _edtSenhaText = TextEditingController();
  TextEditingController _edtServicoText = TextEditingController();

  FocusNode _edtCodigoFocus = FocusNode();
  FocusNode _edtUsuarioFocus = FocusNode();
  FocusNode _edtSenhaFocus = FocusNode();
  FocusNode _edtServicoFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    setaCampos();
  }

  setaCampos() async {
    this._edtUsuarioText.text = await redPreferences("edtUsuario");
    this._edtCodigoText.text = await redPreferences("edtCodigo");
    this._edtSenhaText.text = await redPreferences("edtSenha");
    this._edtServicoText.text = await redPreferences("edtServico");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text("Configurações"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  _grava();
                })
          ],
        ),
        body: SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextField(
                    focusNode: _edtCodigoFocus,
                    controller: _edtCodigoText,
                    decoration: InputDecoration(labelText: "Código de Acesso"),
                    keyboardType: TextInputType.text),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextField(
                    focusNode: _edtUsuarioFocus,
                    controller: _edtUsuarioText,
                    decoration: InputDecoration(labelText: "Usuário"),
                    keyboardType: TextInputType.text),
              ),
              Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextField(
                      focusNode: _edtSenhaFocus,
                      controller: _edtSenhaText,
                      decoration: InputDecoration(labelText: "Senha"),
                      keyboardType: TextInputType.text,
                      obscureText: true)),
              Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextField(
                      enabled: false,
                      focusNode: _edtServicoFocus,
                      controller: _edtServicoText,
                      decoration: InputDecoration(labelText: "Serviço"),
                      keyboardType: TextInputType.url)),
              Container(
                height: 50,
                margin: EdgeInsets.only(top: 20),
                child: RaisedButton(
                    child: Text(
                      "Política de Privacidade",
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      // Navigator.of(context).push(
                      //     MaterialPageRoute(builder: (context) => Politica()));
                    }),
              )
            ],
          ),
        )));
  }

  Future<Null> savePreferences(String key, String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, value);
  }

  Future<String> redPreferences(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String sRetorno = sharedPreferences.getString(key);

    if (sRetorno == null)
      return "";
    else
      return sRetorno;
  }

  void _grava() async {
    if (!_validaTela()) return;

    await savePreferences("edtCodigo", this._edtCodigoText.text);
    await savePreferences("edtUsuario", this._edtUsuarioText.text);
    await savePreferences("edtSenha", this._edtSenhaText.text);
    await savePreferences("edtServico", this._edtServicoText.text);
    Navigator.of(context).pop(true);
  }

  bool _validaTela() {
    if (_edtCodigoText.text.trim().length == 0) {
      // Funcoes.showMessage(
      //     context: context,
      //     titulo: "Aviso",
      //     mensagem: "Informe o Código de Acesso !",
      //     textoBotao: "OK",
      //     campoFoco: _edtCodigoFocus);
      return false;
    }

    if (_edtUsuarioText.text.trim().length == 0) {
      // Funcoes.showMessage(
      //     context: context,
      //     titulo: "Aviso",
      //     mensagem: "Informe o Usuário !",
      //     textoBotao: "OK",
      //     campoFoco: _edtCodigoFocus);
      return false;
    }

    if (_edtSenhaText.text.trim().length == 0) {
      // Funcoes.showMessage(
      //     context: context,
      //     titulo: "Aviso",
      //     mensagem: "Informe a Senha !",
      //     textoBotao: "OK",
      //     campoFoco: _edtCodigoFocus);
      return false;
    }

    return true;
  }
}
