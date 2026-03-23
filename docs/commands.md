# [CLI Documentation v0.0.0](index.md)

## [Commands](commands.md)

### help

```sh
Display help information for discloud.

Usage: discloud help [command]
-h, --help    Print this usage information.

Run "discloud help" to see global options.
```

### app

```sh
Manage your apps

Usage: discloud app <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  apt       Manage your apps APT
  backup    Get backup of your app code from Discloud
  commit    Commit one app or site to Discloud
  console   Use the app terminal
  delete    Delete one of your apps on Discloud
  info      Get information of your apps
  mod       Manage your app team
  ram       Set amount of ram for your app
  restart   Restart one or all of your apps on Discloud
  start     Start one or all of your apps on Discloud
  status    Get status of your app
  stop      Stop one or all of your apps on Discloud
  upload    Upload one app or site to Discloud

Run "discloud help" to see global options.
```

#### app apt

```sh
Manage your apps APT

Usage: discloud app apt <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  install     Install APT on your app
  uninstall   Uninstall APT from your app

Run "discloud help" to see global options.
```

##### app apt install

```sh
Install APT on your app

Usage: discloud app apt install [arguments]
-h, --help                                                                                        Print this usage information.
    --app (mandatory)                                                                             
    --apt=<canvas,ffmpeg,java,libgl,mysql,openssl,puppeteer,selenium,tesseract,tools,unixodbc>    

Run "discloud help" to see global options.
```

##### app apt uninstall

```sh
Uninstall APT from your app

Usage: discloud app apt uninstall [arguments]
-h, --help                                                                                        Print this usage information.
    --app (mandatory)                                                                             
    --apt=<canvas,ffmpeg,java,libgl,mysql,openssl,puppeteer,selenium,tesseract,tools,unixodbc>    

Run "discloud help" to see global options.
```

#### app backup

```sh
Get backup of your app code from Discloud

Usage: discloud app backup [arguments]
-h, --help                       Print this usage information.
    --app=<appId> (mandatory)    

Run "discloud help" to see global options.
```

#### app commit

```sh
Commit one app or site to Discloud

Usage: discloud app commit [arguments]
-h, --help    Print this usage information.
    --app     App id (This can be omitted to use the discloud.config file)
-g, --glob    (defaults to "**")

Run "discloud help" to see global options.
```

#### app console

```sh
Use the app terminal

Usage: discloud app console [arguments]
-h, --help                       Print this usage information.
    --app=<appId> (mandatory)    
    --command                    

Run "discloud help" to see global options.
```

#### app delete

```sh
Delete one of your apps on Discloud

Usage: discloud app delete [arguments]
-h, --help               Print this usage information.
-y, --[no-]yes           Skip confirmation prompt
    --app (mandatory)    

Run "discloud help" to see global options.
```

#### app info

```sh
Get information of your apps

Usage: discloud app info [arguments]
-h, --help    Print this usage information.
    --app     (defaults to "all")

Run "discloud help" to see global options.
```

#### app mod

```sh
Manage your app team

Usage: discloud app mod <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  add      Add MOD to your app
  delete   Delete MOD of your app
  edit     Edit MOD perms of your app
  info     Get MOD info of your app

Run "discloud help" to see global options.
```

##### app mod add

```sh
Add MOD to your app

Usage: discloud app mod add [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
    --mod (mandatory)    
    --perms              [backup_app, commit_app, edit_ram, logs_app, restart_app, start_app, status_app, stop_app]

Run "discloud help" to see global options.
```

##### app mod delete

```sh
Delete MOD of your app

Usage: discloud app mod delete [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
    --mod (mandatory)    

Run "discloud help" to see global options.
```

##### app mod edit

```sh
Edit MOD perms of your app

Usage: discloud app mod edit [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
    --mod (mandatory)    
    --perms              [backup_app, commit_app, edit_ram, logs_app, restart_app, start_app, status_app, stop_app]

Run "discloud help" to see global options.
```

##### app mod info

```sh
Get MOD info of your app

Usage: discloud app mod info [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    

Run "discloud help" to see global options.
```

