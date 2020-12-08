import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:theme_provider/theme_provider.dart';

///////////////////////////////////////////////FRONT END//////////////////////////////////////////////////////
class ThemeRow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ThemeRowState();
}

class _ThemeRowState extends State<ThemeRow> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
        child: Text(
          "Theme :",
          style: TextStyle(
            color: ThemeProvider.controllerOf(context)
                .theme
                .data
                .textTheme
                .headline1
                .color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.left,
        ),
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 25, 35, 35), child: BoutonTheme())
    ]);
  }
}

/// Le bouton déroulant pour choisir entre clair et sombre
class BoutonTheme extends StatefulWidget {
  BoutonTheme({Key key}) : super(key: key);

  @override
  _BoutonThemeState createState() => _BoutonThemeState();
}

class _BoutonThemeState extends State<StatefulWidget> {
  String dropdownValue;

  @override
  Widget build(BuildContext context) {
    dropdownValue = ThemeApp().currentThemeName();
    return DropdownButton<String>(    //Bouton proposant la liste des thèmes existants
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      dropdownColor: ThemeProvider.themeOf(context).data.cardColor,
      underline: Container(
        height: 2,
      ),
      onChanged: (String newValue) {
        setState(() {
          _updateTheme(newValue); //Met à jour le thème
        });
      },
      items: <String>['Clair', 'Sombre', 'Custom'].map<DropdownMenuItem<String>>((String value) { //Liste des thèmes dispos
        return DropdownMenuItem<String>(  //Un seul élément de la liste du bouton
          value: value,
          child: Text(
            value,
            style: TextStyle(
                color: ThemeProvider.themeOf(context).data.textTheme.headline1.color),
          ),
        );
      }).toList(),
    );
  }

  _updateTheme(String newValue) { //En fonction de la nouvelle valeur, change le thème
    EtatTheme newTheme;
    if (newValue != dropdownValue) {
      dropdownValue = newValue;
      switch (dropdownValue) {
        case 'Clair':
          newTheme = EtatTheme.CLAIR;
          break;
        case 'Sombre':
          newTheme = EtatTheme.SOMBRE;
          break;
        case 'Custom':
          newTheme = EtatTheme.CUSTOM;
          break;
        default:
          newTheme = EtatTheme.SOMBRE;
          break;
      }
      dropdownValue = ThemeApp().changerTheme(context, newTheme); //Change le thème dans le controleur
    }
  }
}

////////////////////////////////////////BACK END//////////////////////////////////////////////////

class ThemeApp extends ChangeNotifier {
  //Singleton
  static ThemeApp _instance = ThemeApp._internal(); //Instancié au lancement

  ThemeData tClair;
  ThemeData tSombre;

  //Thème courant
  EtatTheme etatTheme;
  ThemeData themeCourant;

  factory ThemeApp() {
    //Constructeur : retourne l'instance du singleton
    return _instance;
  }

