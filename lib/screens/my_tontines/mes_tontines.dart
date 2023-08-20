import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../functions/firebase_fcm.dart';
import '../../functions/functions.dart';
import '../../models/money_transaction.dart';
import '../../models/tontine.dart';
import '../../models/transation_by_date.dart';
import '../../models/user.dart';
import '../../remote_services/remote_services.dart';
import '../../style/palette.dart';
import '../../widgets/loading_container.dart';
import '../../widgets/transactions_widget.dart';
import '../add_tontine/add_tontine.dart';
import '../all_transactions_history/all_transations_history.dart';
import 'widgets/create_tontine_sheet_content.dart';
import '../../widgets/empty_transaction.dart';
import 'widgets/join_create_buttons.dart';
import 'widgets/mes_tontines_top_box.dart';

class MesTontinesScreen extends StatefulWidget {
  const MesTontinesScreen({super.key, required this.user});

 final MyUser? user;


  @override
  State<MesTontinesScreen> createState() => _MesTontinesScreenState();
}

class _MesTontinesScreenState extends State<MesTontinesScreen> {
  final ScrollController _scrolleController = ScrollController();
  bool isHiden = false;
  bool isVisible = false;
  List<DataByDate<MoneyTransaction>> AlltrasansactionsByDate = [];

  @override
  void initState() {
    FirebaseFCM.storeNotificationToken();
    if (widget.user?.email != null) {
  FirebaseFCM.getTokenNotificationByEmail(userEmail: widget.user!.email!);
}
    super.initState();
    Future.delayed(const Duration(seconds: 10)).then((_) {
      setState(() {
        isVisible = true;
      });
    });
    getTontineAndTransaction();
  }

  @override
  void dispose() {
    _scrolleController.dispose();
    super.dispose();
  }

  Future<void> getTontineAndTransaction() async {
    await getAllTransactions();
    await getAllTontineListWhereCurrentUserParticiped();
  }

