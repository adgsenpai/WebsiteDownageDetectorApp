import 'package:flutter/material.dart';

import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/widgets/input.dart';
//widgets
import 'package:material_kit_flutter/widgets/navbar.dart';
import 'package:material_kit_flutter/widgets/table-cell.dart';
import 'package:material_kit_flutter/widgets/drawer.dart';
import 'package:material_kit_flutter/database/db.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _websitename = "";
  String _websiteurl = "";
  Future<List<Website>> _websiteList;
  final _textControllerName = TextEditingController();
  final _textControllerUrl = TextEditingController();

  bool _isURLValid(url) {
    return Uri.parse(url).isAbsolute;
  }

  void clearText() {
    _textControllerName.clear();
    _textControllerUrl.clear();
  }

  void fetchWebsites() {
    setState(() {
      _websiteList = DBServices().websites();
    });
  }

  void readWebsite() {
    DBServices().printWebsites();
  }

  void initState() {
    setState(() {
      _websitename = "";
      _websiteurl = "";
      _websiteList = DBServices().websites();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Navbar(
          title: "Settings",
        ),
        drawer: MaterialDrawer(currentPage: "Settings"),
        backgroundColor: MaterialColors.bgColorScreen,
        body: Container(
            child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("Add or Remove Websites",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18)),
                  ),
                ),
                Input(
                  placeholder: "Enter Website Name",
                  controller: _textControllerName,
                  onChanged: (String value) {
                    setState(() {
                      _websitename = value;
                    });
                  },
                ),
                Input(
                  placeholder: "Enter Website URL",
                  controller: _textControllerUrl,
                  onChanged: (String value) {
                    setState(() {
                      _websiteurl = value;
                    });
                  },
                ),
                ElevatedButton(
                  //set color of text
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    //set color of button
                    backgroundColor: MaterialStateProperty.all<Color>(
                        MaterialColors.primary),
                  ),

                  onPressed: () {
                    if (!_isURLValid(_websiteurl)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid URL'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    if (_websitename != "" && _isURLValid(_websiteurl)) {
                      // get max id
                      DBServices().getMaxId().then((value) {
                        DBServices().insertWebsite(Website(
                            id: value + 1,
                            name: _websitename,
                            url: _websiteurl));
                        //show dialog
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Success"),
                                content: Text("Website Added"),
                                actions: [
                                  TextButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                        // refresh list
                        fetchWebsites();
                        // clear text
                        clearText();
                      });
                    }
                  },
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 12, bottom: 12),
                      child: Text("Add Website",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16.0))),
                ),
                // show websites and delete button in cards
                FutureBuilder(
                  future: _websiteList,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(snapshot.data[index].name,
                                    //set color
                                    style: TextStyle(color: Colors.black)),
                                subtitle: Text(snapshot.data[index].url),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    //show dialog
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Delete"),
                                            content: Text(
                                                "Are you sure you want to delete this website?"),
                                            actions: [
                                              TextButton(
                                                child: Text("Cancel"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text("Delete"),
                                                onPressed: () {
                                                  // delete website
                                                  DBServices().deleteWebsite(
                                                      snapshot.data[index].id);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                ),
                              ),
                            );
                          });
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            ),
          ),
        )));
  }
}
