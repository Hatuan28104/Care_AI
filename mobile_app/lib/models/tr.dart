import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

extension Translate on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this)!;
}
