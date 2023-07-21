import 'dart:io';

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
import 'pin_code/pin_code.dart';
import 'singin.dart';
import 'widgets/login_text_field.dart';



// ... Autres importations


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
  
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
              return const SinginScreen();
            }));
          },
          child: Row(
            children: [
              const SizedBox(
                width: 5.0,
              ),
              Icon(
                Platform.isIOS ? CupertinoIcons.chevron_back : CupertinoIcons.arrow_left,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() {
              isLoading = true;
            });
            MyUser logUser = await Functions.postLoginDetails(
              email: emailController.text,
              password: passwordController.text,
            );
            if (logUser != null) {
              if (logUser.isActive.toString() == "1") {
                if (logUser.role == "admin") {
                  // L'utilisateur est un administrateur
                  // Continuez avec le processus d'authentification en tant qu'administrateur
                  await _auth
                      .signInWithEmailAndPassword(
                        email: emailController.text,
                        password: FirebaseConst.authPwd,
                      )
                      .then((uid) => {})
                      .catchError((e) async {
                    setState(() {
                      isLoading = false;
                    });
                    Fluttertoast.showToast(msg: await e!.message);
                  });

                  getAllTontineListWhereCurrentUserParticipated(id: logUser.id!);
                  getAllTransactions(id: logUser.id);

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                      return PinCodeScreen(
                        user: logUser,
                      );
                    }),
                    (route) => false,
                  );
                } else {
                  // L'utilisateur n'est pas un administrateur
                  setState(() {
                    isLoading = false;
                  });
                  Fluttertoast.showToast(
                    msg: 'Vous n\'êtes pas autorisé en tant qu\'administrateur !',
                    backgroundColor: Palette.appPrimaryColor,
                  );
                }
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
        },
        backgroundColor: Palette.secondaryColor.withOpacity(0.9),
        child: !isLoading
            ? const Icon(
                CupertinoIcons.chevron_right,
                color: Palette.whiteColor,
              )
            : const Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: Palette.secondaryColor,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getAllTontineListWhereCurrentUserParticipated({required int id}) async {
    List<Tontine?> tontineList1 = await RemoteServices().getAllTontineList();

    if (tontineList1.isNotEmpty) {
      for (var element in tontineList1) {
        if (element?.creatorId != id && element!.membersId.contains(id)) {
          allTontineWhereCurrentUserParticipated.add(element);
        }
        if (element?.creatorId == id) {
          currentUSerTontineList.add(element!);
        }
      }
    }
  }

  Future<void> getAllTransactions({required id}) async {
    List<MoneyTransaction> allTransactions =
        await RemoteServices().getTransactionsList();

    if (allTransactions.isNotEmpty) {
      globalTransactionsList.clear();
      for (MoneyTransaction element in allTransactions) {
        if (element.tontineCreatorId == id || element.userId == id) {
          globalTransactionsList.add(element);
        }
      }
      globalTransactionsList.sort(
        (a, b) => a.date.compareTo(b.date),
      );
      globalTransactionsList.sort((a, b) {
        int dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) {
          return dateComparison;
        }
        return a.hours.compareTo(b.hours);
      });

      List<DataByDate<MoneyTransaction>> transactionsByDate = [];
      for (var t in globalTransactionsList) {
        DataByDate? last =
            transactionsByDate.isNotEmpty ? transactionsByDate.last : null;
        if (last == null || last.date != t.date) {
          transactionsByDate.add(DataByDate<MoneyTransaction>(
            date: t.date,
            data: [t],
          ));
        } else {
          last.data.add(t);
        }
      }
      AllTransactionsByDate = transactionsByDate;
    }
  }
}
