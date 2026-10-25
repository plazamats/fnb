import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  ConfirmationResult? _webConfirmationResult;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendVerificationCode({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(PhoneAuthCredential credential)
        onVerificationCompleted,
  }) async {
    if (kIsWeb) {
      _webConfirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
      onCodeSent('web-phone-auth');
      return;
    }
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: onCodeSent,
    );
  }

  Future<UserCredential> verifyCode({
    required String verificationId,
    required String smsCode,
  }) {
    final confirmation = _webConfirmationResult;
    if (confirmation != null) {
      _webConfirmationResult = null;
      return confirmation.confirm(smsCode);
    }
    return _auth.signInWithCredential(
      PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      ),
    );
  }

  Future<void> attachPassword({
    required User user,
    required String phoneNumber,
    required String password,
  }) async {
    final digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    try {
      await user.linkWithCredential(
        EmailAuthProvider.credential(
          email: 'phone-$digits@fnbb-ea966.firebaseapp.com',
          password: password,
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code != 'provider-already-linked') rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();
}
