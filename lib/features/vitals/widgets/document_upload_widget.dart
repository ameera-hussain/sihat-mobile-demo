import 'package:flutter/material.dart';

class DocumentUploadWidget extends StatelessWidget {
  final Future<void> Function(String fileName, String fileType) onUpload;

  const DocumentUploadWidget({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showSimulateDialog(context),
      icon: const Icon(Icons.upload_file),
      label: const Text('Upload document'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // BACKEND : replace this entire method with real file picker
  //   1. Already added file_picker: ^6.2.1 to pubspec.yaml
  //   2. final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','jpg','png']);
  //   3. if (result != null) onUpload(result.files.single.name, extension);
  void _showSimulateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Simulate upload'),
        content: const Text(
          'In production this opens the device file picker.\n\n'
          'For now a mock file will be added to the list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onUpload(
                'mock_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
                'pdf',
              );
            },
            child: const Text('Simulate PDF upload'),
          ),
        ],
      ),
    );
  }
}
