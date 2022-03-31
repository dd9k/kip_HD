import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:check_in_pro_for_visitor/src/constants/AppString.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/model/BaseResponse.dart';
import 'package:check_in_pro_for_visitor/src/model/CheckInFlow.dart';
import 'package:check_in_pro_for_visitor/src/model/CompanyBuilding.dart';
import 'package:check_in_pro_for_visitor/src/model/ContactPerson.dart';
import 'package:check_in_pro_for_visitor/src/model/Errors.dart';
import 'package:check_in_pro_for_visitor/src/model/IDModelHD.dart';
import 'package:check_in_pro_for_visitor/src/model/ImageDownloaded.dart';
import 'package:check_in_pro_for_visitor/src/model/ListContact.dart';
import 'package:check_in_pro_for_visitor/src/model/RepoUpload.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorType.dart';
import 'package:check_in_pro_for_visitor/src/model/idCard/IDCardHDBank.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainNotifier.dart';
import 'package:check_in_pro_for_visitor/src/screens/Thankyou/ThankYouScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/covidScreen/CovidScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/survey/SurveyScreen.dart';
import 'package:check_in_pro_for_visitor/src/screens/waiting/WaitingScreen.dart';
import 'package:check_in_pro_for_visitor/src/services/ApiCallBack.dart';
import 'package:check_in_pro_for_visitor/src/services/NavigationService.dart';
import 'package:check_in_pro_for_visitor/src/services/RequestApi.dart';
import 'package:check_in_pro_for_visitor/src/services/ServiceLocator.dart';
import 'package:check_in_pro_for_visitor/src/utilities/AppLocalizations.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Validator.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/PopupTakePhoto/PopupTakePhoto.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/PopupTakePhoto/PopupTakePhotoNotifier.dart';
import 'package:check_in_pro_for_visitor/src/widgetUtilities/TextFieldComon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiengviet/tiengviet.dart';
import 'package:uuid/uuid.dart';

import '../../constants/Constants.dart';
import '../../model/VisitorType.dart';
import 'package:check_in_pro_for_visitor/src/model/TakePhotoStep.dart';
import '../../utilities/Extensions.dart';

class InputInformationNotifier extends MainNotifier {
  final TextEditingController controllerTo = TextEditingController();
  String errorToCompany;
  bool isReloadCompany = false;
  CheckInFlow companyBuildingItem;

  final TextEditingController controllerFrom = TextEditingController();
  String errorFromCompany;
  bool isReloadFrom = false;
  CheckInFlow fromCompanyItem;

  final TextEditingController controllerType = TextEditingController();
  String errorVisitorType;
  bool isReloadType = false;
  CheckInFlow visitorTypeItem;

  final TextEditingController controllerNote = TextEditingController();
  String errorNote;
  bool isReloadNote = false;
  CheckInFlow noteItem;

  final TextEditingController controllerGender = TextEditingController();
  String errorGender;
  bool isReloadGender = false;
  CheckInFlow genderItem;

  ScrollController scrollController = ScrollController();
  String valueFocus = '';
  List<String> defaultPurpose = List();
  List<CompanyBuilding> listCompanyBuilding;
  bool isReload = false;
  CompanyBuilding companyBuilding;
  bool hideLoading = true;
  AsyncMemoizer<List<VisitorType>> memCache = AsyncMemoizer();
  AsyncMemoizer<List<CompanyBuilding>> memCacheCompany = AsyncMemoizer();
  AsyncMemoizer<List<CheckInFlow>> memCacheFlows = AsyncMemoizer();
  bool isLoading;
  bool isShowLogo = true;
  bool isShowFooter = true;
  bool isDelivery = false;
  GlobalKey<FormState> formKey = GlobalKey();
  var textFormFields = <TextFieldCommon>[];
  List<CheckInFlow> flows = List();
  Map<String, TextEditingController> textEditingControllers = {};
  List<GlobalKey<FormState>> keyList = List();
  BuildContext context;
  String initValueBuilding;
  bool isHaveCompany = false;
  VisitorCheckIn visitorBackup;
  ContactPerson contactPersonSelected;
  var indexInitType;
  var langSaved;
  var isBuilding = false;
  bool isDoneIdBack = false;
  bool isDoneIdFont = false;
  bool isDoneIdFace = false;
  bool isReturn = false;
  bool isSurvey = false;
  bool isContact = false;
  String qrGroupGuestUrl = "";

  bool isScanId = false;
  List<TakePhotoStep> takePhotoStep = List();
  List<TakePhotoStep> deleteTakePhotoStep = List();

  CancelableOperation cancelCheckIn;

  List<String> dummyData = [StepCode.CAPTURE_FACE, StepCode.PRINT_CARD, StepCode.SCAN_ID_CARD, StepCode.LEGAL_SIGN];

  CancelableOperation cancelableUploadID;
  CancelableOperation cancelableUploadIDBack;

  CancelableOperation cancelableOperation;

  CancelableOperation cancelSearch;
  List<ContactPerson> listContact = List();
  int pageIndex = 1;
//  int totalCount = 1;
  bool isCapture = false;
  bool isDie = false;

