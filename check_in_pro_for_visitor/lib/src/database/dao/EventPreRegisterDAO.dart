import 'package:check_in_pro_for_visitor/src/constants/Constants.dart';
import 'package:check_in_pro_for_visitor/src/database/Database.dart';
import 'package:check_in_pro_for_visitor/src/database/entities/EventPreRegisterEntity.dart';
import 'package:check_in_pro_for_visitor/src/model/EventLog.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

part 'EventPreRegisterDAO.g.dart';

@UseDao(tables: [EventPreRegisterEntity])
class EventPreRegisterDAO extends DatabaseAccessor<Database> with _$EventPreRegisterDAOMixin {
  Database db;

  EventPreRegisterDAO(db) : super(db);

  Future<void> insert(List<EventLog> eventPreRegisters) async {
    await batch((batch) {
      batch.insertAll(
          eventPreRegisterEntity,
          eventPreRegisters.map((row) {
            row.id = Uuid().v1();
            return createCompanion(row);
          }).toList());
    });
  }

  Future<String> insertNew(EventLog eventPreRegisters) async {
    eventPreRegisters.id = Uuid().v1();
    final entityCompanion = createCompanion(eventPreRegisters);
    await into(eventPreRegisterEntity).insert(entityCompanion);
    return eventPreRegisters.id;
  }

  Future<void> deleteAll() async {
    final query = select(eventPreRegisterEntity);
    List<EventLog> list = await query.map((row) => EventLog.copyWithPreEntry(row)).get();
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
    await delete(eventPreRegisterEntity).go();
  }

  Future<EventLog> validate(String inviteCode, String phoneNumber) async {
    String key = inviteCode?.toUpperCase() ?? phoneNumber ?? "";
    if (key.isEmpty) {
      EventLog eventPreRegister = EventLog.init();
      eventPreRegister.status = Constants.VALIDATE_WRONG;
      return eventPreRegister;
    }
    final query = select(eventPreRegisterEntity)
      ..where((eventPreRegister) => eventPreRegister.inviteCode.equals(key) | eventPreRegister.phoneNumber.equals(key));
    List<EventLog> list = await query.map((row) => EventLog.copyWithPreEntry(row)).get();
    if (query == null || list.isEmpty) {
      EventLog eventPreRegister = EventLog.init();
      eventPreRegister.status = Constants.VALIDATE_WRONG;
      return eventPreRegister;
    }
    EventLog eventPreRegister = list.first;
    if (eventPreRegister.signIn == null) {
      eventPreRegister.status = Constants.VALIDATE_IN;
    } else if (eventPreRegister.signOut == null) {
      eventPreRegister.status = Constants.VALIDATE_OUT;
    } else {
      eventPreRegister.status = Constants.VALIDATE_ALREADY;
    }
    return eventPreRegister;
  }

  Future<List<EventLog>> getFailLogs() async {
    final query = select(eventPreRegisterEntity)..where((eventPreRegister) => eventPreRegister.syncFail);
    List<EventLog> list = await query.map((row) => EventLog.copyWithPreEntry(row)).get();
    if (query == null || list == null || list.isEmpty) {
      return List();
    }
    return list;
  }

  Future<EventLog> getFirstLog() async {
    final query = select(eventPreRegisterEntity);
    List<EventLog> list = await query.map((row) => EventLog.copyWithPreEntry(row)).get();
    if (query == null || list == null || list.isEmpty) {
      return EventLog.init();
    }
    return list[0];
  }

  Future<List<EventLog>> getAllLogs() async {
    final query = select(eventPreRegisterEntity);
    List<EventLog> list = await query.map((row) => EventLog.copyWithPreEntry(row)).get();
    if (query == null || list == null || list.isEmpty) {
      return List();
    }
    return list;
  }

  void updateRow(EventLog eventPreRegister) {
    EventPreRegisterEntityCompanion companion = createCompanion(eventPreRegister);
    update(eventPreRegisterEntity)
      ..where((tbl) => tbl.id.equals(eventPreRegister.id))
      ..write(companion);
  }

  EventPreRegisterEntityCompanion createCompanion(EventLog eventPreRegister) {
    EventPreRegisterEntityCompanion companion = EventPreRegisterEntityCompanion(
        id: Value(eventPreRegister.id),
        guestId: Value(eventPreRegister.guestId),
        fullName: Value(eventPreRegister.fullName),
        email: Value(eventPreRegister.email),
        phoneNumber: Value(eventPreRegister.phoneNumber),
        inviteCode: Value(eventPreRegister.inviteCode),
        timeZone: Value(eventPreRegister.timeZone),
        idCard: Value(eventPreRegister.idCard),
        signInType: Value(Constants.TYPE_CHECK),
        signOutType: Value(Constants.TYPE_CHECK),
        registerType: Value(Constants.TYPE_CHECK),
        survey: Value(eventPreRegister.survey),
        surveyId: Value(eventPreRegister.surveyId),
        imagePath: Value(eventPreRegister.imagePath),
        imageIdPath: Value(eventPreRegister.imageIdPath),
        imageIdBackPath: Value(eventPreRegister.imageIdBackPath),
        eventId: Value(eventPreRegister.eventId),
        signIn: Value(eventPreRegister.signIn),
        signOut: Value(eventPreRegister.signOut),
        feedback: Value(eventPreRegister.feedback),
        rating: Value(eventPreRegister.rating),
        branchId: Value(eventPreRegister.branchId),
        status: Value(eventPreRegister.status),
        visitorType: Value(eventPreRegister.visitorType),
        syncFail: Value(eventPreRegister.syncFail),
        faceCaptureFile: Value(eventPreRegister.faceCaptureFile));
    return companion;
  }
}
