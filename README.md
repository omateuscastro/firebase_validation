# Firebase Validation

Um pacote para validações do firebase da CGI;

## Instalação

- Adicione o `firebase_validation: 0.0.17` no `pubspec.yaml` do seu aplicativo.
- Adicione os arquivos do google firebase no Android e iOS.
- Rode `flutter pub get`

## Uso

Instancie a classe de configurações:

```dart
await Navigator.push(context,
    PageRouteBuilder(
        pageBuilder: (c, a1, a2) => ConfigPage(),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 100)));
```

Vocẽ pode passar alguns paramêtros se precisar:

```dart
ConfigPage(
    motorista: true, 
    placa: true, 
    filled: true, 
    appBarColor: Theme.of(context).primaryColor, 
    appBarTextColor: Colors.white
);
```


