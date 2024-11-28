# GERRIT_LNAV

Formats and other resources to support [Gerrit log files](https://gerrit-review.googlesource.com/Documentation/logs.html) in [lnav](https://lnav.org/).
**The Log File Navigator** (lnav) is an advanced log file viewer for the console.

* [Installation](#installation)
  * [Pre-requisites](#pre-requisites)
  * [Install](#install)
  * [Update](#update)
  * [Uninstall](#uninstall)
  * [Switch to a different Gerrit version](#switch-to-a-different-gerrit-version)
* [Usage](#usage)
  * [Commands](#commands)
  * [Queries](#queries)
  * [Scripts](#scripts)
    * [http_log](#http_log)
  * [Headless Scripts](#headless-scripts)
* [Development](#development)
  * [Add and test a new format](#add-and-test-a-new-format)
  * [Add and test a new script](#add-and-test-a-new-script)
* [Resources](#resources)
  * [Lnav cheatsheet](#lnav-cheatsheet)
  * [Formats](#formats)

# Installation

## Pre-requisites

Please install [lnav](https://lnav.org/) in your system. On MacOS it is as simple as running:

```shell
brew install lnav
```

Please check the [lnav download page](https://lnav.org/downloads) for other options.
After installing it, running `lnav` without any arguments, lnav will try to open the syslog file on your system.
Press `q` to exit lnav.

## Install

1. Clone the [gerrit_lnav repository](https://github.com/dzsessona/gerrit-lnav)
2. Cd into the cloned repository
3. Run the installer script `install.sh`

```shell
git clone "git@github.com:dzsessona/gerrit-lnav.git" && \
cd "$(basename "$_" .git)" && \
./install.sh
```

The installer assume that lnav is installed in your system. The installer script will add the resources
(such as formats and scripts) in the folder used by lnav for the installed formats, and will create that directory if
it does not exists.
Formats, scripts, and other resources will be copied (linked) into the directory:

📂 ~/.lnav/formats/installed

Please note that lnav by default also will store configuration, session, etc. in:

📂 ~/.lnav

## Update

1. Update the repository
2. Run the `install.sh` script again.

## Uninstall

To remove all resources that this repository is adding to lnav, either remove the folder `~/.lnav/formats/installed`
or run the install script with the --remove flag i.e

```shell
install.sh --remove
```

## Switch to a different Gerrit version

If there are differences in the log formats, or in the Gerrit api, you can choose to install the specific resources for
a particular Gerrit version that is supported by this repository just by running the `install.sh` script again.

As part of the installation process you will be able to choose the particular version of Gerrit, atm the version of
Gerrit supported are:

| Resource folder | Gerrit Versions | Notes |
|-----------------|-----------------|-------|
| default         | 3.11, 3.10, 3.9 |       |

If a version is not supported, but you would like to add it, please check the sections
[Add and test a new format](#add-and-test-a-new-format) and [Add and test a new script](#add-and-test-a-new-script)
as a guide to add a new format or script.

# Usage

## Commands

Commands provide access to some of the more advanced features in lnav, like filtering, configuration settings, I/O etc.

Press `:` at the command prompt to **activate** a command.

Press `TAB` after you started typing in the desired command activate **auto-completion and show the available commands**.

Commands are build-in lnav components and cannot be customized or extended, although commands are composable and can be used in scripts.
Gerrit-lnav for example add a shortcut to enable or disable the mouse mode, this is achieved adding a script that uses
the `:config` config command. For example, you can enable the mouse mode by running `:config /ui/mouse/mode enabled` or,
considering that gerrit-lnav provide a script for it, you could simply call the script `|mouse-on`, in fact looking at
the script implementation:

```shell
#
# @synopsis: mouse-on
# @description: shortcut for ':config /ui/mouse/mode enabled'
#
:config /ui/mouse/mode enabled
```

Please refer to the [lnav commands](https://docs.lnav.org/en/v0.12.3/commands.html) for the full list of available commands in lnav.

## Queries

The DB view shows the results of queries done through the SQLite interface. Please note that this view is automatically
selected after executing a query, alternatively with mouse-mode enable select `DB` in the top status bar, or press `v` if
mouse is not enables.
Tip: in lnav, you can go back to the previous view by pressing `q`. This also quit lnav if you are currently in the first view.

Press `;` at the command prompt to write and execute a query

Press `TAB` after you started typing the query to activate **auto-completion**

For example, while having a httpd_log open in lnav, typing:

```
;SELECT * FROM gerrit_httpd_log LIMIT 10
```

Will display in the DB view the first 10 logs present in the db.
To have the benefits of syntax highlight, multiline etc for more complex queries, **this repository provide a simple script
that you can use to test the queries**. For example, after installing lnav-gerrit, simply type `|gerrit-playground` this will
execute and print some results in the db view. Now open the file in `$this_repo/resources/default/scripts/gerrit-playground.lnav`,
modify the query, save the file, and in lnav console (you don't need to restart it or reload the file) run the script again.

Notes:
1. **Syntax highlight** for lnav scripts (and therefore sql) is supported only in visual studio. Please check it out [here](https://lnav.org/2022/09/24/vscode-extension.html) if you want to use it.
2. Be careful of the **hidden fields** in the tables generated by a particular format, for example looking at the format for the httpd_log
   you can see that the request is defined as `"body-field": "request",` meaning that the field `log_body` will contain the request, which is hidden in the table an will not be included in a SELECT *.
4. Other fileds hidden in the log format tables (i.e. the generated _gerrit_httpd_log_ table) are:


| Hidden field   | Description                                                                                                                                                                      |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| log_time_msecs | The adjusted timestamp for the log message as the number of milliseconds from the epoch. This column can be more efficient to use for time-related operations, like timeslice(). |
| log_path       | The path to the log file this message is from.                                                                                                                                   |
| log_text       | The full text of the log message.                                                                                                                                                |
| log_body       | The body of the log message.                                                                                                                                                     |
| log_raw_text   | The raw text of this message from the log file. In this case of JSON and CSV logs, this will be the exact line of JSON-Line and CSV text from the file.                          |


## Scripts

Format directories (`~/.lnav/formats/installed`) may also contain .lnav files to help automate log file analysis.

The hotkey `|` is used at the command prompt or within another script to execute it.

For convenience, all scripts added by this repository start with the prefix `gerrit-` so that you simply use autocompletion to
find a particular script to execute for gerrrit, i.e :

`|gerrit-<TAB>` will show all scripts added to lnav by this repository, each one also showing the synopsis and a short description.

Reports can be generated by writing an lnav script that uses SQL queries and [commands](https://docs.lnav.org/en/v0.12.3/commands.html) to format a document.
A basic script can simply execute a SQL query that is shown in the DB view. More sophisticated scripts can use the following commands to generate customized output for a report:

* The **:echo** command to write plain text
* SQL queries followed by a “write” command, like **:write-table-to** **:write-csv-to** etc.
* **:redirect-to** redirect the output of commands that write to stdout to the given file

**Syntax highlight** for lnav scripts (and therefore sql) is supported only in visual studio. Please check it out [here](https://lnav.org/2022/09/24/vscode-extension.html) if you want to use it.

The following is an (hopefully) up-to-date summary of the scripts provided by gerrit-lnav:

### http_log

| Name                        | Description                                               | Parameter                                               | Mandatory | Default |  Gerrit Versions |
|-----------------------------|-----------------------------------------------------------|---------------------------------------------------------|-----------|---------|------------------|
| gerrit-httpd-tag-git        | Tag the messages http GIT operation (receive upload)-pack | -                                                       | -         | -       | tbd              |
| gerrit-httpd-tag-rest-read  | Tag the messages that are a rest-api call (reads)         | -                                                       | -         | -       | tbd              |
| gerrit-httpd-tag-rest-write | Tag the messages that are a rest-api call (writes)        | -                                                       | -         | -       | tbd              |
| gerrit-httpd-tag-static     | Tag the messages that are get static content              | -                                                       | -         | -       | tbd              |
| gerrit-httpd-tag-all        | Concatenate gerrit-httpd-tag-git, rest and static         | -                                                       | -         | -       | tbd              |
| gerrit-httpd-view-tags      | Display a report on screen with stats for each tag        | username: if present will filter by the username passed | no        | -       | tbd              |

### misc

| Name              | Description                                    | Parameters                                              | Gerrit Versions |
|-------------------|------------------------------------------------|---------------------------------------------------------|-----------------|
| mouse-on          | set /ui/mouse/mode enabled                     | -                                                       | all             |
| mouse-off         | set /ui/mouse/mode disabled                    | -                                                       | all             |
| gerrit-playground | sandbox, useful to write scripts, test queries | subject: any string, example on how to pass a parameter | all             |

## Headless Scripts

# Development

## Add and test a new format

## Add and test a new script

# Resources

## Lnav cheatsheet

## Formats