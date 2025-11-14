import 'package:flutter/services.dart';
import 'package:unique_identifier/unique_identifier.dart';

class UniqueIdentifierService {
  Future<String?> getIMEI() async {
    final identifier = await UniqueIdentifier.serial;

    return identifier;
  }
}
