// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'आरोग्य AI';

  @override
  String get symptomHint => 'अपने लक्षण बताएं...';

  @override
  String get voiceHint => 'बोलने के लिए माइक दबाएं';

  @override
  String get emergency => 'आपातकाल';

  @override
  String get medicines => 'दवाइयाँ';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get home => 'होम';

  @override
  String get urgencyLow => 'कम जरूरी';

  @override
  String get urgencyMedium => 'मध्यम जरूरी';

  @override
  String get urgencyHigh => 'जल्द डॉक्टर से मिलें';

  @override
  String get urgencyCritical => 'आपातकाल — तुरंत अस्पताल जाएं';

  @override
  String get addMedicine => 'दवाई जोड़ें';

  @override
  String get medicineName => 'दवाई का नाम';

  @override
  String get dosage => 'खुराक';

  @override
  String get saveReminder => 'याद दिलाओ सेट करें';

  @override
  String get noMedicines => 'कोई दवाई नहीं जोड़ी गई';

  @override
  String get offlineBadge => 'ऑफलाइन';
}
