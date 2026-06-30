import 'package:shared_preferences/shared_preferences.dart';

class PrimerUsoSharedPrefs {
  static const _key = 'primer_uso_completado';

  final SharedPreferences _prefs;

  const PrimerUsoSharedPrefs(this._prefs);

  bool obtenerBienvenidaVista() => _prefs.getBool(_key) ?? false;

  Future<void> marcarComoVisto() => _prefs.setBool(_key, true);
}
