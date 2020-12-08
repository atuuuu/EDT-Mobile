import 'dart:convert';
import 'package:edt_mobile/pageOption/Compte.dart';
import 'package:imap_client/imap_client.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class JourneeMail {
  DateTime date;
  List<Mail> mails;

  JourneeMail(DateTime date) {
    this.date = date;
    mails = new List();
  }

  void addMail(Mail mail) {
    this.mails.add(mail);
  }

  List<Mail> getDailyMail() {
    return this.mails;
  }

  String getDate() {
    DateTime today = new DateTime.now();
    int difference = today.day - date.day;
    switch (difference) {
      case 0:
        return "Aujourd'hui";
        break;
      case 1:
        return "Hier";
      default:
        return date.day.toString() +
            "/" +
            date.month.toString() +
            "/" +
            date.year.toString();
    }
  }
}

class Mail {
  int id;
  String nomFrom;
  String emailFrom;
  String objet;
  DateTime date;
  bool pj;
  List flags;
  String html;

  Mail(this.id, String from, String objet, this.date, this.pj, this.flags,
      this.html) {
    setNom(from);
    setEmailFrom(from);
    if (objet.length == 0) objet = "<Sans Objet>";
    this.objet = objet;
  }

  String getText() {
    return this.html;
  }

  bool hasPJ() {
    return this.pj;
  }

  bool isSeen() {
    if (flags.contains("\\Seen")) {
      return true;
    }
    return false;
  }

  void setNom(String from) {
    if (from.contains("<") && from.indexOf("<") != 1) {
      nomFrom = from.split("<")[0];
    } else {
      nomFrom = from;
    }
  }

  void setEmailFrom(String from) {
    if (from.contains("<") && from.indexOf("<") != 1) {
      emailFrom = from.split("<")[1];
      emailFrom = '<' + emailFrom;
    } else {
      emailFrom = from;
    }
  }

  String getNomFrom() {
    return nomFrom;
  }

  String getEmailFrom() {
    return emailFrom;
  }

  String getObjet() {
    return objet;
  }

  String getDate() {
    return date.year.toString() +
        "-" +
        date.month.toString() +
        "-" +
        date.day.toString();
  }

  String getTime() {
    String time = date.hour.toString() + "H";

    if (date.minute.toString().length == 1) time += "0";
    time += date.minute.toString() + "m" + date.second.toString();
    return time;
  }

  String getDatetime() {
    String month = getMonthName().substring(0, 3);
    month = month.replaceRange(0, 1, month.substring(0, 1).toUpperCase());
    return date.day.toString() +
        ' ' +
        month +
        ' ' +
        date.year.toString() +
        '\n' +
        getTime();
  }

  String getMonthName() {
    switch (this.date.month) {
      case 1:
        return "janvier";
      case 2:
        return "fevrier";
      case 3:
        return "avril";
      case 4:
        return "mars";
      case 5:
        return "mai";
      case 6:
        return "juin";
      case 7:
        return "juillet";
      case 8:
        return "aout";
      case 9:
        return "septembre";
      case 10:
        return "octobre";
      case 11:
        return "novembre";
      case 12:
        return "decembre";
    }
  }

  void aff() {
    print(nomFrom);
    print(objet);
    print(date.toString());
    print("-----------------------------------");
  }
}

class MailClient {
  static MailClient client;

  String username = Compte().username;
  String password = Compte().password;

  ImapClient imapClient;
  String imapHost = "imap.unicaen.fr";
  int imapPort = 993;

  SmtpServer smtpClient;
  String smtpHost = "smtp.unicaen.fr";
  int smtpPort = 465;

  MailClient._() {
    this.imapClient = new ImapClient();
    this.smtpClient = new SmtpServer(smtpHost,
        port: smtpPort, ssl: true, username: username, password: password);
  }

  static MailClient getMailClient() {
    if (client != null) {
      return client;
    } else {
      return MailClient._();
    }
  }

  Future<bool> connect() async {
    await imapClient.connect(imapHost, imapPort, true);
    ImapTaggedResponse response = await imapClient.login(username, password);
    if (!getError(response))
      throw new ErrorDescription("Echec Connexion");
    else
      return true;
  }

