# Serena MCP Official Implementation Guide

## Overview

Based on research from the official Model Context Protocol (MCP) specification and Python SDK documentation, here's the comprehensive guide for properly implementing Serena MCP with global configuration.

## Official MCP Architecture

### Core Components

**MCP Host**: AI application coordinating MCP clients (e.g., Claude Desktop, OpenCode)
**MCP Client**: Component maintaining connection to MCP server
**MCP Server**: Program exposing capabilities through standardized protocol

### Transport Mechanisms

1. **Stdio Transport**: Direct process communication (optimal performance)
2. **Streamable HTTP Transport**: HTTP POST with optional SSE (remote servers)
3. **SSE Transport**: Server-Sent Events (being superseded by Streamable HTTP)

## Global Configuration Structure

### Primary Configuration Files

**`.serena/serena_config.yaml`** - Main Serena configuration:

```yaml
# Tool enablement and security settings
tools:
  find_symbol: true
  search_for_pattern: true
  get_symbols_overview: true
  read_file: true
  execute_shell_command: false # Security: disabled

# Project-specific settings
project:
  auto_index: true
  ignore_paths: [".git", "node_modules"]
```

**`opencode/serena-integration/serena-agent-config.yaml`** - Agent permissions:

```yaml
token_budgets:
  scs_aws: 2000
  auto_compress_threshold: 1500

permissions:
  analyst: allow
  security: allow
  general: ask
  devops: ask

mcp_checkpoints:
  - think_about_collected_information
  - think_about_task_adherence
  - think_about_whether_you_are_done
```

### Project Registration

**`.serena/project.json`** - Language and feature enablement:

```json
{
  "name": "dotfiles",
  "description": "Personal dotfiles project",
  "languages": ["shell", "lua"],
  "type": "dotfiles",
  "maintainer": "killerkidbo"
}
```

## MCP Server Implementation

### FastMCP Server (Recommended)

```python
from mcp.server.fastmcp import FastMCP

# Create MCP server
mcp = FastMCP("My Server")

@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers together."""
    return a + b

@mcp.resource("file://documents/{name}")
def read_document(name: str) -> str:
    """Read a document by name."""
    return f"Content of {name}"

@mcp.prompt()
def analyze_code(code: str) -> str:
    return f"Please analyze this code:\\n\\n{code}"

if __name__ == "__main__":
    mcp.run()
```

### Low-Level Server (Advanced)

```python
import mcp.server.stdio
import mcp.types as types
from mcp.server.lowlevel import Server

server = Server("example-server")

@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="add",
            description="Add two numbers",
            inputSchema={
                "type": "object",
                "properties": {
                    "a": {"type": "integer"},
                    "b": {"type": "integer"}
                },
                "required": ["a", "b"]
            }
        )
    ]

@server.call_tool()
async def handle_call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    if name == "add":
        result = arguments["a"] + arguments["b"]
        return [types.TextContent(type="text", text=str(result))]
    raise ValueError(f"Unknown tool: {name}")

async def run():
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, ...)

if __name__ == "__main__":
    import asyncio
    asyncio.run(run())
```

## MCP Primitives

### Tools (Model-Controlled)

Tools enable LLMs to perform actions:

```python
@mcp.tool()
async def search_files(query: str, ctx: Context) -> str:
    """Search for files containing query."""
    await ctx.info(f"Searching for: {query}")
    # Implementation
    return f"Found files: {results}"
```

### Resources (Application-Controlled)

Resources provide data access:

```python
@mcp.resource("file://logs/{date}")
def get_logs(date: str) -> str:
    """Get application logs for specific date."""
    return f"Logs for {date}: ..."
```

### Prompts (User-Controlled)

Prompts provide interaction templates:

```python
@mcp.prompt()
def code_review(code: str, language: str = "python") -> str:
    return f"Review this {language} code:\\n\\n{code}"
```

## Context and Capabilities

### Context Object

Access MCP capabilities through context:

```python
@mcp.tool()
async def process_data(data: str, ctx: Context) -> str:
    # Logging
    await ctx.info("Starting processing")
    await ctx.warning("This is experimental")

    # Progress reporting
    await ctx.report_progress(progress=0.5, message="Halfway done")

    # Resource access
    config = await ctx.read_resource("config://settings")

    # User interaction
    result = await ctx.elicit(
        message="Confirm action?",
        schema=ConfirmationSchema
    )

    return "Processing complete"
```

### Structured Output

Return typed data with validation:

```python
from pydantic import BaseModel

class WeatherData(BaseModel):
    temperature: float
    condition: str
    humidity: float

@mcp.tool()
def get_weather(city: str) -> WeatherData:
    """Get weather data - returns structured output."""
    return WeatherData(
        temperature=22.5,
        condition="sunny",
        humidity=65.0
    )
```

## Transport Configuration

### Stdio Transport (Local)

```python
# Run with stdio transport
if __name__ == "__main__":
    mcp.run(transport="stdio")
```

### Streamable HTTP Transport (Remote)

```python
# Stateful server
mcp = FastMCP("My Server")

# Stateless server
mcp = FastMCP("My Server", stateless_http=True)

if __name__ == "__main__":
    mcp.run(transport="streamable-http")
```

### Mounting to ASGI Server

```python
from starlette.applications import Starlette
from starlette.routing import Mount

app = Starlette(
    routes=[
        Mount("/api", app=mcp.streamable_http_app()),
    ]
)
```

## Client Implementation