#### app ram

```sh
Set amount of ram for your app

Usage: discloud app ram [arguments]
-h, --help                  Print this usage information.
    --app (mandatory)       
    --amount (mandatory)    

Run "discloud help" to see global options.
```

#### app restart

```sh
Restart one or all of your apps on Discloud

Usage: discloud app restart [arguments]
-h, --help    Print this usage information.
    --app     (defaults to "all")

Run "discloud help" to see global options.
```

#### app start

```sh
Start one or all of your apps on Discloud

Usage: discloud app start [arguments]
-h, --help    Print this usage information.
    --app     (defaults to "all")

Run "discloud help" to see global options.
```

#### app status

```sh
Get status of your app

Usage: discloud app status [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    

Run "discloud help" to see global options.
```

#### app stop

```sh
Stop one or all of your apps on Discloud

Usage: discloud app stop [arguments]
-h, --help    Print this usage information.
    --app     (defaults to "all")

Run "discloud help" to see global options.
```

#### app upload

```sh
Upload one app or site to Discloud

Usage: discloud app upload [arguments]
-h, --help    Print this usage information.
-g, --glob    (defaults to "**")

Run "discloud help" to see global options.
```

### init

```sh
Init discloud.config file

Usage: discloud init [arguments]
-h, --help     Print this usage information.
-f, --force    
    --main     
    --type     [bot, site]

Run "discloud help" to see global options.
```

### login

```sh
Login on Discloud API

Usage: discloud login [arguments]
-h, --help    Print this usage information.

Run "discloud help" to see global options.
```

### team

```sh
Manage team apps

Usage: discloud team <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  backup    Get backup of your app code from Discloud
  commit    Commit one app or site to Discloud
  info      Get information of your apps
  restart   Restart one or all of your apps on Discloud
  start     Start one or all of your apps on Discloud
  status    Get status of your app
  stop      Stop one or all of your apps on Discloud

Run "discloud help" to see global options.
```

#### team backup

```sh
Get backup of your app code from Discloud

Usage: discloud team backup [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    

Run "discloud help" to see global options.
```

#### team commit

```sh
Commit one app or site to Discloud

Usage: discloud team commit [arguments]
-h, --help    Print this usage information.
    --app     App id (This can be omitted to use the discloud.config file)
-g, --glob    (defaults to "**")

Run "discloud help" to see global options.
```

#### team info

```sh
Get information of your apps

Usage: discloud team info [arguments]
-h, --help    Print this usage information.
    --app     (defaults to "all")

Run "discloud help" to see global options.
```

#### team restart

```sh
Restart one or all of your apps on Discloud

Usage: discloud team restart [arguments]
-h, --help    Print this usage information.
    --app     (defaults to "all")

Run "discloud help" to see global options.
```

#### team start

```sh
Start one or all of your apps on Discloud

Usage: discloud team start [arguments]
-h, --help    Print this usage information.
    --app     (defaults to "all")

Run "discloud help" to see global options.
```

#### team status

```sh
Get status of your app

Usage: discloud team status [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    

Run "discloud help" to see global options.
```

#### team stop

```sh
Stop one or all of your apps on Discloud

Usage: discloud team stop [arguments]
-h, --help    Print this usage information.
    --app     (defaults to "all")

Run "discloud help" to see global options.
```

### user

```sh
Manage your profile

Usage: discloud user <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  info     Get your information
  locale   Set your locale

Run "discloud help" to see global options.
```

#### user info

```sh
Get your information

Usage: discloud user info [arguments]
-h, --help    Print this usage information.

Run "discloud help" to see global options.
```

#### user locale

```sh
Set your locale

Usage: discloud user locale [arguments]
-h, --help                          Print this usage information.
-l, --locale=<pt-BR> (mandatory)    

Run "discloud help" to see global options.
```

### zip

```sh
Make zip

Usage: discloud zip [arguments]
-h, --help        Print this usage information.
-e, --encoding    [buffer]
-g, --glob        (defaults to "**")
-o, --out         

Run "discloud help" to see global options.
```
