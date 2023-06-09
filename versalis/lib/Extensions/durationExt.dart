extension DurationExt on Duration{
  String formatTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(inHours);
    final minutes = twoDigits(inMinutes.remainder(60));
    final seconds = twoDigits(inSeconds.remainder(60));
    return [
      if (inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }
}