import 'package:flutter/material.dart';
import '../services/marketing_service.dart';

class MarketingScreen extends StatefulWidget {
  @override
  _MarketingScreenState createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
  final MarketingService _marketingService = MarketingService();
  bool _isSending = false;

  Future<void> _sendHealthTipsNewsletter() async {
    setState(() => _isSending = true);
    try {
      final success = await _marketingService.sendHealthTipsNewsletter();
      _showResult(success, 'Health Tips Newsletter');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendSpecialOfferSms() async {
    setState(() => _isSending = true);
    try {
      final success = await _marketingService.sendSpecialOfferSms();
      _showResult(success, 'Special Offer SMS');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showResult(bool success, String campaignType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '$campaignType sent successfully'
              : 'Failed to send $campaignType',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _showCustomCampaignDialog() async {
    final _formKey = GlobalKey<FormState>();
    String subject = '';
    String content = '';
    bool isEmail = true;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Custom Campaign'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text('Campaign Type'),
                  subtitle: Text(isEmail ? 'Email' : 'SMS'),
                  value: isEmail,
                  onChanged: (value) => setState(() => isEmail = value),
                ),
                if (isEmail) ...[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Subject'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                    onSaved: (value) => subject = value ?? '',
                  ),
                  SizedBox(height: 16),
                ],
                TextFormField(
                  decoration: InputDecoration(
                    labelText: isEmail ? 'HTML Content' : 'Message',
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (value) => content = value ?? '',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                Navigator.pop(context);
                setState(() => _isSending = true);
                try {
                  bool success;
                  if (isEmail) {
                    success = await _marketingService.sendPromotionalEmail(
                      campaignName: 'Custom Email Campaign',
                      subject: subject,
                      htmlContent: content,
                    );
                  } else {
                    success = await _marketingService.sendPromotionalSms(
                      campaignName: 'Custom SMS Campaign',
                      message: content,
                    );
                  }
                  _showResult(success, 'Custom Campaign');
                } catch (e) {
                  _showError(e.toString());
                } finally {
                  setState(() => _isSending = false);
                }
              }
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketing Campaigns'),
      ),
      body: _isSending
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildCampaignCard(
                  title: 'Health Tips Newsletter',
                  description:
                      'Send monthly health tips newsletter to all patients',
                  icon: Icons.health_and_safety,
                  onTap: _sendHealthTipsNewsletter,
                ),
                SizedBox(height: 16),
                _buildCampaignCard(
                  title: 'Special Offer SMS',
                  description:
                      'Send promotional SMS about special offers to all patients',
                  icon: Icons.local_offer,
                  onTap: _sendSpecialOfferSms,
                ),
                SizedBox(height: 16),
                _buildCampaignCard(
                  title: 'Custom Campaign',
                  description:
                      'Create and send custom email or SMS campaign',
                  icon: Icons.campaign,
                  onTap: _showCustomCampaignDialog,
                ),
              ],
            ),
    );
  }

  Widget _buildCampaignCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(description),
        trailing: IconButton(
          icon: Icon(Icons.send),
          onPressed: onTap,
        ),
      ),
    );
  }
}
