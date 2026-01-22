import 'package:flutter/foundation.dart';
import '../repositories/ticket_repository.dart';

class TicketProvider with ChangeNotifier {
  final TicketRepository _ticketRepository;

  bool _isLoading = false;
  String? _error;

  TicketProvider({required TicketRepository ticketRepository})
      : _ticketRepository = ticketRepository;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _ticketRepository.createTicket(
        subject: subject,
        description: description,
        category: category,
        priority: priority,
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
