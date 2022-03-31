import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/database/Database.dart';
import 'package:check_in_pro_for_visitor/src/database/entities/EventLogEntity.dart';
import 'package:check_in_pro_for_visitor/src/model/EventLog.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

part 'EventLogDAO.g.dart';

@UseDao(tables: [EventLogEntity])
class EventLogDAO extends DatabaseAccessor<Database> with _$EventLogDAOMixin {
  Database db;

  EventLogDAO(db) : super(db);

  Future<void> insert(List<EventLog> eventLogs) async {
    await batch((batch) {
      batch.insertAll(
          eventLogEntity,
          eventLogs.map((row) {
            row.id = Uuid().v1();
            return createCompanion(row);
          }).toList());
    });
  }

  Future<String> insertNew(EventLog eventLogs) async {
    eventLogs.id = Uuid().v1();
    final entityCompanion = createCompanion(eventLogs);
    await into(eventLogEntity).insert(entityCompanion);
    return eventLogs.id;
  }

  Future<void> deleteAll() async {
    final query = select(eventLogEntity);
    List<EventLog> list = await query.map((row) => EventLog.copyWithEntry(row)).get();
    list.forEach((element) async {
      if (element?.imagePath?.isNotEmpty == true) {
        String folderName = Constants.FOLDER_FACE_OFFLINE;
        element.imagePath = await Utilities().getLocalPathFile(folderName, "", element?.imagePath, Constants.PNG_ETX);
        Utilities().deleteFileWithPath(element?.imagePath);
      }
      if (element?.imageIdPath?.isNotEmpty == true) {
        String folderName = Constants.FOLDER_ID_OFFLINE;
        element.imageIdPath = await Utilities().getLocalPathFile(folderName, "", element?.imageIdPath, Constants.PNG_ETX);
        Utilities().deleteFileWithPath(element?.imageIdPath);
      }
      if (element?.imageIdBackPath?.isNotEmpty == true) {
        String folderName = Constants.FOLDER_ID_BACK_OFFLINE;
        element.imageIdBackPath = await Utilities().getLocalPathFile(folderName, "", element?.imageIdBackPath, Constants.PNG_ETX);
        Utilities().deleteFileWithPath(element?.imageIdBackPath);
      }
    });
    await delete(eventLogEntity).go();
  }

  Future<EventLog> validate(String inviteCode, String phoneNumber) async {
    String key = inviteCode?.toUpperCase() ?? phoneNumber ?? "";
    if (key.isEmpty) {
      EventLog eventLog = EventLog.init();
      eventLog.status = Constants.VALIDATE_WRONG;
      return eventLog;
    }
    final query = select(eventLogEntity)
      ..where((eventLog) => eventLog.inviteCode.equals(key) | eventLog.phoneNumber.equals(key))
      ..orderBy([
            (t) => OrderingTerm(expression: t.lastUpdate.cast<int>(), mode: OrderingMode.desc),
      ]);
    List<EventLog> list = await query.map((row) => EventLog.copyWithEntry(row)).get();
    if (query == null || list.isEmpty) {
      EventLog eventLog = EventLog.init();
      eventLog.status = Constants.VALIDATE_WRONG;
      return eventLog;
    }
    EventLog eventLog = list.first;
    var date = DateTime.fromMillisecondsSinceEpoch(eventLog.lastUpdate);
    if (Utilities().isSameDate(date, DateTime.now())) {
      if (eventLog.signIn == null) {
        eventLog.status = Constants.VALIDATE_IN;
      } else if (eventLog.signOut == null) {
        eventLog.status = Constants.VALIDATE_OUT;
      } else {
        eventLog.status = Constants.VALIDATE_ALREADY;
      }
    } else {
      eventLog.status = Constants.VALIDATE_IN;
    }
    return eventLog;
  }

  Future<List<EventLog>> getFailLogs() async {
    final query = select(eventLogEntity)..where((eventLog) => eventLog.syncFail);
    List<EventLog> list = await query.map((row) => EventLog.copyWithEntry(row)).get();
    if (query == null || list == null || list.isEmpty) {
      return List();
    }
    return list;
  }

  Future<EventLog> getFirstLog() async {
    final query = select(eventLogEntity);
    List<EventLog> list = await query.map((row) => EventLog.copyWithEntry(row)).get();
    if (query == null || list == null || list.isEmpty) {
      return EventLog.init();
    }
    return list[0];
  }

  Future<EventLog> getLogById(String id) async {
    final query = select(eventLogEntity)..where((tbl) => tbl.id.equals(id));
    List<EventLog> list = await query.map((row) => EventLog.copyWithEntry(row)).get();
    if (query == null || list == null || list.isEmpty) {
      return EventLog.init();
    }
    return list[0];
  }

  Future<List<EventLog>> getAllLogs() async {
    final query = select(eventLogEntity);
    List<EventLog> list = await query.map((row) => EventLog.copyWithEntry(row)).get();
    if (query == null || list == null || list.isEmpty) {
      return List();
    }
    return list;
  }

  Future<EventLog> updateRow(EventLog eventLog) async {
    var date = new DateTime.fromMillisecondsSinceEpoch(eventLog.lastUpdate);
    if (Utilities().isSameDate(date, DateTime.now())) {
      EventLogEntityCompanion companion = createCompanion(eventLog);
      update(eventLogEntity)
        ..where((tbl) => tbl.id.equals(eventLog.id))
        ..write(companion);
      return eventLog;
    } else {
      String id = await insertNew(eventLog);
      return await getLogById(id);
    }
  }

  EventLogEntityCompanion createCompanion(EventLog eventLog) {
    int lastUpdate = (eventLog?.signIn != null) ? eventLog.signIn * 1000 : DateTime.now().millisecondsSinceEpoch;
    EventLogEntityCompanion companion = EventLogEntityCompanion(
        id: Value(eventLog.id),
        guestId: Value(eventLog.guestId),
        fullName: Value(eventLog.fullName),
        email: Value(eventLog.email),
        phoneNumber: Value(eventLog.phoneNumber),
        inviteCode: Value(eventLog.inviteCode),
        timeZone: Value(eventLog.timeZone),
        idCard: Value(eventLog.idCard),
        signInType: Value(Constants.TYPE_CHECK),
        signOutType: Value(Constants.TYPE_CHECK),
        registerType: Value(Constants.TYPE_CHECK),
        survey: Value(eventLog.survey),
        surveyId: Value(eventLog.surveyId),
        imagePath: Value(eventLog.imagePath),
        imageIdPath: Value(eventLog.imageIdPath),
        imageIdBackPath: Value(eventLog.imageIdBackPath),
        eventId: Value(eventLog.eventId),
        signIn: Value(eventLog.signIn),
        signOut: Value(eventLog.signOut),
        feedback: Value(eventLog.feedback),
        rating: Value(eventLog.rating),
        branchId: Value(eventLog.branchId),
        status: Value(eventLog.status),
        visitorType: Value(eventLog.visitorType),
        syncFail: Value(eventLog.syncFail),
        faceCaptureFile: Value(eventLog.faceCaptureFile),
        visitorLogId: Value(eventLog.visitorLogId),
        lastUpdate: Value(lastUpdate));
    return companion;
  }
}
