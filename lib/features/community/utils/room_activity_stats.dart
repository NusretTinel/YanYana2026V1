/// Estimates online members from total member count (no fake fixed numbers).
int estimateRoomOnlineCount(int memberCount) {
  if (memberCount <= 0) return 0;
  final estimated = (memberCount * 0.08).round();
  return estimated.clamp(1, memberCount);
}
