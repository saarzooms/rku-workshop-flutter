import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/widgets/state_views.dart';
import '../viewmodels/attendance_viewmodel.dart';

class QrGenerateScreen extends StatefulWidget {
  const QrGenerateScreen({super.key, required this.eventId, this.eventTitle});

  final int eventId;
  final String? eventTitle;

  @override
  State<QrGenerateScreen> createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends State<QrGenerateScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => mounted
        ? context.read<AttendanceViewModel>().generateQr(widget.eventId)
        : null);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AttendanceViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance QR Code')),
      body: Builder(
        builder: (context) {
          if (vm.isLoading) {
            return const LoadingStateView(message: 'Generating secure QR...');
          }
          if (vm.errorMessage != null) {
            return ErrorStateView(
              message: vm.errorMessage!,
              onRetry: () => vm.generateQr(widget.eventId),
            );
          }

          final qr = vm.activeQr;
          if (qr == null) {
            return const SizedBox.shrink();
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.eventTitle != null)
                    Text(
                      widget.eventTitle!,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Students scan this code to mark attendance.\nExpires at: ${qr.expiresAt}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: QrImageView(
                        data: qr.qrToken,
                        size: 240,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    qr.qrToken,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: qr.qrToken));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('QR token copied')),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Token'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () => vm.generateQr(widget.eventId),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Regenerate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
