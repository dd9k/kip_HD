import 'dart:convert';

import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/model/EventLog.dart';
import 'package:check_in_pro_for_visitor/src/model/RepoUpload.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorLog.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:flutter/material.dart';
import 'dart:isolate';
import 'dart:io';
import 'package:check_in_pro_for_visitor/src/database/Database.dart';
import 'package:provider/provider.dart';
import 'package:check_in_pro_for_visitor/src/services/RequestApi.dart';
import 'package:check_in_pro_for_visitor/src/services/ApiCallBack.dart';
import 'package:check_in_pro_for_visitor/src/model/BaseResponse.dart';
import 'package:check_in_pro_for_visitor/src/model/Errors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SyncService {
  Isolate isolate;
  Database db;
  SharedPreferences preferences;

  Future<void> syncAllLog(BuildContext context) async {
    db = Provider.of<Database>(context, listen: false);
    var logs = await db.visitorCheckInDAO.getAll();
    if (preferences == null) {
      preferences = await SharedPreferences.getInstance();
    }
    if (logs?.isEmpty != false) {
      preferences.setInt(Constants.KEY_LAST_SYNC, DateTime.now().millisecondsSinceEpoch);
      return;
    }
    logs.forEach((VisitorCheckIn visitorCheckIn) async {
      await Future.delayed(new Duration(milliseconds: 500));
      bool isUpload = visitorCheckIn?.imagePath?.isNotEmpty == true ||
          visitorCheckIn?.imagePath?.isNotEmpty == true ||
          visitorCheckIn?.imagePath?.isNotEmpty == true;
      if (isUpload) {
        if (visitorCheckIn?.imagePath?.isNotEmpty == true) {
          String folderName = Constants.FOLDER_FACE_OFFLINE;
          visitorCheckIn.imagePath =
              await Utilities().getLocalPathFile(folderName, "", visitorCheckIn?.imagePath, Constants.PNG_ETX);
          uploadFace(context, visitorCheckIn);
        } else {
          visitorCheckIn?.isDoneIdFace = true;
        }
        if (visitorCheckIn?.imageIdPath?.isNotEmpty == true) {
          String folderName = Constants.FOLDER_ID_OFFLINE;
          visitorCheckIn.imageIdPath =
              await Utilities().getLocalPathFile(folderName, "", visitorCheckIn?.imageIdPath, Constants.PNG_ETX);
          uploadIdCardOnline(context, visitorCheckIn, false);
        } else {
          visitorCheckIn?.isDoneIdFont = true;
        }
        if (visitorCheckIn?.imageIdBackPath?.isNotEmpty == true) {
          String folderName = Constants.FOLDER_ID_BACK_OFFLINE;
          visitorCheckIn.imageIdBackPath =
              await Utilities().getLocalPathFile(folderName, "", visitorCheckIn?.imageIdBackPath, Constants.PNG_ETX);
          uploadIdCardOnline(context, visitorCheckIn, true);
        } else {
          visitorCheckIn?.isDoneIdBack = true;
        }
      } else {
        registerVisitor(context, visitorCheckIn);
      }
    });
  }

  void actionWhenUploadDone(BuildContext context, VisitorCheckIn visitorCheckIn) {
    if (visitorCheckIn?.isDoneIdBack == true && visitorCheckIn?.isDoneIdFace == true && visitorCheckIn?.isDoneIdFont == true) {
      registerVisitor(context, visitorCheckIn);
    }
  }

  Future<void> registerVisitor(BuildContext context, VisitorCheckIn visitor) async {
    ApiCallBack listCallBack = ApiCallBack((BaseResponse baseResponse) async {
      clearData(visitor);
    }, (Errors message) async {
      if (message.code != -2 && message.code != ApiRequest.CODE_DIE) {
        clearData(visitor);
      }
    });
    visitor.isOnline = true;
    ApiRequest().requestRegisterVisitor(context, visitor.toJson(), listCallBack);
  }

  Future uploadIdCardOnline(BuildContext context, VisitorCheckIn visitorCheckIn, bool isBack) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var repoUpload = RepoUpload.fromJson(baseResponse.data);
      if (isBack) {
        visitorCheckIn.idCardBackRepoId = repoUpload.captureFaceRepoId;
        visitorCheckIn.idCardBackFile = repoUpload.captureFaceFile;
        visitorCheckIn.isDoneIdBack = true;
      } else {
        visitorCheckIn.idCardRepoId = repoUpload.captureFaceRepoId;
        visitorCheckIn.idCardFile = repoUpload.captureFaceFile;
        visitorCheckIn.isDoneIdFont = true;
      }
      actionWhenUploadDone(context, visitorCheckIn);
    }, (Errors message) {
      if (message.code != -2) {
        if (isBack) {
          visitorCheckIn.isDoneIdBack = true;
        } else {
          visitorCheckIn.isDoneIdFont = true;
        }
        actionWhenUploadDone(context, visitorCheckIn);
      }
    });
    ApiRequest().requestUploadIDCard(context, isBack ? visitorCheckIn.imageIdBackPath : visitorCheckIn.imageIdPath, callBack);
  }

  Future uploadFace(BuildContext context, VisitorCheckIn visitorCheckIn) async {
    ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
      var repoUpload = RepoUpload.fromJson(baseResponse.data);
      visitorCheckIn.faceCaptureRepoId = repoUpload.captureFaceRepoId;
      visitorCheckIn.faceCaptureFile = repoUpload.captureFaceFile;
      visitorCheckIn.isDoneIdFace = true;
      actionWhenUploadDone(context, visitorCheckIn);
    }, (Errors message) {
      if (message.code != -2 && message.code != ApiRequest.CODE_DIE) {
        clearData(visitorCheckIn);
      }
    });
    await ApiRequest().requestUploadFace(context, visitorCheckIn.imagePath, callBack);
  }

  Future<void> syncEventFail(BuildContext context) async {
    var db = Provider.of<Database>(context, listen: false);
    var logs = await db.eventLogDAO.getFailLogs();
    if (logs?.isNotEmpty == true) {
      logs.forEach((element) async {
        await Future.delayed(new Duration(milliseconds: 500));
        ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
          var eventLog = EventLog.fromJson(baseResponse.data);
          if (element.inviteCode == null || element.inviteCode.isEmpty) {
            element.inviteCode = eventLog.inviteCode;
          }
          element.visitorLogId = eventLog.visitorLogId;
          element.syncFail = false;
          element.isNew = false;
          db.eventLogDAO.updateRow(element);
        }, (Errors message) async {

        });
        element.isOnline = true;
        String imagePath;
        String imageIdPath;
        String imageIdBackPath;
        if (element?.imagePath?.isNotEmpty == true) {
          String folderName = Constants.FOLDER_FACE_OFFLINE;
          imagePath = await Utilities().getLocalPathFile(folderName, "", element?.imagePath, Constants.PNG_ETX);
        }
        if (element?.imageIdPath?.isNotEmpty == true) {
          String folderName = Constants.FOLDER_ID_OFFLINE;
          imageIdPath = await Utilities().getLocalPathFile(folderName, "", element?.imageIdPath, Constants.PNG_ETX);
        }
        if (element?.imageIdBackPath?.isNotEmpty == true) {
          String folderName = Constants.FOLDER_ID_BACK_OFFLINE;
          imageIdBackPath = await Utilities().getLocalPathFile(folderName, "", element?.imageIdBackPath, Constants.PNG_ETX);
        }
        ApiRequest().requestSyncEvent(context, element, imagePath, imageIdPath, imageIdBackPath, callBack);
      });
    }
  }

  Future<void> syncEventCheckout(BuildContext context, EventLog eventLog) async {
    if (eventLog != null) {
      ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
        var convert = EventLog.fromJson(baseResponse.data);
        if (eventLog.inviteCode == null || eventLog.inviteCode.isEmpty) {
          eventLog.inviteCode = convert.inviteCode;
        }
        eventLog.visitorLogId = convert.visitorLogId;
        eventLog.syncFail = false;
        eventLog.isNew = false;
        db.eventLogDAO.updateRow(eventLog);
      }, (Errors message) async {
        eventLog.syncFail = true;
        db.eventLogDAO.updateRow(eventLog);
      });
      String imagePath;
      String imageIdPath;
      String imageIdBackPath;
      if (eventLog?.imagePath?.isNotEmpty == true) {
        String folderName = Constants.FOLDER_FACE_OFFLINE;
        imagePath = await Utilities().getLocalPathFile(folderName, "", eventLog?.imagePath, Constants.PNG_ETX);
      }
      if (eventLog?.imageIdPath?.isNotEmpty == true) {
        String folderName = Constants.FOLDER_ID_OFFLINE;
        imageIdPath = await Utilities().getLocalPathFile(folderName, "", eventLog?.imageIdPath, Constants.PNG_ETX);
      }
      if (eventLog?.imageIdBackPath?.isNotEmpty == true) {
        String folderName = Constants.FOLDER_ID_BACK_OFFLINE;
        imageIdBackPath = await Utilities().getLocalPathFile(folderName, "", eventLog?.imageIdBackPath, Constants.PNG_ETX);
      }
      ApiRequest().requestSyncEvent(context, eventLog, imagePath, imageIdPath, imageIdBackPath, callBack);
    }
  }

  Future<void> syncEventNow(BuildContext context, EventLog eventLog) async {
    if (eventLog != null) {
      var db = Provider.of<Database>(context, listen: false);
      ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
        var convert = EventLog.fromJson(baseResponse.data);
        if (eventLog.inviteCode == null || eventLog.inviteCode.isEmpty) {
          eventLog.inviteCode = convert.inviteCode;
        }
        eventLog.visitorLogId = convert.visitorLogId;
        eventLog.syncFail = false;
        eventLog.isNew = false;
        if (eventLog?.imagePath?.isNotEmpty == true) {
          String fileName = '${DateTime.now()}.png';
          String folderName = Constants.FOLDER_FACE_OFFLINE;
          await Utilities().saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(eventLog.imagePath).readAsBytesSync());
          eventLog.imagePath = fileName;
        }
        if (eventLog?.imageIdPath?.isNotEmpty == true) {
          String fileName = '${DateTime.now()}${Constants.SCAN_VISION}.png';
          String folderName = Constants.FOLDER_ID_OFFLINE;
          await Utilities().saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(eventLog.imageIdPath).readAsBytesSync());
          eventLog.imageIdPath = fileName;
        }
        if (eventLog?.imageIdBackPath?.isNotEmpty == true) {
          String fileName = '${DateTime.now()}${Constants.BACKSIDE_SCAN_VISION}.png';
          String folderName = Constants.FOLDER_ID_BACK_OFFLINE;
          await Utilities().saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(eventLog.imageIdBackPath).readAsBytesSync());
          eventLog.imageIdBackPath = fileName;
        }
        db.eventLogDAO.updateRow(eventLog);
      }, (Errors message) async {
        eventLog.syncFail = true;
        String pathFace;
        if (eventLog?.imagePath?.isNotEmpty == true) {
          String fileName = '${DateTime.now()}.png';
          String folderName = Constants.FOLDER_FACE_OFFLINE;
          pathFace = (await Utilities().saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(eventLog.imagePath).readAsBytesSync())).path;
          eventLog.imagePath = fileName;
        }
        if (eventLog?.imageIdPath?.isNotEmpty == true) {
          String fileName = '${DateTime.now()}${Constants.SCAN_VISION}.png';
          String folderName = Constants.FOLDER_ID_OFFLINE;
          await Utilities().saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(eventLog.imageIdPath).readAsBytesSync());
          eventLog.imageIdPath = fileName;
        }
        if (eventLog?.imageIdBackPath?.isNotEmpty == true) {
          String fileName = '${DateTime.now()}${Constants.BACKSIDE_SCAN_VISION}.png';
          String folderName = Constants.FOLDER_ID_BACK_OFFLINE;
          await Utilities().saveLocalFile(folderName, "", fileName, Constants.PNG_ETX, File(eventLog.imageIdBackPath).readAsBytesSync());
          eventLog.imageIdBackPath = fileName;
        }
