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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            children: [
              // 1. Top Download & Share Row (aligned flush with outer margins)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const Row(
                      children: [
                        Icon(Icons.download_outlined,
                            color: primaryGreen, size: 21),
                        SizedBox(width: 4),
                        Text(
                          'Download',
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Row(
                      children: [
                        Icon(Icons.share_outlined,
                            color: primaryGreen, size: 21),
                        SizedBox(width: 4),
                        Text(
                          'Share',
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // 2. Green Checkmark Circle & "Successful"
              Container(
                width: 58,
                height: 58,
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
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 36),

              // 3. Dynamic Negative Amount (-96.00 (ETB))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '-${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '(ETB)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Divider(thickness: 1, height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 18),

              // 4. Transaction Metadata Rows
              _buildDetailRow('Transaction Time:', _transactionTime),
              const SizedBox(height: 16),
              _buildDetailRow('Transaction Type:', 'Transfer Money'),
              const SizedBox(height: 16),
              _buildDetailRow('Transaction To:', widget.recipientName),
              const SizedBox(height: 16),
              _buildDetailRow('Transaction Number:', _transactionNumber),
              const SizedBox(height: 18),

              // 5. Right-aligned QR Code Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_2, color: primaryGreen, size: 23),
                      SizedBox(width: 6),
                      Text(
                        'QR Code',
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 6. FAYDA Promo Banner Image (full uncropped aspect ratio)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'images/fayda_banner.jpg',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
              const SizedBox(height: 10),

              // 7. Banner Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryGreen, width: 1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 8. Bottom Finished Button
              SizedBox(
                width: 220,
                height: 46,
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
                      fontWeight: FontWeight.w500,
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8C8C8C),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
