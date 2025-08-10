import 'package:attendance_tracker/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  late final _dbProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  bool isProcessing = false;

  Future<void> _processQrData(String qrData) async {
    try {
      await _dbProvider.markAttendance(qrData: qrData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Attendance marked successfully",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(255, 20, 98, 22),
          ),
        );
      } // call your validation logic
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      setState(() => isProcessing = false);
      if (mounted) {
        Navigator.pop(context);
        
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR Scanner',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
        ),
        onDetect: (BarcodeCapture capture) async {
          final String? rawValue = capture.barcodes.first.rawValue;
          if (rawValue != null && !isProcessing) {
            setState(() => isProcessing = true);
            await _processQrData(rawValue);
          }
        },
      ),
    );
  }
}
