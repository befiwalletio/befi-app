import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  Future<bool> checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    _canCheckBiometrics = canCheckBiometrics;
    return _canCheckBiometrics;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    _availableBiometrics = availableBiometrics;
    return _availableBiometrics;
  }

  Future<void> authenticate() async {
    bool authenticated = false;
    try {
      _isAuthenticating = true;
      _authorized = 'Authenticating';
      authenticated = await auth.authenticateWithBiometrics(localizedReason: 'Scan your fingerprint to authenticate', useErrorDialogs: true, stickyAuth: true);

      _isAuthenticating = false;
      _authorized = 'Authenticating';
    } on PlatformException catch (e) {
      print(e);
    }
    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    _authorized = message;
  }

  void cancelAuthentication() {
    auth.stopAuthentication();
  }
}
