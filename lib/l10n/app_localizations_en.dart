// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AarogyaAI';

  @override
  String get symptomHint => 'Describe your symptoms...';

  @override
  String get voiceHint => 'Tap mic to speak';

  @override
  String get emergency => 'Emergency';

  @override
  String get medicines => 'Medicines';

  @override
  String get settings => 'Settings';

  @override
  String get home => 'Home';

  @override
  String get urgencyLow => 'Low urgency';

  @override
  String get urgencyMedium => 'Medium urgency';

  @override
  String get urgencyHigh => 'High urgency';

  @override
  String get urgencyCritical => 'CRITICAL — seek emergency care';

  @override
  String get addMedicine => 'Add Medicine';

  @override
  String get medicineName => 'Medicine name';

  @override
  String get dosage => 'Dosage';

  @override
  String get saveReminder => 'Save & Set Reminder';

  @override
  String get noMedicines => 'No medicines added yet';

  @override
  String get offlineBadge => 'Offline';
}
