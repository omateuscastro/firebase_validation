import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info/package_info.dart';
import 'package:device_info/device_info.dart';
import 'package:quiver/strings.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';

class Seguranca {
  String _retorno;
  String codigoAcesso;
  final String email;
  final String password;

  Seguranca({this.codigoAcesso, this.email, this.password});

  Future<String> execute() async {
    this.codigoAcesso = await readPreferences("edtCodigo");
    if (codigoAcesso.trim().length == 0) {
      _retorno = "Informe o Código de Acesso para realizar está operação !";
    } else {
      _retorno = "";
      await podeVerificar();
    }
    return _retorno;
  }

  Future<Null> podeVerificar() async {
    String sDias = await readPreferences("dias_autenticacao");

    if (sDias.trim().length == 0 || sDias.contains("0"))
      await verificaAutenticacao();
    else {
      String sData = await readPreferences("dt_ult_autenticacao");

      if (sData.trim().length == 0) {
        await verificaAutenticacao();
      } else {
        int iDataAtual = int.tryParse(getData(getDate())[4]);
        int iDataAutenticacao = int.tryParse(sData);
        int iDias = int.tryParse(sDias);

        if (iDataAutenticacao + iDias <= iDataAtual) {
          await verificaAutenticacao();
        } else {
          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          String sVersao = await readPreferences("versao");

          if (equalsIgnoreCase(sVersao, packageInfo.version)) {
            return;
          } else {
            await verificaAutenticacao();
          }
        }
      }
    }
  }

