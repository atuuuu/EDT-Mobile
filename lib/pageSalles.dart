import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:edt_mobile/Calendrier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'objets.dart';

class PageSalles extends StatefulWidget {
  @override
  _PageSallesState createState() => _PageSallesState();
}

class _PageSallesState extends State<PageSalles> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 50, bottom: 15),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Text(
                'Lundi 27 Septembre',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
                ),
              ),
            ),
            Column(
              children: [
                //PlageHoraireGenerale(Horaire(8, 0), Horaire(9, 0)),
                Salle(
                  salle: Salles.S1110,
                  possedeOrdis: false,
                ),
                Salle(
                  salle: Salles.S2127,
                  possedeOrdis: false,
                ),
                Salle(
                  salle: Salles.S2129,
                  possedeOrdis: false,
                ),
                Salle(
                  salle: Salles.S2236,
                  possedeOrdis: true,
                ),
                //PlageHoraireGenerale(Horaire(9, 0), Horaire(10, 0)),
                Salle(
                  salle: Salles.S1110,
                  possedeOrdis: false,
                ),
                Salle(
                  salle: Salles.S2236,
                  possedeOrdis: true,
                ),
                //PlageHoraireGenerale(Horaire(10, 0), Horaire(11, 0)),
                Salle(
                  salle: Salles.S2236,
                  possedeOrdis: true,
                ),
                Salle(
                  salle: Salles.S2127,
                  possedeOrdis: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class PlageHoraire {
  final Horaire debut;
  final Horaire fin;

  PlageHoraire({this.debut, this.fin});

  @override
  String toString() {
    return "$debut-$fin";
  }

  @override
  bool operator ==(Object other) {
    return other is PlageHoraire && other.fin == fin && other.debut == debut;
  }
}

class PlageHoraireGenerale extends StatefulWidget {
  _PlageHoraireGeneraleState createState() => _PlageHoraireGeneraleState();

  final Horaire debut;
  final Horaire fin;
  final List<Salle> listSalles;

  PlageHoraireGenerale({this.listSalles, this.debut, this.fin});

  String get horaireString {
    return debut.heureSoloStr + "H - " + fin.heureSoloStr + "H";
  }
}

class _PlageHoraireGeneraleState extends State<PlageHoraireGenerale> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 100,
        top: 40,
        right: 100,
        bottom: 20,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[350],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        widget.horaireString,
        style: TextStyle(
          fontSize: 25,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class Salle extends StatefulWidget {
  @override
  _SalleState createState() => _SalleState();

  Salle({Key key, this.possedeOrdis, this.salle}) : super(key: key);

  final Salles salle;
  final bool possedeOrdis;
  final List<PlageHoraire> horaireVide = new List<PlageHoraire>();

  getDateAuj() {
    return "20201201";
  }

  sort(List<PlageHoraire> pH) {
    List<PlageHoraire> newPh = new List<PlageHoraire>();
    int ppt;
    int place;
    if (pH.length > 1) {
      for (int i = 0; i < pH.length; i++) {
        ppt = 18;
        for (int j = 0; j < pH.length; j++) {
          if (int.parse(pH[j].debut.toString().substring(0, 2)) < ppt &&
              !newPh.contains(pH[j])) {
            ppt = int.parse(pH[j].debut.toString().substring(0, 2));
            place = j;
          }
        }
        newPh.add(pH[place]);
      }
    }
    return newPh;
  }

  IconData get salleOrdi {
    if (this.possedeOrdis == true) {
      creerPH();
      return Icons.computer;
    } else {
      return Icons.phonelink_off;
    }
  }

  creerPH() async {
    String dateAuj = getDateAuj();
    String file = await http.read(this.salle.url);
    List<String> listeCoursAuj = List<String>();
    List<PlageHoraire> coursJournee = new List<PlageHoraire>();
    String reduceLength;
    for (String verif in LineSplitter.split(file)) {
      if (verif.contains("DTSTART:" + dateAuj) ||
          verif.contains("DTEND:" + dateAuj)) {
        reduceLength = verif.split(":" + dateAuj + "T")[1];
        reduceLength = reduceLength.split("00Z")[0];
        listeCoursAuj.add(reduceLength.substring(0, 2));
        listeCoursAuj.add(reduceLength.substring(2, 4));
      }
    }

    for (int i = 0; i < listeCoursAuj.length; i += 4) {
      coursJournee.add(PlageHoraire(
          debut: Horaire(
              int.parse(listeCoursAuj[i]), int.parse(listeCoursAuj[i + 1])),
          fin: Horaire(int.parse(listeCoursAuj[i + 2]),
              int.parse(listeCoursAuj[i + 3]))));
    }
    coursJournee = sort(coursJournee);
    List<PlageHoraire> listPause = new List<PlageHoraire>();
    if (coursJournee.isNotEmpty) {
      listPause
          .add(PlageHoraire(debut: Horaire(7, 0), fin: coursJournee[0].debut));
      for (int i = 0; i < coursJournee.length - 1; i++) {
        listPause.add(PlageHoraire(
            debut: coursJournee[i].fin, fin: coursJournee[i + 1].debut));
      }
      listPause.add(PlageHoraire(
          debut: coursJournee[coursJournee.length - 1].fin,
          fin: Horaire(17, 0)));
    }
    for (int i = listPause.length - 1; i != -1; i--) {
      //ne pas modifier une liste qu'on itère!!!! créer une autre liste?! -> pas pratique! -> meilleure soluce?
      if (listPause[i].debut == listPause[i].fin) {
        listPause.removeAt(i);
      }
    }

    return listPause;
  }
}

class _SalleState extends State<Salle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      height: 50,
      decoration: BoxDecoration(
        color: widget.salle.couleur.withOpacity(0.5),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            //width: double.infinity,
            child: Text(
              widget.salle.nom,
              style: TextStyle(
                fontSize: 23,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            child: Icon(
              widget.salleOrdi,
              color: Colors.grey[800],
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

enum Salles {
  S1106,
  S1109,
  S1110,
  S2124,
  S2127,
  S2129,
  S2234,
  S2235,
  S2236,
  S2237,
  LicensePro,
  Reseau,
  LaboLangue,
  SalleMultimedia,
  Amphi,
  SalleReunion,
}

extension DetailsSalles on Salles {
  static const noms = {
    Salles.S1106: 'Salle 1106',
    Salles.S1109: 'Salle 1109',
    Salles.S1110: 'Salle 1110',
    Salles.S2124: 'Salle 2124',
    Salles.S2127: 'Salle 2127',
    Salles.S2129: 'Salle 2129',
    Salles.S2234: 'Salle 2234',
    Salles.S2235: 'Salle 2235',
    Salles.S2236: 'Salle 2236',
    Salles.S2237: 'Salle 2237',
    Salles.LicensePro: 'License Pro',
    Salles.Reseau: 'Salle Réseau',
    Salles.LaboLangue: 'Labo des Langues',
    Salles.SalleMultimedia: 'Salle Multimédia',
    Salles.Amphi: 'Amphi',
    Salles.SalleReunion: 'Salle de Réunion',
  };

  static const possedeOrdis = {
    Salles.S1106: false,
    Salles.S1109: false,
    Salles.S1110: false,
    Salles.S2124: true,
    Salles.S2127: true,
    Salles.S2129: true,
    Salles.S2234: true,
    Salles.S2235: true,
    Salles.S2236: true,
    Salles.S2237: true,
    Salles.LicensePro: true,
    Salles.Reseau: true,
    Salles.LaboLangue: false,
    Salles.SalleMultimedia: true,
    Salles.Amphi: false,
    Salles.SalleReunion: true,
  };

  static const numUrl = {
    Salles.S1106: "38541",
    Salles.S1109: "37355",
    Salles.S1110: "39548",
    Salles.S2124: "38756",
    Salles.S2127: "39491",
    Salles.S2129: "38113",
    Salles.S2234: "39052",
    Salles.S2235: "37590",
    Salles.S2236: "38484",
    Salles.S2237: "39005",
    Salles.LicensePro: "39568",
    Salles.Reseau: "39568",
    Salles.LaboLangue: "38713",
    Salles.SalleMultimedia: "24132",
    Salles.Amphi: "39294",
    Salles.SalleReunion: "140414",
  };

  String get nom => noms[this];

  bool get ordis => possedeOrdis[this];

  String get url =>
      "http://ade.unicaen.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=" +
      numUrl[this] +
      "&projectId=4&calType=ical&nbWeeks=1";

  Color get couleur => Matiere.couleurString(nom);
}