//        callApiAC(context, VisitorCheckIn.copyWithEventLog(eventLog), pathFace);
        db.eventLogDAO.updateRow(eventLog);
      });
      ApiRequest().requestSyncEvent(context, eventLog, eventLog.imagePath, eventLog.imageIdPath, eventLog.imageIdBackPath, callBack);
    }
  }

  void callApiAC(BuildContext context, VisitorCheckIn visitorCheckIn, String imagePath) {
    ApiCallBack callBackLogin = ApiCallBack((BaseResponse baseResponse) async {
      if (preferences == null) {
        preferences = await SharedPreferences.getInstance();
      }
      var authenticationString = JsonEncoder().convert(baseResponse.data);
      preferences.setString(Constants.KEY_AUTHENTICATE_AC, authenticationString);
      final uuid = Uuid();
      String fileName = uuid.v1();
      ApiRequest().requestLogBackup(context, visitorCheckIn.fullName, visitorCheckIn.phoneNumber, fileName, imagePath,
          ApiCallBack((BaseResponse baseResponse) async {}, (Errors message) async {}));
    }, (Errors message) async {});
    ApiRequest().requestLoginAC(context, callBackLogin);
  }

  Future clearData(VisitorCheckIn element) async {
    await Utilities().deleteFileWithPath(element?.imagePath);
    await Utilities().deleteFileWithPath(element?.imageIdPath);
    await Utilities().deleteFileWithPath(element?.imageIdBackPath);
    db.visitorCheckInDAO.deleteById(element.localId);
//    var newLogs = await db.visitorCheckInDAO.getAll();
//    if (newLogs.length == 0) {
//      prefer.setInt(Constants.KEY_LAST_SYNC, DateTime.now().millisecondsSinceEpoch);
//    }
  }

  void stopService() {
    if (isolate != null) {
      isolate.kill(priority: Isolate.immediate);
    }
  }
}
