# [CLI Documentation](index.md)

## [Commands](commands.md)

### help

```sh
Display help information for discloud.

Usage: discloud help [command]
-h, --help    Print this usage information.
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
  logs      View the logs from application in Discloud
  mod       Manage your app team
  profile   Updates the profile information (avatar and name) for a specific app
  ram       Set amount of ram for your app
  restart   Restart one or all of your apps on Discloud
  start     Start one or all of your apps on Discloud
  status    Get status of your app
  stop      Stop one or all of your apps on Discloud
  upload    Upload one app or site to Discloud
```

#### app apt

```sh
Manage your apps APT

Usage: discloud app apt <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  install     Install APT on your app
  uninstall   Uninstall APT from your app
```

##### app apt install

```sh
Install APT on your app

Usage: discloud app apt install [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
    --apt                canvas,ffmpeg,java,libgl,mysql,openssl,puppeteer,selenium,tesseract,tools,unixodbc
```

##### app apt uninstall

```sh
Uninstall APT from your app

Usage: discloud app apt uninstall [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
    --apt                canvas,ffmpeg,java,libgl,mysql,openssl,puppeteer,selenium,tesseract,tools,unixodbc
```

#### app backup

```sh
Get backup of your app code from Discloud

Usage: discloud app backup [arguments]
-h, --help                     Print this usage information.
    --app=<all> (mandatory)    When set to 'all', this command will automatically download backups and will not display URLs. If the 'out' option is not set, downloads will be made to the current folder.
    --out                      Specifies the destination path for downloading backups. When the application option is set to 'all', the destination path will be considered a directory where all downloads will be stored.
```

#### app commit

```sh
Commit one app or site to Discloud

Usage: discloud app commit [arguments]
-h, --help    Print this usage information.
    --app     App id (This can be omitted to use the discloud.config file)
-g, --glob    (defaults to "**")
```

#### app console

```sh
Use the app terminal

Usage: discloud app console [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
    --command            
```

#### app delete

```sh
Delete one of your apps on Discloud

Usage: discloud app delete [arguments]
-h, --help               Print this usage information.
-y, --yes                Skip confirmation prompt
    --app (mandatory)    
```

#### app info

```sh
Get information of your apps

Usage: discloud app info [arguments]
-h, --help    Print this usage information.
    --app     (defaults to "all")
```

#### app logs

```sh
View the logs from application in Discloud

Usage: discloud app logs [arguments]
-h, --help                     Print this usage information.
    --app=<all> (mandatory)    When set to 'all', this command will automatically download logs and will not display URLs. If the 'out' option is not set, downloads will be made to the current folder.
    --out                      Specifies the destination path for downloading logs. When the application option is set to 'all', the destination path will be considered a directory where all downloads will be stored.
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
```

##### app mod add

```sh
Add MOD to your app

Usage: discloud app mod add [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
    --mod (mandatory)    
    --perms              [backup_app, commit_app, edit_ram, logs_app, restart_app, start_app, status_app, stop_app]
```

##### app mod delete

```sh
Delete MOD of your app

Usage: discloud app mod delete [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
    --mod (mandatory)    
```

##### app mod edit

```sh
Edit MOD perms of your app

Usage: discloud app mod edit [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
    --mod (mandatory)    
    --perms              [backup_app, commit_app, edit_ram, logs_app, restart_app, start_app, status_app, stop_app]
```

##### app mod info

```sh
Get MOD info of your app

Usage: discloud app mod info [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
```

#### app profile

```sh
Updates the profile information (avatar and name) for a specific app

Usage: discloud app profile [arguments]
-h, --help                  Print this usage information.
    --app (mandatory)       
    --name (mandatory)      
    --avatar (mandatory)    
```

#### app ram

```sh
Set amount of ram for your app

Usage: discloud app ram [arguments]
-h, --help                        Print this usage information.
    --app (mandatory)             
    --amount=<100> (mandatory)    
```

#### app restart

```sh
Restart one or all of your apps on Discloud

Usage: discloud app restart [arguments]
-h, --help         Print this usage information.
    --app=<all>    
```

#### app start

```sh
Start one or all of your apps on Discloud

Usage: discloud app start [arguments]
-h, --help         Print this usage information.
    --app=<all>    
```

#### app status

