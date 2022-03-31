import 'package:check_in_pro_for_visitor/src/database/entities/VisitorEntity.dart';
import 'package:check_in_pro_for_visitor/src/model/VisitorCheckIn.dart';
import 'package:moor/moor.dart';
import 'package:check_in_pro_for_visitor/src/database/Database.dart';

part 'VisitorDAO.g.dart';

@UseDao(tables: [VisitorEntity])
class VisitorDAO extends DatabaseAccessor<Database> with _$VisitorDAOMixin {
  final Database db;

  VisitorDAO(this.db) : super(db);

  Future<VisitorCheckIn> getByPhoneNumber(String phoneNumber) async {
    final query = select(visitorEntity)
      ..where((tbl) => tbl.phoneNumber.equals(phoneNumber));

    List<VisitorCheckIn> list = await query
        .map((row) => VisitorCheckIn.copyWithVisitorEntry(row))
        .get();
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  Future<VisitorCheckIn> getByIdCard(String idCard, double companyId) async {
    final query = select(visitorEntity)
      ..where((tbl) => tbl.idCard.equals(idCard));

    List<VisitorCheckIn> list = await query
        .map((row) => VisitorCheckIn.copyWithVisitorEntry(row))
        .get();
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  Future<VisitorCheckIn> insertNewOrUpdateOld(VisitorCheckIn visitor) async {
    // Check visitor exist by phone number
    final visitorCheckIn = await this._getByPhoneNumberEntry(visitor.phoneNumber);
    if (visitorCheckIn != null) {
      this._updateData(visitor.phoneNumber, visitor);
      return null;
    }
    VisitorEntityCompanion visitorCompanion = createCompanion(visitor);
    await into(visitorEntity).insert(visitorCompanion);
    return null;
  }

  Future<VisitorEntry> _getByPhoneNumberEntry(String phoneNumber) async {
    final query = select(visitorEntity)
      ..where((tbl) => tbl.phoneNumber.equals(phoneNumber));
    List<VisitorEntry> list = await query.get();
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  Future<VisitorEntry> _getVistorCheckIn(int rowId) {
    final query = select(visitorEntity)..limit(1, offset: rowId - 1);

    return query.getSingle();
  }

  Future<void> _updateData(String searchPhoneNumber, VisitorCheckIn visitor) async {
    VisitorEntityCompanion visitorCompanion = createCompanion(visitor);
    update(visitorEntity)
      ..where((tbl) => tbl.phoneNumber.equals(searchPhoneNumber))
      ..write(visitorCompanion);
  }

  Future<void> deleteAlls() async {
    delete(visitorEntity).go();
  }

  VisitorEntityCompanion createCompanion(VisitorCheckIn visitor) {
    final companion = VisitorEntityCompanion(
        fullName : Value(visitor.fullName),
        email : Value(visitor.email),
        phoneNumber : Value(visitor.phoneNumber),
        idCard : Value(visitor.idCard),
        purpose : Value(visitor.purpose),
        visitorType : Value(visitor.visitorType),
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
        inviteCode : Value(visitor.inviteCode)
    );
    return companion;
  }
}
