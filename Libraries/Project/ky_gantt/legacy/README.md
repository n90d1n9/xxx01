# ky_gantt Legacy Archive

This folder preserves earlier prototype and generated Gantt experiments that
used broader dependencies and unfinished app assumptions.

They live outside `lib` by design:

- Flutter/Dart analyzers no longer treat them as supported package source.
- The `ky_gantt` public API remains small and stable.
- Future work can mine or migrate specific ideas back into `lib` deliberately.

Do not import files from this archive from app code. Promote a file into the
supported package only after it is cleaned, tested, and exported through
`lib/ky_gantt.dart`.
