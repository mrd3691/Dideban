import 'dart:convert';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Util{

  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static DateTime? jalaliToGeorgianDateTime(String Date,String time) {
    DateTime? dateTime=null;
    try{
      if(Date.isEmpty || time.isEmpty) {
        return null;
      }
      var splittedDate = Date.split('/');
      if(splittedDate.isEmpty) {
        return null;
      }
      var yearJalali = int.parse(splittedDate[0].trim());
      var monthJalali = int.parse(splittedDate[1].trim());
      var dayJalali = int.parse(splittedDate[2].trim());


      var splittedTime = time.split(':');
      var hour = int.parse(splittedTime[0].trim());
      var minute = int.parse(splittedTime[1].trim());
      var second = int.parse(splittedTime[2].trim());


      Jalali jalali = Jalali(yearJalali, monthJalali, dayJalali,hour,minute,second);
      Gregorian georgian = jalali.toGregorian();
      DateTime dateTime =georgian.toDateTime();

      return dateTime;
    }
    catch(e){
      return null;
    }
  }

  static String jalaliToGeorgian(String input) {
    try{
      if(input.isEmpty || input.length<8 || input.length>10) {
        return "";
      }
      var splitted = input.split('/');
      if(splitted.isEmpty) {
        return "";
      }
      var yearJalali = int.parse(splitted[0].trim());
      var monthJalali = int.parse(splitted[1].trim());
      var dayJalali = int.parse(splitted[2].trim());
      Jalali jalali = Jalali(yearJalali, monthJalali, dayJalali);
      Gregorian georgian = jalali.toGregorian();
      String yearGeorgian = georgian.year.toString();
      String monthGeorgian = georgian.month.toString();
      if(monthGeorgian.length == 1) {
        monthGeorgian = "0$monthGeorgian";
      }
      String dayGeorgian = georgian.day.toString();
      if(dayGeorgian.length == 1) {
        dayGeorgian = "0$dayGeorgian";
      }
      return "$yearGeorgian-$monthGeorgian-$dayGeorgian";
    }
    catch(e){
      return "";
    }
  }

  static String jalaliToGeorgianGMTConvert(String date, String time) {
    try{
      if(date.isEmpty || date.length<8 || date.length>10) {
        return "";
      }
      if(time.isEmpty || time.length<3 || time.length>5) {
        return "";
      }


      List<String> splittedDate = date.split('/');
      if(splittedDate.isEmpty) {
        return "";
      }
      int yearJalali = int.parse(splittedDate[0].trim());
      int monthJalali = int.parse(splittedDate[1].trim());
      int dayJalali = int.parse(splittedDate[2].trim());


      List<String> splittedTime = time.split(':');
      if(splittedTime.isEmpty) {
        return "";
      }
      int hour = int.parse(splittedTime[0].trim());
      int minute = int.parse(splittedTime[1].trim());

      Jalali jalali = Jalali(yearJalali, monthJalali, dayJalali, hour, minute);
      Gregorian georgian = jalali.toGregorian();
      DateTime dateTime= georgian.toDateTime();
      dateTime = dateTime.subtract(Duration(hours: 3,minutes: 30));


      return dateTime.toString();
    }
    catch(e){
      return "";
    }
  }

  static String georgianToJalali(String input) {
    try{
      if(input.isEmpty || input.length<8) {
        return "";
      }
      var splitted = input.split('-');
      if(splitted.isEmpty) {
        return "";
      }
      var yearGeorgian = int.parse(splitted[0].trim());
      var monthGeorgian = int.parse(splitted[1].trim());
      var dayGeorgian = int.parse(splitted[2].trim());
      Gregorian georgian = Gregorian(yearGeorgian, monthGeorgian, dayGeorgian);
      Jalali jalali = georgian.toJalali();
      String yearJalali = jalali.year.toString();
      String monthJalali = jalali.month.toString();
      if(monthJalali.length == 1) {
        monthJalali = "0$monthJalali";
      }
      String dayJalali = jalali.day.toString();
      if(dayJalali.length == 1) {
        dayJalali = "0$dayJalali";
      }
      return "$yearJalali/$monthJalali/$dayJalali";
    }
    catch(e){
      return "";
    }
  }

  static String georgianToJalaliWithGMTConvert(DateTime input) {
    try{

      DateTime georgianDateTime = input.add(Duration(hours: 3,minutes: 30));
      Jalali jalaliDateTime = georgianDateTime.toJalali();

      String yearJalali =  jalaliDateTime.year.toString();
      String monthJalali =  jalaliDateTime.month.toString();
      String dayJalali =  jalaliDateTime.day.toString();
      String hour = jalaliDateTime.hour.toString();
      String minute = jalaliDateTime.minute.toString();
      String second = jalaliDateTime.second.toString();
      return "$hour:$minute:$second $yearJalali/$monthJalali/$dayJalali";
    }
    catch(e){
      return "";
    }
  }

  static String getHashSha1(String input){
    /*var bytes = utf8.encode(input); // data being hashed
    String digest = sha1.convert(bytes).toString();
    print("Digest as hex string: $digest");
    return digest;*/
    return "";
  }

  static Future<String> getHash(String input)async{
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 10000, // 20k iterations
      bits: 256, // 256 bits = 32 bytes output
    );

    // Calculate a hash that can be stored in the database
    final newSecretKey = await pbkdf2.deriveKeyFromPassword(
      // Password given by the user.
      password: 'qwerty',

      // Nonce (also known as "salt") should be some random sequence of
      // bytes.
      //
      // You should have a different nonce for each user in the system
      // (which you store in the database along with the hash).
      // If you can't do that for some reason, choose a random value not
      // used by other applications.
      nonce: const [1,2,3],
    );

    final secretKeyBytes = await newSecretKey.extractBytes();
    var b = utf8.decode(secretKeyBytes);
    print('Result: $b');
    return secretKeyBytes.toString();
  }

  static Future<String>  getUserName()async{
    try{
      final SharedPreferences prefs = await _prefs;
      String userName =  prefs.getString('userName') ?? "";
      return userName;
    }catch(e){
      return "";
    }
  }

  static Future<String>  getPassword()async{
    try{
      final SharedPreferences prefs = await _prefs;
      String password =  prefs.getString('password') ?? "";
      return password;
    }catch(e){
      return "";
    }
  }


}