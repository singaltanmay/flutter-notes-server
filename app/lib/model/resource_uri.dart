import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class ResourceUri {
  static String _normalized(String url) {
    if (url.isEmpty) return "";
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      url = "http://" + url;
    }
    if (!url.endsWith('/')) {
      url = url + '/';
    }
    return url;
  }

  static Future<Uri> getBaseUri() async {
    var prefs = await SharedPreferences.getInstance();
    String? sharedPrefsBaseUrl = prefs.getString(Constants.databaseBaseUrl);
    if (sharedPrefsBaseUrl != null && sharedPrefsBaseUrl.isNotEmpty) {
      return Uri.parse(_normalized(sharedPrefsBaseUrl));
    }
    const String envBaseUrl = String.fromEnvironment('DB_BASE_URL',
        defaultValue: 'http://localhost:3000/');
    prefs.setString(Constants.databaseBaseUrl, envBaseUrl);
    return Uri.parse(_normalized(envBaseUrl));
  }

  static Future<Uri> getAppendedUri(String append) async {
    Uri baseUri = await getBaseUri();
    return Uri.parse(_normalized(baseUri.toString() + append));
  }

  static Future<void> setBaseUri(String uri) async {
    if (uri.isEmpty) return;
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(Constants.databaseBaseUrl, _normalized(uri));
  }

  static Future<bool> isServerHealthy() async {
    var appendedUri = await getAppendedUri('health');
    try {
      var response = await http.get(appendedUri);
      return response.statusCode == 200 &&
          response.body.toLowerCase() == "true";
    } catch(_) {
      return false;
    }
  }

  static Future<String> getBase() async {
    var prefs = await SharedPreferences.getInstance();
    String? sharedPrefsBaseUrl = prefs.getString(Constants.databaseBaseUrl);
    if (sharedPrefsBaseUrl != null && sharedPrefsBaseUrl.isNotEmpty) {
      return _normalized(sharedPrefsBaseUrl);
    }
    String envBaseUrl = const String.fromEnvironment('DB_BASE_URL',
        defaultValue: 'localhost:3000/');
    envBaseUrl = _normalized(envBaseUrl);
    prefs.setString(Constants.databaseBaseUrl, envBaseUrl);
    return envBaseUrl;
  }
}
