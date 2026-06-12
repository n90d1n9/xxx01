# ky_builder_shared

Shared builder primitives and UI widgets for Kaysir visual builders.

The package keeps common builder concerns outside app-specific features:

- canvas sizing and snapping rules
- layout mechanisms such as grid, tabular columns, and auto grid
- reusable component catalogs
- serializable component geometry and responsive overrides
- compact builder panels, empty states, canvas frames, and metric chips

`ky_website_builder` uses this package now, and `kaysir_ui` layout builder can adopt it incrementally without a large migration.
