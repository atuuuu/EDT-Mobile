import 'package:edt_mobile/pageOption/Compte.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'Notification.dart';
import 'aPropos.dart';
import 'theme.dart';

//Squelette de la page option :
class PageOptions extends StatefulWidget {
  @override
  _PageOptionsState createState() => _PageOptionsState();
}

class _PageOptionsState extends State<PageOptions> {
  bool notification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.controllerOf(context).theme.data.scaffoldBackgroundColor,
      body: SingleChildScrollView(
          child: Column(
        children: [
          EnTeteParametre(), //Done
          Diviseur(), //Done
          ThemeRow(), //TODO Ajouter un personnalisateur de thème - après avoir fini le compte et les notifications
          NotificationRow(), //TODO
          CompteRow(), //Done
          AProposRow(), //Done
        ],
      )),
    );
  }
}

class EnTeteParametre extends StatelessWidget {
  //Haut de la page
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        top: 50,
        right: 15,
        bottom: 30,
      ),
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Text(
          "Parametres",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
          ),
        ),
      ),
    );
  }
}

class Diviseur extends StatelessWidget {
  //Réutilisable - la barre noire qui sépare l'en-tête et le reste de la page
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Divider(
        thickness: 2,
        color: Colors.black,
        indent: 30,
        endIndent: 30,
      ))
    ]);
  }
}

class AProposRow extends StatelessWidget {
  //Ligne à propos
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      RaisedButton(
        child: const Text('A propos'),
        elevation: 4.0,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => PopupAPropos(),
          );
          // Perform some action
        },
      )
    ]);
  }
}
