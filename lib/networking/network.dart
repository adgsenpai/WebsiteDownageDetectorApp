import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class WebsiteChecking {
  Future<String> getScreenShot(url) async {
    String requestURL =
        "https://shot.screenshotapi.net/screenshot?token=PBR2KPW-NMK42W1-MY1YPCR-J1YW1R4&url=" +
            Uri.encodeComponent(url) +
            "&fresh=true&output=json&file_type=png&wait_for_event=load";
    try {
      var response = await http.get(Uri.parse(requestURL));
      var json = jsonDecode(response.body);
      return Uri.parse(json["screenshot"]).toString();
    } catch (e) {
      return "https://cdn-icons-png.flaticon.com/128/159/159469.png";
    }
  }

  Future<String> isValidLink(Uri url) async {
    try {
      http.Response _response = await http.head(url);
      if (_response.statusCode == 404) {
        return "Website is down";
      } else if (_response.statusCode == 200) {
        return "Website is up";
      } else {
        return "Unknown";
      }
    } catch (e) {
      return "Website is down";
    }
  }

  void main() async {
    var websiteChecking = WebsiteChecking();
    var url = Uri.parse("https://www.google.com");
    var response = await websiteChecking.isValidLink(url);
    print(response);
    var screenshot =
        await websiteChecking.getScreenShot("https://www.google.com");
    print(screenshot);
  }
}