  ThemeApp._internal() {
    //"Vrai" constructeur (initialise l'appli sur le thème de l'utilisateur)

    etatTheme = EtatTheme.CLAIR;

    tClair = new ThemeData(
      backgroundColor: Color(0xFFFCFCFC),
      textTheme: TextTheme(
          headline1: TextStyle(
            //Titres
            color: Color(0xFF4A5255),
          ),
          headline2: TextStyle(
            //
            color: Color(0xFF707070),
          ),
          headline3: TextStyle(
            color: Color(0xFF3D3D3D),
          ),
          headline4: TextStyle(
            color: Color(0xFF404040),
          ),
          headline5: TextStyle(
            color: Color(0xFF757575),
          ),
          headline6: TextStyle(
            //StyleHeure (et je l'utilise pour les noms de matière aussi ça rends bien)
            color: Color(0xff606060),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          )),
      scaffoldBackgroundColor: Color(0xFFFCFCFC),
      cardColor: Color(0xFFC4C4C4),
      canvasColor: Color(0xFFFCFCFC),
      primaryColor: Color(0xFFDDDDDD),
      iconTheme: IconThemeData(
        color: Color(0xFFC4C4C4),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(
          color: Color(0xFF14A4F5),
        ),
        unselectedIconTheme: IconThemeData(
          color: Color(0xFFC4C4C4),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Color.fromRGBO(50, 50, 55, 1),
        ),
      ),
    );

    tSombre = new ThemeData(
      backgroundColor: Color(0xFF2F3136),
      textTheme: TextTheme(
          headline1: TextStyle(
            color: Color(0xFFCBD6DA),
          ),
          headline2: TextStyle(
            color: Color(0xFF898989),
          ),
          headline3: TextStyle(
            color: Color(0xFF3D3D3D),
          ),
          headline4: TextStyle(
            color: Color(0xFF101010),
          ),
          headline5: TextStyle(
            color: Color(0xFF303030),
          ),
          headline6: TextStyle(
            //StyleHeure (et je l'utilise pour les noms de matière aussi ça rends bien)
            color: Color(0xff606060),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          )),
      scaffoldBackgroundColor: Color(0xFF2F3136),
      cardColor: Color(0xFF202225),
      canvasColor: Color(0xFF2F3136),
      primaryColor: Color(0xFF222222),
      iconTheme: IconThemeData(
        color: Color(0xFF747784),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF202225),
        selectedIconTheme: IconThemeData(
          color: Color(0xFF3E6DE7),
        ),
        unselectedIconTheme: IconThemeData(color: Color(0xFF545764)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Color.fromRGBO(50, 50, 55, 1),
        titleTextStyle: TextStyle(
          color: Color.fromRGBO(203, 214, 218, 1),
        ),
      ),
    );
  }

  String changerTheme(BuildContext context, EtatTheme newTheme) {   //Change le thème dans le controleur
    if (!ThemeProvider.controllerOf(context).hasTheme(newTheme.id))
    {
      ThemeCreatorPopup();
    }
    else {
      //Applique le thème actuellement choisi
      ThemeProvider.controllerOf(context).setTheme(newTheme.id);
      etatTheme = newTheme;
    }
    return currentThemeName();
  }

  //Retourne le nom du thème actuel
  String currentThemeName() {
    switch (etatTheme) {
      case EtatTheme.CLAIR:
        return 'Clair';
      case EtatTheme.SOMBRE:
        return 'Sombre';
      case EtatTheme.CUSTOM:
        return 'Custom';
      default:
        return 'Sombre';
    }
  }

  //Initialise le thème au démarage de l'appli
  void initTheme(String savedTheme) {
    switch(savedTheme) {
      case 'custom':
        ThemeApp().etatTheme = EtatTheme.CUSTOM;
        break;
      case 'light':
        ThemeApp().etatTheme = EtatTheme.CLAIR;
        break;
      case 'dark':
        ThemeApp().etatTheme = EtatTheme.SOMBRE;
        break;
    }
  }
}

///Pas ouf, faire sans
enum EtatTheme {
  CLAIR,
  SOMBRE,
  CUSTOM,
}

///Pareil
extension EtatThemeId on EtatTheme {
  static const names = {
    EtatTheme.SOMBRE: 'dark',
    EtatTheme.CLAIR: 'light',
    EtatTheme.CUSTOM: 'custom',
  };

  String get id => names[this];
}

//Contient le thème actuel...
/// Revoir la construction de cette classe et de la classe ThemeApp() parce que pas propre
class TheTheme {
  static TheTheme _instance = TheTheme._internal(); //Instancié au lancement

  factory TheTheme() {
    return _instance;
  }

  TheTheme._internal();
}

class ThemeCreatorPopup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ThemeCreatorPopupState();
}

class _ThemeCreatorPopupState extends State<ThemeCreatorPopup> {
  @override
  Widget build(BuildContext context) {
    return Text("Pas encore implémenté...");
  }
}