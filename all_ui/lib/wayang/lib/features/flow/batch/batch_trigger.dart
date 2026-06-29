enum BatchTrigger {
  size, // Trigger when batch reaches size
  time, // Trigger after time elapsed
  both, // Trigger on size OR time (whichever first)
}
