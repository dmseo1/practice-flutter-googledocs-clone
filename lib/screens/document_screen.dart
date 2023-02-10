import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:practice_flutter_googledocs_clone/colors.dart';
import 'package:practice_flutter_googledocs_clone/models/document_model.dart';
import 'package:practice_flutter_googledocs_clone/models/error_model.dart';
import 'package:practice_flutter_googledocs_clone/repository/auth_repository.dart';
import 'package:practice_flutter_googledocs_clone/repository/document_repository.dart';
import 'package:practice_flutter_googledocs_clone/repository/socket_repository.dart';

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

  final quill.QuillController _controller = quill.QuillController.basic();

  ErrorModel? errorModel;

  SocketRepository socketRepository = SocketRepository();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    socketRepository.joinRoom(widget.id);
    fetchDocumentData();
  }

  void fetchDocumentData() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)?.token ?? '', widget.id);
    if (errorModel?.data != null) {
      print(errorModel?.data.runtimeType);
      titleController.text = (DocumentModel.fromMap(errorModel?.data)).title;
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {},
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
              Image.asset(
                'assets/images/docs-logo.png',
                height: 40,
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
            quill.QuillToolbar.basic(controller: _controller),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: kWhiteColor,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor.basic(
                      controller: _controller,
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
