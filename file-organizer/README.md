# file-organizer

A simple bash script that organizes files in a directory by moving them into subdirectories named after their file extension.

## Usage

```bash
./file-organizer.sh [options] <directory>
```

### Options

| Option | Description |
| ------ | ----------- |
| `--dry-run` | Preview the changes without moving any files |

## Requirements

- `bash`
- `tree` (used for the summary output)

## Example

```bash
# Preview changes
./file-organizer.sh --dry-run ~/Downloads

# Organize files
./file-organizer.sh ~/Downloads
```

## How it works

1. Scans the specified directory for files (non-recursive)
2. Groups files by their extension
3. Creates subdirectories for each extension
4. Moves files into their corresponding subdirectory
5. Displays a summary of files moved and directories created

Files without an extension or hidden files (starting with `.`) are placed in a `no-extension` directory.
