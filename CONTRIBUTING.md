# Contributing to VoxCode

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/RisorseArtificiali/voxcode.git
   cd voxcode
   ```

2. Install in development mode (requires [uv](https://docs.astral.sh/uv/)):
   ```bash
   uv sync
   ```

3. Run:
   ```bash
   uv run voxcode --help
   ```

## Prerequisites

- Python 3.11+
- A working microphone
- [PortAudio](https://www.portaudio.com/) (`sudo dnf install portaudio-devel` or `brew install portaudio`)
- GPU recommended for real-time transcription (CPU mode available but slower)

## Code Style

- Python 3.11+ required
- Use absolute imports (never relative)
- Type hints where practical
- snake_case for functions/variables, CamelCase for classes
- Line length: 119 characters
- Formatter: ruff

## Testing

```bash
# Interactive audio test
uv run python test_interactive.py

# Unit tests
uv run pytest tests/
```

## Integration with LINCE Dashboard

VoxCode integrates with the [LINCE dashboard](https://github.com/RisorseArtificiali/lince) via Zellij pipes. When running in pipe mode (`--use-pipe`), transcribed text is sent to the dashboard which routes it to the focused agent. See the LINCE dashboard documentation for setup details.

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-change`)
3. Make your changes and test with your audio setup
4. Submit a pull request

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
