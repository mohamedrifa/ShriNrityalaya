enum ApprovalStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected'),
  paid('Paid'),
  unpaid('Unpaid');

  final String value;
  const ApprovalStatus(this.value);

  static ApprovalStatus fromString(String? val) {
    for (final status in ApprovalStatus.values) {
      if (status.value.toLowerCase() == val?.toLowerCase()) {
        return status;
      }
    }
    return ApprovalStatus.pending;
  }
}
