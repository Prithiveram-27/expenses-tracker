// ignore_for_file: prefer_const_constructors

import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import './widgets/Chart.dart';
import './widgets/new_transactions.dart';
import './widgets/transaction_list.dart';
import './models/Transactions.dart';
import 'package:flutter/material.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(My_App());
}

class My_App extends StatelessWidget {
  MaterialColor buildMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Personal Expenses",
      home: My_HomePage(),
      theme: ThemeData(
        primarySwatch: buildMaterialColor(Color(0xff051367)),
        accentColor: buildMaterialColor(Color(0xff051367)),
        primaryColor: buildMaterialColor(Color(0xff2D31FA)),
        secondaryHeaderColor: buildMaterialColor(Color(0xff8D8DAA)),
        primaryColorLight: buildMaterialColor(Color(0xffDFDFDE)),
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
            headline6: TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              //color: buildMaterialColor(Color(0xff051367)),
            ),
            button: TextStyle(
              color: Colors.white,
            )),
        appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
      ),
    );
  }
}

class My_HomePage extends StatefulWidget {
  @override
  State<My_HomePage> createState() => _My_HomePageState();
}

class _My_HomePageState extends State<My_HomePage> {
  final List<Transactions> _userTransactions = [
    // Transactions(
    //   id: "t1",
    //   title: "Shoes",
    //   amount: 30.23,
    //   date: DateTime.now(),
    // ),
    // Transactions(
    //   id: "t2",
    //   title: "Shirts",
    //   amount: 60.03,
    //   date: DateTime.now(),
    // ),
  ];

  List<Transactions> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransactions(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transactions(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransactions(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          child: NewTransaction(_addNewTransactions),
          onTap: () {},
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransactions(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  bool _showChart = false;

  @override
  Widget build(BuildContext context) {
    final isLandScape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final Appbar = AppBar(
      title: const Text(
        "Personal Expenses",
      ),
      actions: [
        IconButton(
          onPressed: () => _startAddNewTransactions(context),
          icon: Icon(
            Icons.add,
          ),
        )
      ],
    );
    final txListWidget = Container(
      height: (MediaQuery.of(context).size.height -
              Appbar.preferredSize.height -
              MediaQuery.of(context).padding.top) *
          0.7,
      child: TransactionList(_userTransactions, _deleteTransactions),
    );
    return Scaffold(
      appBar: Appbar,
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isLandScape)
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Text('Show Chart'),
                    ),
                    Switch(
                        value: _showChart,
                        onChanged: (Val) {
                          setState(() {
                            _showChart = Val;
                          });
                        })
                  ],
                ),
              if (!isLandScape)
                Container(
                  height: (MediaQuery.of(context).size.height -
                          Appbar.preferredSize.height -
                          MediaQuery.of(context).padding.top) *
                      0.3,
                  child: Chart(_recentTransactions),
                ),
              if (!isLandScape) txListWidget,
              if (isLandScape)
                _showChart
                    ? Container(
                        height: (MediaQuery.of(context).size.height -
                                Appbar.preferredSize.height -
                                MediaQuery.of(context).padding.top) *
                            0.6,
                        child: Chart(_recentTransactions),
                      )
                    : txListWidget
            ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewTransactions(context),
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
