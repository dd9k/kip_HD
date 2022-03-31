import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/model/BaseListResponse.dart';
import 'package:check_in_pro_for_visitor/src/model/BaseResponse.dart';
import 'package:check_in_pro_for_visitor/src/model/Errors.dart';
import 'package:check_in_pro_for_visitor/src/model/Event.dart';
import 'package:check_in_pro_for_visitor/src/model/EventDetail.dart';
import 'package:check_in_pro_for_visitor/src/model/EventTicket.dart';
import 'package:check_in_pro_for_visitor/src/model/EventTicketDetail.dart';
import 'package:check_in_pro_for_visitor/src/model/ImageDownloaded.dart';
import 'package:check_in_pro_for_visitor/src/screens/MainNotifier.dart';
import 'package:check_in_pro_for_visitor/src/screens/settting/SettingScreen.dart';
import 'package:check_in_pro_for_visitor/src/services/ApiCallBack.dart';
import 'package:check_in_pro_for_visitor/src/services/RequestApi.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../../widgetUtilities/awesomeDialog/awesome_dialog.dart';

class AdvancedNotifier extends MainNotifier {
  AsyncMemoizer<List<Event>> memCache = AsyncMemoizer();
  AsyncMemoizer<List<EventTicket>> memCacheTicket = AsyncMemoizer();
  int countBackground = 0;
  bool isReload = false;
  bool isReloadTicket = false;
  bool isDoneImage = false;
  bool isDoneDetail = false;
  double eventId;
  double eventTicketId;
  Event event;
  List<Event> listEvent = List();
  List<EventTicket> listEventTicket = List();
  var eventMode = false;
  bool isHaveEvent = false;
  bool isEventTicket = false;
  RoundedLoadingButtonController btnController = new RoundedLoadingButtonController();
  var completerEvent = new Completer<List<Event>>();
  var completerEventTicket = new Completer<List<EventTicket>>();
  double branchId;

  Future<List<ItemSwitch>> getSaveItems() async {
    eventMode = (preferences.getBool(Constants.KEY_EVENT) ?? false);
    eventId = preferences.getDouble(Constants.KEY_EVENT_ID);
    eventTicketId = preferences.getDouble(Constants.KEY_EVENT_TICKET_ID);
    isHaveEvent = preferences.getBool(Constants.FUNCTION_EVENT) ?? false;
    isEventTicket = utilities.getUserInforNew(preferences).isEventTicket;
    List<ItemSwitch> items = <ItemSwitch>[
      ItemSwitch(
          title: appLocalizations.eventMode,
          subtitle: appLocalizations.eventModeSub,
          icon: Icons.event,
          isSelect: eventMode,
          switchType: SwitchType.EVENT),
    ];
    if (isHaveEvent) {
      var currentInfor = utilities.getUserInforNew(preferences);
      var branchIdNew = currentInfor?.deviceInfo?.branchId ?? 0.0;
      if (branchId != null && branchIdNew != branchId) {
        memCache = AsyncMemoizer();
        memCacheTicket = AsyncMemoizer();
        completerEvent = new Completer<List<Event>>();
        completerEventTicket = new Completer<List<EventTicket>>();
      }
      branchId = branchIdNew;
      if (isEventTicket) {
        await getEventTicket(context);
      } else {
        await getEvent(context);
      }
    }
    if (!(listEvent?.isNotEmpty == true) && !(listEventTicket?.isNotEmpty == true)) {
      noEventAction();
    }
    return items;
  }

  Future<void> switchItem(Function animation, ItemSwitch item) async {
    switch (item.switchType) {
      case SwitchType.EVENT:
        {
          if (!item.isSelect && listEvent.isEmpty && listEventTicket.isEmpty) {
            Utilities().showErrorPop(context, appLocalizations.noEvent, null, null);
          } else {
            item.isSelect = !item.isSelect;
            preferences.setBool(Constants.KEY_EVENT, item.isSelect);
            if (!item.isSelect) {
              noEventAction();
            }
            animation();
            eventMode = item.isSelect;
            notifyListeners();
          }
          break;
        }
      default:
        {}
    }
  }

  Future<List<Event>> getEvent(BuildContext context) async {
    return memCache.runOnce(() async {
      try {
        ApiCallBack callBack = ApiCallBack((BaseListResponse baseListResponse) async {
          listEvent.clear();
          if (baseListResponse.data != null) {
            listEvent = baseListResponse.data.map((Map model) => Event.fromJson(model)).toList();
            if (listEvent == null || listEvent.length <= 0) {
              preferences.setDouble(Constants.KEY_EVENT_ID, null);
            } else {
              var isHaveEvent = false;
              for (Event element in listEvent) {
                if (element.id == eventId) {
                  element.isSelect = true;
                  isHaveEvent = true;
                  event = element;
                  break;
                }
              }
              if (!isHaveEvent) {
                listEvent[0].isSelect = true;
                event = listEvent[0];
                eventId = listEvent[0].id;
                preferences.setDouble(Constants.KEY_EVENT_ID, eventId);
              }
              listEvent.sort((a, b) => a.isSelect ? 0 : 1);
            }
          }
          completerEvent.complete(listEvent);
        }, (Errors message) async {
          if (message.code != -2) {
            Utilities().showErrorPop(context, message.description, null, null);
          }
          memCache = AsyncMemoizer();
        });
        var currentInfor = Utilities().getUserInforNew(preferences);
        var branchId = currentInfor?.deviceInfo?.branchId ?? 0.0;
        await ApiRequest().requestAllEvent(context, branchId, callBack);
        return completerEvent.future;
      } catch (e) {}
      return null;
    });
  }

