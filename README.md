<!-- markdownlint-disable MD024 -->

# DisCloud CLI

## Installation

Welcome to the **DisCloud CLI** installation documentation. Follow the instructions below according to your operating system to install and start using the tool.

> **Note:** Before proceeding, ensure you have the necessary **prerequisites** installed on your machine.

---

## 📋 Prerequisites

* **Operating System:**
  * Linux x64
  * Windows 10/11 x64

---

## 🐧 For Linux (Standalone Binary)

On Linux, the CLI is distributed as a raw binary file. There is **no graphical installer** (`.deb` or `.rpm`). You must download the binary manually and ensure it is executable and accessible in your system's `PATH`.

### Step-by-Step

1. **Download the Binary:**

    Download the latest release for your architecture from the official repository.

    ```bash
    wget -O discloud https://github.com/discloud/cli-dart/releases/download/vX.X.X/discloud-linux-x64
    ```

2. **Move to Global Path (Optional but Recommended):**

    To run `discloud` from any terminal window, move the binary to `/usr/local/bin`.

    ```bash
    sudo mv discloud /usr/local/bin/
    ```

### ⚠️ Troubleshooting

If you receive a "Permission denied" error when running the binary, ensure you have execute permissions:

```bash
chmod +x $(which discloud)
```

---

## 🪟 For Windows (With Installer)

The distribution for Windows is provided through a **standalone executable installer** (`.exe`). This installer bundles the binary and automatically configures the system environment variables.

### Step-by-Step

1. **Download the Installer:**
    Go to the official releases page and download the file `discloud-cli-x64-setup.exe`.

2. **Run the Installer:**
    Double-click the downloaded file. If Windows SmartScreen or Defender prompts you, select **More info** > **Run anyway** (as it is a community tool signed by the developer).

3. **Follow the Wizard:**
    * Click **Next**.
    * Read and accept the license terms (**I Agree**).
    * Choose the installation directory (default is recommended).
    * Click **Install**.

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
