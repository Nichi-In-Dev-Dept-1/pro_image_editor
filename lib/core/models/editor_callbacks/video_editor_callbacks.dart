class VideoEditorCallbacks {
  VideoEditorCallbacks({
    this.onPlay,
    this.onPause,
    this.onMuteToggle,
  });
  final Function()? onPlay;
  final Function()? onPause;
  final Function(bool isMuted)? onMuteToggle;
}
