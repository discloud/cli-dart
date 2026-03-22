<!-- markdownlint-disable MD024 -->

# Discloud CLI

## Installation

Welcome to the **Discloud CLI** installation documentation. Follow the instructions below according to your operating system to install and start using the tool.

> **Note:** Before proceeding, ensure you have the necessary **prerequisites** installed on your machine.

---

## 📋 Prerequisites

- **Operating System:**
  - Linux x64
  - Windows x64

---

## 🐧 For Linux (Standalone Binary)

On Linux, the CLI is distributed as a raw binary file. There is **no graphical setup** (`.deb` or `.rpm`). You must download the binary manually and ensure it is executable and accessible in your system's `PATH`.

- You can install the CLI using the script in the [`linux-setup.sh`](linux-setup.sh) file.

---

## 🪟 For Windows (With Setup)

The distribution for Windows is provided through a **standalone executable setup** (`.exe`). This setup bundles the binary and automatically configures the system environment variables.

### Step-by-Step

1. **Download the Setup:**
    Go to the official releases page and download the file `discloud-cli-x64-setup.exe`.

2. **Run the Setup:**
    Double-click the downloaded file. If Windows SmartScreen or Defender prompts you, select **More info** > **Run anyway** (as it is a community tool signed by the developer).

3. **Follow the Wizard:**
    - Click **Next**.
    - Read and accept the license terms (**I Agree**).
    - Choose the installation directory (default is recommended).
    - Click **Install**.

4. **Finish:**
    Once completed, click **Finish**. You may check "Launch Discloud CLI" to open immediately.

---

## ✅ Verify Installation

After completing the steps above, verify that the installation was successful by typing the following command in your terminal or command prompt:

```bash
discloud --version
```

If installed correctly, the output will display the current version number (e.g., `v1.0.0`).

---

## 🔐 Authentication (Login)

To use the CLI commands and manage your bots/applications, you must authenticate your account:

```bash
discloud login
```

The system will either generate an OTP code or open your default browser to confirm access to your DisCloud account.

## CONTRIBUTING

For details see [CONTRIBUTING.md](CONTRIBUTING.md).

## Getting Started

### Prerequisites

- Dart 3.10 or higher due to the [`dot shorthand`](https://dart.dev/language/dot-shorthands).

### Preparing for development

- Get the dependencies

    ```sh
    dart pub get
    ```

### Preparing for format and build

- Run build runner

    ```sh
    dart run build_runner build
    ```

- Run formatter and linter

    ```sh
    dart format .
    dart fix --apply
    ```

### Testing

- You can perform the test manually by running the command below.

    ```sh
    dart run lib/main.dart
    ```

- Try adding arguments.

    ```sh
    dart run lib/main.dart --version
    ```

## LICENSE

For details see [LICENSE](LICENSE).
