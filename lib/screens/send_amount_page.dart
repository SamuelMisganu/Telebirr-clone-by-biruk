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
      builder: (context) => Container(
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
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Text(
              'Send Money to ${widget.recipientName}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: totalAmount.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const TextSpan(
                    text: 'ETB',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              Column(
                children: [
                  _buildFeeRow('Original Amount', '${originalAmount.toStringAsFixed(2)}ETB'),
                  const SizedBox(height: 16),
                  _buildFeeRow('Service fee', '${serviceFee.toStringAsFixed(2)}ETB'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Method', style: TextStyle(fontSize: 15, color: Colors.black54)),
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
                        child: const Icon(Icons.account_balance_wallet, color: _primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Balance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                            const SizedBox(height: 2),
                            Text(
                              '(Available Balance:${availableBalance.toStringAsFixed(2)}ETB)',
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: _primaryGreen, size: 24),
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
                  BalanceNotifier.deduct(totalAmount);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionSuccessPage(
                        amount: originalAmount,
                        recipientName: widget.recipientName,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Send', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: child,
      );

  Widget _buildFeeRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      );

  Widget _buildDigitKey(String label, {int flex = 1}) => Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () => _onKeyPress(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      );

  Widget _buildSideKey({
    required Widget child,
    required VoidCallback? onPressed,
    Color bg = Colors.white,
    Color fg = Colors.black87,
  }) =>
      Padding(
        padding: const EdgeInsets.all(3.0),
        child: SizedBox(
          height: 110,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              disabledBackgroundColor: bg.withOpacity(0.45),
              disabledForegroundColor: fg.withOpacity(0.8),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: child,
          ),
        ),
      );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Send Money', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.recipientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(widget.phoneNumber, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  const Divider(height: 24),
                  const Text('Amount', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text('ETB ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          _amount.isEmpty ? '0.00' : _amount,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _amount.isEmpty ? Colors.black26 : Colors.black,
),
),
),
],
),
const Divider(height: 24),
TextField(
controller: _notesController,
textInputAction: TextInputAction.done,
decoration: const InputDecoration(
hintText: 'Add notes (optional)',
hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
border: InputBorder.none,
isDense: true,
),
),
],
),
),
),
const Spacer(),
SafeArea(
top: false,
child: Container(
color: const Color(0xFFECEEF1),
padding: const EdgeInsets.all(4),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
flex: 3,
child: Column(
children: [
for (final row in [
['1', '2', '3'],
['4', '5', '6'],
['7', '8', '9'],
])
Row(children: row.map((d) => _buildDigitKey(d)).toList()),
Row(children: [_buildDigitKey('0', flex: 2), _buildDigitKey('.')]),
],
),
),
Expanded(
flex: 1,
child: Column(
children: [
_buildSideKey(
onPressed: _onBackspace,
child: const Icon(Icons.backspace_outlined),
),
_buildSideKey(
onPressed: (double.tryParse(_amount) ?? 0) > 0
? _showConfirmationBottomSheet
: null,
bg: _primaryGreen,
fg: Colors.white,
child: const Text(
'OK',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
