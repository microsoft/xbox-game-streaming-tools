## Welcome!

This repository provides tools, schemas, and samples to empower game creators that are optimizing their games for Xbox game streaming.

To get started with Xbox game streaming you apply to the ID@Xbox program at http://www.xbox.com/en-us/Developers/id.

To learn more about optimizing your Xbox game for game streaming see the [developer documentation](https://docs.microsoft.com/en-us/gaming/game-streaming/).

## What's included

- [Touch Adaptation Kit Command Line Tool (TAK CLI)](https://github.com/microsoft/xbox-game-streaming-tools/releases) releases for Windows and MacOS.
- [Schema](./touch-adaptation-kit/schemas) representing the capabilities of the [Touch Adaptation Kit](https://docs.microsoft.com/en-us/gaming/game-streaming/ux/touch-adaptation-kit/) that allows for your creation of custom touch layouts for your games.
- [Sample touch adaptation layouts](./touch-adaptation-kit/samples) to get started.
- [Scripts](./touch-adaptation-kit/scripts) to assist in the development of touch adaptation layouts.

### Touch Adaptation Kit Command Line Tool (TAK CLI)

> ⚠️ The TAK CLI is governed by its own End User License Agreement that must be read and accepted before using the tool. This can be done using the CLI's `license` command.

The TAK CLI is a command line tool that allows you to create, validate, and package touch adaptation layouts for your games. It is available for Windows and MacOS and is publicly distributed as a standalone executable for through the [releases page](https://github.com/microsoft/xbox-game-streaming-tools/releases) of this repository.

You can read more about the TAK CLI in the [public documentation](https://aka.ms/game-streaming-touch-tak-cli).

The CLI is also required for the core functionalities of the [Touch Adaptation Kit Editor extension for VS Code](https://aka.ms/get-takeditor). The extension provides a visual editing experience for touch adaptation bundles and is recommended as a starting point for creating touch experiences for Xbox game streaming.

> 💡 Note that newer versions of the TAK Editor extension may require a newer version of the TAK CLI. Please ensure that you are using the latest version of both tools.

You can read more about setting up the TAK Editor extension in the [public documentation](https://aka.ms/takeditor-docs).

#### Windows

A single file executable (`tak.exe`) can be downloaded from the [releases page](https://github.com/microsoft/xbox-game-streaming-tools/releases) of this repository and used immediately from the command line.

Once the CLI executable is downloaded and the extension is installed in VS Code, you must provide its path to the extension, either through the VS Code settings, or by executing the "Set TAK CLI path" command from the command palette.

#### MacOS

The TAK CLI can be installed on MacOS using Homebrew. If you have not installed Homebrew, you can do so by following the instructions on the [Homebrew website](https://brew.sh/).

```bash
brew install microsoft/xbox-game-creator-tools/tak-cli
```

If you have already installed the TAK CLI through Homebrew, you can upgrade to the latest version using the following command:

```bash
brew upgrade tak-cli
```

Alternatively, you can download a DMG file (`tak-<version>.dmg`) from the [releases page](https://github.com/microsoft/xbox-game-streaming-tools/releases) of this repository. The file contains the CLI executable (`tak`) that can be extracted and used from the command line. This can either be done by double-clicking the DMG file and dragging the executable to a location of your choice, or by using the terminal to extract the executable.

```bash
hdiutil attach tak-<version>.dmg
cp /Volumes/tak/tak <destination directory>
hdiutil detach /Volumes/tak
```

Similar to the Windows installation, you must provide the path to the CLI executable to the extension in VS Code, either through the VS Code settings, or by executing the "Set TAK CLI path" command from the command palette.

## Contributing

This project welcomes contributions and suggestions. For more information see [CONTRIBUTING](CONTRIBUTING.md).

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
