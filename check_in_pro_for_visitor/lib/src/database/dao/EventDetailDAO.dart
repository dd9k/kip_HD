import 'package:check_in_pro_for_visitor/src/database/Database.dart';
import 'package:check_in_pro_for_visitor/src/database/dao/EventLogDAO.dart';
import 'package:check_in_pro_for_visitor/src/database/entities/EventDetailEntity.dart';
import 'package:check_in_pro_for_visitor/src/model/EventDetail.dart';
import 'package:check_in_pro_for_visitor/src/utilities/AppLocalizations.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:moor/moor.dart';

part 'EventDetailDAO.g.dart';

@UseDao(tables: [EventDetailEntity])
class EventDetailDAO extends DatabaseAccessor<Database> with _$EventDetailDAOMixin {
  Database db;

  EventLogDAO _eventLogDAO;

  EventDetailDAO(this.db) : super(db) {
    _eventLogDAO = EventLogDAO(db);
  }

  Future<void> insert(EventDetail eventDetail) async {
    EventDetailEntityCompanion companion = createCompanion(eventDetail);

    into(eventDetailEntity).insert(companion);
    await _eventLogDAO.insert(eventDetail.guests);
  }

  Future<String> validateCheckIn(BuildContext context) async {
    final query = select(eventDetailEntity);
    List<EventDetail> list = await query.map((row) => EventDetail.copyWithEntity(row)).get();
    if (query == null || list.isEmpty) {
      return null;
    }
    EventDetail eventDetail = list.first;
    int currentDate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int dateCheckin = eventDetail.startDate - ((eventDetail?.duration ?? 0) * 60).toInt();
    if (currentDate >= dateCheckin) {
      return null;
    }
    return AppLocalizations.of(context).eventStartNotYet;
  }

  Future<EventDetail> getEventDetail() async {
    final query = select(eventDetailEntity);
    List<EventDetail> list = await query.map((row) => EventDetail.copyWithEntity(row)).get();
    if (query == null || list.isEmpty) {
      return null;
    }
    return list.first;
  }

  EventDetailEntityCompanion createCompanion(EventDetail eventDetail) {
    final companion = EventDetailEntityCompanion(
        id: Value(eventDetail.id),
        endDate: Value(eventDetail.endDate),
        startDate: Value(eventDetail.startDate),
        eventName: Value(eventDetail.eventName),
        badgeTemplate: Value(eventDetail.badgeTemplate),
        duration: Value(eventDetail.duration));
    return companion;
  }

  Future<void> deleteAll() async {
    await delete(eventDetailEntity).go();
    await _eventLogDAO.deleteAll();
  }
}