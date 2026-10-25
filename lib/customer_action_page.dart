import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'data/customer_action_service.dart';
import 'main.dart' show teal;
import 'auth/auth_service.dart';

class ActionFormPage extends StatefulWidget {
  const ActionFormPage({super.key, required this.action});

  final String action;

  @override
  State<ActionFormPage> createState() => _ActionFormPageState();
}

class _ActionFormPageState extends State<ActionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  bool _saving = false;

  bool get _needsAmount =>
      widget.action == 'Buy airtime' ||
      widget.action == 'Pay' ||
      widget.action == 'Transfer';

  bool get _needsReference =>
      widget.action == 'Buy airtime' ||
      widget.action == 'Pay' ||
      widget.action == 'Transfer';

  @override
  void dispose() {
    _nameController.dispose();
    _referenceController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await CustomerActionService.createRequest(
        action: widget.action,
        details: {
          'name': _nameController.text.trim(),
          'reference': _referenceController.text.trim(),
          'amount': _amountController.text.trim(),
          'message': _messageController.text.trim(),
        },
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Request submitted'),
          content: Text(
            'Your ${widget.action.toLowerCase()} request was saved. '
            'This demo does not move money or submit a real application.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save request: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.action)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.action,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_description),
            const SizedBox(height: 24),
            if (widget.action == 'Open an account' ||
                widget.action == 'Apply now') ...[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: _required,
              ),
              const SizedBox(height: 14),
            ],
            if (_needsReference) ...[
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: widget.action == 'Buy airtime'
                      ? 'Mobile number'
                      : 'Account or beneficiary reference',
                  prefixIcon: const Icon(Icons.receipt_long_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: 14),
            ],
            if (_needsAmount) ...[
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'R ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: 14),
            ],
            if (widget.action == 'Contact us' ||
                widget.action == 'My offers') ...[
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'How can we help?',
                  prefixIcon: Icon(Icons.chat_bubble_outline),
                ),
                validator: _required,
              ),
              const SizedBox(height: 14),
            ],
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text('Submit ${widget.action.toLowerCase()} request'),
              style: FilledButton.styleFrom(backgroundColor: teal),
            ),
          ],
        ),
      ),
    );
  }

  String get _description {
    switch (widget.action) {
      case 'Open an account':
        return 'Tell us about yourself and save an account-opening request.';
      case 'Apply now':
        return 'Start an application request for a future approved product.';
      case 'Buy airtime':
        return 'Save an airtime request for this demo account.';
      case 'Pay':
        return 'Save a payment request for review. No money will be moved.';
      case 'Transfer':
        return 'Save a transfer request for review. No money will be moved.';
      case 'Contact us':
        return 'Send a message to the support queue.';
      default:
        return 'Save your request so it can be reviewed later.';
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;
}

class InfoActionPage extends StatelessWidget {
  const InfoActionPage({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(icon, color: teal, size: 54),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(description, textAlign: TextAlign.center),
      ],
    ),
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.email_outlined, color: teal),
            title: const Text('Signed-in email'),
            subtitle: Text(user?.email ?? 'Unknown'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: teal),
            title: const Text('Sign out'),
            onTap: () async {
              await AuthService().signOut();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