### Basic MCP Client

```python
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def run_client():
    server_params = StdioServerParameters(
        command="python",
        args=["path/to/server.py"]
    )

    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()

            # List tools
            tools = await session.list_tools()
            print(f"Available tools: {[t.name for t in tools.tools]}")

            # Call tool
            result = await session.call_tool("add", {"a": 5, "b": 3})
            print(f"Result: {result.content[0].text}")

asyncio.run(run_client())
```

### Streamable HTTP Client

```python
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client

async def run_http_client():
    async with streamablehttp_client("http://localhost:8000/mcp") as (
        read_stream, write_stream, _
    ):
        async with ClientSession(read_stream, write_stream) as session:
            await session.initialize()
            tools = await session.list_tools()
            print(f"Available tools: {[t.name for t in tools.tools]}")

asyncio.run(run_http_client())
```

## Authentication and Security

### OAuth Implementation

```python
from mcp.server.auth.provider import AccessToken, TokenVerifier
from mcp.server.auth.settings import AuthSettings

class CustomTokenVerifier(TokenVerifier):
    async def verify_token(self, token: str) -> AccessToken | None:
        # Implement token validation
        pass

mcp = FastMCP(
    "Protected Server",
    token_verifier=CustomTokenVerifier(),
    auth=AuthSettings(
        issuer_url="https://auth.example.com",
        resource_server_url="http://localhost:8000",
        required_scopes=["read", "write"]
    )
)
```

## MCP Checkpoints

### Required Thinking Points

```python
def think_about_collected_information():
    """Call after gathering information."""
    # Implementation
    pass

def think_about_task_adherence():
    """Call before making changes."""
    # Implementation
    pass

def think_about_whether_you_are_done():
    """Call before completing task."""
    # Implementation
    pass
```

### Integration Pattern

```python
async def agent_workflow():
    # Phase 1: Gather information
    data = collect_information()
    think_about_collected_information()

    # Phase 2: Plan changes
    plan = create_plan(data)
    think_about_task_adherence()

    # Phase 3: Execute
    execute_changes(plan)

    # Phase 4: Complete
    think_about_whether_you_are_done()
```

## Notification System

### Real-time Updates

```python
@mcp.tool()
async def update_data(ctx: Context) -> str:
    # Notify clients of changes
    await ctx.session.send_resource_list_changed()
    await ctx.session.send_tool_list_changed()

    return "Data updated and clients notified"
```

## Best Practices

### Server Development

1. **Use FastMCP** for most use cases (simpler API)
2. **Implement structured output** for type safety
3. **Use context object** for logging and progress
4. **Handle errors gracefully** with proper error messages
5. **Document tools and resources** clearly

### Client Development

1. **Handle all content types** (text, images, resources)
2. **Implement proper error handling** for failed tool calls
3. **Use sampling callbacks** for LLM integration
4. **Handle notifications** for real-time updates
5. **Implement authentication** for protected servers

### Global Configuration

1. **Configure tools globally** in `.serena/serena_config.yaml`
2. **Set permissions appropriately** in agent config
3. **Use token budgets** to control resource usage
4. **Implement context compression** for long conversations
5. **Enable audit logging** for security monitoring

## Official SDKs

### Language Support

- **Python SDK**: Full implementation with FastMCP
- **TypeScript SDK**: Official TypeScript implementation
- **Java SDK**: Spring AI integration
- **Go SDK**: Google collaboration
- **C# SDK**: Microsoft collaboration
- **Rust SDK**: High-performance implementation

### Installation

```bash
# Python
pip install "mcp[cli]"
# or
uv add "mcp[cli]"

# TypeScript
npm install @modelcontextprotocol/sdk

# Go
go get github.com/modelcontextprotocol/go-sdk
```

## Testing and Debugging

### MCP Inspector

```bash
# Install MCP Inspector
npm install -g @modelcontextprotocol/inspector

# Run inspector
mcp-inspector
```

### Development Mode

```bash
# Python development server
uv run mcp dev server.py

# With dependencies
uv run mcp dev server.py --with pandas --with numpy
```

## Production Deployment

### Docker Deployment

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY server.py .
EXPOSE 8000

CMD ["python", "server.py"]
```

### Systemd Service

```ini
[Unit]
Description=MCP Server
After=network.target

[Service]
Type=simple
User=mcp-user
WorkingDirectory=/opt/mcp-server
ExecStart=/usr/bin/python server.py
Restart=always

[Install]
WantedBy=multi-user.target
```

## Troubleshooting

### Common Issues

1. **Server not connecting**: Check transport configuration
2. **Tools not appearing**: Verify tool registration and permissions
3. **Authentication failing**: Check token validation and scopes
4. **Performance issues**: Implement context compression
5. **Memory leaks**: Use proper lifespan management

### Debug Logging

```python
import logging
logging.basicConfig(level=logging.DEBUG)

# Enable MCP debug logging
mcp = FastMCP("Debug Server", debug=True)
```

## Official Resources

- **Specification**: https://spec.modelcontextprotocol.io
- **Documentation**: https://modelcontextprotocol.io/docs
- **Python SDK**: https://github.com/modelcontextprotocol/python-sdk
- **Servers**: https://github.com/modelcontextprotocol/servers
- **Inspector**: https://github.com/modelcontextprotocol/inspector

This guide provides the official, standards-compliant approach to implementing Serena MCP with global configuration based on the Model Context Protocol specification and official SDK documentation.</content>
</xai:function_call
