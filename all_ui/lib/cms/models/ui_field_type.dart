/// UI field types for CMS interface

enum UIFieldType {
  // Text inputs
  textInput,
  textArea,
  richTextEditor,
  markdown,
  code,

  // Numbers
  numberInput,
  slider,
  rating,

  // Dates & Time
  datePicker,
  dateTimePicker,
  timePicker,
  dateRange,

  // Selections
  dropdown,
  radioGroup,
  checkboxGroup,
  tags,

  // Boolean
  toggle,
  checkbox,

  // Media
  imageUpload,
  fileUpload,
  mediaGallery,

  // Advanced
  colorPicker,
  location,
  json,
  relation,

  // Custom
  custom,
  slug,
}
