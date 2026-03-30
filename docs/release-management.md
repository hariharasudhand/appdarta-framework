# Release Management

AppDarta Engine releases are versioned and installed under:

- `APPDARTA_HOME/framework/releases/<version>`
- `APPDARTA_HOME/framework/current`

Verticals pin the required release in `appdarta.framework.yaml`.

That allows:

- repeatable installs
- safe upgrades
- public vertical repos without vendored framework source
