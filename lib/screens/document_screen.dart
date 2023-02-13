import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:practice_flutter_googledocs_clone/colors.dart';
import 'package:practice_flutter_googledocs_clone/common/widgets/loader.dart';
import 'package:practice_flutter_googledocs_clone/models/document_model.dart';
import 'package:practice_flutter_googledocs_clone/models/error_model.dart';
import 'package:practice_flutter_googledocs_clone/repository/auth_repository.dart';
import 'package:practice_flutter_googledocs_clone/repository/document_repository.dart';
import 'package:practice_flutter_googledocs_clone/repository/socket_repository.dart';
import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');

  quill.QuillController? _controller;

  ErrorModel? errorModel;

  SocketRepository socketRepository = SocketRepository();

  Timer? autoSaveTimer;

  @override
  void initState() {
    super.initState();

    socketRepository.joinRoom(widget.id);
    fetchDocumentData();

    socketRepository.changeListener((data) {
      _controller?.compose(
        quill.Delta.fromJson(data['delta']),
        _controller?.selection ??
            const TextSelection.collapsed(
              offset: 0,
            ),
        quill.ChangeSource.REMOTE,
      );
    });

    autoSaveTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'documentId': widget.id,
        'room': widget.id,
        'delta': _controller?.document.toDelta() ??
            (throw Exception(['No controller has been attached!'])),
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)?.token ?? '', widget.id);
    final data = DocumentModel.fromMap(errorModel?.data);
    if (errorModel?.data != null) {
      titleController.text = data.title;

      _controller = quill.QuillController(
        document: data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(quill.Delta.fromJson(data.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});

      _controller?.document.changes.listen((event) {
        // 1 -> entire content of document
        // 2 -> changesthat are made from the previous part
        // 3-> local? -> we have typed remote?

        if (event.item3 == quill.ChangeSource.LOCAL) {
          Map<String, dynamic> map = {
            'delta': event.item2,
            'room': widget.id,
          };

          socketRepository.typing(map);
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    _controller?.dispose();
    autoSaveTimer?.cancel();
  }

  void updateTitle(WidgetRef ref, String title) async {
    await ref.read(documentRepositoryProvider).updateTitle(
          token: ref.read(userProvider)?.token ?? '',
          id: widget.id,
          title: title,
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(body: Loader());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(
                    text: 'http://localhost:3000/#/document/${widget.id}',
                  ),
                ).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link Copied!'),
                    ),
                  );
                });
              },
              icon: const Icon(
                Icons.lock,
                color: kWhiteColor,
                size: 16,
              ),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueColor,
              ),
            ),
          )
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 9,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Routemaster.of(context).replace('/');
                },
                child: Image.asset(
                  'assets/images/docs-logo.png',
                  height: 40,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kBlueColor,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                  controller: titleController,
                  onSubmitted: (value) {
                    updateTitle(ref, value);
                  },
                ),
              ),
            ],
          ),
        ),
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(1),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       border: Border.all(
        //         color: kGreyColor,
        //         width: 0.1,
        //       ),
        //     ),
        //   ),
        // ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            quill.QuillToolbar.basic(
              controller: _controller ??
                  (throw Exception(
                    [
                      'No controller has been attached',
                    ],
                  )),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: kWhiteColor,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor.basic(
                      controller: _controller ??
                          (throw Exception(
                            [
                              'No controller has been attached',
                            ],
                          )),
                      readOnly: false, // true for view only mode
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
