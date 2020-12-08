import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

class Horaire {
  DateTime date;
  int heures;
  int minutes;

  Horaire(this.heures, this.minutes, {this.date}) {
    if (minutes < 0 || minutes >= 60) {
      heures = heures + (minutes / 60).floor();
      minutes = minutes % 60;
    }

    if (date == null) {
      DateTime now = DateTime.now();
      date = DateTime(now.year, now.month, now.day);
      date = date.add(Duration(hours: heures, minutes: minutes));
    }
  }

  int get totalMinutes => heures * 60 + minutes;

  double get totalHeures => heures + (minutes / 60.0);

  String get heureStr {
    return toStr2Dig(heures) + ':' + toStr2Dig(minutes);
  }

  String get heureSoloStr {
    return toStr2Dig(heures);
  }

  static String toStr2Dig(int n) {
    if (n < 10)
      return '0' + n.toString();
    else
      return n.toString();
  }

  @override
  String toString() {
    if (heures == null && minutes == null)
      return "NC";
    else
      return heureStr;
  }

  @override
  bool operator ==(Object other) {
    return other is Horaire &&
        other.heures == heures &&
        other.minutes == minutes;
  }

  static Horaire fromCalendar(String debut) {
    return Horaire.fromDate(DateTime.parse(debut).toLocal());
  }

  static Horaire fromDate(DateTime date) {
    return Horaire(date.hour, date.minute, date: date);
  }
}

class Journee {
  DateTime date;

  List<HeureCours> cours;

  Journee({List<HeureCours> cours, this.date}) {
    if (cours != null) {
      ajouterCours(cours);

      if (date == null) {
        date = cours[0].debut.date;
      }
    }
  }

  ajouterCours(List<HeureCours> cours) {
    this.cours = new List<HeureCours>();

    Cours last;

    for (HeureCours c in cours) {
      if (c is Cours) {
        if (last != null) {
          Duration dif = c.debut.date.difference(last.fin.date);
          if (dif.inMinutes > 15) {
            this.cours.add(Pause(last.fin, c.debut));
          }
        }

        last = c;
      } else {
        last = null;
      }

      this.cours.add(c);
    }
  }
}

class Matiere {
  static int randomMult = 2;

  final String nom;

  Matiere(this.nom);

  Color couleur() {
    return couleurString(nom);
  }

  /// Retourne une couleur propre à cette matière, générée à partir
  /// de son nom
  static Color couleurString(String nom) {
    String nomOnlyAscii = nom.replaceAll(RegExp(r"[^\s\w]"), '');
    int nomInt = 0;

    for (int n in AsciiCodec().encode(nomOnlyAscii)) {
      nomInt += n;
    }

    double randHue = Random(nomInt * randomMult).nextDouble() * 360;

    return HSVColor.fromAHSV(1, randHue, 0.65, 1.0).toColor();
  }

  //quand le nom de la matiere est trop long
  String shortVersion({int longueur = 25}) {
    return shortString(this.nom, longueur: longueur);
  }

  @override
  String toString() {
    return nom;
  }
}

String shortString(String str, {int longueur = 25}) {
  if (str.length <= longueur)
    return str;
  else
    return str.substring(0, longueur - 2) + "...";
}

abstract class HeureCours {
  final Horaire debut;
  final Horaire fin;

  HeureCours(this.debut, this.fin);

  double get duree => (fin.totalHeures - debut.totalHeures).abs();

  String get horaireString {
    return debut.heureStr + ' - ' + fin.heureStr;
  }
}

class Cours extends HeureCours {
  final Matiere matiere;
  final String module;
  final String prof;
  final String salle;

  Cours(
      {this.matiere,
      this.module,
      this.prof,
      this.salle,
      Horaire debut,
      Horaire fin})
      : super(debut, fin);

  @override
  String toString() {
    return "Cours de $matiere ($module) avec $prof en $salle de $debut à $fin";
  }
}

class Pause extends HeureCours {
  Pause(Horaire debut, Horaire fin) : super(debut, fin);
}
