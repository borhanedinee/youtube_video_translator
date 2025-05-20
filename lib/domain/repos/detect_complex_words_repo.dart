import 'package:Transcripto/domain/models/response_model.dart';

abstract class DetectComplexWordsRepo {
  Future<ResponseModel?> getComplexWordsByText(
    String text,
    String level,
    String langToLrean,
    String nativeLan,
  );
}
