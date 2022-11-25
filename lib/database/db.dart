import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:material_kit_flutter/networking/network.dart';

class DBServices {
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join('lib', 'database', 'db.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        "CREATE TABLE websites(id INTEGER PRIMARY KEY, name TEXT, url TEXT, screenshot TEXT, status TEXT)",
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  Future insertWebsite(Website website) async {
    // Get a reference to the database.
    final Database db = await database;
    // Insert the Website into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same website is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'websites',
      website.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future updateWebsite(Website website) async {
    // Get a reference to the database.
    final db = await database;
    // Update the given Website.
    await db.update(
      'websites',
      website.toMap(),
      // Ensure that the Website has a matching id.
      where: "id = ?",
      // Pass the Website's id as a whereArg to prevent SQL injection.
      whereArgs: [website.id],
    );
  }

  Future deleteWebsite(int id) async {
    // Get a reference to the database.
    final db = await database;
    // Remove the Website from the database.
    await db.delete(
      'websites',
      // Use a `where` clause to delete a specific website.
      where: "id = ?",
      // Pass the Website's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  //print  all websites
  void printWebsites() async {
    websites().then((value) => print(value));
  }

  //View all websites
  Future<List<Website>> websites() async {
    // Get a reference to the database.
    updateWebsiteStatus();

    final Database db = await database;
    // Query the table for all The Websites.
    final List<Map<String, dynamic>> maps = await db.query('websites');

    //update status

    //using the Website class toMap() method get also status and screenshot
    return List.generate(maps.length, (i) {
      return Website(
        id: maps[i]['id'],
        name: maps[i]['name'],
        url: maps[i]['url'],
        screenshot: maps[i]['screenshot'],
        status: maps[i]['status'],
      );
    });
  }

  Future<String> getValidUrl(url) async {
    final websiteChecking = WebsiteChecking();
    final URI = Uri.parse(url);
    final response = await websiteChecking.isValidLink(URI);
    return response;
  }

  Future<String> getScreenShot(url) async {
    final websiteChecking = WebsiteChecking();
    final screenshot = await websiteChecking.getScreenShot(url);
    return screenshot;
  }

  void updateWebsiteStatus() async {
    // update website status and screenshot by id
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('websites');
    for (var i = 0; i < maps.length; i++) {
      final id = maps[i]['id'];
      final url = maps[i]['url'];
      final status = await getValidUrl(url);
      final screenshot = await getScreenShot(url);
      await db.rawUpdate(
          'UPDATE websites SET status = ?, screenshot = ? WHERE id = ?',
          [status, screenshot, id]);
    }
    print('Updated All Websites Status');
  }

  //get max id
  Future<int> getMaxId() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('websites');
    return maps.length;
  }

  //get all website urls
  Future<List<String>> getUrls() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('websites');
    List<String> urls = [];
    for (var i = 0; i < maps.length; i++) {
      urls.add(maps[i]['url']);
    }
    return urls;
  }
}

class Website {
  int id;
  String name;
  String url;
  String status;
  String screenshot;

  Website({this.id, this.name, this.url, this.status, this.screenshot});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'status': status,
      'screenshot': screenshot,
    };
  }

  // Implement toString to make it easier to see information about
  // each website when using the print statement.
  @override
  String toString() {
    return 'Website{id: $id, name: $name, url: $url, status: $status, screenshot: $screenshot}';
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DBServices().websites().then((value) => print(value));
}