```sh
Get status of your app

Usage: discloud app status [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
```

#### app stop

```sh
Stop one or all of your apps on Discloud

Usage: discloud app stop [arguments]
-h, --help         Print this usage information.
    --app=<all>    
```

#### app upload

```sh
Upload one app or site to Discloud

Usage: discloud app upload [arguments]
-h, --help    Print this usage information.
-g, --glob    (defaults to "**")
```

### init

```sh
Init discloud.config file

Usage: discloud init [arguments]
-h, --help           Print this usage information.
    --autorestart    Determines whether the app should automatically restart if it crashes.
-f, --force          Overwrite config file
    --vlan           Enables private networking
    --apt            canvas,ffmpeg,java,libgl,mysql,openssl,puppeteer,selenium,tesseract,tools,unixodbc
    --avatar         Image URL (.gif, .jpeg, .jpg, .png)
    --hostname       Custom hostname alias for other apps to reach this one
    --id             User-defined subdomains
    --main           Relative file path
    --name           1 - 30 characters
    --ram            Amount in MB; min 100
    --type           [bot, site]
    --version        current|latest|legacy|suja|x.x.x
```

### login

```sh
Login on Discloud API

Usage: discloud login [arguments]
-h, --help    Print this usage information.
```

### team

```sh
Manage team apps

Usage: discloud team <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  backup    Get backup of your team app code from Discloud
  commit    Commit one app or site to Discloud
  info      Get information of your apps
  logs      View the logs from application in Discloud
  ram       Set amount of ram for your app
  restart   Restart one or all of your apps on Discloud
  start     Start one or all of your apps on Discloud
  status    Get status of your app
  stop      Stop one or all of your apps on Discloud
```

#### team backup

```sh
Get backup of your team app code from Discloud

Usage: discloud team backup [arguments]
-h, --help                     Print this usage information.
    --app=<all> (mandatory)    
```

#### team commit

```sh
Commit one app or site to Discloud

Usage: discloud team commit [arguments]
-h, --help    Print this usage information.
    --app     App id (This can be omitted to use the discloud.config file)
-g, --glob    (defaults to "**")
```

#### team info

```sh
Get information of your apps

Usage: discloud team info [arguments]
-h, --help    Print this usage information.
    --app     
```

#### team logs

```sh
View the logs from application in Discloud

Usage: discloud team logs [arguments]
-h, --help                     Print this usage information.
    --app=<all> (mandatory)    When set to 'all', this command will automatically download logs and will not display URLs. If the 'out' option is not set, downloads will be made to the current folder.
    --out                      Specifies the destination path for downloading logs. When the application option is set to 'all', the destination path will be considered a directory where all downloads will be stored.
```

#### team ram

```sh
Set amount of ram for your app

Usage: discloud team ram [arguments]
-h, --help                        Print this usage information.
    --app (mandatory)             
    --amount=<100> (mandatory)    
```

#### team restart

```sh
Restart one or all of your apps on Discloud

Usage: discloud team restart [arguments]
-h, --help         Print this usage information.
    --app=<all>    
```

#### team start

```sh
Start one or all of your apps on Discloud

Usage: discloud team start [arguments]
-h, --help         Print this usage information.
    --app=<all>    
```

#### team status

```sh
Get status of your app

Usage: discloud team status [arguments]
-h, --help               Print this usage information.
    --app (mandatory)    
```

#### team stop

```sh
Stop one or all of your apps on Discloud

Usage: discloud team stop [arguments]
-h, --help         Print this usage information.
    --app=<all>    
```

### user

```sh
Manage your profile

Usage: discloud user <subcommand> [arguments]
-h, --help    Print this usage information.

Available subcommands:
  info     Get your information
  locale   Set your locale
```

#### user info

```sh
Get your information

Usage: discloud user info [arguments]
-h, --help    Print this usage information.
```

#### user locale

```sh
Set your locale

Usage: discloud user locale [arguments]
-h, --help                          Print this usage information.
-l, --locale=<en-US> (mandatory)    
```

### zip

```sh
Make zip

Usage: discloud zip [arguments]
-h, --help           Print this usage information.
-g, --glob           (defaults to "**")
-o, --out            Zip output
-l, --level=<0-9>    Compression level
-p, --password       Zip password
```
