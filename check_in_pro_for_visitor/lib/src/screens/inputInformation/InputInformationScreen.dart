import 'dart:io';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppColors.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppDestination.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppImage.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppString.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/constants/Styles.dart';
import 'package:check_in_pro_for_visitor/src/model/CheckInFlow.dart';
import 'package:check_in_pro_for_visitor/src/model/CompanyBuilding.dart';
import 'package:check_in_pro_for_visitor/src/model/ContactPerson.dart';
import 'package:check_in_pro_for_visitor/src/model/TakePhotoStep.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorType.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/inputInformation/InputInformationNotifier.dart';
import 'package:check_in_pro_for_visitor/src/services/ServiceLocator.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/Loading.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/RaisedGradientButton.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/TextFieldComon.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/TypeHead.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:check_in_pro_for_visitor/src/constants/SizeConfig.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/Background.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'InputInformationNotifier.dart';
import 'dart:math' as math;

class InputInformationScreen extends MainScreen {
  static const String route_name = '/information';

  @override
  _InputInformationScreenState createState() => _InputInformationScreenState();

  @override
  String getNameScreen() {
    return route_name;
  }
}

class _InputInformationScreenState extends MainScreenState<InputInformationNotifier> {
  List<FocusNode> focusNodes = List();
  TextEditingController controller;
  ScrollController scrollController = ScrollController();
  FocusNode currentNodes;
  FocusNode nodeContact = FocusNode();
  bool isScroll = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<CheckInFlow>>(
      future: provider.getCheckInFlow(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            onTap: () => Utilities().moveToWaiting(),
            child: Background(
              isShowBack: true,
              isShowClock: true,
              isOpeningKeyboard: !provider.isShowLogo,
              isShowFooter: provider.isShowFooter,
              isShowLogo: provider.isShowLogo,
              isShowChatBox: false,
              isAnimation: true,
              initState: !provider.parent.isOnlineMode,
              messSnapBar: appLocalizations.messOffMode,
              contentChat: appLocalizations.translate(AppString.MESSAGE_INPUT_INFORMATION_CHATBOX),
              type: BackgroundType.MAIN,
              child: SingleChildScrollView(
                controller: provider.scrollController,
                physics: ClampingScrollPhysics(),
                child: Selector<InputInformationNotifier, bool>(
                    selector: (context, provider) => provider.isLoading,
                    builder: (context, data, child) => Loading(visible: data, child: buildReviewInfo())),
              ),
            ),
          );
        }
        return Background(
          isShowBack: true,
          isShowLogo: false,
          isShowChatBox: false,
          type: BackgroundType.MAIN,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  @override
  void onKeyboardChange(bool visible) {
    provider.isShowLogo = !visible;
    provider.isShowFooter = !visible;
    provider.hideLoading = false;
    isScroll = visible;
  }

  Widget buildReviewInfo() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Container(
        width: widthScreen * 100,
        height: heightScreen * 75,
        padding: EdgeInsets.only(bottom: 40),
        child: Row(
          children: <Widget>[
            if (provider.isCapture || provider.isScanId)
              Expanded(
                flex: 4,
                child: buildPhoto(),
              ),
            if (provider.isCapture || provider.isScanId)
              SizedBox(
                width: 20,
              ),
            Expanded(
              flex: 6,
              child: buildInputInfor(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputInfor() {
    return Container(
      height: heightScreen * 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: Color(0xffD3D8DE),
            blurRadius: 3,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              buildInformation(),
              if (provider.isContact)
                buildContactPerson(),
//          Spacer(),
              Container(
                alignment: Alignment.centerRight,
                height: 80,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: buildBtnNext(),
              ),
              Selector<InputInformationNotifier, bool>(
                  selector: (context, provider) => provider.isShowLogo,
                  builder: (context, data, child) => Loading(
                      visible: data,
                      child: SizedBox(
                        height: !data ? 100 : 10,
                      )))
            ],
          ),
        ),
      ),
    );
  }

  RaisedButton buildBtnNext() {
    return RaisedButton(
      onPressed: () async {
        bool isValidate = true;
        Utilities().hideKeyBoard(context);
        provider.keyList.forEach((key) {
          if (key.currentState?.validate() == false) {
            isValidate = false;
            return;
          }
        });
        if (await provider.checkIsNext(isValidate, false, isShowError: true)) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDestination.RADIUS_TEXT_INPUT),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      buildReviewCard(),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Icon(Icons.clear),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: EdgeInsets.zero,
      child: Container(
        width: 200,
        padding: const EdgeInsets.only(top: 5.0, bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: LinearGradient(
            colors: [
              Color(0xffFFC20E),
              Color(0xffF7A30A),
            ],
            stops: [0.0, 1.0],
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                appLocalizations.btnContinue,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: appImage.okeHDBank,
            ),
          ],
        ),
      ),
    );

    // RaisedButton.icon(
    //   onPressed: () async {
    //     bool isValidate = true;
    //     Utilities().hideKeyBoard(context);
    //     provider.keyList.forEach((key) {
    //       if (key.currentState?.validate() == false) {
    //         isValidate = false;
    //         return;
    //       }
    //     });
    //     if (await provider.checkIsNext(isValidate, false, isShowError: true)) {
    //       showDialog(
    //         context: context,
    //         builder: (BuildContext context) {
    //           return AlertDialog(
    //             contentPadding:
    //                 EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
    //             shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(
    //                     AppDestination.RADIUS_TEXT_INPUT)),
    //             content: buildReviewCard(),
    //           );
    //         },
    //       );
    //     }
    //   },
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    //   color: Color(0XFFFFC20E),
    //   icon: Padding(
    //     padding:
    //         const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
    //     child: Padding(
    //       padding: const EdgeInsets.only(left: 0.0),
    //       child: Text(
    //         appLocalizations.btnContinue,
    //         style: TextStyle(
    //           fontSize: 20,
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //     ),
    //   ),
    //   label: Padding(
    //     padding: const EdgeInsets.only(top: 10, bottom: 10),
    //     child: Container(
    //       decoration: BoxDecoration(
    //         shape: BoxShape.circle,
    //         color: Colors.white,
    //       ),
    //       child: Padding(
    //         padding: const EdgeInsets.all(5.0),
    //         child: AppImage.iconBntNextHDBank,
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget buildContactPerson() {
    return TextFormFieldReviewInfo(
      title: appLocalizations.whoAreUVisiting,
      isRequest: true,
      child: Selector<InputInformationNotifier, ContactPerson>(
        builder: (context, contactPerson, child) {
          if (contactPerson != null) {
            return buildItemContact(contactPerson, context);
          }
          return Selector<InputInformationNotifier, List<ContactPerson>>(
            builder: (context, data, child) {
              return Selector<InputInformationNotifier, String>(
                selector: (context, provider) => provider.errorContact,
                builder: (context, error, child) => TypeAheadField<ContactPerson>(
                  hideSuggestionsOnKeyboardHide: false,
                  keepSuggestionsOnLoading: false,
                  getImmediateSuggestions: false,
                  debounceDuration: Duration(milliseconds: Constants.DELAY_SEARCH),
                  suggestionsBoxDecoration: SuggestionsBoxDecoration(
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDestination.RADIUS_TEXT_INPUT),
                        side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
                    constraints: BoxConstraints(
                      maxHeight: SizeConfig.safeBlockVertical * 40,
                    ),
                  ),
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: appLocalizations.personUMeet,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                      errorStyle: TextStyle(fontSize: 0),
                      errorText: error,
                      helperText: " ",
                      helperStyle: TextStyle(fontSize: 0),
                      hintStyle: TextStyle(fontSize: 20, fontFamily: Styles.OpenSans),
                    ),
                    readOnly: false,
                    showCursor: true,
                    focusNode: nodeContact,
                    onTap: () {
                      isScroll = true;
                    },
                    onSubmitted: (_) async {},
                    onChanged: (text) {},
                    style: Styles.formFieldText.copyWith(fontSize: 20, fontFamily: Styles.OpenSans),
                  ),
                  suggestionsCallback: (String pattern) {
                    provider.utilities.moveToWaiting();
                    return provider.getContactPerson(context, pattern, false);
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  itemBuilder: (context, suggestion) {
                    if (isScroll) {
                      isScroll = false;
                      if (scrollController.offset < scrollController.position.maxScrollExtent) {
                        double offset = scrollController.position.maxScrollExtent - scrollController.offset;
                        scrollController.animateTo(offset, curve: Curves.easeIn, duration: Duration(milliseconds: 200));
                      }
                    }
                    return buildItemContact(suggestion, context);
                  },
                  noItemsFoundBuilder: (context) {
                    return Container(
                      height: 60,
                      alignment: Alignment.center,
                      child: Text(appLocalizations.noResults),
                    );
                  },
                  loadingBuilder: (context) {
                    if (isScroll) {
                      isScroll = false;
                      if (scrollController.offset < scrollController.position.maxScrollExtent) {
                        double offset = scrollController.position.maxScrollExtent - scrollController.offset;
                        scrollController.animateTo(offset, curve: Curves.easeIn, duration: Duration(milliseconds: 200));
                      }
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                  onSuggestionSelected: (ContactPerson suggestion) async {},
                ),
              );
            },
            selector: (context, provider) => provider.listContact,
          );
        },
        selector: (context, provider) => provider.contactPersonSelected,
      ),
    );
  }

  StaggeredGridView buildInformation() {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 5,
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.flows.length,
      itemBuilder: (context, index) {
        var item = provider.flows[index];
        return TextFormFieldReviewInfo(
          title: item.stepName,
          isRequest: (item.getRequestType() == RequestType.ALWAYS || item.getRequestType() == RequestType.FIRST),
          child: renderWidgetByType(item, index),
        );
      },
      staggeredTileBuilder: (int index) {
        int crossAxisCellCount = index.isEven ? 3 : 2;
        if (provider.flows.length.isOdd && index == provider.flows.length - 1) {
          crossAxisCellCount = 5;
        }
        return StaggeredTile.fit(crossAxisCellCount);
      },
      mainAxisSpacing: 10.0,
      crossAxisSpacing: 4.0,
    );
  }

  Container buildPhoto() {
    if (provider.isScanId && !provider.isCapture) {
      return Container(
        height: heightScreen * 75,
        child: buildPhotoOnlyIDCard(),
      );
    }
    return Container(
      height: heightScreen * 75,
      child: Column(
        children: <Widget>[
          if (provider.isScanId)
            Expanded(
              flex: 2,
              child: buildPhotoIDCard(),
            ),
          if (provider.isCapture && provider.isScanId)
            SizedBox(
              height: 20,
            ),
          if (provider.isCapture)
            Expanded(
              flex: 3,
              child: buildPhotoFace(),
            )
        ],
      ),
    );
  }

  Container buildPhotoFace() {
    return Container(
      width: widthScreen * 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: Color(0xffD3D8DE),
            blurRadius: 3,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Selector<InputInformationNotifier, String>(
        builder: (context, data, child) {
          return data?.isNotEmpty == true
              ? Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    _buildPictureFaceId(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                      provider.visitorBackup.imagePath,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: MaterialButton(
                        onPressed: () {
                          provider.deletePhoto(PhotoStep.FACE_STEP);
                        },
                        color: Colors.white,
                        child: appImage.iconTrashHDBank,
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    appImage.photoHDBank,
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        appLocalizations.portrait,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    RaisedButton.icon(
                      elevation: 0,
                      color: Color(0XFFEAEEF2),
                      onPressed: () {
                        provider.showDialogPhoto(PhotoStep.FACE_STEP);
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                      icon: appImage.cameraSnapshotHDBank,
                      label: Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: Text(
                          appLocalizations.takePicture,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        },
        selector: (buildContext, provider) => provider.visitorBackup.imagePath,
      ),
    );
  }

  Column buildPhotoOnlyIDCard() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            width: double.infinity,
            height: heightScreen * 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xffD3D8DE),
                  blurRadius: 3,
                  offset: Offset(0, 10), // changes position of shadow
                ),
              ],
            ),
            child: Selector<InputInformationNotifier, String>(
              builder: (context, data, child) {
                return data?.isNotEmpty == true
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: <Widget>[
                          _buildPictureFaceId(
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height,
                            provider.visitorBackup.imageIdPath,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: MaterialButton(
                              onPressed: () {
                                provider.deletePhoto(PhotoStep.ID_FONT_STEP);
                              },
                              color: Colors.white,
                              child: appImage.iconTrashHDBank,
                              padding: EdgeInsets.all(7),
                              shape: CircleBorder(),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          appImage.photoHDBank,
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Text(
                              appLocalizations.idCardFrontFace,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          RaisedButton.icon(
                            elevation: 0,
                            color: Color(0XFFEAEEF2),
                            onPressed: () {
                              provider.showDialogPhoto(PhotoStep.ID_FONT_STEP);
                            },
                            icon: appImage.cameraSnapshotHDBank,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                            label: Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: Text(
                                appLocalizations.takePicture,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
              },
              selector: (buildContext, provider) => provider.visitorBackup.imageIdPath,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            height: heightScreen * 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xffD3D8DE),
                  blurRadius: 3,
                  offset: Offset(0, 10), // changes position of shadow
                ),
              ],
            ),
            child: Selector<InputInformationNotifier, String>(
              builder: (context, data, child) {
                return data?.isNotEmpty == true
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: <Widget>[
                          _buildPictureFaceId(
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height,
                            provider.visitorBackup.imageIdBackPath,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: MaterialButton(
                              onPressed: () {
                                provider.deletePhoto(PhotoStep.ID_BACK_STEP);
                              },
                              color: Colors.white,
                              child: appImage.iconTrashHDBank,
                              padding: EdgeInsets.all(7),
                              shape: CircleBorder(),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          appImage.photoHDBank,
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Text(
                              appLocalizations.idCardBackSize,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: Styles.OpenSans),
                            ),
                          ),
                          RaisedButton.icon(
                            elevation: 0,
                            color: Color(0XFFEAEEF2),
                            onPressed: () {
                              provider.showDialogPhoto(PhotoStep.ID_BACK_STEP);
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                            icon: appImage.cameraSnapshotHDBank,
                            label: Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: Text(
                                appLocalizations.takePicture,
                                style: TextStyle(fontSize: 14, fontFamily: Styles.OpenSans),
                              ),
                            ),
                          ),
                        ],
                      );
              },
              selector: (buildContext, provider) => provider.visitorBackup.imageIdBackPath,
            ),
          ),
        ),
      ],
    );
  }

  Row buildPhotoIDCard() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: heightScreen * 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xffD3D8DE),
                  blurRadius: 3,
                  offset: Offset(0, 10), // changes position of shadow
                ),
              ],
            ),
            child: Selector<InputInformationNotifier, String>(
              builder: (context, data, child) {
                return data?.isNotEmpty == true
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: <Widget>[
                          _buildPictureFaceId(
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height,
                            provider.visitorBackup.imageIdPath,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: MaterialButton(
                              onPressed: () {
                                provider.deletePhoto(PhotoStep.ID_FONT_STEP);
                              },
                              color: Colors.white,
                              child: appImage.iconTrashHDBank,
                              padding: EdgeInsets.all(7),
                              shape: CircleBorder(),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          appImage.photoHDBank,
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Text(
                              appLocalizations.idCardFrontFace,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          RaisedButton.icon(
                            elevation: 0,
                            color: Color(0XFFEAEEF2),
                            onPressed: () {
                              provider.showDialogPhoto(PhotoStep.ID_FONT_STEP);
                            },
                            icon: appImage.cameraSnapshotHDBank,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                            label: Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: Text(
                                appLocalizations.takePicture,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
              },
              selector: (buildContext, provider) => provider.visitorBackup.imageIdPath,
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Expanded(
          child: Container(
            height: heightScreen * 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xffD3D8DE),
                  blurRadius: 3,
                  offset: Offset(0, 10), // changes position of shadow
                ),
              ],
            ),
            child: Selector<InputInformationNotifier, String>(
              builder: (context, data, child) {
                return data?.isNotEmpty == true
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: <Widget>[
                          _buildPictureFaceId(
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height,
                            provider.visitorBackup.imageIdBackPath,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: MaterialButton(
                              onPressed: () {
                                provider.deletePhoto(PhotoStep.ID_BACK_STEP);
                              },
                              color: Colors.white,
                              child: appImage.iconTrashHDBank,
                              padding: EdgeInsets.all(7),
                              shape: CircleBorder(),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          appImage.photoHDBank,
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Text(
                              appLocalizations.idCardBackSize,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: Styles.OpenSans),
                            ),
                          ),
                          RaisedButton.icon(
                            elevation: 0,
                            color: Color(0XFFEAEEF2),
                            onPressed: () {
                              provider.showDialogPhoto(PhotoStep.ID_BACK_STEP);
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                            icon: appImage.cameraSnapshotHDBank,
                            label: Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: Text(
                                appLocalizations.takePicture,
                                style: TextStyle(fontSize: 14, fontFamily: Styles.OpenSans),
                              ),
                            ),
                          ),
                        ],
                      );
              },
              selector: (buildContext, provider) => provider.visitorBackup.imageIdBackPath,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPictureFaceId(double sizewidth, double sizeHeight, String path) {
    return buildLayoutFaceId(
      sizewidth,
      sizeHeight,
      Container(
        width: sizewidth,
        height: sizeHeight,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(pi),
          child: (path != null)
              ? Image.file(
                  File(path),
                  fit: BoxFit.cover,
                )
              : Image.asset("assets/images/default_avatar.png"),
        ), // this is my CameraPreview
      ),
    );
  }

  Widget buildLayoutFaceId(double sizewidth, double sizeHeight, Widget child) {
    return Container(
      width: sizewidth,
      height: sizeHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        child: OverflowBox(
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  Widget buildItemContact(ContactPerson contactPerson, BuildContext context) {
    return InkWell(
      onTap: () {
        if (contactPerson?.id != provider?.contactPersonSelected?.id) {
          provider.updateSelectedContact(contactPerson);
          Utilities().hideKeyBoard(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: (contactPerson?.id == provider?.contactPersonSelected?.id) ? AppColor.HDBANK_YELLOW : Colors.white,
          border: Border.all(color: Colors.transparent, width: 1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: EdgeInsets.only(top: 8, bottom: 8, right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 15,
            ),
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(360.0) //         <--- border radius here
                    ),
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(360.0)),
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: buildAvatar(contactPerson),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 3,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      contactPerson.fullName ?? "",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: Styles.OpenSans,
                      ),
                    ),
                    if (contactPerson?.jobTitle?.isNotEmpty == true)
                      SizedBox(
                        height: 5,
                      ),
                    if (contactPerson?.jobTitle?.isNotEmpty == true)
                      Text(contactPerson.jobTitle,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, fontFamily: Styles.OpenSans)),
                  ],
                ),
              ),
            ),
            if (contactPerson?.id == provider?.contactPersonSelected?.id)
              Container(
                width: 40,
                padding: const EdgeInsets.only(right: 0),
                child: MaterialButton(
                  onPressed: () {
                    provider.editContactPerson();
                  },
                  child: Icon(
                    Icons.edit,
                    size: 22,
                    color: Colors.black,
                  ),
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  FutureBuilder<String> buildAvatar(ContactPerson contactPerson) {
    return FutureBuilder<String>(
        future: provider.getImage(contactPerson.avatarFileName),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Image image;
            if (snapshot.data.isEmpty) {
              image =
                  Image.asset("assets/images/default_avatar.png", cacheWidth: 50, cacheHeight: 50, fit: BoxFit.cover);
            } else {
              image = Image.file(File(snapshot.data), fit: BoxFit.cover);
            }
            return image;
          }
          return Image.asset("assets/images/default_avatar.png", cacheWidth: 50, cacheHeight: 50, fit: BoxFit.cover);
        });
  }

  Widget renderWidgetByType(CheckInFlow item, int index) {
//    provider.visitorTypeItem?.isVisible = false;
//    provider.noteItem?.isVisible = false;
//    provider.genderItem?.isVisible = false;
//    provider.fromCompanyItem?.isVisible = false;
//    provider.companyBuildingItem?.isVisible = false;

    item.isVisible = true;
    var radius = AppDestination.RADIUS_TEXT_INPUT;
    var labelText = "";
    var widgetChild;
    switch (item.stepCode) {
//        case StepCode.VISITOR_TYPE:
//          {
//            provider.initItemFlow(item, index, provider.controllerType, focusNodes);
//            widgetChild = buildVisitorType(item, labelText, radius);
//            break;
//          }
      case StepCode.TO_COMPANY:
        {
//          if (provider.isBuilding) {
//            provider.initItemFlow(item, index, provider.controllerTo, focusNodes);
//            widgetChild = buildCompanyBuilding(provider.flows, item, labelText, radius);
//          } else {
          provider.initItemFlow(item, index, null, focusNodes);
          widgetChild = buildTextFormField(provider.flows, item, labelText, radius);
//          }
          break;
        }
      case StepCode.FROM_COMPANY:
        {
          var arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
          var visitorCheckIn = arguments["visitor"] as VisitorCheckIn;
          var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
          var percentSuggestHeight = isPortrait ? 50 : 30;
          if (item.initValue.isEmpty) {
            item.initValue = visitorCheckIn.fromCompany;
          }
          provider.initItemFlow(item, index, provider.controllerFrom, focusNodes);
          widgetChild = searchFromCompany(percentSuggestHeight, item, context, provider.flows, labelText);
          break;
        }
      case StepCode.PURPOSE:
        {
          var arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
          var visitorCheckIn = arguments["visitor"] as VisitorCheckIn;
          var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
          var percentSuggestHeight = isPortrait ? 50 : 30;
          if (item.initValue.isEmpty) {
            item.initValue = visitorCheckIn.purpose;
          }
          provider.initItemFlow(item, index, provider.controllerNote, focusNodes);
          widgetChild = buildSuggestionNote(percentSuggestHeight, item, context, provider.flows, labelText);
          break;
        }
      case StepCode.GENDER:
        {
          var arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
          var visitorCheckIn = arguments["visitor"] as VisitorCheckIn;
          var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
          var percentSuggestHeight = isPortrait ? 50 : 30;
          if (item.initValue.isEmpty) {
            item.initValue = visitorCheckIn.getGender(context);
          }
          provider.initItemFlow(item, index, provider.controllerGender, focusNodes);
          widgetChild = buildSuggestionGender(percentSuggestHeight, item, context, provider.flows, labelText);
          break;
        }
      default:
        {
          provider.initItemFlow(item, index, null, focusNodes);
          widgetChild = buildTextFormField(provider.flows, item, labelText, radius);
          break;
        }
    }
    return GestureDetector(
      onTap: () => Utilities().moveToWaiting(),
      child: Form(
        key: provider.keyList[item.index],
        child: widgetChild,
      ),
    );
  }

  Widget searchFromCompany(
    int percentSuggestHeight,
    CheckInFlow item,
    BuildContext context,
    List<CheckInFlow> convertList,
    String labelText,
  ) {
    if (provider.controllerFrom.text == null || provider.controllerFrom.text.isEmpty) {
      provider.controllerFrom.value = TextEditingValue(text: (item.initValue != null) ? item.initValue : "");
    }
    provider.fromCompanyItem = item;
    return Selector<InputInformationNotifier, bool>(
      builder: (context, data, child) => Selector<InputInformationNotifier, String>(
        builder: (context, data, child) {
          return TypeAheadField<String>(
            hideSuggestionsOnKeyboardHide: false,
            hideOnLoading: true,
            noItemsFoundBuilder: (context) => itemNone(),
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDestination.RADIUS_TEXT_INPUT),
                    side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
                constraints: BoxConstraints(maxHeight: SizeConfig.safeBlockVertical * percentSuggestHeight)),
            textFieldConfiguration: TextFieldConfiguration(
              textCapitalization: TextCapitalization.sentences,
              focusNode: focusNodes[item.index],
              inputFormatters: provider.inputFormat(item),
              onTap: () {
                Utilities().moveToWaiting();
                if (item.index > 0) {
                  provider.validateFieldBefore(item.index - 1);
                }
                scrollView(item, 500);
              },
              onSubmitted: (_) async {
                if ((item.index + 1) == provider.flows.length) {
                  if (provider.isContact) {
                    FocusScope.of(context).requestFocus(nodeContact);
                  } else {
                    Utilities().hideKeyBoard(context);
                    bool isValidate = true;
                    provider.keyList.forEach((key) {
                      if (!key.currentState.validate()) {
                        isValidate = false;
                        return;
                      }
                    });
                    await provider.checkIsNext(isValidate, false);
                  }
                } else {
                  nextFocus(context, item, convertList);
                }
              },
              controller: provider.controllerFrom,
              onChanged: (text) {
                item.initValue = text;
                Utilities().moveToWaiting();
              },
              style: Styles.formFieldText.copyWith(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                errorText: provider.errorFromCompany,
                errorStyle: TextStyle(fontSize: 0),
                helperText: " ",
                helperStyle: TextStyle(fontSize: 0),
                suffixIcon: (provider.valueFocus == item.stepCode)
                    ? GestureDetector(
                        onTap: () {
                          provider.controllerFrom.text = "";
                          item.initValue = "";
                        },
                        child: Container(
                          height: 56,
                          width: 56,
                          child: Icon(
                            Icons.cancel,
                            size: 24,
                            color: AppColor.HINT_TEXT_COLOR,
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(),
                labelText: labelText,
                hintStyle: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor, fontFamily: Styles.OpenSans),
              ),
            ),
            suggestionsCallback: (String pattern) async {
              return await provider.getSuggestionFromCompany(pattern);
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            itemBuilder: (context, String suggestion) {
              return itemFromCompany(suggestion);
            },
            onSuggestionSelected: (String suggestion) async {
              Utilities().moveToWaiting();
              provider.controllerFrom.text = suggestion;
              item.initValue = suggestion;
              if ((item.index + 1) == provider.flows.length) {
                Utilities().hideKeyBoard(context);
                bool isValidate = true;
                provider.keyList.forEach((key) {
                  if (!key.currentState.validate()) {
                    isValidate = false;
                    return;
                  }
                });
                await provider.checkIsNext(isValidate, false);
              } else {
                nextFocus(context, item, convertList);
              }
            },
          );
        },
        selector: (buildContext, provider) => provider.valueFocus,
      ),
      selector: (buildContext, provider) => provider.isReloadFrom,
    );
  }

  Widget buildSuggestionGender(
    int percentSuggestHeight,
    CheckInFlow item,
    BuildContext context,
    List<CheckInFlow> convertList,
    String labelText,
  ) {
    if (provider.controllerGender.text == null || provider.controllerGender.text.isEmpty) {
      provider.controllerGender.value = TextEditingValue(text: (item.initValue != null) ? item.initValue : "");
    }
    provider.genderItem = item;
    return Selector<InputInformationNotifier, bool>(
      builder: (context, data, child) => Selector<InputInformationNotifier, String>(
        builder: (context, data, child) {
          return TypeAheadField<String>(
            hideSuggestionsOnKeyboardHide: false,
            hideOnLoading: true,
            noItemsFoundBuilder: (context) => itemNone(),
            getImmediateSuggestions: true,
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDestination.RADIUS_TEXT_INPUT),
                    side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
                constraints: BoxConstraints(maxHeight: SizeConfig.safeBlockVertical * percentSuggestHeight)),
            textFieldConfiguration: TextFieldConfiguration(
              readOnly: true,
              showCursor: false,
              focusNode: focusNodes[item.index],
              onTap: () {
                if (item.index > 0) {
                  provider.validateFieldBefore(item.index - 1);
                }
                Utilities().moveToWaiting();
              },
              onSubmitted: (_) async {},
              controller: provider.controllerGender,
              onChanged: (text) {
                Utilities().moveToWaiting();
              },
              style: Styles.formFieldText.copyWith(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                errorText: provider.errorGender,
                errorStyle: TextStyle(fontSize: 0),
                helperText: " ",
                helperStyle: TextStyle(fontSize: 0),
                suffixIcon: (provider.valueFocus == item.stepCode)
                    ? GestureDetector(
                        onTap: () {
                          provider.controllerGender.text = "";
                          item.initValue = "";
                        },
                        child: Container(
                          height: 56,
                          width: 56,
                          child: Icon(
                            Icons.cancel,
                            size: 24,
                            color: AppColor.HINT_TEXT_COLOR,
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(),
                labelText: labelText,
                hintStyle: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor, fontFamily: Styles.OpenSans),
              ),
            ),
            suggestionsCallback: (String pattern) async {
              return [appLocalizations.male, appLocalizations.female];
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            itemBuilder: (context, String suggestion) {
              return itemGender(suggestion);
            },
            onSuggestionSelected: (String suggestion) async {
              Utilities().moveToWaiting();
              provider.controllerGender.text = suggestion;
              await Future.delayed(const Duration(milliseconds: 250));
              if ((item.index + 1) == provider.flows.length) {
                if (provider.isContact) {
                  FocusScope.of(context).requestFocus(nodeContact);
                } else {
                  Utilities().hideKeyBoard(context);
                  bool isValidate = true;
                  provider.keyList.forEach((key) {
                    if (!key.currentState.validate()) {
                      isValidate = false;
                      return;
                    }
                  });
                }
              } else {
                FocusScope.of(context).requestFocus(focusNodes[item.index + 1]);
                currentNodes = focusNodes[item.index + 1];
                provider.validateFieldBefore(item.index);
              }
            },
          );
        },
        selector: (buildContext, provider) => provider.valueFocus,
      ),
      selector: (buildContext, provider) => provider.isReloadGender,
    );
  }

  Widget buildSuggestionNote(
    int percentSuggestHeight,
    CheckInFlow item,
    BuildContext context,
    List<CheckInFlow> convertList,
    String labelText,
  ) {
    if (provider.controllerNote.text == null || provider.controllerNote.text.isEmpty) {
      provider.controllerNote.value = TextEditingValue(text: (item.initValue != null) ? item.initValue : "");
    }
    provider.noteItem = item;
    return Selector<InputInformationNotifier, bool>(
      builder: (context, data, child) => Selector<InputInformationNotifier, String>(
        builder: (context, data, child) {
          return TypeAheadField<String>(
            hideSuggestionsOnKeyboardHide: false,
            getImmediateSuggestions: false,
            hideOnLoading: true,
            hideOnEmpty: true,
            hideOnError: true,
            keepSuggestionsOnLoading: true,
            keepSuggestionsOnSuggestionSelected: false,
            noItemsFoundBuilder: (context) => itemNone(),
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDestination.RADIUS_TEXT_INPUT),
                    side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
                constraints: BoxConstraints(maxHeight: SizeConfig.blockSizeVertical * 40)),
            textFieldConfiguration: TextFieldConfiguration(
              textCapitalization: TextCapitalization.sentences,
              focusNode: focusNodes[item.index],
              inputFormatters: provider.inputFormat(item),
              onTap: () {
                Utilities().moveToWaiting();
              },
              onSubmitted: (_) async {
                if ((item.index + 1) == provider.flows.length) {
                  if (provider.isContact) {
                    FocusScope.of(context).requestFocus(nodeContact);
                  } else {
                    Utilities().hideKeyBoard(context);
                    bool isValidate = true;
                    provider.keyList.forEach((key) {
                      if (!key.currentState.validate()) {
                        isValidate = false;
                        return;
                      }
                    });
                    await provider.checkIsNext(isValidate, false);
                  }
                } else {
                  nextFocus(context, item, convertList);
                }
              },
              controller: provider.controllerNote,
              onChanged: (text) {
                item.initValue = text;
                Utilities().moveToWaiting();
              },
              style: Styles.formFieldText.copyWith(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                errorText: provider.errorNote,
                errorStyle: TextStyle(fontSize: 0),
                helperText: " ",
                helperStyle: TextStyle(fontSize: 0),
                suffixIcon: (provider.valueFocus == item.stepCode)
                    ? GestureDetector(
                        onTap: () {
                          provider.controllerNote.text = "";
                          item.initValue = "";
                        },
                        child: Container(
                          height: 56,
                          width: 56,
                          child: Icon(
                            Icons.cancel,
                            size: 24,
                            color: AppColor.HINT_TEXT_COLOR,
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(),
                labelText: labelText,
                hintStyle: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor, fontFamily: Styles.OpenSans),
              ),
            ),
            suggestionsCallback: (String pattern) {
              return List();
            },
            loadingBuilder: (context) {
              return Center(child: CircularProgressIndicator());
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            itemBuilder: (context, String suggestion) {
              return itemFromCompany(suggestion);
            },
            onSuggestionSelected: (String suggestion) async {
              Utilities().moveToWaiting();
              provider.controllerNote.text = suggestion;
              item.initValue = suggestion;
              if ((item.index + 1) == provider.flows.length) {
                Utilities().hideKeyBoard(context);
                bool isValidate = true;
                provider.keyList.forEach((key) {
                  if (!key.currentState.validate()) {
                    isValidate = false;
                    return;
                  }
                });
                await provider.checkIsNext(isValidate, false);
              } else {
                nextFocus(context, item, convertList);
              }
            },
          );
        },
        selector: (buildContext, provider) => provider.valueFocus,
      ),
      selector: (buildContext, provider) => provider.isReloadNote,
    );
  }

  Widget itemFromCompany(String fromCompany) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var percentBox = isPortrait ? 50 : 17;
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.public,
            size: 32,
            color: AppColor.HINT_TEXT_COLOR,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              fromCompany,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: AppDestination.TEXT_NORMAL + 3, fontFamily: Styles.OpenSans),
            ),
            Divider(height: 2, thickness: 1, color: AppColor.LINE_COLOR)
          ],
        )
      ],
    );
  }

  Widget itemCompanyBuilding(CompanyBuilding companyBuilding) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var widthText = isPortrait ? SizeConfig.safeBlockHorizontal * 70 : SizeConfig.safeBlockVertical * 50;
    return FutureBuilder<File>(
      future: Utilities().getLocalFile(
          Constants.FOLDER_TEMP, Constants.FILE_TYPE_COMPANY_BUILDING, companyBuilding.index.toString(), null),
      builder: (context, snapshot) {
        Image image;
        if (snapshot.hasData) {
          try {
            image = Image.memory(
              snapshot.data.readAsBytesSync(),
              width: 40,
              height: 40,
            );
          } catch (e) {
            image = Image.asset(
              "assets/images/waiting0.png",
              cacheWidth: 40,
              cacheHeight: 40,
            );
          }
        } else {
          image = null;
        }
        return Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: image ?? Container(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: widthText - 63,
                  padding: EdgeInsets.only(bottom: 10, top: 10),
                  child: AutoSizeText(
                    companyBuilding.companyName,
                    maxLines: 3,
                    minFontSize: 8,
                    maxFontSize: 16,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppDestination.TEXT_NORMAL + 5,
                      fontFamily: Styles.OpenSans,
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget buildCompanyBuilding(List<CheckInFlow> dataSources, CheckInFlow item, String labelText, double radius) {
    var convertList = List<CheckInFlow>();
    convertList.addAll(dataSources);
    convertList.removeWhere((element) => element.stepCode == StepCode.CAPTURE_FACE);
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var percentSuggestHeight = isPortrait ? 50 : 30;
    return Selector<InputInformationNotifier, bool>(
      builder: (context, data, child) => FutureBuilder<List<CompanyBuilding>>(
          future: provider.getCompanyBuilding(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              provider.buildInitValueTypeHead();
              var companyBuilding = snapshot.data;
              if (companyBuilding.isEmpty) {
                return buildTextFormField(dataSources, item, labelText, radius);
              }
              if (item.initValue.isEmpty) {
                item.initValue = provider.initValueBuilding;
              }
              provider.companyBuildingItem = item;
              return searchToCompany(percentSuggestHeight, item, context, convertList, labelText, companyBuilding);
            } else {
              if (snapshot.connectionState == ConnectionState.done) return Container();
              return CircularProgressIndicator();
            }
          }),
      selector: (buildContext, provider) => provider.isReloadCompany,
    );
  }

  Widget searchToCompany(int percentSuggestHeight, CheckInFlow item, BuildContext context,
      List<CheckInFlow> convertList, String labelText, List<CompanyBuilding> companyBuilding) {
    if (provider.controllerTo.text == null || provider.controllerTo.text.isEmpty) {
      provider.controllerTo.value = TextEditingValue(text: (item.initValue != null) ? item.initValue : "");
    }
    return Selector<InputInformationNotifier, String>(
      builder: (context, data, child) {
        return TypeAheadField<CompanyBuilding>(
          hideSuggestionsOnKeyboardHide: false,
          hideOnLoading: true,
          noItemsFoundBuilder: (context) => itemNone(),
          suggestionsBoxDecoration: SuggestionsBoxDecoration(
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDestination.RADIUS_TEXT_INPUT),
                  side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
              constraints: BoxConstraints(maxHeight: SizeConfig.safeBlockVertical * percentSuggestHeight)),
          textFieldConfiguration: TextFieldConfiguration(
            textCapitalization: TextCapitalization.sentences,
            focusNode: focusNodes[item.index],
            inputFormatters: provider.inputFormat(item),
            onTap: () {
              Utilities().moveToWaiting();
              if (item.index > 0) {
                provider.validateFieldBefore(item.index - 1);
              }
              scrollView(item, 500);
            },
            onSubmitted: (_) async {
              if ((item.index + 1) == provider.flows.length) {
                Utilities().hideKeyBoard(context);
                bool isValidate = true;
                provider.keyList.forEach((key) {
                  if (!key.currentState.validate()) {
                    isValidate = false;
                    return;
                  }
                });
                await provider.checkIsNext(isValidate, false);
              } else {
                nextFocus(context, item, convertList);
              }
            },
            controller: provider.controllerTo,
            onChanged: (text) {
              item.initValue = text;
              Utilities().moveToWaiting();
              provider.companyBuilding = null;
            },
            style: Styles.formFieldText,
            decoration: InputDecoration(
              errorText: provider.errorToCompany,
              errorStyle: TextStyle(fontSize: 0),
              helperText: " ",
              helperStyle: TextStyle(fontSize: 0),
              suffixIcon: (provider.valueFocus == item.stepCode)
                  ? GestureDetector(
                      onTap: () {
                        provider.controllerTo.text = "";
                        item.initValue = "";
                        provider.companyBuilding = null;
                      },
                      child: Container(
                        height: 56,
                        width: 56,
                        child: Icon(
                          Icons.cancel,
                          size: 24,
                          color: AppColor.HINT_TEXT_COLOR,
                        ),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(),
              labelText: labelText,
              hintStyle: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor, fontFamily: Styles.OpenSans),
            ),
          ),
          suggestionsCallback: (String pattern) async {
            return await provider.getSuggestionOffice(companyBuilding, pattern);
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          itemBuilder: (context, CompanyBuilding suggestion) {
            return itemCompanyBuilding(suggestion);
          },
          onSuggestionSelected: (CompanyBuilding suggestion) {
            Utilities().moveToWaiting();
            provider.controllerTo.text = suggestion.companyName;
            item.initValue = suggestion.companyName;
            provider.errorToCompany = null;
            provider.companyBuilding = suggestion;
            if ((item.index + 1) == provider.flows.length) {
              Utilities().hideKeyBoard(context);
              bool isValidate = true;
              provider.keyList.forEach((key) {
                if (!key.currentState.validate()) {
                  isValidate = false;
                  return;
                }
              });
//              if (isValidate) {
//                moveToNextPage();
//              }
            } else {
              nextFocus(context, item, convertList);
            }
          },
        );
      },
      selector: (buildContext, provider) => provider.valueFocus,
    );
  }

  Widget buildTextFormField(List<CheckInFlow> dataSources, CheckInFlow item, String labelText, double radius) {
    var convertList = List<CheckInFlow>();
    convertList.addAll(dataSources);
    convertList.removeWhere((element) => element.stepCode == StepCode.CAPTURE_FACE);

    var widgetChild = Selector<InputInformationNotifier, String>(
      builder: (context, data, child) {
        return TextFieldCommon(
            enabled: (item.stepCode != StepCode.PHONE_NUMBER),
            controller: provider.textEditingControllers[item.stepCode],
            validator: provider.checkingValidator(item),
            textCapitalization: provider.checkingCapitalization(item),
            keyboardType: provider.getKeyBoardType(item.stepType),
            textInputAction: TextInputAction.done,
            inputFormatters: provider.inputFormat(item),
            maxLines: item.stepType == StepType.MULTIPLE_TEXT ? 3 : 1,
            focusNode: focusNodes[item.index],
            decoration: InputDecoration(
              fillColor: (item.stepCode != StepCode.PHONE_NUMBER) ? Colors.white : Color(0xffEAEEF2),
              suffixIcon: (provider.valueFocus == item.stepCode)
                  ? GestureDetector(
                      onTap: () {
                        provider.textEditingControllers[item.stepCode].text = "";
                        item.initValue = '';
                      },
                      child: Container(
                        height: 56,
                        width: 56,
                        child: Icon(
                          Icons.cancel,
                          size: 24,
                          color: AppColor.HINT_TEXT_COLOR,
                        ),
                      ),
                    )
                  : null,
              labelText: labelText,
              errorStyle: TextStyle(fontSize: 0),
              helperText: " ",
              helperStyle: TextStyle(fontSize: 0),
            ),
            onEditingComplete: () async {
              //Condition hide keyboard
              if ((item.index + 1) == provider.flows.length) {
                if (provider.isContact) {
                  FocusScope.of(context).requestFocus(nodeContact);
                } else {
                  Utilities().hideKeyBoard(context);
                  bool isValidate = true;
                  provider.keyList.forEach((key) {
                    if (key.currentState?.validate() == false) {
                      isValidate = false;
                      return;
                    }
                  });
                  await provider.checkIsNext(isValidate, false);
                }
              } else {
                nextFocus(context, item, convertList);
              }
            },
            onTap: () {
              if (item.index > 0) {
                provider.validateFieldBefore(item.index - 1);
              }
            },
            onChanged: (text) {
              item.initValue = text;
              Utilities().moveToWaiting();
            },
            style: Styles.formFieldText.copyWith(
              fontWeight: FontWeight.bold,
            ));
      },
      selector: (buildContext, provider) => provider.valueFocus,
    );
    switch (item.stepCode) {
      case StepCode.FULL_NAME:
        {
          return Selector<InputInformationNotifier, String>(
              selector: (buildContext, provider) => provider.visitorBackup?.fullName,
              builder: (context, data, child) {
                if (provider.textEditingControllers[item.stepCode]?.text?.isNotEmpty != true) {
                  provider.textEditingControllers[item.stepCode].text = data;
                }
                return widgetChild;
              });
        }
      case StepCode.ID_CARD:
        {
          return Selector<InputInformationNotifier, String>(
              selector: (buildContext, provider) => provider.visitorBackup?.idCard,
              builder: (context, data, child) {
                if (provider.textEditingControllers[item.stepCode]?.text?.isNotEmpty != true) {
                  provider.textEditingControllers[item.stepCode].text = data;
                }
                return widgetChild;
              });
        }
      case StepCode.PERMANENT_ADDRESS:
        {
          return Selector<InputInformationNotifier, String>(
              selector: (buildContext, provider) => provider.visitorBackup?.permanentAddress,
              builder: (context, data, child) {
                if (provider.textEditingControllers[item.stepCode]?.text?.isNotEmpty != true) {
                  provider.textEditingControllers[item.stepCode].text = data;
                }
                return widgetChild;
              });
        }
      case StepCode.BIRTH_DAY:
        {
          return Selector<InputInformationNotifier, String>(
              selector: (buildContext, provider) => provider.visitorBackup?.birthDay,
              builder: (context, data, child) {
                if (provider.textEditingControllers[item.stepCode]?.text?.isNotEmpty != true) {
                  provider.textEditingControllers[item.stepCode].text = data;
                }
                return widgetChild;
              });
        }
      default:
        {
          return widgetChild;
        }
    }
  }

  void nextFocus(BuildContext context, CheckInFlow item, List<CheckInFlow> convertList) {
    FocusScope.of(context).requestFocus(focusNodes[item.index + 1]);
    currentNodes = focusNodes[item.index + 1];
    provider.validateFieldBefore(item.index);
    provider.keyList[item.index].currentState.validate();
    var stepCode = convertList[item.index + 1].stepCode;
    if (stepCode == StepCode.TO_COMPANY || stepCode == StepCode.FROM_COMPANY || stepCode == StepCode.PURPOSE) {
      scrollView(convertList[item.index + 1], 500);
    }
  }

  void scrollView(CheckInFlow item, int duration) {
    if ((item.index > 1 || focusNodes.length < 3) &&
        (!focusNodes[item.index].hasFocus || (focusNodes[item.index].hasFocus && provider.isShowLogo))) {
      Future.delayed(Duration(milliseconds: duration), () {
        provider.scrollController.animateTo(
          (Constants.HEIGHT_BUTTON + 20) * item.index,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      });
    }
  }

//  Widget buildVisitorType(CheckInFlow item, String labelText, double radius) {
//    return Selector<InputInformationNotifier, bool>(
//      builder: (context, data, child) {
//        provider.visitorTypeItem = item;
//        var visitorType = provider.listType;
//        if (provider.visitorBackup != null && provider.visitorType == null) {
//          provider.indexInitType = provider.getTypeInit(visitorType);
//          provider.visitorType =
//              (provider.indexInitType != null) ? visitorType[provider.indexInitType] : provider.indexInitType;
//        }
//        var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
//        var percentSuggestHeight = isPortrait ? 50 : 30;
//        if (provider.controllerType.text == null || provider.controllerType.text.isEmpty) {
//          provider.controllerType.value = TextEditingValue(
//              text: (provider.indexInitType != null)
//                  ? visitorType[provider.indexInitType].description
//                  : visitorType[0].description);
//        }
//        return TypeAheadField<VisitorType>(
//          hideSuggestionsOnKeyboardHide: false,
//          hideOnLoading: true,
//          noItemsFoundBuilder: (context) => itemNone(),
//          getImmediateSuggestions: true,
//          suggestionsBoxDecoration: SuggestionsBoxDecoration(
//              shadowColor: Colors.transparent,
//              shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(AppDestination.RADIUS_TEXT_INPUT),
//                  side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
//              constraints: BoxConstraints(maxHeight: SizeConfig.safeBlockVertical * percentSuggestHeight)),
//          textFieldConfiguration: TextFieldConfiguration(
//            readOnly: true,
//            showCursor: false,
//            focusNode: focusNodes[item.index],
//            onTap: () {
//              if (item.index > 0) {
//                provider.validateFieldBefore(item.index - 1);
//              }
//              Utilities().moveToWaiting();
//            },
//            onSubmitted: (_) async {},
//            controller: provider.controllerType,
//            onChanged: (text) {
//              Utilities().moveToWaiting();
//            },
//            style: Styles.formFieldText,
//            decoration: InputDecoration(
//              errorText: provider.errorVisitorType,
//              suffixIcon: (provider.valueFocus == item.stepCode)
//                  ? GestureDetector(
//                      onTap: () {
//                        provider.controllerType.text = "";
//                        item.initValue = "";
//                        provider.visitorType = null;
//                      },
//                      child: Container(
//                        height: 56,
//                        width: 56,
//                        child: Icon(
//                          Icons.cancel,
//                          size: 24,
//                          color: AppColor.HINT_TEXT_COLOR,
//                        ),
//                      ),
//                    )
//                  : null,
//              border: OutlineInputBorder(),
//              labelText: labelText,
//              hintStyle: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
//            ),
//          ),
//          suggestionsCallback: (String pattern) async {
//            return await provider.getVisitorType(context);
//          },
//          transitionBuilder: (context, suggestionsBox, controller) {
//            return suggestionsBox;
//          },
//          itemBuilder: (context, VisitorType suggestion) {
//            return itemVisitorType(suggestion);
//          },
//          onSuggestionSelected: (VisitorType suggestion) async {
//            Utilities().moveToWaiting();
//            provider.reloadFlow(suggestion);
//            await Future.delayed(const Duration(milliseconds: 250));
//            if ((item.index + 1) == provider.flows.length) {
//              Utilities().hideKeyBoard(context);
//              bool isValidate = true;
//              provider.keyList.forEach((key) {
//                if (!key.currentState.validate()) {
//                  isValidate = false;
//                  return;
//                }
//              });
////                    if (isValidate) {
////                      moveToNextPage();
////                    }
//            } else {
//              FocusScope.of(context).requestFocus(focusNodes[item.index + 1]);
//              currentNodes = focusNodes[item.index + 1];
//              provider.validateFieldBefore(item.index);
//            }
//          },
//        );
//      },
//      selector: (buildContext, provider) => provider.isReloadType,
//    );
//  }

  Widget itemVisitorType(VisitorType visitorType) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var percentBox = isPortrait ? 50 : 30;
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.person,
            size: 32,
            color: AppColor.HINT_TEXT_COLOR,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: SizeConfig.safeBlockHorizontal * percentBox,
              child: Text(visitorType.description,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppDestination.TEXT_NORMAL + 5,
                      fontFamily: Styles.OpenSans)),
            ),
            Divider(height: 2, thickness: 1, color: AppColor.LINE_COLOR)
          ],
        )
      ],
    );
  }

  Widget itemGender(String gender) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var percentBox = isPortrait ? 50 : 30;
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.person,
            size: 32,
            color: AppColor.HINT_TEXT_COLOR,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: SizeConfig.safeBlockHorizontal * percentBox,
              child:
                  Text(gender, style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppDestination.TEXT_NORMAL + 5)),
            ),
            Divider(height: 2, thickness: 1, color: AppColor.LINE_COLOR)
          ],
        )
      ],
    );
  }

  Widget itemNone() {
    return Visibility(
      child: Container(),
      visible: false,
    );
  }

  Widget buildReviewCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 25,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: locator<AppDestination>().getPadding(
                          context, AppDestination.PADDING_NORMAL, AppDestination.PADDING_NORMAL_HORIZONTAL, true)),
                  child: _buildPicturePreview(
                    105,
                    (provider.visitorBackup.imagePath?.isNotEmpty == true) ? provider.visitorBackup.imagePath : null,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, bottom: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    buildRowMain(appLocalizations.fullNameText,
                        provider.textEditingControllers[StepCode.FULL_NAME]?.text, context),
                    buildRowSub(appLocalizations.phoneText,
                        provider.textEditingControllers[StepCode.PHONE_NUMBER]?.text, context),
                    buildRowSub(
                        appLocalizations.idCardText, provider.textEditingControllers[StepCode.ID_CARD]?.text, context),
//                    buildRowSub(appLocalizations.birthDayText,
//                        provider.textEditingControllers[StepCode.BIRTH_DAY]?.text, context),
//                    buildRowSub(appLocalizations.permanentAddressText,
//                        provider.textEditingControllers[StepCode.PERMANENT_ADDRESS]?.text, context),
//                    buildRowSub(appLocalizations.fromText, provider.textEditingControllers[StepCode.FROM_COMPANY]?.text,
//                        context),
//                    buildRowSub(
//                        appLocalizations.toText, provider.textEditingControllers[StepCode.TO_COMPANY]?.text, context),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
          width: widthScreen * 38,
          child: RaisedGradientButton(
            isLoading: false,
            disable: false,
            btnText: appLocalizations.translate(AppString.BTN_CHECK_IN),
            textSize: 26,
            onPressed: () {
              provider.navigationService.navigatePop(context);
              provider.checkIsNext(true, true);
            },
          ),
        ),
      ],
    );
  }

  Widget buildRowSub(String title, String value, BuildContext context) {
    return Visibility(
      visible: (value != null && value.isNotEmpty),
      child: Container(
        padding: EdgeInsets.only(
            bottom: locator<AppDestination>()
                .getPadding(context, AppDestination.PADDING_NORMAL, AppDestination.PADDING_NORMAL_HORIZONTAL, true)),
        child: RichText(
            maxLines: 1,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: "$title:",
                    style: TextStyle(
                        fontSize: AppDestination.TEXT_NORMAL,
                        color: AppColor.BLACK_TEXT_COLOR,
                        fontFamily: Styles.OpenSans)),
                TextSpan(text: ' '),
                TextSpan(
                    text: value,
                    style: TextStyle(
                        fontSize: AppDestination.TEXT_NORMAL,
                        color: Colors.blue,
                        fontFamily: Styles.OpenSans,
                        fontWeight: FontWeight.bold)),
              ],
            )),
      ),
    );
  }

  Widget buildRowMain(String title, String value, BuildContext context) {
    return Visibility(
      visible: (value != null && value.isNotEmpty),
      child: Container(
        padding: EdgeInsets.only(
            bottom: locator<AppDestination>()
                .getPadding(context, AppDestination.PADDING_NORMAL, AppDestination.PADDING_NORMAL_HORIZONTAL, true)),
        child: RichText(
            maxLines: 1,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: '$title:',
                    style: TextStyle(
                        fontSize: AppDestination.TEXT_NORMAL,
                        color: AppColor.BLACK_TEXT_COLOR,
                        fontFamily: Styles.OpenSans)),
                TextSpan(text: '  '),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: locator<AppDestination>().getTextBigger(context),
                    color: AppColor.RED_TEXT_COLOR,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                    fontFamily: Styles.OpenSans,
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildPicturePreview(double size, String path) {
    return buildCircleLayout(
        size,
        Container(
          width: size,
          height: size,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi),
            child: (path != null)
                ? Image.file(
                    File(path),
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/images/default_avatar.png",
                  ),
          ), // this is my CameraPreview
        ));
  }

  Widget buildCircleLayout(double size, Widget child) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(360.0) //         <--- border radius here
              ),
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(360.0)),
          child: OverflowBox(
            alignment: Alignment.center,
            child: child,
          ),
        ));
  }

  @override
  void dispose() {
    focusNodes.forEach((element) {
      element.dispose();
    });
    currentNodes?.dispose();
    super.dispose();
  }
}

class TextFormFieldReviewInfo extends StatefulWidget {
  String title;
  bool isRequest = false;
  Widget child;

  TextFormFieldReviewInfo({this.title, this.isRequest, @required this.child});

  @override
  _TextFormFieldReviewInfoState createState() => _TextFormFieldReviewInfoState();
}

class _TextFormFieldReviewInfoState extends State<TextFormFieldReviewInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
            text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                text: widget.title,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontSize: 20, fontFamily: Styles.OpenSans, fontWeight: FontWeight.normal)),
            if (widget.isRequest)
              TextSpan(text: " *", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.red))
          ],
        )),
        SizedBox(
          height: 10,
        ),
        widget.child
      ],
    );
  }
}
