import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:theme_provider/theme_provider.dart';

//////////////////////////////////////////FRONT END/////////////////////////////////////////
class PopupAPropos extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _PopupAProposState();
  }
}

class _PopupAProposState extends State<PopupAPropos> {
  PackageInfo _packageInfo = PackageInfo(     //Initialisation du Popup avec des valeurs par défaut
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();       //Récupère les vrais informations sur l'app actuelle
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(               //Popup qui s'affiche lorsqu'on appuie sur le bouton
      title: Text('A propos',
        style: TextStyle(
            color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
        ),
      ),
      content: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                "Nom : ",
                style: TextStyle(
                  color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
                ),
              ),
              Text(_packageInfo.appName,
                style: TextStyle(
                  color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
                ),),
              Expanded(
                  child: Divider(
                thickness: 2,
                color: ThemeProvider.themeOf(context).data.textTheme.headline6.color,
                indent: 30,
                endIndent: 30,
              )),
              Text("Version : ",
                style: TextStyle(
                  color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
                ),),
              Text(_packageInfo.version,
                style: TextStyle(
                  color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
                ),)
            ])
          ]),
      actions: <Widget>[
        new FlatButton(                   //Bouton fermer
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: ThemeProvider.themeOf(context).data.primaryColor,
          child: Text(
            'Fermer',
            style: TextStyle(
              color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
            ),
          ),
        ),
      ],
    );
  }

  /////////////////////BACK END/////////////////
  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();  //Récupère les infos relatives à l'application (version actuelle...)
    setState(() {
      _packageInfo = info;
    });
  }
}
