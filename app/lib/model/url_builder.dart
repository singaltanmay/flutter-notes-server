import 'package:app/model/resource_uri.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class UrlBuilder {

  var currentQueryChar = "?";
  var currentQuery = "";
  var currentAppend = "";


  UrlBuilder append(String append) {
    currentAppend = currentAppend + append + "/";
    return this;
  }

  UrlBuilder query(String query, String value) {
    if(currentQuery.isNotEmpty){
      currentQueryChar="&";
    }
    currentQuery = currentQueryChar + query + "=" + value;
    return this;
  }

  Future<Uri> build({bool withToken = true}) async {
    if (withToken) {
      var prefs = await SharedPreferences.getInstance();
      query("token", prefs.getString(Constants.userTokenKey)!);
    }
    var baseUrl = await ResourceUri.getBase();
    return Uri.parse(baseUrl + currentAppend + currentQuery);
  }

}