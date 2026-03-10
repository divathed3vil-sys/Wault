// lib/screens/add_account_screen.dart
// Bottom sheet for adding a new account. Takes a label, creates the account,
// then immediately opens a WhatsApp Web session for it.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/account.dart';
import '../services/account_service.dart';
import '../services/engine_service.dart';
import '../theme/wault_theme.dart';

/// Shows the add account bottom sheet.
/// [onAccountAdded] is called with the updated account list after creation.
Future<void> showAddAccountSheet(
  BuildContext context, {
  required void Function(List<Account> accounts) onAccountAdded,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AddAccountSheet(onAccountAdded: onAccountAdded),
  );
}

class _AddAccountSheet extends StatefulWidget {
  final void Function(List<Account> accounts) onAccountAdded;
  const _AddAccountSheet({required this.onAccountAdded});

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field after sheet animates in
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final label = _controller.text.trim();
    if (label.isEmpty) {
      setState(() => _error = 'Please enter a name for this account');
      return;
    }
    if (label.length > 30) {
      setState(() => _error = 'Name must be 30 characters or less');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final account = await AccountService.createAccount(label);
    if (account == null) {
      setState(() {
        _isLoading = false;
        _error = 'Vault is full (max 5 accounts)';
      });
      return;
    }

    // Load updated list and notify parent
    final accounts = await AccountService.loadAccounts();
    widget.onAccountAdded(accounts);

    if (mounted) {
      Navigator.of(context).pop();
      // Open session immediately after adding
      await EngineService.openSession(account);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: WaultColors.elevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: WaultColors.glassBorder, width: 0.5),
          left: BorderSide(color: WaultColors.glassBorder, width: 0.5),
          right: BorderSide(color: WaultColors.glassBorder, width: 0.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: WaultColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'New Account',
            style: GoogleFonts.inter(
              color: WaultColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Give this WhatsApp account a name so you can tell them apart.',
            style: GoogleFonts.inter(
              color: WaultColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Label field
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: GoogleFonts.inter(
              color: WaultColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: WaultColors.primary,
            maxLength: 30,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\n')),
            ],
            decoration: InputDecoration(
              hintText: 'e.g. Personal, Work, Business',
              counterStyle: GoogleFonts.inter(
                color: WaultColors.textTertiary,
                fontSize: 11,
              ),
              errorText: _error,
              errorStyle: GoogleFonts.inter(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),

          const SizedBox(height: 20),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: _ContinueButton(
              isLoading: _isLoading,
              onTap: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _ContinueButton({required this.isLoading, required this.onTap});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.isLoading
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: widget.isLoading
                ? WaultColors.primary.withOpacity(0.6)
                : WaultColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: WaultColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Continue',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
