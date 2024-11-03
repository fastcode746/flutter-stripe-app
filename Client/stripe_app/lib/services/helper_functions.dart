import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  //keys
  static String subscriptionStatus = "SUBSCRIPTIONSTATUS";

  // saving subscrption data to SF

  static Future<bool> saveSubscriptionStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(subscriptionStatus, isUserLoggedIn);
  }

  // getting the subscription data from SF

  static Future<bool?> getSubscriptionStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(subscriptionStatus);
  }

 
}