  Future<void> getAllTransactions() async {
    List<MoneyTransaction> allTransactions =
        await RemoteServices().getTransactionsList();

    if (allTransactions.isNotEmpty) {
      setState(() {
        globalTransactionsList.clear();
      });
      for (MoneyTransaction element in allTransactions) {
        if (element.tontineCreatorId == widget.user?.id ||
            element.userId == widget.user?.id) {
          setState(() {
            globalTransactionsList.add(element);
          });
        }
      }
      globalTransactionsList.sort((a, b) => a.date.compareTo(b.date));
      globalTransactionsList.sort((a, b) {
        int dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) {
          return dateComparison;
        }
        return a.hours.compareTo(b.hours);
      });
      // Créer une liste de TransactionsByDate à partir de la liste triée
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
      setState(() {
        AlltrasansactionsByDate = transactionsByDate;
      });
    }
  }

  Future<void> getAllTontineListWhereCurrentUserParticiped() async {
    List<Tontine?> tontineList1 = await RemoteServices().getAllTontineList();
    List<Tontine> allTontineWhereCurrentUserParticipe = [];

    if (tontineList1.isNotEmpty) {
      allTontineWhereCurrentUserParticipe.clear();
      currentUSerTontineList.clear();
      for (var element in tontineList1) {
        if (element?.creatorId != widget.user?.id &&
            element!.membersId.contains(widget.user?.id)) {
          setState(() {
            allTontineWhereCurrentUserParticipe.add(element);
          });
        }
        if (element?.creatorId == widget.user?.id) {
          setState(() {
            currentUSerTontineList.add(element!);
          });
        }
      }
    }
  }

  void _showBottomSheet(BuildContext context, bool isCreateTontine) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return CreatetontineSheetContent(
          user: widget.user!,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Obtenir le nom complet de l'utilisateur (fullName)
    String fullName = widget.user?.fullName ?? "ouedraogo armel";
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 249, 249, 249),
        extendBody: true,
        appBar: AppBar(
          centerTitle: false,
          shadowColor: Palette.greyColor,
          backgroundColor: Palette.secondaryColor,
          elevation: 0,
        ),
        body: Stack(
          children: [
            SafeArea(
              child: globalTransactionsList.length > 3
                  ? LiquidPullToRefresh(
                      color: Palette.secondaryColor,
                      springAnimationDurationInMilliseconds: 400,
                      onRefresh: getTontineAndTransaction,
                      child: getChild(),
                    )
                  : GestureDetector(
                      onVerticalDragDown: (details) {},
                      onVerticalDragEnd: (details) {
                        Functions.showLoadingSheet(ctxt: context);
                        getTontineAndTransaction();
                        Future.delayed(const Duration(seconds: 5)).then((_) {
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            msg: 'Mise à jour de la liste est effectuée.',
                            backgroundColor: Palette.appPrimaryColor,
                          );
                        });
                      },
                      child: getChild(),
                    ),
            ),
            !isHiden
                ? MesTontinesTopBox(
                    widget: widget,
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget getChild() {
    return Column(
      
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ////////////////// top container mise en commentaire pour plutard
        ///
        !isHiden
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: 15.0,
                  right: 4.0,
                ),
                height: 150,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.elliptical(200, 10),
                      bottomLeft: Radius.elliptical(200, 10)),
                  color: Palette.secondaryColor,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  //minVerticalPadding: 0,
                  horizontalTitleGap: 0,

                  leading: Container(
                    // padding: const EdgeInsets.only(bottom: 28.0),
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Palette.whiteColor,
                      border: Border.all(
                        width: 4,
                        color: Palette.appPrimaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.person_fill,
                        color: Palette.greyColor,
                        size: 40,
                      ),
                    ),
                  ),
                  title: Text(
                    'Bonjour',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Palette.whiteColor, fontSize: 18),
                  ),
                  subtitle: Text(
                    widget.user!.fullName,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          height: 1.5,
                          color: Palette.whiteColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              )
            : Container(),

        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            child: SingleChildScrollView(
              controller: _scrolleController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !isHiden
                      ? const SizedBox(
                          height: 10,
                        )
                      : Container(),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                        top: 8.0, right: 45.0, left: 45.0),
                    child: FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          JoinCreateButton(
                            text: 'Créer',
                            svg: 'assets/icons/create.svg',
                            color: Palette.secondaryColor,
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return AddTontineScreen(
                                  tontineName:
                                      DateFormat('tontine_dd/MM/yyyy').format(
                                    DateTime.now(),
                                  ),
                                  user: widget.user!,
                                );
                              }));
                            },
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          JoinCreateButton(
                            text: 'Rejoindre',
                            svg: 'assets/icons/finger.svg',
                            color: Palette.primaryColor,
                            onTap: () {
                              _showBottomSheet(context, false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 20),
                    child: AlltrasansactionsByDate.isNotEmpty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dernières transactions',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Palette.greySecondaryColor,
                                      fontSize: 14,
                                    ),
                              ),
                              TextButton(
                                onPressed: () {
                                  //print(_trasansactionsByDate.length);
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AllTransactionsHistory(
                                          user: widget.user!,
                                          trasansactionsByDate:
                                              AlltrasansactionsByDate,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  'Tout afficher',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          color: Palette.greySecondaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  isVisible
                      ? AlltrasansactionsByDate.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(right: 0.0),
                              child: Column(
                                children: List.generate(
                                  AlltrasansactionsByDate.length,
                                  ////////// decommenter plutard pour voir tout les transaction du user connecter /////////////
                                  ///
                                  (index) => TransactionsWidget(
                                    user: widget.user!,
                                    trasansactionsByDate:
                                        AlltrasansactionsByDate[index],
                                  ),
                                  //(index) => Container(),
                                ),
                              ),
                            )
                          : const EmptyTransactios()
                      : LoadingContainer(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
