import 'dart:convert';

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

  Future<ErrorModel> getDocuments(String token) async {
    ErrorModel error =
        ErrorModel(error: 'Some unexpected error occured', data: null);
    try {
      final res = await _client.get(Uri.parse('$host/doc/me'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token
      });

      switch (res.statusCode) {
        case 200:
          List<DocumentModel> documents = [];

          final documentsList = jsonDecode(res.body);
          for (int i = 0; i < documentsList.length; i++) {
            documents.add(DocumentModel.fromMap(documentsList[i]));
          }

          error = ErrorModel(error: null, data: documents);

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

  Future<ErrorModel> updateTitle({
    required String token,
    required String id,
    required String title,
  }) async {
    ErrorModel error =
        ErrorModel(error: 'Some unexpected error occured', data: null);
    try {
      final res = await _client.post(
        Uri.parse('$host/doc/title'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'title': title,
          'id': id,
        }),
      );

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

  Future<ErrorModel> getDocumentById(String token, String id) async {
    ErrorModel error =
        ErrorModel(error: 'Some unexpected error occured', data: null);
    try {
      final res = await _client.get(Uri.parse('$host/doc/$id'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token
      });

      switch (res.statusCode) {
        case 200:
          final document = jsonDecode(res.body);
          error = ErrorModel(
            error: null,
            data: document,
          );
          break;
        default:
          throw 'This document does not exist, please create new one';
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
