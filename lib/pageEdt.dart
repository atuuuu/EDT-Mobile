import 'dart:math';

import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

import 'main.dart';
import 'Calendrier.dart';
import 'CalendrierJours.dart';
import 'objets.dart';

class PageEDT extends StatefulWidget {
  @override
  _PageEDTState createState() => _PageEDTState();

  static const int tailleHeure = 107;
  static const double opaciteCours = 0.45;
  static const int matiereLongMax = 30;
  static const int salleLongMax = 23;

  static final Horaire premiereHeure = Horaire(8, 0);

  static CalendrierJours get calendrier {
    return PagePrincipale.calendrier;
  }

  static set calendrier(CalendrierJours cal) {
    PagePrincipale.calendrier = cal;
  }

  static List<JourneeUI> joursScrolls;
  static PageView joursView;

  static initCal() {
    PageEDT.calendrier = CalendrierJours(
      nbWeeks: 8,
    );
  }

  final PageController controller = PageController(
    initialPage: 0,
  );

  premierePage() {
    try {
      controller.animateToPage(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } catch (e) {}
  }
}

class _PageEDTState extends State<PageEDT>
    with AutomaticKeepAliveClientMixin<PageEDT> {
  Widget _pageWidget;

  @override
  void initState() {
    super.initState();

    if (PageEDT.calendrier == null) {
      _pageWidget = LoadingEdt();

      PageEDT.initCal();

      setJournees();
    } else {
      _pageWidget = PageEDT.joursView;
    }
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      switchInCurve: Curves.ease,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(child: child, opacity: animation);
      },
      child: _pageWidget,
    );
  }

  setJournees() async {
    PageEDT.joursScrolls = List<JourneeUI>();

    for (Journee j in await PageEDT.calendrier.fetchJours()) {
      PageEDT.joursScrolls.add(
        JourneeUI(
          journee: j,
        ),
      );
    }

    setState(() {
      _pageWidget = PageView(
        children: PageEDT.joursScrolls,
        controller: widget.controller,
      );

      PageEDT.joursView = _pageWidget;
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class JourneeUI extends StatefulWidget {
  final Journee journee;

  const JourneeUI({Key key, this.journee}) : super(key: key);

  @override
  _JourneeUIState createState() => _JourneeUIState();
}

class _JourneeUIState extends State<JourneeUI> {
  List<Widget> _coursUi;

  String _nomJour;
  double dodoBonus = 0;
  double dodoMargin = 0;

  _JourneeUIState() {
    _coursUi = List<Widget>();
  }

  @override
  void initState() {
    super.initState();

    if (widget.journee.cours != null && widget.journee.cours.length > 0) {
      for (HeureCours cours in widget.journee.cours) {
        if (cours is Cours) {
          _coursUi.add(CoursUI(
            cours: cours,
          ));
        } else if (cours is Pause) {
          _coursUi.add(PauseUI(cours));
        }
      }

      dodoBonus = widget.journee.cours[0].debut.totalHeures -
          PageEDT.premiereHeure.totalHeures;
      dodoMargin = max(dodoBonus * PageEDT.tailleHeure, 0);
    } else {
      _coursUi.add(PasCours());
    }

    String jour = Calendrier.jourSemaine(widget.journee.date);
    int numJour = widget.journee.date.day;
    String mois = Calendrier.mois(widget.journee.date);

    _nomJour = jour + " " + numJour.toString() + " " + mois;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _nomJour,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w400,
            color: ThemeProvider.themeOf(context).data.textTheme.headline1.color,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: ThemeProvider.themeOf(context).data.scaffoldBackgroundColor,
        elevation: 0.0,
        toolbarHeight: 70.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(bottom: 15),
          child: Container(
            margin: EdgeInsets.only(top: 5 + dodoMargin),
            child: Column(
              children: _coursUi,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ),
        ),
      ),
    );
  }
}

class CoursUI extends StatefulWidget {
  @override
  _CoursUIState createState() => _CoursUIState();

  CoursUI({
    Key key,
    this.cours,
  }) : super(key: key);

  final Cours cours;
}

class _CoursUIState extends State<CoursUI> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
        top: 5,
        right: 15,
        bottom: 5,
      ),
      padding: EdgeInsets.only(left: 14, top: 10, right: 14, bottom: 10),
      height: widget.cours.duree * PageEDT.tailleHeure,
      decoration: BoxDecoration(
        color: widget.cours.matiere.couleur().withOpacity(PageEDT.opaciteCours),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Text(
                    widget.cours.matiere.shortVersion(
                      longueur:
                          (PageEDT.matiereLongMax * widget.cours.duree).ceil(),
                    ),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 19,
                      color: ThemeProvider.themeOf(context).data.textTheme.headline4.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 3),
                  width: double.infinity,
                  child: Text(
                    shortString(
                      widget.cours.module,
                      longueur:
                          (PageEDT.salleLongMax * widget.cours.duree).floor(),
                    ),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      color: ThemeProvider.themeOf(context).data.textTheme.headline5.color,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 3),
                  width: double.infinity,
                  child: Text(
                    shortString(
                      widget.cours.salle,
                      longueur:
                          (PageEDT.salleLongMax * widget.cours.duree).floor(),
                    ),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      color: ThemeProvider.themeOf(context).data.textTheme.headline5.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 4),
                  width: double.infinity,
                  child: Text(
                    widget.cours.prof,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.textTheme.headline5.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 0),
                  width: double.infinity,
                  child: Text(
                    widget.cours.horaireString,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.textTheme.headline5.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PauseUI extends StatefulWidget {
  @override
  _PauseUIState createState() => _PauseUIState();

  final Pause pause;

  PauseUI(this.pause);
}

class _PauseUIState extends State<PauseUI> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.pause.debut.heureStr, style: ThemeProvider.themeOf(context).data.textTheme.headline6),
        Container(
          margin: EdgeInsets.all(10),
          height: (0.5 + widget.pause.duree) * PageEDT.tailleHeure * 0.5,
          child: PauseLigne(
            width: 3,
            dashLength: 9.0,
            color: ThemeProvider.themeOf(context).data.textTheme.headline6.color,
          ),
        ),
        Text(widget.pause.fin.heureStr, style: ThemeProvider.themeOf(context).data.textTheme.headline6),
      ],
    );
  }
}

class PauseLigne extends StatelessWidget {
  final double width;
  final double dashLength;
  final Color color;

  const PauseLigne(
      {this.width = 1, this.dashLength = 10.0, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxHeight = constraints.constrainHeight();
        final dashHeight = dashLength;
        final dashWidth = width;
        final dashCount = (boxHeight / (1.75 * dashHeight)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
        );
      },
    );
  }
}

class LoadingEdt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

class PasCours extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 150),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Icon(
                Icons.notifications_off,
                size: 60,
                color: Colors.grey[600],
              ),
            ),
            Text(
              "Repos !",
              style: TextStyle(fontSize: 18),
            )
          ],
        ));
  }
}
