# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a personal Ubuntu dotfiles repository for managing shell configuration files organized by shell type. The [bash/](bash/) directory contains bash-specific configurations. All configuration files within `bash/home/` should be deployed to `~` (user's home directory).

## Architecture

### Bash Configuration ([bash/](bash/))

#### Core Components

1. **[bash/home/.bashrc](bash/home/.bashrc)** - Main bash configuration file that:
   - Sources standard Ubuntu bash settings
   - Loads custom prompt via `~/.bash-custom-data/functions.sh`
   - Configures development tools (nvm, fnm, cargo, pnpm, bun)
   - Sets up Java, Gradle, and Maven environment variables

2. **[bash/home/.bashrc_part](bash/home/.bashrc_part)** - Lightweight snippet for appending to existing system `.bashrc` files on new systems. Contains only essential custom PS1 setup and tool paths.

3. **[bash/home/.bash_aliases](bash/home/.bash_aliases)** - System and development tool shortcuts for:
   - Apache, Nginx, PHP-FPM service management
   - MySQL, PostgreSQL, MongoDB operations
   - Navigation and file management
   - Minecraft Spigot server startup

4. **[bash/home/.bash-custom-data/functions.sh](bash/home/.bash-custom-data/functions.sh)** - Advanced PS1 prompt implementation:
   - File-based caching system with flock for performance
   - Context-aware version display (Node.js, PHP, Python, Minecraft Spigot, Git)
   - Caches version info per directory to avoid repeated command execution
   - Python virtual environment detection (venv and conda)

#### Bash Installation

Two deployment approaches:
1. **Full replacement**: Copy all files from [bash/home/](bash/home/) to `~`
2. **Append-only**: Append [bash/home/.bashrc_part](bash/home/.bashrc_part) to existing `~/.bashrc`

### Zsh Configuration ([zsh/](zsh/))

#### Core Components

1. **[zsh/home/.zshrc](zsh/home/.zshrc)** - Main zsh configuration file that:
   - Configures zsh-specific features (history, completion, colors)
   - Loads custom prompt via `~/.zsh-custom-data/functions.sh`
   - Configures development tools (nvm, fnm, cargo, pnpm, bun)
   - Sets up Java, Gradle, and Maven environment variables

2. **[zsh/home/.zshrc_part](zsh/home/.zshrc_part)** - Lightweight snippet for appending to existing system `.zshrc` files on new systems. Contains only essential custom PROMPT setup and tool paths.

3. **[zsh/home/.zsh_aliases](zsh/home/.zsh_aliases)** - System and development tool shortcuts (identical to bash aliases but adapted for zsh):
   - Apache, Nginx, PHP-FPM service management
   - MySQL, PostgreSQL, MongoDB operations
   - Navigation and file management
   - Minecraft Spigot server startup

4. **[zsh/home/.zsh-custom-data/functions.sh](zsh/home/.zsh-custom-data/functions.sh)** - Advanced PROMPT implementation (zsh version):
   - File-based caching system with flock for performance
   - Context-aware version display (Node.js, PHP, Python, Minecraft Spigot, Git)
   - Caches version info per directory to avoid repeated command execution
   - Python virtual environment detection (venv and conda)
   - Uses zsh-specific prompt syntax (`%F{color}`, `%f`)

#### Zsh Installation

Two deployment approaches:
1. **Full replacement**: Copy all files from [zsh/home/](zsh/home/) to `~`
2. **Append-only**: Append [zsh/home/.zshrc_part](zsh/home/.zshrc_part) to existing `~/.zshrc`

### Prompt System (Both Shells)

The custom prompt displays:
- Current working directory
- Technology versions (only when relevant project files detected)
- Git branch information
- Python virtual environment status

Version detection logic:
- Node: Checks for `package.json`
- PHP: Checks for `composer.json` or `index.php`
- Python: Checks for `.py` files, `requirements.txt`, `setup.py`, `pyproject.toml`
- Minecraft Spigot: Checks for `version_history.json`

Cache files location:
- Bash: `~/.bash-custom-data/` (cache, cache.lock, cache.tmp)
- Zsh: `~/.zsh-custom-data/` (cache, cache.lock, cache.tmp)

### Configuration Files

- `.hushlogin` - Suppresses login messages (present in both bash and zsh)

**Note**: The `.cargo/` and `.config/` directories in `bash/home/` should be ignored as they were test files.

## Testing Changes

### Bash
1. Source the file: `source ~/.bashrc` (or `bash_update` alias)
2. Test prompt rendering by navigating to project directories with different technologies
3. Verify cache operations by checking `~/.bash-custom-data/cache`
4. Clear cache if needed using `reset_version_cache` function

### Zsh
1. Source the file: `source ~/.zshrc` (or `zsh_update` alias)
2. Test prompt rendering by navigating to project directories with different technologies
3. Verify cache operations by checking `~/.zsh-custom-data/cache`
4. Clear cache if needed using `reset_version_cache` function
