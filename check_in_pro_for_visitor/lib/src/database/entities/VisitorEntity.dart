import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

@DataClassName("VisitorEntry")
class VisitorEntity extends Table {
  final uuid = Uuid();

  String get tableName => 'cip_vistor';

  TextColumn get id => text().clientDefault(() => uuid.v1())();

  TextColumn get fullName => text().nullable()();

  TextColumn get email => text().nullable()();

  TextColumn get phoneNumber => text().nullable()();

  TextColumn get idCard => text().nullable()();

  TextColumn get purpose => text().nullable()();

  TextColumn get visitorType => text().nullable()();

  TextColumn get checkOutTimeExpected => text().nullable()();

  TextColumn get fromCompany => text().nullable()();

  TextColumn get toCompany => text().nullable()();

  RealColumn get contactPersonId => real().nullable()();

  RealColumn get faceCaptureRepoId => real().nullable()();

  TextColumn get faceCaptureFile => text().nullable()();

  IntColumn get signInBy => integer().nullable()();

  TextColumn get signInType => text().nullable()();

  TextColumn get floor => text().nullable()();

  TextColumn get imagePath => text().nullable()();

  TextColumn get imageIdPath => text().nullable()();

  TextColumn get imageIdBackPath => text().nullable()();

  RealColumn get toCompanyId => real().nullable()();

  TextColumn get cardNo => text().nullable()();

  TextColumn get goods => text().nullable()();

  TextColumn get receiver => text().nullable()();

  TextColumn get visitorPosition => text().nullable()();

  RealColumn get idCardRepoId => real().nullable()();

  TextColumn get idCardFile => text().nullable()();

  RealColumn get idCardBackRepoId => real().nullable()();

  TextColumn get idCardBackFile => text().nullable()();

  TextColumn get survey => text().nullable()();

  RealColumn get surveyId => real().nullable()();

  IntColumn get gender => integer().nullable()();

  TextColumn get passportNo => text().nullable()();

  TextColumn get nationality => text().nullable()();

  TextColumn get birthDay => text().nullable()();

  TextColumn get permanentAddress => text().nullable()();

  TextColumn get departmentRoomNo => text().nullable()();

  TextColumn get inviteCode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
