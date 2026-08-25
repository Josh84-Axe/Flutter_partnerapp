class NetworkPolicyFormatter {
  /// Format raw DB policy names into user-friendly names with clean icons/titles
  static String format(String? rawName) {
    if (rawName == null || rawName.trim().isEmpty || rawName.trim().toLowerCase() == 'none') {
      return 'None';
    }
    
    final trimmed = rawName.trim();
    final upper = trimmed.toUpperCase();

    if (upper == 'TIKNET_POLICY_UNFILTERED' || upper == 'UNFILTERED') {
      return '🌐 Unfiltered Access';
    }
    if (upper == 'TIKNET_POLICY_SECURITY_ENHANCED' || upper == 'SECURITY_ENHANCED' || upper == 'SECURITY ENHANCED') {
      return '🛡️ Security Enhanced';
    }
    if (upper == 'TIKNET_POLICY_FAMILY_SAFE' || upper == 'FAMILY_SAFE' || upper == 'FAMILY SAFE') {
      return '👨‍👩‍👧 Family Safe';
    }
    if (upper == 'TIKNET_POLICY_CIPA_STRICT' || upper == 'CIPA_STRICT' || upper == 'CIPA STRICT') {
      return '🏫 CIPA Strict Compliance';
    }
    if (upper == 'TIKNET_POLICY_STUDY_FOCUS' || upper == 'STUDY_FOCUS' || upper == 'STUDY FOCUS') {
      return '📚 Study & Focus Mode';
    }
    if (upper == 'TIKNET_POLICY_TEST_SCHED' || upper == 'TEST_SCHED' || upper == 'TEST SCHED') {
      return '🧪 Test Schedule';
    }
    if (upper == 'QA_DEFAULT_POLICY' || upper == 'QA_DEFAULT') {
      return '⚡ QA Default Policy';
    }
    if (upper == 'QA_STRICT_POLICY' || upper == 'QA_STRICT') {
      return '🔒 QA Strict Policy';
    }
    if (upper == 'TIKNET_POLICY_PAUSED' || upper == 'PAUSED' || upper == 'PAUSE') {
      return '⏸️ Paused Mode';
    }

    // Generic fallback: strip prefixes and convert to Title Case
    final clean = trimmed
        .replaceAll('TIKNET_POLICY_', '')
        .replaceAll('TIKNET_', '')
        .replaceAll('_POLICY', '')
        .replaceAll('QA_', 'QA ');

    return clean
        .split(RegExp(r'[\s_]+'))
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '')
        .join(' ');
  }

  /// Check if policy is a Pause policy
  static bool isPausePolicy(dynamic policy) {
    if (policy == null) return false;
    String name = '';
    if (policy is String) {
      name = policy;
    } else if (policy is Map) {
      name = (policy['name'] ?? policy['policy_name'] ?? policy['title'] ?? '').toString();
    }
    final upper = name.trim().toUpperCase();
    return upper.contains('PAUSE') || upper == 'TIKNET_POLICY_PAUSED';
  }

  /// Filter out Pause policies from list of selectable network policies
  static List<dynamic> filterSelectablePolicies(List<dynamic> policies) {
    return policies.where((p) => !isPausePolicy(p)).toList();
  }
}
