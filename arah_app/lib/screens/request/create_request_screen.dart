import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../provider/request_provider.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  Future<void> _pickDocument(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'zip', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        context.read<RequestProvider>().addFiles(result.files);
      }
    } catch (e) {
      debugPrint("File picker error: $e");
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes > 0) ? (bytes.toString().length - 1) ~/ 3 : 0;
    return '${(bytes / (1024 * i > 0 ? 1024 * i : 1)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  void _removeFile(BuildContext context, int index) {
    context.read<RequestProvider>().removeFile(index);
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 20.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.navyBlue,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.blueGrey.shade300, fontSize: 14),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blueGrey.shade100, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.arahPurple, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = context.watch<RequestProvider>();
    final budgetType = requestProvider.budgetType;
    final attachedFiles = requestProvider.attachedFiles;

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      appBar: AppBar(
        title: const Text(
          "Create a Request",
          style: TextStyle(
            color: AppTheme.navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Task Title"),
              TextField(
                decoration: _inputDeco("e.g. Need a Python script for data entry"),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Category"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey.shade100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Select...", style: TextStyle(color: AppTheme.navyBlue, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Experience"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey.shade100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Beginner Friendly", style: TextStyle(color: AppTheme.navyBlue, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _buildLabel("Required Skills"),
              TextField(
                decoration: _inputDeco("Type and press enter (e.g. Figma, React)"),
              ),
              _buildLabel("Budget Type"),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // light grey background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueGrey.shade50),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.read<RequestProvider>().updateBudgetType('Fixed Price'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: budgetType == 'Fixed Price'
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: budgetType == 'Fixed Price'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Fixed Price',
                            style: TextStyle(
                              color: budgetType == 'Fixed Price'
                                  ? AppTheme.navyBlue
                                  : Colors.blueGrey.shade500,
                              fontWeight: budgetType == 'Fixed Price'
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.read<RequestProvider>().updateBudgetType('Hourly Rate'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: budgetType == 'Hourly Rate'
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: budgetType == 'Hourly Rate'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Hourly Rate',
                            style: TextStyle(
                              color: budgetType == 'Hourly Rate'
                                  ? AppTheme.navyBlue
                                  : Colors.blueGrey.shade500,
                              fontWeight: budgetType == 'Hourly Rate'
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: _inputDeco(
                        "\$ 0.00",
                        suffixIcon: const Icon(Icons.unfold_more, size: 20, color: Colors.blueGrey),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: _inputDeco(
                        "dd----yyyy",
                        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black87),
                      ),
                      readOnly: true,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              _buildLabel("Attachments"),
              GestureDetector(
                onTap: () => _pickDocument(context),
                child: CustomPaint(
                  painter: DashedRectPainter(
                    color: Colors.blueGrey.shade300,
                    strokeWidth: 1.2,
                    gap: 6.0,
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_outlined, color: Color(0xFF6A4BFF), size: 32),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Upload File Attachments",
                            style: const TextStyle(
                              color: Color(0xFF6A4BFF),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Images, PDFs, ZIP",
                          style: TextStyle(
                            color: Colors.blueGrey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (attachedFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: attachedFiles.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final file = attachedFiles[index];
                      IconData icon = Icons.insert_drive_file;
                      Color iconColor = Colors.blueGrey;
                      if (file.extension == 'pdf') {
                        icon = Icons.picture_as_pdf;
                        iconColor = Colors.redAccent;
                      } else if (['jpg', 'jpeg', 'png'].contains(file.extension)) {
                        icon = Icons.image;
                        iconColor = Colors.blueAccent;
                      } else if (file.extension == 'zip') {
                        icon = Icons.folder_zip;
                        iconColor = Colors.orangeAccent;
                      }

                      return Container(
                        width: 200,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueGrey.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: iconColor, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    file.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: AppTheme.navyBlue,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatBytes(file.size),
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade400,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _removeFile(context, index),
                              child: Icon(Icons.close, color: Colors.blueGrey.shade300, size: 20),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              _buildLabel("Additional Notes"),
              TextField(
                maxLines: 4,
                decoration: _inputDeco("Provide any extra details here..."),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A4BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Post Request",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({required this.color, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12)));

    PathMetrics pathMetrics = path.computeMetrics();
    Path dashPath = Path();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        double length = draw ? gap : gap;
        dashPath.addPath(
            pathMetric.extractPath(distance, distance + length), Offset.zero);
        distance += length;
        draw = !draw;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
