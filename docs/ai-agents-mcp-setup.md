# Add Darta as an MCP server (Cursor / Codex)

Step-by-step for vertical developers. Tool catalog: [`ai-agents.md`](ai-agents.md).

## Preconditions

1. Framework installed — [`install.md`](install.md) — `darta` on `PATH`.
2. You are inside a **vertical project** folder (template after `darta run-wizard`, or `darta project init`), **not** the AppDarta monorepo.
3. Verify:

```bash
cd /path/to/my-vertical
darta version
test -f appdarta.project.yaml && echo "project ok"
```

## Cursor

1. Open the **vertical** folder as the workspace (`File → Open Folder`).
2. Open **Cursor Settings → MCP** (or project `.cursor/mcp.json` / root `.mcp.json`).
3. Add a server (or use the template’s `.mcp.json` if present):

```json
{
  "mcpServers": {
    "darta": {
      "command": "darta",
      "args": ["mcp", "serve", "--project", "."],
      "env": {}
    }
  }
}
```

4. Ensure `darta` resolves in Cursor’s environment (`APPDARTA_HOME/bin` on `PATH`).
5. Reload MCP / restart Cursor if tools do not appear.
6. Confirm tools such as `get_project_spec` and `appdarta_get_build_status` are listed.

**Failure: `command not found: darta`** — fix shell `PATH`, then restart Cursor from a terminal where `which darta` works.

## Codex

Point the Codex MCP client at the same command:

```json
{
  "mcpServers": {
    "darta": {
      "command": "darta",
      "args": ["mcp", "serve", "--project", "."]
    }
  }
}
```

Working directory must be the vertical project root.

## Manual serve (optional)

Cursor/Codex usually spawn `darta mcp serve` for you. To test in a terminal:

```bash
cd /path/to/my-vertical
darta mcp serve --project .
```

## Wizard UI alongside MCP

```bash
darta ui serve
```

In the browser: **AI Settings → CLI debug** for doctor results and CLI debug logging. Build debug (assemble / prompt-diff / replay) remains under **Build → More ▸**.

When CLI debug is enabled, Build operator mode can show **Debug** (Mode F).

## Windows (WSL2)

Run all of the above inside WSL2 Ubuntu. Point Cursor/Codex at the WSL `darta` binary, or develop inside WSL with a Linux MCP host.

## Next

- Day-0 path: [`../vertical-template/vertical-developer-handbook.md`](../vertical-template/vertical-developer-handbook.md) §2
- Tool list: [`ai-agents.md`](ai-agents.md)