  bool isUpdating = false;
  String errorContact;

  Future<List<CheckInFlow>> getCheckInFlow() async {
    return memCacheFlows.runOnce(() async {
      visitorBackup = VisitorCheckIn.copyWithOther(arguments["visitor"] as VisitorCheckIn);
      isDelivery = arguments["isDelivery"] as bool ?? false;
      isReturn = arguments["isReturn"] as bool ?? false;
      isDie = arguments["isDie"] as bool ?? false;
      await renderFlowByType();
      getDefaultPurpose();
      isBuilding = await utilities.checkIsBuilding(preferences, db);
      isCapture = (isDie) ? isDie : await utilities.checkIsCapture(context, visitorBackup.visitorType);
      isScanId = await utilities.checkIsScanId(context, visitorBackup.visitorType);
      isSurvey = await utilities.isSurveyCustom(context, visitorBackup?.visitorType);
      isContact = await utilities.checkAllowContact(context, visitorBackup?.visitorType);
      isLoading = false;
      notifyListeners();
      return flows;
    });
  }

  void showHideLoading(bool isShow) {
    isLoading = isShow;
    notifyListeners();
  }

  void updateSelectedContact(ContactPerson contactPerson) {
    visitorBackup.contactPersonId = contactPerson.id;
    contactPersonSelected = contactPerson;
    notifyListeners();
  }
  void editContactPerson() {
    contactPersonSelected = null;
    notifyListeners();
  }

  void deletePhoto(PhotoStep step) {
    deleteTakePhotoStep.clear();
    deleteTakePhotoStep.add(TakePhotoStep.init(step));
    deleteTakePhotoStep.forEach(
      (element) {
        switch (element.photoStep) {
          case PhotoStep.FACE_STEP:
            {
              visitorBackup.imagePath = '';
              break;
            }
          case PhotoStep.ID_FONT_STEP:
            {
              visitorBackup.imageIdPath = '';
              break;
            }
          case PhotoStep.ID_BACK_STEP:
            {
              visitorBackup.imageIdBackPath = '';
              break;
            }
        }
      },
    );
    notifyListeners();
  }

