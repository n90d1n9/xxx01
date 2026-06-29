enum MergeStrategy {
  union, // Combine all data
  intersection, // Keep only common fields
  leftJoin, // Prefer first input
  rightJoin, // Prefer last input
  custom, // Custom merge logic
}
