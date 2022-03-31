import 'package:check_in_pro_for_visitor/src/database/dao/VisitorLogDAO.dart';
import 'package:check_in_pro_for_visitor/src/database/entities/VisitorCheckInEntity.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorLog.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Utilities.dart';
import 'package:check_in_pro_for_visitor/src/utilities/Validator.dart';
import 'package:moor/moor.dart';
import 'package:check_in_pro_for_visitor/src/database/Database.dart';

part 'VisitorCheckInDAO.g.dart';

@UseDao(tables: [VisitorCheckInEntity])
class VisitorCheckInDAO extends DatabaseAccessor<Database> with _$VisitorCheckInDAOMixin {
  final Database db;

  VisitorCheckInDAO(this.db) : super(db);

  Future<VisitorCheckIn> getByPhoneNumber(String phoneNumber) async {
    final query = select(visitorCheckInEntity)
      ..where((tbl) => tbl.phoneNumber.equals(phoneNumber));

    List<VisitorCheckIn> list = await query
        .map((row) => VisitorCheckIn.copyWithVisitorCheckInEntry(row))
        .get();
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  Future<List<VisitorCheckIn>> getAll() async {
    final query = select(visitorCheckInEntity);
    List<VisitorCheckIn> list =
    await query.map((row) => VisitorCheckIn.copyWithVisitorCheckInEntry(row)).get();
    if (query == null || list.isEmpty) {
      return null;
    }
    return list;
  }

  Future<void> insert(VisitorCheckIn visitor) async {
    final entityCompanion = createCompanion(visitor);
    await into(visitorCheckInEntity).insert(entityCompanion);
  }

  void deleteById(String localId) {
    delete(visitorCheckInEntity)..where((tbl) => tbl.id.equals(localId))..go();
  }

  Future<void> deleteAlls() async {
    await delete(visitorCheckInEntity).go();
  }

  VisitorCheckInEntityCompanion createCompanion(VisitorCheckIn visitor) {
    final companion = VisitorCheckInEntityCompanion(
        fullName : Value(visitor.fullName),
        email : Value(visitor.email),
        phoneNumber : Value(visitor.phoneNumber),
        idCard : Value(visitor.idCard),
        purpose : Value(visitor.purpose),
        visitorType : Value(visitor.visitorType),
        visitorId: Value(visitor.id),
        checkOutTimeExpected : Value(visitor.checkOutTimeExpected),
        fromCompany : Value(visitor.fromCompany),
        toCompany : Value(visitor.toCompany),
        contactPersonId : Value(visitor.contactPersonId),
        faceCaptureRepoId : Value(visitor.faceCaptureRepoId),
        faceCaptureFile : Value(visitor.faceCaptureFile),
        signInBy : Value(visitor.signInBy),
        signInType : Value(visitor.signInType),
        floor : Value(visitor.floor),
        imagePath : Value(visitor.imagePath),
        imageIdPath : Value(visitor.imageIdPath),
        imageIdBackPath : Value(visitor.imageIdBackPath),
        toCompanyId : Value(visitor.toCompanyId),
        cardNo : Value(visitor.cardNo),
        goods : Value(visitor.goods),
        receiver : Value(visitor.receiver),
        visitorPosition : Value(visitor.visitorPosition),
        idCardRepoId : Value(visitor.idCardRepoId),
        idCardFile : Value(visitor.idCardFile),
        idCardBackRepoId : Value(visitor.idCardBackRepoId),
        idCardBackFile : Value(visitor.idCardBackFile),
        survey : Value(visitor.survey),
        surveyId : Value(visitor.surveyId),
        gender : Value(visitor.gender),
        passportNo : Value(visitor.passportNo),
        nationality : Value(visitor.nationality),
        birthDay : Value(visitor.birthDay),
        permanentAddress : Value(visitor.permanentAddress),
        departmentRoomNo : Value(visitor.departmentRoomNo),
        inviteCode : Value(visitor.inviteCode),
      groupNumberVisitor: Value(visitor.groupNumberVisitor)
    );
    return companion;
  }
}
