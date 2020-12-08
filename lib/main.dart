import 'package:edt_mobile/pageOption/Compte.dart';
import 'package:edt_mobile/pageOption/Notification.dart';
import 'package:edt_mobile/pageOption/theme.dart';
import 'package:flutter/material.dart';

import 'package:flutter/scheduler.dart';
import 'CalendrierJours.dart';
import 'pageEdt.dart';
import 'pageMails/pageMails.dart';
import 'pageSalles.dart';
import 'pageControle/pageControles.dart';
import 'pageOption/pageOptions.dart';
import 'package:theme_provider/theme_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Compte().recupererCompte();
    Notifications().notifier();
    return ThemeProvider(
      saveThemesOnChange: true,
      loadThemeOnInit: false,
      onInitCallback: (controller, previouslySavedThemeFuture) async {
        String savedTheme = await previouslySavedThemeFuture;
        ThemeApp().initTheme(savedTheme);
        if (savedTheme != null) {
          controller.setTheme(savedTheme);
        } else {
          Brightness platformBrightness = SchedulerBinding.instance.window.platformBrightness;
          if (platformBrightness == Brightness.dark) {
            controller.setTheme('dark');
          } else {
            controller.setTheme('light');
          }
          controller.forgetSavedTheme();
        }
      },
      themes: <AppTheme>[
        AppTheme(id: 'light', data: ThemeApp().tClair, description: "Un thème clair"),
        AppTheme(id: 'dark', data: ThemeApp().tSombre, description: "Un thème sombre"),
      ],
      child: ThemeConsumer(
        child: Builder(
          builder: (themeContext) => MaterialApp(
            theme: ThemeProvider.themeOf(themeContext).data,
            title: 'Material App',
            home: PagePrincipale(),
          ),
        ),
      ),
    );
  }
}

class PagePrincipale extends StatefulWidget {
  PagePrincipale({Key key}) : super(key: key);

  static CalendrierJours calendrier;

  @override
  _PagePrincipaleState createState() => _PagePrincipaleState();
}

class _PagePrincipaleState extends State<PagePrincipale> {
  // Page actuelle
  int _selectedIndex = 0;

  final controller = PageController(
    initialPage: 0,
  );

  // Liste pages
  // Dans l'ordre, de gauche à droite
  static List<Widget> _widgetOptions = <Widget>[
    PageEDT(),
    PageMails(),
    PageSalles(),
    PageControles(),
    PageOptions(),
  ];

  void _changePageIndex(int index) {
    _selectedIndex = index;
  }

  // Changement de page
  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex == 0 && index == 0) {
        (_widgetOptions[0] as PageEDT).premierePage();
      }

      _changePageIndex(index);
      controller.animateToPage(
        index,
        curve: Curves.ease,
        duration: Duration(milliseconds: 300),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PageView(
          controller: controller,
          children: _widgetOptions,
          onPageChanged: (page) {
            setState(() {
              _changePageIndex(page);
            });
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ThemeProvider.themeOf(context).data.bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1.75,
              blurRadius: 11,
            ),
          ],
        ),
        child: BottomNavigationBar(
          selectedFontSize: 0,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.calendar_today,
              ),
              activeIcon: Icon(
                Icons.calendar_today,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.mail_outline,
              ),
              activeIcon: Icon(
                Icons.mail_outline,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.desktop_windows),
              activeIcon: Icon(
                Icons.desktop_windows,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              activeIcon: Icon(Icons.assignment),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              activeIcon: Icon(Icons.more_horiz),
              label: "",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: ThemeProvider.themeOf(context).data.bottomNavigationBarTheme.backgroundColor,
          iconSize: 30,
        ),
      ),
    );
  }
}
