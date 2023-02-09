import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:practice_flutter_googledocs_clone/constants.dart';
import 'package:practice_flutter_googledocs_clone/models/document_model.dart';
import 'package:practice_flutter_googledocs_clone/models/error_model.dart';

final documentRepositoryProvider = Provider(
  (ref) => DocumentRepository(
    client: Client(),
  ),
);

class DocumentRepository {
  final Client _client;
  DocumentRepository({
    required Client client,
  }) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error =
        ErrorModel(error: 'Some unexpected error occured', data: null);
    try {
      final res = await _client.post(Uri.parse('$host/doc/create'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token
      });

      switch (res.statusCode) {
        case 200:
          error =
              ErrorModel(error: null, data: DocumentModel.fromJson(res.body));
          break;
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }

    return error;
  }
}
