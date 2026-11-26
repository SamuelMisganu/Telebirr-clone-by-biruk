import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/transaction detail.dart';

class TransactionSuccessPage extends StatefulWidget {
  final double amount;
  final String recipientName;

  const TransactionSuccessPage({
    super.key,
    required this.amount,
    required this.recipientName,
  });

  @override
  State<TransactionSuccessPage> createState() => _TransactionSuccessPageState();
}

class _TransactionSuccessPageState extends State<TransactionSuccessPage> {
  late final String _transactionTime;
  late final String _transactionNumber;

  @override
  void initState() {
    super.initState();
    _transactionTime = _formatCurrentTime();
    _transactionNumber = _generateTransactionId();

    TransactionHistoryNotifier.add(
      TransactionRecord(
        recipientName: widget.recipientName,
        amount: widget.amount,
        time: _transactionTime,
        transactionNumber: _transactionNumber,
      ),
    );
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${now.year}/${twoDigits(now.month)}/${twoDigits(now.day)} '
        '${twoDigits(now.hour)}:${twoDigits(now.minute)}:${twoDigits(now.second)}';
  }

  String _generateTransactionId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final suffix =
        List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
    return 'DK$suffix';
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF8CC63F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Top Download & Share Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined,
                        color: primaryGreen, size: 20),
                    label: const Text(
                      'Download',
                      style: TextStyle(color: primaryGreen, fontSize: 14),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined,
                        color: primaryGreen, size: 20),
                    label: const Text(
                      'Share',
                      style: TextStyle(color: primaryGreen, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Green Checkmark Circle
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 12),
              const Text(
                'Successful',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 36),

              // Dynamic Negative Amount
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '-${widget.amount.toStringAsFixed(2)} ',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const TextSpan(
                      text: '(ETB)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              // Transaction Metadata Rows
              _buildDetailRow('Transaction Time:', _transactionTime),
              const SizedBox(height: 16),
              _buildDetailRow('Transaction Type:', 'Transfer Money'),
              const SizedBox(height: 16),
              _buildDetailRow('Transaction To:', widget.recipientName),
              const SizedBox(height: 16),
              _buildDetailRow('Transaction Number:', _transactionNumber),
              const SizedBox(height: 16),

              // Built-in Icon + Text QR Code Link
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.qr_code_2, color: primaryGreen, size: 24),
                    SizedBox(width: 6),
                    Text(
                      'QR Code',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // FAYDA Promo Banner Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'images/fayda_banner.jpg',
                  width: double.infinity,
                  height: 105,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),

              // Banner Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryGreen),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Finished Button
              SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Finished',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
