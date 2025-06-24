# Services/Core

This section must be imported.

This section contains option definitions and what actions to take on said definitions so
the nixos can be built even when the configuration locations are sporadic.

Because of the Nixos's lazy nature of evaluation, declarations in multiple files will not be
evaluated unless the service itself is enabled. But Nixos **_DO_** care about option definitions,
hence why this exists.

There must be no config enabling actions (side effects) toggled here, they must be defined in `machines` section or elsewhere.
