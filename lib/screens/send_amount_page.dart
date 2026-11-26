import 'package:flutter/material.dart';
import '../widgets/balance_info.dart';
import 'transaction_success_page.dart';

class SendAmountPage extends StatefulWidget {
  final String recipientName;
  final String phoneNumber;

  const SendAmountPage({
    super.key,
    required this.recipientName,
    required this.phoneNumber,
  });

  @override
  State<SendAmountPage> createState() => _SendAmountPageState();
}

class _SendAmountPageState extends State<SendAmountPage> {
  String _amount = '';
  final TextEditingController _notesController = TextEditingController();

  void _onKeyPress(String value) {
    setState(() {
      if (value == '.' && _amount.contains('.')) return;
      if (_amount.contains('.')) {
        final parts = _amount.split('.');
        if (parts.length > 1 && parts[1].length >= 2) return;
      }
      if (_amount == '0' && value != '.') {
        _amount = value;
      } else {
        _amount += value;
      }
    });
  }

  void _onBackspace() {
    if (_amount.isNotEmpty) {
      setState(() {
        _amount = _amount.substring(0, _amount.length - 1);
      });
    }
  }

  void _showConfirmationBottomSheet() {
    final double originalAmount = double.tryParse(_amount) ?? 0.0;
    if (originalAmount <= 0) return;

    const double serviceFee = 1.00;
    final double totalAmount = originalAmount + serviceFee;
    final double availableBalance = BalanceNotifier.currentBalance.value;
    const primaryGreen = Color(0xFF8CC63F);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6F8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close X Icon
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87, size: 26),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Recipient Title
              Text(
                'Send Money to ${widget.recipientName}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Total Amount + ETB
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: totalAmount.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(
                      text: 'ETB',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Original Amount & Service Fee Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Original Amount',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          '${originalAmount.toStringAsFixed(2)}ETB',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Service fee',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          '${serviceFee.toStringAsFixed(2)}ETB',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Payment Method Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: primaryGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Balance',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '(Available Balance:${availableBalance.toStringAsFixed(2)}ETB)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: primaryGreen,
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Green Send Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    BalanceNotifier.deduct(totalAmount);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionSuccessPage(
                          amount: originalAmount,
                          recipientName: widget.recipientName,
                        ),
                      ),
                    );
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
                    'Send',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildDigitKey(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => _onKeyPress(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
borderRadius: BorderRadius.circular(4),
),
),
child: const Text(
'OK',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w600,
),
),
),
),
),
],
),
),
],
),
),
],
),
);
}
}