  void showDialogPhoto(PhotoStep step) {
    utilities.moveToWaiting();
    takePhotoStep.clear();
    takePhotoStep.add(TakePhotoStep.init(step));
    if (isScanId) {
      if (step != PhotoStep.ID_FONT_STEP && visitorBackup?.imageIdPath?.isNotEmpty != true) {
        takePhotoStep.add(TakePhotoStep.init(PhotoStep.ID_FONT_STEP));
      }
      if (step != PhotoStep.ID_BACK_STEP && visitorBackup?.imageIdBackPath?.isNotEmpty != true) {
        takePhotoStep.add(TakePhotoStep.init(PhotoStep.ID_BACK_STEP));
      }
    }
    if (isCapture && step != PhotoStep.FACE_STEP && visitorBackup?.imagePath?.isNotEmpty != true) {
      takePhotoStep.add(TakePhotoStep.init(PhotoStep.FACE_STEP));
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (_) => PopupTakePhotoNotifier(),
          child: PopupTakePhoto(takePhotoStep: takePhotoStep, isOCR: true,),
        );
      },
    ).then(
      (argument) {
        bool isDone = argument["isDone"] as bool;
        if (isDone) {
          List<TakePhotoStep> takePhotoStep = argument["takePhotoStep"] as List<TakePhotoStep>;
          IDModelHD idCardHDBank = argument["idCardHDBank"] as IDModelHD;
          idCardHDBank?.createVisitor(visitorBackup, isReturn);
          takePhotoStep.forEach((element) {
            switch (element.photoStep) {
              case PhotoStep.FACE_STEP:
                {
                  visitorBackup.imagePath = element.pathSavedPhoto;
                  break;
                }
              case PhotoStep.ID_FONT_STEP:
                {
                  visitorBackup.imageIdPath = element.pathSavedPhoto;
                  break;
                }
              case PhotoStep.ID_BACK_STEP:
                {
                  visitorBackup.imageIdBackPath = element.pathSavedPhoto;
                  break;
                }
            }
            if (element.photoStep == takePhotoStep.last.photoStep) {
              notifyListeners();
            }
          });
        }
      },
    );
  }

  Future renderFlowByType() async {
    flows = await getFlowOffline();
    flows?.removeWhere((element) => element.getRequestType() == RequestType.HIDDEN);
    flows?.removeWhere((element) => dummyData.contains(element.stepCode));
    flows?.sort((a, b) => int.parse(a.sort).compareTo(int.parse(b.sort)));
    flows?.removeWhere((element) => (element.stepCode == StepCode.VISITOR_TYPE));
    var langSaved = preferences.getString(Constants.KEY_LANGUAGE) ?? Constants.VN_CODE;
    flows?.forEach((item) {
      var mapLang = json.decode(item.stepName);
      item.stepName = mapLang[langSaved];
    });
  }

  bool isContains() {
    var isContain = false;
    flows?.forEach((element) {
      if (element.stepCode == StepCode.TO_COMPANY) {
        isContain = true;
      }
    });
    return isContain;
  }

  Future<List<CheckInFlow>> getFlowOffline() async {
    return await db.checkInFlowDAO.getbyTemplateCode(visitorBackup.visitorType);
  }

  void _onFocusChange(FocusNode focus, CheckInFlow item) {
    if (focus.hasFocus) {
      valueFocus = item.stepCode;
      notifyListeners();
    } else {
      valueFocus = '';
      notifyListeners();
    }
  }

  void initItemFlow(CheckInFlow item, int index, TextEditingController controller, List<FocusNode> focusNodes) {
    item.index = index;
    // Focus on textfield
    var _focus = FocusNode();
    _focus.addListener(() {
      _onFocusChange(_focus, item);
    });
    focusNodes.add(_focus);
    keyList.add(GlobalKey());
    item.initValue = item.buildInitValue(context, visitorBackup);
    if (controller != null) {
      textEditingControllers.putIfAbsent(item.stepCode, () => controller);
    } else {
      var textEditingController = new TextEditingController();
      textEditingControllers.putIfAbsent(item.stepCode, () => textEditingController);
      textEditingController.value = TextEditingValue(text: item.initValue);
    }
  }

  Future<bool> checkIsNext(bool isValidate, bool isNext, {bool isShowError = false}) async {
    isDoneIdBack = false;
    isDoneIdFont = false;
    isDoneIdFace = false;
    errorContact = null;
    var isErrorTo = await handlerToCompany(context, controllerTo.text);
    var isErrorGender = await handlerGender(context, controllerGender.text);
    var isErrorFrom = await handlerFromCompany(context, controllerFrom.text);
    var isVisitorType = await handlerVisitorType(context, controllerType.text);
    var isErrorNote = await handlerNote(context, controllerNote.text);
    if (!parent.isConnection) {
      contactPersonSelected = ContactPerson.empty();
    }
    var isFlowEmpty = (flows == null || flows.isEmpty);
    var visitorCheckIn = isFlowEmpty ? visitorBackup : await _retrieveValues();
    if (isScanId && (visitorCheckIn?.imageIdPath?.isNotEmpty != true || visitorCheckIn?.imageIdBackPath?.isNotEmpty != true)) {
      utilities.showErrorPop(context, appLocalizations.noIdPhoto, null, null);
      return false;
    }
    if (isCapture && visitorCheckIn?.imagePath?.isNotEmpty != true) {
      utilities.showErrorPop(context, appLocalizations.noFacePhoto, null, null);
      return false;
    }
    if (isVisitorType && isErrorTo &&
        isErrorGender &&
        isErrorFrom &&
        isValidate &&
        isNext &&
        isErrorNote &&
        (!isContact || (isContact && contactPersonSelected != null))) {
      if (!parent.isBEAlive) {
        utilities.showErrorPop(context, appLocalizations.translate(AppString.NO_INTERNET), 5, () {});
        return false;
      }
      bool isUpload = visitorCheckIn?.imagePath?.isNotEmpty == true ||
          visitorCheckIn?.imageIdPath?.isNotEmpty == true ||
          visitorCheckIn?.imageIdBackPath?.isNotEmpty == true;
      if (!isSurvey) {
        showHideLoading(true);
        if (parent.isConnection && parent.isBEAlive) {
          actionOnline(isUpload, visitorCheckIn);
        } else {
          await actionOffline(visitorCheckIn);
        }
      } else {
        moveToNextPage(visitorCheckIn, HomeNextScreen.SURVEY);
      }
    } else if (isShowError) {
      if (!(isVisitorType && isErrorTo && isErrorGender && isErrorFrom && isValidate && isErrorNote)) {
        utilities.showErrorPop(context, appLocalizations.errorInputInfor, null, null);
      } else if (isContact && contactPersonSelected == null) {
        errorContact = "";
        notifyListeners();
        utilities.showErrorPop(context, appLocalizations.noContactPerson, null, null);
      }
    }
    return (isVisitorType && isErrorTo && isErrorGender && isErrorFrom && isValidate && isErrorNote && (!isContact || (isContact && contactPersonSelected != null)));
  }

  Future actionOffline(VisitorCheckIn visitorCheckIn) async {
    String pathFace;
    if (visitorCheckIn?.imagePath?.isNotEmpty == true) {
      String fileName = '${DateTime.now()}.png';
      String folderName = Constants.FOLDER_FACE_OFFLINE;
      String tempPath = visitorCheckIn.imagePath;
      pathFace = (await utilities.saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(visitorCheckIn.imagePath)?.readAsBytesSync()))?.path ?? tempPath;
      visitorCheckIn.imagePath = fileName;
    }
    if (visitorCheckIn?.imageIdPath?.isNotEmpty == true) {
      String fileName = '${DateTime.now()}${Constants.SCAN_VISION}.png';
      String folderName = Constants.FOLDER_ID_OFFLINE;
      await Utilities().saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(visitorCheckIn.imageIdPath)?.readAsBytesSync());
      visitorCheckIn.imageIdPath = fileName;
    }
    if (visitorCheckIn?.imageIdBackPath?.isNotEmpty == true) {
      String fileName = '${DateTime.now()}${Constants.BACKSIDE_SCAN_VISION}.png';
      String folderName = Constants.FOLDER_ID_BACK_OFFLINE;
      await Utilities().saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(visitorCheckIn.imageIdBackPath)?.readAsBytesSync());
      visitorCheckIn.imageIdBackPath = fileName;
    }
    await callApiAC(visitorCheckIn, pathFace);
    await db.visitorCheckInDAO.insert(visitorCheckIn);
    moveToNextPage(visitorCheckIn, HomeNextScreen.THANK_YOU);
  }

  Future<bool> callApiAC(VisitorCheckIn visitorCheckIn, String imagePath) async {
    Completer completer = Completer<bool>();
    ApiCallBack callBackLogin = ApiCallBack((BaseResponse baseResponse) async {
      var authenticationString = JsonEncoder().convert(baseResponse.data);
      preferences.setString(Constants.KEY_AUTHENTICATE_AC, authenticationString);
      final uuid = Uuid();
      String fileName = uuid.v1();
      ApiRequest().requestLogBackup(context, visitorCheckIn.fullName, visitorCheckIn.phoneNumber, fileName, imagePath,
          ApiCallBack((BaseResponse baseResponse) async {
            completer.complete(true);
          }, (Errors message) async {
            completer.complete(false);
          }));
    }, (Errors message) async {
      completer.complete(false);
    });
    ApiRequest().requestLoginAC(context, callBackLogin);
    return completer.future;
  }

  void actionOnline(bool isUpload, VisitorCheckIn visitorCheckIn) {
    if (isUpload) {
      if (visitorCheckIn?.imagePath?.isNotEmpty == true) {
        uploadFace(visitorCheckIn);
      } else {
        isDoneIdFace = true;
      }
      if (visitorCheckIn?.imageIdPath?.isNotEmpty == true) {
        uploadIdCardOnline(visitorCheckIn, false);
      } else {
        isDoneIdFont = true;
      }
      if (visitorCheckIn?.imageIdBackPath?.isNotEmpty == true) {
        uploadIdCardOnline(visitorCheckIn, true);
      } else {
        isDoneIdBack = true;
      }
    } else {
      registerVisitor(visitorCheckIn);
    }
  }

  Future<bool> handlerToCompany(BuildContext context, String value) async {
    if (value.isEmpty &&
        isBuilding &&
        isHaveCompany &&
        companyBuildingItem?.isVisible == true &&
        listCompanyBuilding != null &&
        listCompanyBuilding.isNotEmpty &&
        (companyBuildingItem?.getRequestType() == RequestType.ALWAYS ||
            companyBuildingItem?.getRequestType() == RequestType.FIRST)) {
      errorToCompany = AppLocalizations.of(context).errorNo.replaceAll("field_name", companyBuildingItem?.stepName);
      isReloadCompany = !isReloadCompany;
      notifyListeners();
      return false;
    }
    if (listCompanyBuilding != null && listCompanyBuilding.isNotEmpty && companyBuildingItem?.isVisible == true) {
      errorToCompany = null;
      isReloadCompany = !isReloadCompany;
      notifyListeners();
    }
    return true;
  }

  Future<bool> handlerGender(BuildContext context, String value) async {
    if (value.isEmpty &&
        genderItem?.isVisible == true &&
        (genderItem?.getRequestType() == RequestType.ALWAYS || genderItem?.getRequestType() == RequestType.FIRST)) {
      errorGender = AppLocalizations.of(context).errorNo.replaceAll("field_name", genderItem?.stepName);
      isReloadGender = !isReloadGender;
      notifyListeners();
      return false;
    }
    if (genderItem?.isVisible == true) {
      errorGender = null;
      isReloadGender = !isReloadGender;
      notifyListeners();
    }
    return true;
  }

  Future<bool> handlerFromCompany(BuildContext context, String value) async {
    if (value.isEmpty &&
        fromCompanyItem?.isVisible == true &&
        (fromCompanyItem?.getRequestType() == RequestType.ALWAYS ||
            fromCompanyItem?.getRequestType() == RequestType.FIRST)) {
      errorFromCompany = AppLocalizations.of(context).errorNo.replaceAll("field_name", fromCompanyItem?.stepName);
      isReloadFrom = !isReloadFrom;
      notifyListeners();
      return false;
    }
    if (fromCompanyItem?.isVisible == true) {
      errorFromCompany = null;
      isReloadFrom = !isReloadFrom;
      notifyListeners();
    }
    return true;
  }

  Future<bool> handlerNote(BuildContext context, String value) async {
    if (value.isEmpty &&
        noteItem?.isVisible == true &&
        (noteItem?.getRequestType() == RequestType.ALWAYS || noteItem?.getRequestType() == RequestType.FIRST)) {
      errorNote = AppLocalizations.of(context).errorNo.replaceAll("field_name", noteItem?.stepName);
      isReloadNote = !isReloadNote;
      notifyListeners();
      return false;
    }
    if (noteItem?.isVisible == true) {
      errorNote = null;
      isReloadNote = !isReloadNote;
      notifyListeners();
    }
    return true;
  }

  void validateFieldBefore(int index) {
    List<CheckInFlow> convertList = List();
    convertList.addAll(flows);
    switch (convertList[index].stepCode) {
      case StepCode.PURPOSE:
        {
          handlerNote(context, controllerNote.text);
          break;
        }
      case StepCode.FROM_COMPANY:
        {
          handlerFromCompany(context, controllerFrom.text);
          break;
        }
      case StepCode.TO_COMPANY:
        {
          handlerToCompany(context, controllerTo.text);
          break;
        }
      case StepCode.GENDER:
        {
          handlerGender(context, controllerGender.text);
          break;
        }
      case StepCode.VISITOR_TYPE:
        {
          handlerVisitorType(context, controllerType.text);
          break;
        }
      default:
        {
          keyList[index].currentState.validate();
          break;
        }
    }
  }

  Future<bool> handlerVisitorType(BuildContext context, String value) async {
    if (value.isEmpty &&
        visitorTypeItem?.isVisible == true &&
        (visitorTypeItem?.getRequestType() == RequestType.ALWAYS ||
            visitorTypeItem?.getRequestType() == RequestType.FIRST)) {
      errorVisitorType = AppLocalizations.of(context).errorNo.replaceAll("field_name", visitorTypeItem?.stepName);
      isReloadType = !isReloadType;
      notifyListeners();
      return false;
    }
    if (visitorTypeItem?.isVisible == true) {
      errorVisitorType = null;
      isReloadType = !isReloadType;
      notifyListeners();
    }
    return true;
  }

  void buildInitValueTypeHead() {
    var visitorCheckIn = arguments["visitor"] as VisitorCheckIn;
    initValueBuilding = (initValueBuilding == null) ? (visitorCheckIn.toCompany ?? "") : controllerTo.text;
  }

  Future<VisitorCheckIn> _retrieveValues() async {
    var tempData = VisitorCheckIn.createVisitorByInput(context, flows, textEditingControllers, visitorBackup);

    tempData.id = 0;
    if (isBuilding) {
      if (companyBuilding != null) {
        tempData.toCompany = companyBuilding.companyName;
        tempData.toCompanyId = companyBuilding.id;
        tempData.contactPersonId = companyBuilding.representativeId;
        tempData.floor = companyBuilding.floor;
      } else {
        var isMatch = false;
        if (listCompanyBuilding != null && listCompanyBuilding.isNotEmpty && tempData.toCompany != null) {
          await Future.forEach(listCompanyBuilding, (CompanyBuilding element) {
            if (element.companyName.toLowerCase() == tempData.toCompany.toLowerCase() && !isMatch) {
              isMatch = true;
              tempData.toCompany = element.companyName;
              tempData.toCompanyId = element.id;
              tempData.contactPersonId = element.representativeId;
              tempData.floor = element.floor;
            }
          });
        }
      }
    }

    var userInfor = Utilities().getUserInforNew(preferences);
    tempData.signInBy = userInfor?.deviceInfo?.id ?? 0;
    return tempData;
  }

  TextInputType getKeyBoardType(String type) {
    switch (type?.toUpperCase()) {
      case StepType.TEXT:
        return TextInputType.text;

      case StepType.PHONE:
        return TextInputType.number;

      case StepType.EMAIL:
        return TextInputType.emailAddress;

      case StepType.NUMBER:
        return TextInputType.number;

      case StepType.MULTIPLE_TEXT:
        return TextInputType.multiline;

      default:
        return TextInputType.text;
    }
  }

  List<String> getDefaultPurpose() {
    Constants.DEFAULT_PURPOSE.forEach((element) {
      defaultPurpose.add(AppLocalizations.of(context).translate(element));
    });
    return defaultPurpose;
  }

  List<TextInputFormatter> inputFormat(CheckInFlow item) {
    switch (item?.stepType?.toUpperCase()) {
      case StepType.TEXT:
        {
          if (item?.stepCode == StepCode.FULL_NAME) {
            return <TextInputFormatter>[
              AutoCapWordsInputFormatter(),
              BlacklistingTextInputFormatter(RegExp("[0-9!#\$\"%&'()*+,-./:;<=>?@[\\]^_`{|}~₫¥€§…]")),
              LengthLimitingTextInputFormatter(30),
            ];
          }
          if (item?.stepCode == StepCode.BIRTH_DAY) {
            return <TextInputFormatter>[
              LengthLimitingTextInputFormatter(30),
            ];
          }
          if (item?.stepCode == StepCode.PERMANENT_ADDRESS) {
            return <TextInputFormatter>[
              LengthLimitingTextInputFormatter(150),
            ];
          }
          if (item?.stepCode == StepCode.TO_COMPANY || item?.stepCode == StepCode.FROM_COMPANY) {
            return <TextInputFormatter>[
              AutoCapWordsInputFormatter(),
              BlacklistingTextInputFormatter(RegExp("[!#\$\"%&'()*+,-./:;<=>?@[\\]^_`{|}~₫¥€§…]")),
              LengthLimitingTextInputFormatter(50),
            ];
          }
          return <TextInputFormatter>[
            UpperCaseFirstLetterFormatter(),
            BlacklistingTextInputFormatter(RegExp("[!#\$\"%&'()*+,-./:;<=>?@[\\]^_`{|}~₫¥€§…]")),
            LengthLimitingTextInputFormatter(50),
          ];
        }

      case StepType.PHONE:
        return <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(30),
        ];

      case StepType.EMAIL:
        return <TextInputFormatter>[
          LengthLimitingTextInputFormatter(30),
        ];

      case StepType.NUMBER:
        return <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(30),
        ];

      case StepType.MULTIPLE_TEXT:
        return <TextInputFormatter>[
          LengthLimitingTextInputFormatter(200),
        ];

      default:
        return <TextInputFormatter>[
          LengthLimitingTextInputFormatter(30),
        ];
    }
  }

  TextCapitalization checkingCapitalization(CheckInFlow item) {
    if (item?.stepCode == StepCode.FULL_NAME) {
      return TextCapitalization.words;
    }
    return TextCapitalization.sentences;
  }

  FormFieldValidator<String> checkingValidator(CheckInFlow item) {
    switch (item.stepType?.toUpperCase()) {
      case StepType.TEXT:
        if (item.getRequestType() == RequestType.ALWAYS || item.getRequestType() == RequestType.FIRST) {
          ValidatorLabel _validator = new ValidatorLabel(context);
          _validator.setStrParam(item.stepName);
          if (item.stepCode == StepCode.FULL_NAME) return _validator.validateName;
          return _validator.validateText;
        }
        return null;

      case StepType.MULTIPLE_TEXT:
        if (item.getRequestType() == RequestType.ALWAYS || item.getRequestType() == RequestType.FIRST) {
          ValidatorLabel _validator = new ValidatorLabel(context);
          _validator.setStrParam(item.stepName);
          if (item.stepCode == StepCode.FULL_NAME) return _validator.validateName;
          return _validator.validateText;
        }
        return null;

      case StepType.PHONE:
        ValidatorLabel _validator = new ValidatorLabel(context);
        if (item.getRequestType() == RequestType.ALWAYS || item.getRequestType() == RequestType.FIRST) {
          _validator.setStrParam(item.stepName);
          return _validator.validatePhoneNumber;
        }
        return _validator.validatePhoneWithoutRequire;

      case StepType.NUMBER:
        ValidatorLabel _validator = new ValidatorLabel(context);
        if (item.stepCode == StepCode.PHONE_NUMBER) {
          if (item.getRequestType() == RequestType.ALWAYS || item.getRequestType() == RequestType.FIRST) {
            _validator.setStrParam(item.stepName);
            return _validator.validatePhoneNumber;
          }
          return _validator.validatePhoneWithoutRequire;
        } else if (item.getRequestType() == RequestType.ALWAYS || item.getRequestType() == RequestType.FIRST) {
          _validator.setStrParam(item.stepName);
          return _validator.validateText;
        }
        return null;

      case StepType.EMAIL:
        ValidatorLabel _validator = new ValidatorLabel(context);
        if (item.getRequestType() == RequestType.ALWAYS || item.getRequestType() == RequestType.FIRST) {
          _validator.setStrParam(item.stepName);
          return _validator.validateEmail;
        }
        return _validator.validateEmailWithoutRequire;

      default:
        return null;
    }
  }