  Future<Null> verificaAutenticacao() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();
    await _auth
        .signInWithEmailAndPassword(
            email: codigoAcesso + email, password: password)
        .then((user) async {
      await verificaPermissoes();
    }).catchError((e) {
      _retorno =
          "Não foi possivel verificar as permissões de acesso junto aos servidores da CGI. Verifique o código de acesso nas configurações !";
    });
  }

  Future<Null> verificaPermissoes() async {
    String string_003 =
        "Não foi possivel verificar as permissões de acesso junto aos servidores da CGI. Contate a CGI Software para mais informações !";

    DocumentSnapshot snapshot = await Firestore.instance
        .collection("Permissoes")
        .document(this.codigoAcesso)
        .get();
    // ativo
    if (!equalsIgnoreCase(snapshot.data["ativo"].toString(), "sim")) {
      _retorno = string_003;
      return;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // dt_validade
    List<String> vDtAtual = getData(getDate());
    List<String> vDtValidade = getData(snapshot.data["dt_validade"].toString());
    if (int.tryParse(vDtAtual[4]) > int.tryParse(vDtValidade[4])) {
      _retorno = string_003;
      return;
    }

    await savePreferences(
        "dias_autenticacao", snapshot.data["dias_autenticacao"].toString());

    // black_list
    List<String> vLista = snapshot.data["black_list"].toString().split(",");
    for (int i = 0; i <= vLista.length - 1; i++) {
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        if (vLista[i].contains(iosInfo.identifierForVendor.toString())) {
          _retorno =
              "Este dispositivo não tem autorização de acesso. Para maiores informações contate a CGI Software !";
          return;
        }
      } else {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (vLista[i].contains(androidInfo.androidId.toString())) {
          _retorno =
              "Este dispositivo não tem autorização de acesso. Para maiores informações contate a CGI Software !";

          return;
        }
      }
    }

    // versao_minima
    if (int.tryParse(packageInfo.buildNumber) <
        int.tryParse(snapshot.data["versao_minima"].toString())) {
      _retorno =
          "A versão atual do seu aplicativo não pode mais ser executada. Por favor, atualize o aplicativo e tente novamente !";
      return;
    }

    // endereco_pacific
    // if (snapshot.data["endereco_pacific"].toString().trim().length != 0) {
    await savePreferences(
        "edtServico", snapshot.data["endereco_pacific"].toString());
    //}

    await savePreferences("dt_ult_autenticacao", getData(getDate())[4]);
    await savePreferences("versao", packageInfo.version);

    String sUsuario = await readPreferences("edtUsuario");
    String sSenha = await readPreferences("edtSenha");
    String sServico = await readPreferences("edtServico");

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      Firestore.instance
          .collection("Permissoes")
          .document(this.codigoAcesso)
          .collection("Devices")
          .document(iosInfo.identifierForVendor.toString())
          .setData({
        "identifierForVendor": iosInfo.identifierForVendor.toString(),
        "model": iosInfo.model.toString(),
        "localizedModel": iosInfo.localizedModel.toString(),
        "name": iosInfo.name.toString(),
        "systemName": iosInfo.systemName.toString(),
        "systemVersion": iosInfo.systemVersion.toString(),
        "versao_aplicativo": packageInfo.version.toString(),
        "versao_code": packageInfo.buildNumber.toString(),
        "dt_acesso": getDate(),
        "erp_codigo_acesso": this.codigoAcesso.toString(),
        "erp_usuario_cgi": sUsuario,
        "erp_senha_cgi": sSenha,
        "erp_servico": sServico
      });
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      Firestore.instance
          .collection("Permissoes")
          .document(this.codigoAcesso)
          .collection("Devices")
          .document(androidInfo.androidId.toString())
          .setData({
        "androidId": androidInfo.androidId.toString(),
        "device": androidInfo.device.toString(),
        "model": androidInfo.model.toString(),
        "version": androidInfo.version.toString(),
        "board": androidInfo.board.toString(),
        "bootloader": androidInfo.bootloader.toString(),
        "display": androidInfo.display.toString(),
        "fingerprint": androidInfo.fingerprint.toString(),
        "hardware": androidInfo.hardware.toString(),
        "brand": androidInfo.brand.toString(),
        "host": androidInfo.host.toString(),
        "id": androidInfo.id.toString(),
        "manufacturer": androidInfo.manufacturer.toString(),
        "product": androidInfo.product.toString(),
        "type": androidInfo.type.toString(),
        "versao_aplicativo": packageInfo.version.toString(),
        "versao_code": packageInfo.buildNumber.toString(),
        "dt_acesso": getDate(),
        "erp_codigo_acesso": this.codigoAcesso.toString(),
        "erp_usuario_cgi": sUsuario,
        "erp_senha_cgi": sSenha,
        "erp_servico": sServico
      });
    }
  }

  Future getCodigo() async {
    var cod =  await readPreferences('edtCodigo');
    return cod;
  }

  Future getSenha() async {
    var senha =  await readPreferences('edtSenha');
    return senha;
  }

  Future getURL() async {
    var url =  await readPreferences('edtServico');
    return url;
  }

  Future getUsuario() async {
    var usuario =  await readPreferences('edtUsuario');
    return usuario;
  }

  Future getMotorista() async {
    var motorista =  await readPreferences('edtMotorista');
    return motorista;
  }

  Future getPlaca() async {
    var placa =  await readPreferences('edtPlaca');
    return placa;
  }

  Future<Null> savePreferences(String key, String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, value);
  }

  Future<String> readPreferences(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String sRetorno = sharedPreferences.getString(key);

    if (sRetorno == null)
      return "";
    else
      return sRetorno;
  }

  String getDate() {
    return new DateFormat("dd/MM/yyyy").format(new DateTime.now());
  }

  String getDateTime() {
    return new DateFormat("dd/MM/yyyy HH:mm:ss").format(new DateTime.now());
  }

  List<String> getData(String data) {
    List<String> vRetorno = new List(9);
    int iDia = 0;
    int iMes = 0;
    int iAno = 0;
    String sAno = "";
    String sMes = "";
    String sDia = "";

    if (data.trim().length != 0) {
      iDia = int.tryParse(data.split("/")[0]);
      iMes = int.tryParse(data.split("/")[1]);
      iAno = int.tryParse(data.split("/")[2]);

      sDia = data.split("/")[0];
      sMes = data.split("/")[1];
      sAno = data.split("/")[2];
    }

    vRetorno[0] = data;
    vRetorno[1] = iDia.toString();
    vRetorno[2] = iMes.toString();
    vRetorno[3] = iAno.toString();
    vRetorno[4] = sAno + sMes + sDia;
    vRetorno[5] = sMes + "/" + sAno;
    vRetorno[6] = sDia;
    vRetorno[7] = sMes;
    vRetorno[8] = sAno;

    return vRetorno;
  }
}
