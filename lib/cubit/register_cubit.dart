import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadamatic_auth/constants/endpoints.dart';
import 'package:khadamatic_auth/cubit_states/register_states.dart';
import 'package:khadamatic_auth/models/auth_model.dart';
import 'package:khadamatic_auth/networks/authentication_dio_helper.dart';
import 'package:khadamatic_auth/sharedpref/sharedpref.dart';

class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(RegisterInitState());
  static RegisterCubit get(context) => BlocProvider.of(context);
  var registerFormKey = GlobalKey<FormState>();
  AuthModel? authModel;
  bool obsecureText = true;
  var IconData = const Icon(Icons.visibility_off_outlined);
  void onPasswordSuffixIconTaped() {
    if (obsecureText) {
      IconData = const Icon(Icons.visibility_outlined);
      obsecureText = false;
    } else {
      IconData = const Icon(Icons.visibility_off_outlined);
      obsecureText = true;
    }
    emit(PasswordsVisibilityState());
  }

  Future<dynamic> onRegisterPressed(
      {required BuildContext context,
      required String name,
      required String email,
      required String password,
      required String passwordConfirmation,
      required String phone}) async {
    await sendregisterUserData(
        context: context,
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );
  }

  Future<dynamic> sendregisterUserData(
      {required BuildContext context,
      required String name,
      required String email,
      required String password,
      required String passwordConfirmation,
      required String phone}) async {
    emit(RegisterLoadingState());
    await AuthenticationDioHelper.sendUserData(url: Register, data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone': phone
    }).then((value) {
      authModel = AuthModel.fromJson(value.data);
      var response = value.data;
      print(authModel!.data!.phone.toString());
      print('response  is${response.toString()}');
      setUserDataToSharedPref(
          token: true,
          name: name,
          email:email,
          phoneNumber: phone);
      emit(RegisterSuccessState(authModel!));
    }).catchError((error) {
      emit(RegisterFailureState());
      print('error on send sendregisterUserData ${error.toString()}');

    });
  }

  void setUserDataToSharedPref(
      {bool? token, String? name, String? email, String? phoneNumber}) async {
    // ignore: avoid_print
    await SharedPref_Helper.setDataToSharePref(key: 'token', value: token)
        .then((value) => print('token added with $value')).catchError((error){print('error on et token${error.toString()}');});
    await SharedPref_Helper.setDataToSharePref(key: 'name', value: name)
        .then((value) => print('name added with $value')).catchError((error){print('error on et token${error.toString()}');});;

    await SharedPref_Helper.setDataToSharePref(key: 'email', value: email)
        .then((value) => print('email added with $value')).catchError((error){print('error on et token${error.toString()}');});;

    await SharedPref_Helper.setDataToSharePref(
            key: 'phoneNumber', value: phoneNumber)
        .then((value) => print('phoneNumber added with $value')).catchError((error){print('error on et token${error.toString()}');});;
  }
}
