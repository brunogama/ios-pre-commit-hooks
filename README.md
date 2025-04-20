# Pre-Commit Configurations for iOS Development

**Why**? Developers functiond is to code so why not apply styling and linting in a pre-commit-hook?

This repository provides pre-commit hooks designed specifically for iOS development. These hooks help automate code quality checks and enforce coding standards, ensuring a smoother development experience.

## Features

- Automates code quality checks.
- Ensures adherence to coding standards.
- Identifies and resolves common issues before committing changes.

## Requirements

To use this project, you need to have the [pre-commit framework](https://pre-commit.com/) installed. Below are instructions for installing it using either [Homebrew](https://brew.sh/) or [Pyenv](https://github.com/pyenv/pyenv).

### Installing `pre-commit`

#### Using Homebrew

1. Open your terminal.
2. Run the following command to install `pre-commit`:

   ```bash
   brew install pre-commit
   ```

3. Confirm the installation:

   ```bash
   pre-commit --version
   ```

#### Using Pyenv

1. Make sure you have Python installed via Pyenv. If not, follow the [Pyenv installation guide](https://github.com/pyenv/pyenv#installation).
2. Install a Python version using Pyenv:

   ```bash
   pyenv install <version> # Replace <version> with the desired Python version, e.g., 3.9.9
   pyenv global <version>  # Set the installed version as the global default
   ```

3. Ensure `pip` is available:

   ```bash
   pyenv exec python -m ensurepip --upgrade
   ```

4. Use `pip` to install `pre-commit`:

   ```bash
   pip install pre-commit
   ```

5. Confirm the installation:

   ```bash
   pre-commit --version
   ```

## Installation

Once the `pre-commit` framework is installed, set up the hooks by following these steps:

1. Open your terminal.
2. Run the following command:

   ```bash
   curl -sSL https://raw.githubusercontent.com/brunogama/ios-pre-commit-hooks/main/install | bash
   ```

3. This command will:
   - Download the necessary files.
   - Execute the `install-hooks` script to set up your pre-commit environment.

## Contributing

Contributions are welcome! If you encounter issues or have suggestions for improvement, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Let me know if you'd like further refinements!
