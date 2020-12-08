import 'dart:convert';

import 'package:edt_mobile/Calendrier.dart';

import 'objets.dart';

class CalendrierJours extends Calendrier {
  List<Journee> jours;

  CalendrierJours({
    int ressource = 1205,
    int projectId = 4,
    int nbWeeks = 2,
  })  : jours = new List<Journee>(),
        super(ressource: ressource, nbWeeks: nbWeeks);

  @override
  traitement() {
    List<String> coursStr = this.rawCal.split("BEGIN:VEVENT");

    for (String cr in coursStr) {
      if (!cr.contains("DTSTART")) continue;

      creerCours(cr);
    }

    rangerCours();
    creerJours();
  }

  @override
  creerCours(String calEvent) {
    String matiere = "";
    String module = "";
    String prof = "";
    String salle = "";
    String debut = "";
    String fin = "";

    // Répare les lignes qui sont découpées parce qu'elles sont trop longues
    // On les retrouve parce qu'elles commencent par un espace
    calEvent = calEvent.replaceAll(RegExp("(\r\n )"), "");

    for (String prop in LineSplitter.split(calEvent)) {
      if (prop.contains("DTSTART")) {
        debut = prop.split(":")[1];
      } else if (prop.contains("DTEND")) {
        fin = prop.split(":")[1];
      } else if (prop.contains("SUMMARY")) {
        matiere = prop.split(":")[1];
      } else if (prop.contains("LOCATION")) {
        List<String> s = prop.split(":");
        if (s.length > 1) {
          salle = prop.split(":")[1];
        }
      } else if (prop.contains("DESCRIPTION")) {
        List<String> morceaux = prop.split("\\n");
        if (morceaux.length > 4) {
          prof = morceaux[4];
          module = trimModule(morceaux[2]);
        }
      }
    }

    matiere = trimMatiere(matiere);
    prof = verifProf(trimProf(prof));

    cours.add(Cours(
      matiere: Matiere(matiere),
      module: module,
      prof: prof,
      salle: salle,
      debut: Horaire.fromCalendar(debut),
      fin: Horaire.fromCalendar(fin),
    ));
  }

  creerJours() {
    DateTime current;
    List<Cours> coursJours;

    for (Cours c in cours) {
      if (current == null ||
          Calendrier.dateJour(c.debut.date).isAfter(current)) {
        if (current != null) {
          jours.add(Journee(cours: coursJours, date: current));

          Duration dif = Calendrier.dateJour(c.debut.date).difference(current);
          int days = dif.inDays;

          if (days > 1)
            for (int i = 1; i < days; i++) {
              jours.add(Journee(
                  date:
                      DateTime(current.year, current.month, current.day + i)));
            }
        }

        coursJours = List<Cours>();
        coursJours.add(c);
        current = Calendrier.dateJour(c.debut.date);
      } else {
        coursJours.add(c);
      }
    }
  }

  Future<List<Journee>> fetchJours() async {
    await getHtmlCal();
    return jours;
  }

  String trimMatiere(String mat) {
    if (mat.contains(RegExp(r'[_ ]s[0-9][0-9]$')))
      return mat.substring(0, mat.length - 4);
    else
      return mat;
  }

  String trimModule(String str) {
    return str
        .replaceFirst(RegExp(r".*GRP[^ ]* "), '')
        .replaceFirst(RegExp(r":.*"), '')
        .trim();
  }

  String trimProf(String prof) {
    if (prof.contains("Exported"))
      return prof.split("(")[0];
    else
      return prof;
  }

  String verifProf(String prof) {
    if (prof.contains(RegExp(r'^.+ .+$')))
      return prof;
    else
      return '';
  }
}