  Future<List<EventTicket>> getEventTicket(BuildContext context) async {
    return memCacheTicket.runOnce(() async {
      try {
        ApiCallBack callBack = ApiCallBack((BaseListResponse baseListResponse) async {
          listEventTicket.clear();
          if (baseListResponse.data != null) {
            listEventTicket = baseListResponse.data.map((Map model) => EventTicket.fromJson(model)).toList();
            await db.eventTicketDAO.deleteAll();
            await db.eventTicketDAO.insertAll(listEventTicket);
            if (listEventTicket == null || listEventTicket.length <= 0) {
              preferences.setDouble(Constants.KEY_EVENT_TICKET_ID, null);
            } else {
              var isHaveEvent = false;
              for (EventTicket element in listEventTicket) {
                if (element.id == eventTicketId) {
                  element.isSelect = true;
                  isHaveEvent = true;
                  break;
                }
              }
              if (!isHaveEvent) {
                listEventTicket[0].isSelect = true;
                eventTicketId = listEventTicket[0].id;
                preferences.setDouble(Constants.KEY_EVENT_TICKET_ID, eventTicketId);
              }
              listEventTicket.sort((a, b) => a.isSelect ? 0 : 1);
            }
          }
          completerEventTicket.complete(listEventTicket);
        }, (Errors message) async {
          if (message.code != -2) {
            Utilities().showErrorPop(context, message.description, null, null);
          }
          memCacheTicket = AsyncMemoizer();
        });
        var currentInfor = Utilities().getUserInforNew(preferences);
        var branchId = currentInfor?.deviceInfo?.branchId ?? 0.0;
        await ApiRequest().requestGetAllEventTicket(context, callBack);
        return completerEventTicket.future;
      } catch (e) {}
      return null;
    });
  }

  Future noEventAction() async {
    preferences.setBool(Constants.KEY_EVENT, false);
    preferences.setDouble(Constants.KEY_EVENT_ID, null);
    preferences.setDouble(Constants.KEY_EVENT_TICKET_ID, null);
    await db.eventDetailDAO.deleteAll();
    await db.eTOrderDetailInfoDAO.deleteAll();
    await db.eTOrderInfoDAO.deleteAll();
    await db.eventTicketDAO.deleteAll();
    preferences.setBool(Constants.KEY_SYNC_EVENT, false);
    preferences.setString(Constants.KEY_COVER_EVENT, "");
  }

  void syncEventNormal(Function(bool) onLoading) {
    countBackground = 0;
    (SettingScreen.of(context).imageLocalPath).clear();
    isDoneImage = false;
    isDoneDetail = false;
    onLoading(true);
    getEventDetails(onLoading);
    preferences.setString(Constants.KEY_COVER_EVENT, "");
    (SettingScreen.of(context).imageLocalPath).clear();
    List<String> listConvert = List();
    if (event?.coverImages?.isNotEmpty == true) {
      if (event?.isSlider == 1) {
        for (int i = 0; i < event.coverImages.length; i++) {
          getImage(event.coverImages[i], i, onLoading);
          listConvert.add(utilities.shortBase64(event.coverImages[i]));
        }
      } else {
        event.coverImages.removeRange(1, event.coverImages.length);
        getImage(event.coverImages[0], 0, onLoading);
        listConvert.add(utilities.shortBase64(event.coverImages[0]));
      }
      preferences.setString(Constants.KEY_COVER_EVENT, json.encode(listConvert));
    } else {
      isDoneImage = true;
    }
  }

