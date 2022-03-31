
enum PhotoStep {
  FACE_STEP,
  ID_FONT_STEP,
  ID_BACK_STEP
}

class TakePhotoStep {
  PhotoStep photoStep;
  String pathSavedPhoto;
  TakePhotoStep(this.photoStep, this.pathSavedPhoto);
  TakePhotoStep.init(this.photoStep);
}