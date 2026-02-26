import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import '../providers/ticket_provider.dart';
import '../models/crm_ticket_model.dart';

class SupportTicketChatScreen extends StatefulWidget {
  final String ticketId;
  final String subject;

  const SupportTicketChatScreen({
    super.key,
    required this.ticketId,
    required this.subject,
  });

  @override
  State<SupportTicketChatScreen> createState() => _SupportTicketChatScreenState();
}

class _SupportTicketChatScreenState extends State<SupportTicketChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchMessages());
  }

  void _fetchMessages() {
    context.read<TicketProvider>().fetchMessages(widget.ticketId);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Compress for faster upload
      );
      if (file != null) {
        setState(() => _selectedFile = file);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error picking image: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = XFile(result.files.single.path!);
        });
      } else if (result != null && result.files.single.bytes != null) {
        // Handle web bytes
        setState(() {
          _selectedFile = XFile.fromData(
            result.files.single.bytes!,
            name: result.files.single.name,
          );
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error picking file: $e');
    }
  }

  void _clearFile() {
    setState(() => _selectedFile = null);
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty && _selectedFile == null) return;

    final ticketProvider = context.read<TicketProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() => _isUploading = true);
    
    final file = _selectedFile;
    // Capture data before async gaps
    final filePath = kIsWeb ? null : file?.path;
    final fileName = file?.name;
    final fileBytes = file != null ? await file.readAsBytes() : null;

    _messageController.clear();
    setState(() => _selectedFile = null);

    final success = await ticketProvider.replyToTicket(
      widget.ticketId,
      content.isEmpty ? 'Attachment' : content,
      filePath: filePath,
      fileName: fileName,
      fileBytes: fileBytes,
    );

    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        _scrollToBottom();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('failed_to_send_message'.tr())),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subject, style: const TextStyle(fontSize: 16)),
            Text('Ticket ID: ${widget.ticketId}', 
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ticketProvider.isLoading && ticketProvider.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: ticketProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = ticketProvider.messages[index];
                      return _MessageBubble(message: message);
                    },
                  ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedFile != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedFile!.name.toLowerCase().endsWith('.png') || 
                      _selectedFile!.name.toLowerCase().endsWith('.jpg') || 
                      _selectedFile!.name.toLowerCase().endsWith('.jpeg')
                        ? Icons.image
                        : Icons.insert_drive_file,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFile!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _clearFile,
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                  onPressed: _isUploading ? null : () => _showAttachmentOptions(context),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isUploading,
                    decoration: InputDecoration(
                      hintText: 'type_your_message'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                if (_isUploading)
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('From Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Attach File'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final CrmMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isFromUser;
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 2),
            if (message.fileUrl != null && message.fileUrl!.isNotEmpty)
              _buildAttachment(context, message, isMe, theme),
            Text(
              message.content,
              style: TextStyle(
                color: isMe 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.sentAt != null 
                  ? DateFormat('HH:mm').format(message.sentAt!) 
                  : '',
              style: TextStyle(
                fontSize: 9,
                color: (isMe 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment(BuildContext context, CrmMessage message, bool isMe, ThemeData theme) {
    final bool isImage = message.fileUrl!.toLowerCase().endsWith('.png') || 
                         message.fileUrl!.toLowerCase().endsWith('.jpg') || 
                         message.fileUrl!.toLowerCase().endsWith('.jpeg');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openAttachment(context, message.fileUrl!),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.fileUrl!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: theme.colorScheme.errorContainer,
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.white24 : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.insert_drive_file, 
                        color: isMe ? Colors.white : theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          message.fileName ?? 'Attachment',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isMe ? Colors.white : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAttachment(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open attachment')),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error launching URL: $e');
    }
  }
}
