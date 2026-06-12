enum DataType {
  string,
  number,
  date,
  boolean,
  currency,
  percentage,
  email,
  phone,
  url,
  datetime,
  time,
  json,
  array,
  object,
  binary,
  geo,
  uuid,
}

enum ExportFormat {
  pdf,
  excel,
  csv,
  json,
  html,
  xml,
  markdown,
  powerpoint,
  googleSheets,
  tableau,
  powerBI,
  custom,
}

enum AggregationType {
  sum,
  average,
  count,
  min,
  max,
  median,
  stdDev,
  variance,
  mode,
  percentile,
  distinctCount,
  first,
  last,
  custom,
}

enum ChartType { line, bar, pie, scatter, area, combo }

enum ScheduleFrequency { daily, weekly, monthly, quarterly, yearly }