  Future<void> sendMail(
      String to, List<String> cc, String objet, String text) async {
    Message msg = Message()
      ..from = username + '@etu.unicaen.fr'
      ..recipients.add(to)
      ..ccRecipients.addAll(cc)
      ..subject = objet
      ..text = text;

    try {
      final sendReport = await send(msg, smtpClient);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Future<List> getFolderList() async {
    List<ImapListResponse> folder = await imapClient.list('*');

    return folder;
  }

  ImapClient getClient() {
    return this.imapClient;
  }

  String quoPriToUtf(String txt, String mode) {
    txt = txt.replaceAll("=?UTF-8?Q?", "");
    txt = txt.replaceAll("=?ISO-8859-1?Q?", "");
    txt = txt.replaceAll("=?UTF-8?B?", "");
    txt = txt.replaceAll("=?utf-8?B?", "");
    txt = txt.replaceAll("=?utf-8?Q?", "");

    while (txt.contains("?=")) {
      int index = txt.indexOf('?=');
      if (index + 2 < txt.length) {
        txt = txt.replaceRange(index, index + 5, '');
      } else {
        txt = txt.replaceAll("?=", "");
      }
    }

    if (txt.contains("_")) {
      txt = txt.replaceAll("_", " ");
    }

    if (mode == "B") {
      List liste = txt.split(" ");
      List b64;
      txt = "";
      liste.forEach((element) {
        if (element.contains("<")) {
          element = element.split("<")[0];
        }
        element = element.trim();
        b64 = base64.decode(element);

        for (int i = 0; i < b64.length; i++) {
          if (b64[i] == 195) {
            txt += utf8.decode([b64[i], b64[i + 1]]);
            i++;
          } else
            txt += String.fromCharCode(b64[i]);
        }
      });
    } else if (txt != null && mode == 'Q') {
      int partCount = 0;
      while (txt.contains('=')) {
        int index = txt.indexOf('=');
        //Remplace les = suivi de \n ou \r
        if (txt.codeUnits[index + 1] == 13 || txt.codeUnits[index + 1] == 10) {
          txt = txt.replaceRange(index, index + 3, '');
          //Skip le cas =C3=\n
        } else if (index + 4 < txt.length &&
            txt.codeUnits[index + 4] == 13 &&
            txt[index + 3] == '=') {
          txt = txt.replaceRange(index + 3, index + 4, '');

          //skip le mauvais decoupage d'un mail content-type ect
        } else if (index - 2 > 0 &&
            txt.codeUnitAt(index - 1) == 45 &&
            txt.codeUnitAt(index - 2) == 45) {
          if (partCount != 1) {
            List a = txt.split('\n');
            a.removeRange(0, 3);
            txt = a.join('\n');
            partCount++;
          } else {
            txt = txt.substring(0, index - 1);
          }

          // gere =C3=A0
        } else if (index + 3 < txt.length && txt[index + 3] == '=') {
          String one = txt[index + 1] + txt[index + 2];
          String two = txt[index + 4] + txt[index + 5];

          int hexOne = hex.decode(one).first;
          int hexTwo = hex.decode(two).first;
          txt = txt.replaceAll(
              "=" + one + "=" + two, utf8.decode([hexOne, hexTwo]));
          //gere
        } else if (txt[index + 1] + txt[index + 2] == "C3" &&
            txt.codeUnits[index + 3] == 13) {
          String one = txt[index + 1] + txt[index + 2];
          String two = txt[index + 6] + txt[index + 7];

          int hexOne = hex.decode(one).first;
          int hexTwo = hex.decode(two).first;
          txt = txt.replaceAll(
              "=" + one + "\r\n=" + two, utf8.decode([hexOne, hexTwo]));
          //gere =A9
        } else {
          String one = txt[index + 1] + txt[index + 2];

          if (one == '0m') {
            txt = txt.replaceAll("=0A", '');
            continue;
          }
          try {
            int hexOne = hex.decode(one).first;
            txt = txt.replaceAll("=" + one, String.fromCharCode(hexOne));
          } catch (Error) {
            txt = txt.replaceRange(index, index + 1, '');
          }
        }
      }
    }

    return txt;
  }

  String convertDate(String mois) {
    switch (mois) {
      case "Jan":
        return '01';
      case "Feb":
        return '02';
      case "Mar":
        return "03";
      case "Apr":
        return "04";
      case "May":
        return "05";
      case "Jun":
        return "06";
      case "Jul":
        return "07";
      case "Aug":
        return "08";
      case "Sep":
        return "09";
      case "Oct":
        return "10";
      case "Nov":
        return "11";
      case "Dec":
        return "12";
    }
  }

  String formateString(String res) {
    if (res.contains("'")) {
      res = res.replaceAll("'", "");
    }
    if (res.contains('"')) {
      res = res.replaceAll('"', '');
    }
    res = res.trim();

    if (res.contains("=?utf-8?Q?") ||
        res.contains("=?UTF-8?Q?") ||
        res.contains("=?ISO-8859-1?Q?")) {
      res = quoPriToUtf(res, 'Q');
    } else if (res.contains("=?UTF-8?B?") || res.contains("=?utf-8?B?")) {
      res = quoPriToUtf(res, 'B');
    }

    return res;
  }

  Future<String> getFrom(ImapFolder folder, int number) async {
    String res;
    List liste = new List();
    Map<int, Map<String, dynamic>> from = await folder
        .fetch(["BODY.PEEK[HEADER.FIELDS (FROM)]"], messageIds: [number]);
    res = from.values.last.values.last;
    if (res.split(":")[0] == null) {
      print(res);
    }
    liste = res.split(":");
    liste.removeAt(0);
    res = liste.join(":");
    res = formateString(res);
    return res;
  }

  Future<String> getObjet(ImapFolder folder, int number) async {
    String res;
    List liste = new List();
    Map<int, Map<String, dynamic>> objet = await folder
        .fetch(["BODY.PEEK[HEADER.FIELDS (SUBJECT)]"], messageIds: [number]);
    res = objet.values.last.values.last;
    liste = res.split(":");
    liste.removeAt(0);
    res = liste.join(":");
    res = formateString(res);

    return res;
  }

  Future<DateTime> getDate(ImapFolder folder, int number) async {
    String res, tmp;
    List<String> liste = new List();
    Map<int, Map<String, dynamic>> date =
        await folder.fetch(["INTERNALDATE"], messageIds: [number]);
    res = date.values.last.values.last;

    liste = res.split('-');
    liste[1] = convertDate(liste[1]);
    tmp = liste[0];
    liste[0] = liste[2].substring(0, 4);
    liste[2] = tmp + liste[2].substring(4);

    res = liste.join("-");
    res = res.substring(0, res.length - 6);

    DateTime time = DateTime.parse(res);
    return time;
  }

  Future<bool> hasPJ(ImapFolder folder, int number) async {
    Map<int, Map<String, dynamic>> pj =
        await folder.fetch(["BODYSTRUCTURE"], messageIds: [number]);

    Map<String, dynamic> bodystruct = pj.values.last.values.last;
    while (bodystruct.values.first[1] is! String)
      bodystruct = bodystruct.values.first[1];

    String res;
    if (bodystruct.values.first is String)
      res = bodystruct.values.first;
    else {
      res = bodystruct.values.first[1].values.first;
    }

    if (res == "TEXT")
      return false;
    else
      return true;
  }

  Future<List> getFlags(ImapFolder folder, int number) async {
    Map<int, Map<String, dynamic>> flags =
        await folder.fetch(["FLAGS"], messageIds: [number]);
    return (flags.values.last.values.last);
  }

  Future<String> getText(ImapFolder folder, int number) async {
    String out;
    var res;
    Map<int, Map<String, dynamic>> txt =
        await folder.fetch(["BODY[1]"], messageIds: [number]);

    Map<int, Map<String, dynamic>> html =
        await folder.fetch(["BODY[2]"], messageIds: [number]);

    if (html.values.last.values.last != null &&
        (html.values.last.values.last.contains('<html>') ||
            html.values.last.values.last.contains('<p>'))) {
      res = html.values.last.values.last;

      res = quoPriHtml(res);
    } else {
      res = txt.values.last.values.last;
      if (res is String) res = quoPriToUtf(res, 'Q');
    }

    if (res == null) {
      out = "";
    } else if (res is! String) {
      out = res[0];
    } else {
      out = res;
    }
    // out = quoPriToUtf(out, 'Q');
    // convertB64(res);

    return out;
  }

  String quoPriHtml(String txt) {
    List<String> liste = txt.split('<html>');
    liste.removeAt(0);
    txt = liste.join('<html>');
    liste = txt.split('>');
    for (int i = 0; i < liste.length; i++) {
      List<String> content = liste[i].split('<');
      content[0] = quoPriToUtf(content[0], 'Q');
      liste[i] = content.join('<');
    }
    return liste.join('>');
  }

  void convertB64(String txt) {
    print(txt);
  }

  Future<List<JourneeMail>> getMail(String folderName) async {
    ImapFolder folder = await imapClient.getFolder(folderName);
    int size = folder.mailCount;
    List<JourneeMail> liste = new List();
    DateTime lastDate;

    if (size > 0) {
      for (int i = size; i > size - 1; i--) {
        int mailNumber = i;
        String from, objet, html;
        DateTime date;
        bool pj;
        Mail mail;
        List flags = new List();
        JourneeMail journee;

        flags = await getFlags(folder, i);
        pj = await hasPJ(folder, i);
        from = await getFrom(folder, i);
        objet = await getObjet(folder, i);
        date = await getDate(folder, i);
        html = await getText(folder, i);

        mail = new Mail(mailNumber, from, objet, date, pj, flags, html);

        if (lastDate == null) {
          lastDate = date;
          journee = new JourneeMail(lastDate);
          journee.addMail(mail);
          liste.add(journee);
        } else if (lastDate.year != date.year ||
            lastDate.month != date.month ||
            lastDate.day != date.day) {
          journee = new JourneeMail(date);
          journee.addMail(mail);
          liste.add(journee);
        } else {
          journee = liste.last;
          journee.addMail(mail);
        }
        lastDate = date;
      }
    }
    return liste;
  }

  bool getError(ImapTaggedResponse response) {
    switch (response) {
      case ImapTaggedResponse.ok:
        print('ok');
        return true;
        break;
      case ImapTaggedResponse.no:
        print('echec');
        return false;
        break;
      case ImapTaggedResponse.bad:
        print('command not accepted');
        return false;
        break;
      default:
        return false;
    }
  }

  void debug(String txt) {
    if (txt == null) print("null");
  }
}
