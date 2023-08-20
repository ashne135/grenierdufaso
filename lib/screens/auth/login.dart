import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config/firebase_const.dart';
import '../../config/prefs.dart';
import '../../functions/functions.dart';
import '../../models/money_transaction.dart';
import '../../models/tontine.dart';
import '../../models/transation_by_date.dart';
import '../../models/user.dart';
import '../../remote_services/remote_services.dart';
import '../../style/palette.dart';
import '../../widgets/logo_container.dart';
import '../home_page/home_page.dart';
import 'pin_code/pin_code.dart';
import 'singin.dart';
import 'widgets/login_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List<DataByDate<MoneyTransaction>> AllTransactionsByDate = [];
  List<Tontine?> allTontineWhereCurrentUserParticipated = [];
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  bool isLoading = false;

  @override
  void initState() {
    passwordController.text = FirebaseConst.laraPwd;
    super.initState();
    emailController.text = 'ashneouedraogo@gmail.com';
    passwordController.text = 'conjugaison';
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leadingWidth: 100,
      leading: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              return const SinginScreen();
            },
          ));
        },
        child: Row(
          children: [
            const SizedBox(
              width: 5.0,
            ),
            Icon(
              Platform.isIOS
                  ? CupertinoIcons.chevron_back
                  : CupertinoIcons.arrow_left,
              color: Palette.blackColor,
              size: 25,
            ),
            const Text(
              'inscription',
              style: TextStyle(
                color: Palette.blackColor,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    ),
    body: Stack(
      children: [
        SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const LogoContainer(),
                  Form(
                    key: _formKey,
                    child: LoginTextField(
                      emailController: emailController,
                      passwordController: passwordController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return const SinginScreen();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Je n\'ai pas de compte',
                        style: TextStyle(
                          color: Palette.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // ... Autres éléments de la pile (si vous en avez)
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            isLoading = true;
          });

          // Appel de la fonction de connexion de l'utilisateur
          //await signInUser();

          // Navigation vers la page d'accueil après une connexion réussie
          // Commentez cette ligne si vous préférez gérer la navigation dans signInUser()
          // N'oubliez pas de décommenter la ligne navigateToHomePage() dans signInUser()
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageScreen(),
            ),
          );
        }
      },
      backgroundColor: Palette.secondaryColor.withOpacity(0.9),
      child: !isLoading
        ? const Icon(
            CupertinoIcons.chevron_right,
            color: Palette.whiteColor,
          )
        : const Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: Color.fromARGB(255, 17, 11, 186),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
    ),
  );
}

  Future<void> signInUser() async {
    MyUser logUser = await Functions.postLoginDetails(
      email: emailController.text,
      password: passwordController.text,
    );

    if (logUser != null) {
      if (logUser.isActive.toString() == "1") {
        // L'utilisateur est actif
        // Rediriger vers la page d'accueil
        navigateToHomePage();
      } else {
        setState(() {
          isLoading = false;
          Fluttertoast.showToast(
            msg: 'Compte désactivé',
            backgroundColor: Palette.appPrimaryColor,
          );
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'Email incorrect !',
        backgroundColor: Palette.appPrimaryColor,
      );
    }
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePageScreen()),
    );
  }
}
