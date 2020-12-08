import 'package:http/http.dart' as http;

import 'objets.dart';

abstract class Calendrier {
  final int ressource;
  final int nbWeeks;

  int projectId = 4; // 3

  String url;
  String rawCal;
  List<Cours> cours;

  Calendrier({
    this.ressource = 1205,
    this.nbWeeks = 2,
  }) {
    this.url =
        "http://ade.unicaen.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=$ressource&projectId=$projectId&calType=ical&nbWeeks=$nbWeeks";
    cours = new List<Cours>();
  }

  traitement();

  creerCours(String calEvent);

  getHtmlCal() async {
    this.rawCal = await http.read(url);
    traitement();
  }

  rangerCours() {
    cours.sort((a, b) => a.debut.date.compareTo(b.debut.date));
  }

  static jourSemaine(DateTime date) {
    const jours = [
      "Lundi",
      "Mardi",
      "Mercredi",
      "Jeudi",
      "Vendredi",
      "Samedi",
      "Dimanche",
    ];

    return jours[date.weekday - 1];
  }

  static mois(DateTime date) {
    const jours = [
      "Janvier",
      "Février",
      "Mars",
      "Avril",
      "Mai",
      "Juin",
      "Juillet",
      "Août",
      "Septembre",
      "Octobre",
      "Novembre",
      "Décembre",
    ];

    return jours[date.month - 1];
  }

  static DateTime dateJour(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
