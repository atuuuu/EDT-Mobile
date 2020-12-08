import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_provider/theme_provider.dart';

////////////////////////////////////////////////////////FRONT END//////////////////////////////////////////////////////
class PopupCompte extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PopupCompteState();
  }
}

class _PopupCompteState extends State<PopupCompte> {
  String pass = "", log = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Identifiant : ',
            style: ThemeProvider.themeOf(context).data.textTheme.headline1,
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3, //TODO Pas propre
            child: TextField(
              style: TextStyle(
                fontSize: 13,
                color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
              ),
              expands: false,
              decoration: InputDecoration(
                  hintText: 'N° Etudiant',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
                  )),
              enabled: true,
              onSubmitted: (text) {
                Compte().username = text;
                if(pass != "" && log != "") {
                  Compte().enregistrerCompte();
                }
              },
              onChanged: (text) => log = text,
            ),
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mot de passe : ',
            style: ThemeProvider.themeOf(context).data.textTheme.headline1,
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            child: TextField(
              style: TextStyle(
                fontSize: 13,
                color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
              ),
              expands: false,
              decoration: InputDecoration(
                  hintText: 'Etupass',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
                  )),
              enabled: true,
              onSubmitted: (text) {
                Compte().password = text;
                Compte().enregistrerCompte();
              },
              onChanged: (text) => pass = text,
            ),
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Compte().username = log;
              Compte().password = pass;
              Compte().enregistrerCompte();
              Navigator.of(context).pop();
            },
            child: Text(
              "Valider",
              style: ThemeProvider.themeOf(context).data.textTheme.headline1,
            ),
          )
        ],
      )
    ]));
  }
}

class CompteRow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CompteRowState();
}

class _CompteRowState extends State<CompteRow> {
  String compteName = Compte().username == null ? "inconnu" : Compte().username;

  @override
  void initState() {
    //Initialise l'accès aux SharedPreferences pour récupérer les identifiants d'un compte déjà enregistré
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() => Compte().prefs = prefs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      //Affichage de la ligne 'Compte' de la page option
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
          child: Text(
            //Titre de la ligne
            "Compte : ",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(0, 25, 35, 35),
            child: TextButton(
              //Bouton indiquant 'Inconnu' ou le numéro étudiant du compte actuellement connecté
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(ThemeProvider.themeOf(context).data.primaryColor)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      PopupCompte(), //Ouvre un popup enregistrant les identifiants de l'étudiant
                );
              },
              child: Text(
                //Affichage du bouton
                compteName,
                style: ThemeProvider.themeOf(context).data.textTheme.headline1,
              ),
            )),
      ],
    );
  }
}

///////////////////////////////////////////////////////BACK END////////////////////////////////////////////////////

class Compte {
  static final Compte _singleton = Compte._internal(); //Instance du compte

  SharedPreferences prefs;

  String username;
  String password;

  factory Compte() {
    return _singleton;
  }

  void enregistrerCompte() async {
    //Enregistre les identifiants dans les SharedPreferences
    await prefs.setString('username', username);
    await prefs.setString('password', password);

    username = prefs.getString('username');
    password = prefs.getString('password');
  }

  Compte._internal(); //Initialisation : récupère les identifiants depuis les SharedPreferences

  void recupererCompte() async {
    try {
      prefs = await SharedPreferences.getInstance();
      username = prefs.get('username');
      password = prefs.get('password');
    } on NoSuchMethodError {
      username = "Inconnu";
      password = "";
    }
    if (username == "") {
      username = "Inconnu";
    }
  }
}
