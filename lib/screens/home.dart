import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
//widgets
import 'package:material_kit_flutter/widgets/navbar.dart';
import 'package:material_kit_flutter/widgets/card-horizontal.dart';
import 'package:material_kit_flutter/widgets/card-small.dart';
import 'package:material_kit_flutter/widgets/card-square.dart';
import 'package:material_kit_flutter/widgets/drawer.dart';
import 'package:material_kit_flutter/database/db.dart';
import 'package:material_kit_flutter/networking/network.dart';
import 'dart:async';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Website>> _websiteList;

  void fetchWebsites() {
    setState(() {
      _websiteList = DBServices().websites();
    });
  }

  Future<String> getValidUrl(url) async {
    final websiteChecking = WebsiteChecking();
    final URI = Uri.parse(url);
    final response = await websiteChecking.isValidLink(URI);
    print(response);
    return Future.delayed(Duration(seconds: 1), () => response);
  }

  Future<String> getScreenShot(url) async {
    final websiteChecking = WebsiteChecking();
    final screenshot = await websiteChecking.getScreenShot(url);
    print(screenshot);
    return Future.delayed(Duration(seconds: 1), () => screenshot);
  }

  void initState() {
    setState(() {
      _websiteList = DBServices().websites();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Navbar(
          title: "Home",
        ),
        drawer: MaterialDrawer(currentPage: "Home"),
        backgroundColor: MaterialColors.bgColorScreen,
        body: Container(
            child: SingleChildScrollView(
                child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Text(
                "Your Websites",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: MaterialColors.caption),
              ),
            ),
            FutureBuilder(
                future: _websiteList,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return CardHorizontal(
                              cta: getScreenShot(snapshot.data[index].url)
                                  .toString(),
                              title: snapshot.data[index].name,
                              img: getScreenShot(snapshot.data[index].url)
                                  .toString());
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
          ],
        ))));
  }
}