//  Future<List<VisitorType>> getSuggestions(
//      List<VisitorType> list, String query) async {
//    var completer = new Completer<List<VisitorType>>();
//    var convertList = List<VisitorType>();
//    list.forEach((element) {
//      var convertItem = VisitorType(
//          element.settingKey, element.settingValue, element.description);
//      convertList.add(convertItem);
//    });
//    var preferences = await SharedPreferences.getInstance();
//    var langSaved =
//        preferences.getString(Constants.KEY_LANGUAGE) ?? Constants.EN_CODE;
//    if (!Constants.LIST_LANG.contains(langSaved)) {
//      langSaved = Constants.EN_CODE;
//    }
//    convertList.forEach((element) {
//      mapLang = json.decode(element.description);
//      element.description = mapLang[langSaved];
//    });
//    var returnList = convertList
//        .where((item) =>
//            item.description.toLowerCase().contains(query.toLowerCase()))
//        .toList();
//    completer.complete(returnList);
//    listType = returnList;
//    return completer.future;
//  }

  Future<List<CompanyBuilding>> getSuggestionOffice(List<CompanyBuilding> list, String query) async {
    return await db.companyBuildingDAO.getDataByCompanyName(query);
  }

  Future<List<String>> getSuggestionFromCompany(String query) async {
    return await db.visitorCompanyDAO.searchCompanyNameForVisitor(query);
  }

  List<String> getSuggestionNote(String query) {
    if (query.isEmpty || query == null) {
      return defaultPurpose;
    }
    return defaultPurpose.where((element) => tiengviet(element).contains(tiengviet(query))).toList();
  }

  int getTypeInit(List<VisitorType> list) {
    var convertList = List<VisitorType>();
    list.forEach((element) {
      var convertItem = VisitorType(
          element.settingKey,
          element.settingValue,
          element.description,
          element.isTakePicture,
          element.isScanIdCard,
          element.isSurvey,
          element.isPrintCard,
          element.allowToDisplayContactPerson);
      convertList.add(convertItem);
    });

//    convertList.forEach((element) {
//      mapLang = json.decode(element.description);
//      element.description = mapLang[langSaved];
//    });

    var settingKey = visitorBackup.visitorType;
    int index;
    if (settingKey != null) {
      convertList.asMap().forEach((key, value) {
        if (value.settingKey.toLowerCase() == settingKey.toLowerCase()) {
          index = key;
        }
      });
    }
    return index;
  }

  Future<List<CompanyBuilding>> getCompanyBuilding(BuildContext context) async {
    langSaved = preferences.getString(Constants.KEY_LANGUAGE) ?? Constants.VN_CODE;
    if (!Constants.LIST_LANG.contains(langSaved)) {
      langSaved = Constants.EN_CODE;
    }
    var list = await getCompany(context);
    return list;
  }

  Future<List<CompanyBuilding>> getCompany(BuildContext context) async {
    return memCacheCompany.runOnce(() async {
      var completer = new Completer<List<CompanyBuilding>>();
      listCompanyBuilding = await db.companyBuildingDAO.isExistData();
      if (listCompanyBuilding == null) {
        listCompanyBuilding = List();
      }
      completer.complete(listCompanyBuilding);
      return completer.future;
    });
  }

  void actionWhenUploadDone(VisitorCheckIn visitorCheckIn) {
    if (isDoneIdBack && isDoneIdFace && isDoneIdFont) {
      registerVisitor(visitorCheckIn);
    }
  }

  Future<void> registerVisitor(VisitorCheckIn visitor) async {
    ApiCallBack listCallBack = ApiCallBack((BaseResponse baseResponse) async {
      //Callback SUCCESS
      VisitorCheckIn visitorCheckIn = VisitorCheckIn.fromJson(baseResponse.data);
      qrGroupGuestUrl = visitorCheckIn.qrGroupGuestUrl;
      db.visitorDAO.insertNewOrUpdateOld(visitor);
      if (visitorCheckIn.fromCompany != null && visitorCheckIn.fromCompany.isNotEmpty) {
        db.visitorCompanyDAO.insertCompanyName(visitorCheckIn.fromCompany.trim());
      }
      bool isCovid = await Utilities().isSurveyCovid(context, visitorCheckIn.visitorType);
      if (isCovid) {
        moveToNextPage(visitor, HomeNextScreen.COVID);
      } else {
        moveToNextPage(visitor, HomeNextScreen.THANK_YOU);
      }
    }, (Errors message) async {
      if (message.code == ApiRequest.CODE_DIE) {
        actionOffline(visitor);
      } else {
        //Callback ERROR
        if (message.code != -2) {
          Utilities().showErrorPop(context, message.description, null, null);
        }
        showHideLoading(false);
      }
    });

    cancelCheckIn = await ApiRequest().requestRegisterVisitor(context, visitor.toJson(), listCallBack);
  }

  Future uploadIdCardOnline(VisitorCheckIn visitorCheckIn, bool isBack) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var repoUpload = RepoUpload.fromJson(baseResponse.data);
      if (isBack) {
        visitorCheckIn.idCardBackRepoId = repoUpload.captureFaceRepoId;
        visitorCheckIn.idCardBackFile = repoUpload.captureFaceFile;
        isDoneIdBack = true;
      } else {
        visitorCheckIn.idCardRepoId = repoUpload.captureFaceRepoId;
        visitorCheckIn.idCardFile = repoUpload.captureFaceFile;
        isDoneIdFont = true;
      }
      actionWhenUploadDone(visitorCheckIn);
    }, (Errors message) {
      if (message.code != -2) {
        if (isBack) {
          isDoneIdBack = true;
        } else {
          isDoneIdFont = true;
        }
        actionWhenUploadDone(visitorCheckIn);
      } else {
        showHideLoading(false);
      }
    });
    var convertCancel = isBack ? cancelableUploadIDBack : cancelableUploadID;
    convertCancel = await ApiRequest().requestUploadIDCard(context, isBack ? visitorCheckIn.imageIdBackPath : visitorCheckIn.imageIdPath, callBack);
    await convertCancel.valueOrCancellation();
  }

  Future uploadFace(VisitorCheckIn visitorCheckIn) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var repoUpload = RepoUpload.fromJson(baseResponse.data);
      visitorCheckIn.faceCaptureRepoId = repoUpload.captureFaceRepoId;
      visitorCheckIn.faceCaptureFile = repoUpload.captureFaceFile;
      isDoneIdFace = true;
      actionWhenUploadDone(visitorCheckIn);
    }, (Errors message) {
      if (message.code == ApiRequest.CODE_DIE) {
        actionOffline(visitorCheckIn);
      } else {
        if (message.code != -2) {
          Utilities().showErrorPop(context, message.description, Constants.AUTO_HIDE_LONG, () {
            showHideLoading(false);
          });
        } else {
          showHideLoading(false);
        }
      }
    });
    cancelableOperation = await ApiRequest().requestUploadFace(context, visitorCheckIn.imagePath, callBack);
    await cancelableOperation.valueOrCancellation();
  }

  Future<void> moveToNextPage(VisitorCheckIn visitorCheckIn, HomeNextScreen type) async {
    showHideLoading(false);
    switch (type) {
      case HomeNextScreen.SURVEY:
        {
          locator<NavigationService>().navigateTo(SurveyScreen.route_name, 1, arguments: {'visitor': visitorCheckIn, 'isQRScan': false, 'isDie' : isDie, 'qrGroupGuestUrl': qrGroupGuestUrl});
          break;
        }
      case HomeNextScreen.COVID:
        {
          locator<NavigationService>().navigateTo(CovidScreen.route_name, 1, arguments: {'visitor': visitorCheckIn, 'isQRScan': false, 'qrGroupGuestUrl': qrGroupGuestUrl});
          break;
        }
      case HomeNextScreen.THANK_YOU:
        {
          locator<NavigationService>()
              .pushNamedAndRemoveUntil(ThankYouScreen.route_name, WaitingScreen.route_name, arguments: {
            'visitor': visitorCheckIn,
            'qrGroupGuestUrl': qrGroupGuestUrl
          });
          break;
        }
      default:
        {
          break;
        }
    }
  }

  void clearList() {
    listContact = List();
    isUpdating = false;
    isLoading = false;
    pageIndex = 1;
    cancelSearch?.cancel();
    notifyListeners();
  }

  Future<List<ContactPerson>> getContactPerson(BuildContext context, String input, bool isUpdate) async {
    var completer = Completer<List<ContactPerson>>();
    if (input == null || input.length < 2) {
      clearList();
      return null;
    } else {
      if (isUpdate) {
        isUpdating = true;
        pageIndex++;
      } else {
        cancelSearch?.cancel();
        pageIndex = 1;
      }
      notifyListeners();
      ApiCallBack listCallBack = ApiCallBack((BaseResponse baseResponse) async {
        //Callback SUCCESS
        if (baseResponse?.data == null) {
          clearList();
          completer.complete(List());
          return;
        }
        var data = ListContact.fromJson(baseResponse.data);
        if (data != null && data.listContact != null) {
          var listResponse = data.listContact;
//            totalCount = data.totalCount;
          if (isUpdate) {
            List<ContactPerson> convertList = List();
            convertList.addAll(listContact);
            convertList.addAll(listResponse);
            listContact = convertList;
            isUpdating = false;
          } else {
            listContact = listResponse;
          }
          notifyListeners();
        } else {
          clearList();
        }
        completer.complete(listContact);
      }, (Errors message) async {
        //Callback ERROR
//          totalCount = 0;
        if (!isUpdate) {
          clearList();
          completer.complete(List());
          return;
        } else {
          isUpdating = false;
          pageIndex--;
        }
        notifyListeners();
      });
      var currentInfor = await utilities.getUserInfor();
      var branchId = currentInfor?.deviceInfo?.branchId ?? 0.0;
      cancelSearch = await ApiRequest().requestSearchContact(context, input, pageIndex, branchId, listCallBack);
      return completer.future;
    }
  }

  Future<String> getImage(String base64) async {
    if (base64?.isNotEmpty == true) {
      try {
        String pathSaved;
        var shortLink = utilities.shortBase64(base64);
        ImageDownloaded imageDownloaded = await db.imageDownloadedDAO.getByLink(shortLink);
        if (imageDownloaded != null) {
          pathSaved = await Utilities()
              .getLocalPathFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_IMAGE_EVENT, imageDownloaded.localPath, null);
        } else {
          var base64Decoded = Base64Decoder().convert(base64.split(',').last).toList();
          pathSaved = (await Utilities()
              .saveLocalFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_IMAGE_EVENT, DateTime.now().millisecondsSinceEpoch.toString(), null, base64Decoded))
              .path;
          List<String> paths = pathSaved.split(Constants.FILE_TYPE_IMAGE_EVENT);
          await db.imageDownloadedDAO.insert(ImageDownloaded(shortLink, paths.last));
        }
        return pathSaved;
      } catch (e) {
        return "";
      }
    }
    return "";
  }

  @override
  void dispose() {
    cancelCheckIn?.cancel();
    cancelableUploadID?.cancel();
    cancelableUploadIDBack?.cancel();
    cancelableOperation?.cancel();
    super.dispose();
  }
}
