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
  static const _primaryGreen = Color(0xFF8CC63F);
  String _amount = '';
  final TextEditingController _notesController = TextEditingController();

  void _onKeyPress(String value) {
    setState(() {
      if (value == '.' && _amount.contains('.')) return;
      if (_amount.contains('.') && _amount.split('.')[1].length >= 2) return;
      _amount = (_amount == '0' && value != '.') ? value : '$_amount$value';
    });
  }

  void _onBackspace() {
    if (_amount.isNotEmpty) {
      setState(() => _amount = _amount.substring(0, _amount.length - 1));
    }
  }

  void _showConfirmationBottomSheet() {
    final originalAmount = double.tryParse(_amount) ?? 0.0;
    if (originalAmount <= 0) return;

    const serviceFee = 1.00;
    final totalAmount = originalAmount + serviceFee;
    final availableBalance = BalanceNotifier.currentBalance.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F6F8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black87, size: 26),
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ),
            Text(
              'Send Money to ${widget.recipientName}',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: totalAmount.toStringAsFixed(2),
                    style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const TextSpan(
                    text: 'ETB',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              Column(
                children: [
                  _buildFeeRow('Original Amount',
                      '${originalAmount.toStringAsFixed(2)}ETB'),
                  const SizedBox(height: 16),
                  _buildFeeRow(
                      'Service fee', '${serviceFee.toStringAsFixed(2)}ETB'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Method',
                      style: TextStyle(fontSize: 15, color: Colors.black54)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _primaryGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance_wallet,
                            color: _primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Balance',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                            const SizedBox(height: 2),
                            Text(
                              '(Available Balance:${availableBalance.toStringAsFixed(2)}ETB)',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle,
                          color: _primaryGreen, size: 24),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _showPinBottomSheet(originalAmount, totalAmount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Send',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPinBottomSheet(double originalAmount, double totalAmount) {
    String enteredPin = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (pinContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          void onPinDigit(String digit) {
            if (enteredPin.length >= 6) return;
            setModalState(() {
              enteredPin += digit;
            });

            if (enteredPin.length == 6) {
              Future.delayed(const Duration(milliseconds: 180), () {
                if (!mounted) return;
                Navigator.pop(pinContext);
                BalanceNotifier.deduct(totalAmount);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionSuccessPage(
                      amount: originalAmount,
                      recipientName: widget.recipientName,
                    ),
                  ),
                );
              });
            }
          }

          void onPinBackspace() {
            if (enteredPin.isEmpty) return;
            setModalState(() {
              enteredPin = enteredPin.substring(0, enteredPin.length - 1);
            });
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.black87, size: 24),
                          onPressed: () => Navigator.pop(pinContext),
                        ),
                        const Expanded(
                          child: Text(
                            'Enter PIN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    )
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 22),

                  // 6 Masked PIN Boxes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final isFilled = index < enteredPin.length;
                        return Container(
                          width: 42,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isFilled
Use code with caution.
? _primaryGreen
: const Color(0xFFD0D5DD),
width: 1.4,
),
),
child: isFilled
? Container(
width: 10,
height: 10,
decoration: const BoxDecoration(
color: Colors.black87,
shape: BoxShape.circle,
),
)
: null,
);
}),
),
),
const SizedBox(height: 14),
const Text(
'Forgot PIN?',
style: TextStyle(
color: _primaryGreen,
fontSize: 13,
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 20),
// Numeric PIN Keypad
Container(
color: const Color(0xFFECEEF1),
padding: const EdgeInsets.all(4),
child: Column(
children: [
for (final row in [
['1', '2', '3'],
['4', '5', '6'],
['7', '8', '9'],
])
Row(
children: row
.map((d) => _buildPinKey(
label: d,
onTap: () => onPinDigit(d),
))
.toList(),
),
Row(
children: [
const Expanded(child: SizedBox(height: 50)),
_buildPinKey(
label: '0',
onTap: () => onPinDigit('0'),
),
Expanded(
child: Padding(
padding: const EdgeInsets.all(3),
child: SizedBox(
height: 50,
child: ElevatedButton(
onPressed: onPinBackspace,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.white,
foregroundColor: Colors.black87,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(4),
),
),
child: const Icon(Icons.backspace_outlined,
size: 20),
),
),
),
),
],
),
],
),
),
],
),
),
);
},
),
);
  }
  _buildSideKey(
onPressed: (double.tryParse(_amount) ?? 0) > 0
? _showConfirmationBottomSheet
: null,
bg: _primaryGreen,
fg: Colors.white,
child: const Text(
'OK',
style: TextStyle(
fontSize: 18, fontWeight: FontWeight.w600),
),
),
],
),
),
],
),
),
),
],
),
);
}
}
