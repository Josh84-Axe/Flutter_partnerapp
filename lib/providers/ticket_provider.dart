import 'package:flutter/foundation.dart';
import '../repositories/ticket_repository.dart';
import '../models/crm_ticket_model.dart';

class TicketProvider with ChangeNotifier {
  final TicketRepository _ticketRepository;

  bool _isLoading = false;
  String? _error;
  List<CrmTicket> _tickets = [];
  List<CrmMessage> _messages = [];

  TicketProvider({required TicketRepository ticketRepository})
      : _ticketRepository = ticketRepository;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CrmTicket> get tickets => _tickets;
  List<CrmMessage> get messages => _messages;

  Future<bool> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
    required String email,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _ticketRepository.createCrmTicket(
        subject: subject,
        description: description,
        email: email,
        name: name,
        priority: priority.toUpperCase(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchTickets(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tickets = await _ticketRepository.fetchTickets(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String caseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _ticketRepository.fetchTicketMessages(caseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> replyToTicket(String caseId, String content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _ticketRepository.replyToTicket(caseId, content);
      if (success) {
        // Refresh messages after successful reply
        await fetchMessages(caseId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