  Future<List<Event>> getEventDetails(Function(bool) onLoading) async {
    try {
      await db.eventDetailDAO.deleteAll();
      var completer = new Completer<List<Event>>();
      ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
        var eventDetail = EventDetail.fromJson(baseResponse.data);
        db.eventDetailDAO.insert(eventDetail);
        preferences.setBool(Constants.KEY_SYNC_EVENT, true);
        isDoneDetail = true;
        handlerDone(onLoading, false);
      }, (Errors message) async {
        isDoneDetail = true;
        handlerDone(onLoading, true);
        preferences.setBool(Constants.KEY_SYNC_EVENT, false);
        if (message.code != -2) {
          var errorText = message.description;
          if (message.description == appLocalizations.noData || message.description == appLocalizations.errorInviteCode) {
            errorText = appLocalizations.noGuestEvent;
          }
          Utilities().showErrorPop(context, errorText, null, null);
        }
      });
      await ApiRequest().requestEventDetails(context, eventId, callBack);
      return completer.future;
    } catch (e) {}
    return null;
  }

  Future getImage(String base64, int index, Function(bool) onLoading) async {
    try {
      String pathSaved;
      var shortLink = utilities.shortBase64(base64);
      ImageDownloaded imageDownloaded = await db.imageDownloadedDAO.getByLink(shortLink);
      if (imageDownloaded != null) {
        pathSaved = await Utilities()
            .getLocalPathFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_IMAGE_EVENT, imageDownloaded.localPath, null);
      } else {
        var nameSaved = utilities.nameFromBase64(base64);
        var base64Decoded = Base64Decoder().convert(base64.split(',').last).toList();
        pathSaved = (await Utilities()
                .saveLocalFile(Constants.FOLDER_TEMP, Constants.FILE_TYPE_IMAGE_EVENT, nameSaved, null, base64Decoded))
            .path;
        List<String> paths = pathSaved.split(Constants.FILE_TYPE_IMAGE_EVENT);
        await db.imageDownloadedDAO.insert(ImageDownloaded(shortLink, paths.last));
      }
      (SettingScreen.of(context).imageLocalPath).add(pathSaved);
      countBackground++;
      if (countBackground == event.coverImages.length) {
        isDoneImage = true;
        handlerDone(onLoading, false);
      }
    } catch (e) {
      countBackground++;
      if (countBackground == event.coverImages.length) {
        isDoneImage = true;
        handlerDone(onLoading, true);
      }
    }
  }

  void handlerDone(Function(bool) onLoading, bool isError) {
    if (isDoneDetail && isDoneImage) {
      onLoading(false);
      if (!isError) {
        utilities.showNoButtonDialog(context, true, DialogType.SUCCES, Constants.AUTO_HIDE_LITTLE,
            appLocalizations.successTitle, appLocalizations.successTitle, null);
      }
    }
  }

  Future<List<EventTicketDetail>> getEventTicketDetails(BuildContext context, Function(bool) onLoading) async {
    try {
      await db.eTOrderDetailInfoDAO.deleteAll();
      await db.eTOrderInfoDAO.deleteAll();
      await db.eventTicketDAO.deleteAll();
      onLoading(true);
      var completer = new Completer<List<EventTicketDetail>>();
      ApiCallBack callBack = ApiCallBack((BaseResponse baseResponse) async {
        var eventDetail = EventTicketDetail.fromJson(baseResponse.data);
        await db.eTOrderInfoDAO.insertAll(eventDetail.orderInfo);
        await db.eventTicketDAO.insert(eventDetail.eventInfo);
        preferences.setBool(Constants.KEY_SYNC_EVENT, true);
        onLoading(false);
        utilities.showNoButtonDialog(context, true, DialogType.SUCCES, Constants.AUTO_HIDE_LITTLE,
            appLocalizations.successTitle, appLocalizations.successTitle, null);
      }, (Errors message) async {
        preferences.setBool(Constants.KEY_SYNC_EVENT, false);
        onLoading(false);
        if (message.code != -2) {
          var errorText = message.description;
          if (message.description == appLocalizations.noData) {
            errorText = appLocalizations.noGuestEvent;
          }
          Utilities().showErrorPop(context, errorText, null, null);
        }
      });
      await ApiRequest().requestEventTicketDetails(context, eventTicketId, callBack);
      return completer.future;
    } catch (e) {}
    return null;
  }

  void updateList(Event event) {
    if (eventId != event.id) {
      preferences.setBool(Constants.KEY_SYNC_EVENT, false);
    }
    eventId = event.id;
    this.event = event;
    preferences.setDouble(Constants.KEY_EVENT_ID, eventId);
    preferences.setDouble(Constants.KEY_EVENT_TICKET_ID, null);
    listEvent.forEach((element) {
      if (element.id == eventId) {
        element.isSelect = true;
      } else {
        element.isSelect = false;
      }
    });
    isReload = !isReload;
    notifyListeners();
  }

  void updateListTicket(EventTicket event) {
    if (eventTicketId != event.id) {
      preferences.setBool(Constants.KEY_SYNC_EVENT, false);
    }
    eventTicketId = event.id;
    preferences.setDouble(Constants.KEY_EVENT_TICKET_ID, eventTicketId);
    preferences.setDouble(Constants.KEY_EVENT_ID, null);
    listEventTicket.forEach((element) {
      if (element.id == eventTicketId) {
        element.isSelect = true;
      } else {
        element.isSelect = false;
      }
    });
    isReloadTicket = !isReloadTicket;
    notifyListeners();
  }
}
