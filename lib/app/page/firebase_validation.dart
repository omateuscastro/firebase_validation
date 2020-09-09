import 'package:firebase_validation/app/page/politica.dart';
import 'package:firebase_validation/seguranca.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'funcoes.dart';
// import 'package:liberacaoremota/politica.dart';

class ConfigPage extends StatefulWidget {
  final bool motorista;
  final bool placa;
  final bool filled;
  ConfigPage({this.motorista = false, this.placa = false, this.filled = false});
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  Seguranca s = new Seguranca(email: "@cgi.com.br", password: "Mariana23");

  TextEditingController _edtCodigoText = TextEditingController();
  TextEditingController _edtUsuarioText = TextEditingController();
  TextEditingController _edtSenhaText = TextEditingController();
  TextEditingController _edtServicoText = TextEditingController();
  TextEditingController _edtMotoristaText = TextEditingController();
  TextEditingController _edtPlacaText = TextEditingController();

  FocusNode _edtCodigoFocus = FocusNode();
  FocusNode _edtUsuarioFocus = FocusNode();
  FocusNode _edtSenhaFocus = FocusNode();
  FocusNode _edtServicoFocus = FocusNode();
  FocusNode _edtMotoristaFocus = FocusNode();
  FocusNode _edtPlacaFocus = FocusNode();

  bool _isLoading = false;
  Map<String, dynamic> _version = {};

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    setValues();
  }

  setValues() async {
    this._edtUsuarioText.text = await redPreferences("edtUsuario");
    this._edtCodigoText.text = await redPreferences("edtCodigo");
    this._edtSenhaText.text = await redPreferences("edtSenha");
    this._edtServicoText.text = await redPreferences("edtServico");
    if (this.widget.motorista) {
      this._edtMotoristaText.text = await redPreferences("edtMotorista");
    }
    if (this.widget.placa) {
      this._edtPlacaText.text = await redPreferences("edtPlaca");
    }

    _version = await s.getBuildVersion();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: !_isLoading,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text("Configurações"),
          actions: <Widget>[
            !_isLoading
                ? IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      _grava();
                    })
                : Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Center(
                        child: SizedBox(
                            height: 25.0,
                            width: 25.0,
                            child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                              backgroundColor: Colors.white,
                            )))),
          ],
        ),
        body: SingleChildScrollView(
            child: Container(
                padding:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 80),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: TextFormField(
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'Informe o código de acesso';
                                }
                                return null;
                              },
                              focusNode: _edtCodigoFocus,
                              controller: _edtCodigoText,
                              decoration: InputDecoration(
                                  labelText: "Código de Acesso",
                                  filled: this.widget.filled),
                              keyboardType: TextInputType.text)),
                      this.widget.motorista
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: TextFormField(
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return 'Informe a código do motorista';
                                    }
                                    return null;
                                  },
                                  focusNode: _edtMotoristaFocus,
                                  controller: _edtMotoristaText,
                                  decoration: InputDecoration(
                                      labelText: "Código do Motorista",
                                      filled: this.widget.filled),
                                  keyboardType: TextInputType.number))
                          : Container(),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: TextFormField(
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'Informe o usuário';
                                }
                                return null;
                              },
                              focusNode: _edtUsuarioFocus,
                              controller: _edtUsuarioText,
                              decoration: InputDecoration(
                                  labelText: "Usuário",
                                  filled: this.widget.filled),
                              keyboardType: TextInputType.text)),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: TextFormField(
                              validator: (val) {
                                if (val.isEmpty) {
                                  return 'Informe a senha';
                                }
                                return null;
                              },
                              focusNode: _edtSenhaFocus,
                              controller: _edtSenhaText,
                              decoration: InputDecoration(
                                  labelText: "Senha",
                                  filled: this.widget.filled),
                              keyboardType: TextInputType.text,
                              obscureText: true)),
                      this.widget.placa
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: TextFormField(
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return 'Informe a placa do veiculo';
                                    }
                                    return null;
                                  },
                                  focusNode: _edtPlacaFocus,
                                  controller: _edtPlacaText,
                                  decoration: InputDecoration(
                                      labelText: "Placa do veículo",
                                      filled: this.widget.filled),
                                  keyboardType: TextInputType.text))
                          : Container(),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: TextFormField(
                              enabled: false,
                              focusNode: _edtServicoFocus,
                              controller: _edtServicoText,
                              decoration: InputDecoration(
                                  labelText: "Serviço",
                                  filled: this.widget.filled),
                              keyboardType: TextInputType.url)),
                      Container(
                          padding: EdgeInsets.only(top: 10),
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              _version != null
                                  ? Text(
                                      "Versão atual do aplicativo: ${_version['v']}")
                                  : Container(),
                              _version != null
                                  ? Text(
                                      "Versão atual do build: ${_version['b']}")
                                  : Container(),
                            ],
                          )),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        height: 50,
                        width: double.infinity,
                        child: RaisedButton(
                            child: Text(
                              "Política de Privacidade",
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PoliticaPage()));
                            }),
                      )
                    ],
                  ),
                ))));
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
    if (_formKey.currentState.validate()) {
      this._isLoading = true;
      setState(() {});
      await savePreferences("edtCodigo", this._edtCodigoText.text);
      await savePreferences("edtUsuario", this._edtUsuarioText.text);
      await savePreferences("edtSenha", this._edtSenhaText.text);
      await savePreferences("edtServico", this._edtServicoText.text);
      await savePreferences("edtMotorista", this._edtMotoristaText.text);
      await savePreferences("edtPlaca", this._edtPlacaText.text);
      ;
      var r = await s.execute();
      print(r);
      if (r != "") {
        s.show(r, context);
        this._isLoading = false;
        setState(() {});
      } else {
        this._isLoading = false;
        setState(() {});
        this._edtServicoText.text = await redPreferences("edtServico");
        final snackBar = SnackBar(
          content: Text('Configurações salvar com sucesso!'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );

        _scaffoldKey.currentState.showSnackBar(snackBar);
        await Future.delayed(new Duration(milliseconds: 2000));
        Navigator.pop(context);
      }
    }
    // Navigator.of(context).pop(true);
  }
}
