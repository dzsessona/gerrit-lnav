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
    * [httpd_log](#httpd_log)
    * [sshd_log](#sshd_log)
    * [error_log](#error_log)
    * [filtering](#filtering)
    * [misc](#misc)
  * [Headless Scripts](#headless-scripts)
* [Resources](#resources)
  * [Lnav cheatsheet](#lnav-cheatsheet)
  * [Formats](#formats)
    * [Add and test a new format](#add-and-test-a-new-format)


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
4. The first time installing it will ask also to install dependencies for csv2json. csv2json is required only when using lnav to build graphs.

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
[Add and test a new format](#add-and-test-a-new-format) as a guide.

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

```
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

### httpd_log

| Name                                                                                            | Description                                               | Parameter                                               | Mandatory | Default | Gerrit Versions |
|-------------------------------------------------------------------------------------------------|-----------------------------------------------------------|---------------------------------------------------------|-----------|---------|-----------------|
| [gerrit-httpd-tag-git](resources/default/scripts/httpd/gerrit-httpd-tag-git.lnav)               | Tag the messages http GIT operation (receive upload)-pack | -                                                       | -         | -       | tbd             |
| [gerrit-httpd-tag-rest-read](resources/default/scripts/httpd/gerrit-httpd-tag-rest-read.lnav)   | Tag the messages that are a rest-api call (reads)         | -                                                       | -         | -       | tbd             |
| [gerrit-httpd-tag-rest-write](resources/default/scripts/httpd/gerrit-httpd-tag-rest-write.lnav) | Tag the messages that are a rest-api call (writes)        | -                                                       | -         | -       | tbd             |
| [gerrit-httpd-tag-static](resources/default/scripts/httpd/gerrit-httpd-tag-static.lnav)         | Tag the messages that are get static content              | -                                                       | -         | -       | tbd             |
| [gerrit-httpd-tag-all](resources/default/scripts/httpd/gerrit-httpd-tag-all.lnav)               | Concatenate gerrit-httpd-tag-git, rest and static         | -                                                       | -         | -       | tbd             |
| [gerrit-httpd-view-tags](resources/default/scripts/httpd/gerrit-httpd-view-tags.lnav)           | Display a report on screen with stats for each tag        | username: if present will filter by the username passed | no        | -       | tbd             |


### sshd_log

| Name                                                                                       | Description                                              | Parameter                                                             | Mandatory                    | Default | Gerrit Versions |
|--------------------------------------------------------------------------------------------|----------------------------------------------------------|-----------------------------------------------------------------------|------------------------------|---------|-----------------|
| [gerrit-sshd-tag-git](resources/default/scripts/sshd/gerrit-sshd-tag-git.lnav)             | Tag the ssh GIT operation (receive upload)-pack          | -                                                                     | -                            | -       | tbd             |
| [gerrit-sshd-tag-user-cmd](resources/default/scripts/sshd/gerrit-sshd-tag-user-cmd.lnav)   | Tag the messages that are ssh user commands              | -                                                                     | -                            | -       | tbd             |
| [gerrit-sshd-tag-admin-cmd](resources/default/scripts/sshd/gerrit-sshd-tag-admin-cmd.lnav) | Tag the messages that are ssh admin commands             | -                                                                     | -                            | -       | tbd             |
| [gerrit-sshd-tag-all](resources/default/scripts/sshd/gerrit-sshd-tag-all.lnav)             | Concatenate gerrit-sshd-tag-git, user and admin commands | -                                                                     | -                            | -       | tbd             |
| [gerrit-sshd-most-users](resources/default/scripts/sshd/gerrit-sshd-most-users.lnav)       | Report of most active ssh users                          | start-time: only after time specified (format: 'YYYY-MM-DD HH:MM:SS') | no                           | -       |                 |
|                                                                                            |                                                          | end-time: only before time specified (format: 'YYYY-MM-DD HH:MM:SS')  | yes, if start-time specified | -       |                 |


### error_log

| Name                                                                                                            | Description                 | Parameter                                              | Mandatory | Default | Gerrit Versions |
|-----------------------------------------------------------------------------------------------------------------|-----------------------------|--------------------------------------------------------|-----------|---------|-----------------|
| [gerrit-error-report](resources/default/scripts/error/gerrit-error-report.lnav)                                 | Report of logs (summary)    | level: one of error,warning,debug,info or trace        | no        | error   | tbd             |
|                                                                                                                 |                             | time-slice: slice of time duration, i.e. 5m            | yes       | -       |                 |
| [gerrit-error-single-report-by-class](resources/default/scripts/error/gerrit-error-single-report-by-class.lnav) | Report of logs (by class)   | full-class-name: i.e. 'com.google.gerrit.index.Schema' | yes       | -       | tbd             |
|                                                                                                                 |                             | time-slice: slice of time duration, i.e. 5m            | yes       | -       |                 |
|                                                                                                                 |                             | level: one of error,warning,debug,info or trace        | no        | error   |                 |
| [gerrit-error-single-report-by-msg](resources/default/scripts/error/gerrit-error-single-report-by-msg.lnav)     | Report of logs (by message) | pattern: msg pattern to match, ie. 'want % not valid'  | yes       | -       | tbd             |
|                                                                                                                 |                             | time-slice: slice of time duration, i.e. 5m            | yes       | -       |                 |
|                                                                                                                 |                             | level: one of error,warning,debug,info or trace        | no        | error   |                 |

### filtering

| Name                                                                                                              | Description                                           | Parameters | Gerrit Versions |
|-------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|------------|-----------------|
| [gerrit-httpd-filter-out-monitoring](resources/default/scripts/filtering/gerrit-httpd-filter-out-monitoring.lnav) | filter out form the LOG view all calls for monitoring | -          | all             |
| [gerrit-httpd-filter-out-plugins](resources/default/scripts/filtering/gerrit-httpd-filter-out-plugins.lnav)       | filter out form the LOG view all calls to plugins     | -          | all             |
| [gerrit-httpd-filter-out-static](resources/default/scripts/filtering/gerrit-httpd-filter-out-static.lnav)         | filter out form the LOG view all calls to static      | -          | all             |
| [gerrit-filters-reset](resources/default/scripts/filtering/gerrit-filters-reset.lnav)                             | reset the LOG view removing all filters above         | -          | all             |

### misc

| Name                                                                                     | Description                                        | Parameters                                              | Gerrit Versions |
|------------------------------------------------------------------------------------------|----------------------------------------------------|---------------------------------------------------------|-----------------|
| [mouse-on](resources/default/scripts/misc/mouse-on.lnav)                                 | set /ui/mouse/mode enabled                         | -                                                       | all             |
| [mouse-off](resources/default/scripts/misc/mouse-off.lnav)                               | set /ui/mouse/mode disabled                        | -                                                       | all             |
| [gerrit-playground](resources/default/scripts/misc/gerrit-playground.lnav)               | sandbox, useful to write scripts, test queries     | subject: any string, example on how to pass a parameter | all             |
| [make-human-readable-tags](resources/default/scripts/misc/make-human-readable-tags.lnav) | transform tags into meaninful human readable names | -                                                       | all             |

## Headless Scripts

Lnav has the option to be executed in headless mode. This is achieved by using the flags:

- `-n` Run without the curses UI (headless mode).
- `-q` Do not print informational messages.
- `-f <path>` Execute the given command file. This option can be given multiple times.

A command file does not need to be copied in the usual `~/.lnav/formats/installed` folder, but it can contain commands
and scripts instructions, so if in the command reference a custom script, the script needs to be present in that folder. 

Again, to leverage syntax highlight, all command files present in this repo (also called headless scripts) have the suffix `.lnav`.

Let's have a look at the simple `playground.lnav` headless script; the purpose of this command file is just
to extract from an httpd_log the first 5 lines and save them in different formats. This is a bit useless but you can use it
to test new headless scripts exacly as the `|gerrit-playgroud` script.

In this example, let's assume that this repo is installed and  is in the location `~/repositories/gerrit-lnav` on your machine. 
Let's also assume that there is an http_log file in `/tmp/httpd_log`. 

Command files cannot take parameter, but can read env variables. Looking at its description, this script takes a variable
LNAV_OUTPUT_FOLDER used to specify the folder to save the output. So that we can execute it like this:

```shell
LNAV_OUTPUT_FOLDER=/tmp \
lnav -q \
 -n /tmp/httpd_log \
 -f ~/repositories/gerrit-lnav/resources/default/headless/playground.lnav
```

And the headless script will:
* get the env variable LNAV_OUTPUT_FOLDER -> /tmp
* get the base name of the file to analyze using the `log_path` filed in the db -> httpd.log
* redirect the output the report file to generate using `:redirect-to` and `:write-table-to`-> /tmp/httpd_log.txt
* save the filed specified in the select as csv values using  `:write-csv-to ${outfolder}/${filename}.csv`-> /tmp/httpd_log.csv

So after its execution:

```
cat /tmp/httpd_log.txt
these are the first messages of the logs in a table format
┏━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━┳━━━━━━━━━━━━━━━━━━━┓
┃         Time          ┃                                                             Request                                                             ┃method┃    status_code    ┃
┡━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━╇━━━━━━━━━━━━━━━━━━━┩
│2024-11-19 16:23:45.489│/config/server/version                                                                                                           │GET   │200 (OK)           │
│2024-11-19 16:24:15.591│/config/server/version                                                                                                           │GET   │200 (OK)           │
│2024-11-19 16:24:40.952│/a/test/info/refs?service=git-upload-pack                                                                                        │GET   │401 (Unauthorized) │
│2024-11-19 16:24:41.068│/a/test/info/refs?service=git-upload-pack                                                                                        │GET   │200 (OK)           │
│2024-11-19 16:24:41.211│/a/test/git-upload-pack                                                                                                          │POST  │200 (OK)           │
└━━━━━━━━━━━━━━━━━━━━━━━┴━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┴━━━━━━┴━━━━━━━━━━━━━━━━━━━┘

cat /tmp/httpd_log.csv
Time,Request,method,status_code
2024-11-19 16:23:45.489,/config/server/version,GET,200 (OK) 
2024-11-19 16:24:15.591,/config/server/version,GET,200 (OK) 
2024-11-19 16:24:40.952,/a/test/info/refs?service=git-upload-pack,GET,401 (Unauthorized) 
2024-11-19 16:24:41.068,/a/test/info/refs?service=git-upload-pack,GET,200 (OK)
```

The following is a (hopefully) up-to-date summary of the headless scripts in gerrit-lnav:

| Category        | Log file  | Name                                                                                                                            | Path                                 | Description                                                                                                                  |
|-----------------|-----------|---------------------------------------------------------------------------------------------------------------------------------|--------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| Playground      | httpd_log | [playground.lnav](resources/default/headless/playground.lnav)                                                                   | resources/default/headless           | playground                                                                                                                   |
| dataset (graph) | httpd_log | [make_aggregate_datasets.lnav](resources/default/headless/httpd/make_aggregate_datasets.lnav)                                   | resources/default/headless/httpd     | dataset for every operation in the httpd file(s), aggregated by operation                                                    |
| dataset (graph) | httpd_log | [make_timeslice_datasets.lnav](resources/default/headless/httpd/make_timeslice_datasets.lnav)                                   | resources/default/headless/httpd     | dataset for every operation in the httpd file(s), aggregated by operation, time sliced                                       |
| dataset (graph) | httpd_log | [make_timeslice_datasets_latency_and_size.lnav](resources/default/headless/httpd/make_timeslice_datasets_latency_and_size.lnav) | resources/default/headless/httpd     | dataset for every operation in the httpd file(s), aggregated by operation, time sliced, with latency and response size stats |
| filtering       | httpd_log | [rewrite_without_static.lnav](resources/default/headless/httpd/rewrite_without_static.lnav)                                     | resources/default/headless/httpd     | rewrite the given http_log file without messages for the static calls                                                        |
| distribution    | httpd_log | [analyze_ghs_simulation.lnav](resources/default/headless/httpd/ghs/analyze_ghs_simulation.lnav)                                 | resources/default/headless/httpd/ghs | report with the percentages of the operation interesting for ghs real life simulation                                        |
| filtering       | error_log | [reduce_to_level.lnav](resources/default/headless/error/reduce_to_level.lnav)                                                   | resources/default/headless/error     | rewrite the given error file with only the messages with the level specified                                                 |
| filtering       | error_log | [reduce_to_level.sh](resources/default/headless/error/reduce_to_level.sh)                                                       | resources/default/headless/error     | wrapper for reduce_to_level.lnav, processing large error_log files                                                           |

# Resources

## Lnav cheatsheet

- `:` Execute an internal command
- `;` Open the SQLite Interface to execute SQL statement
- `|` Execute an lnav script located in a format directory


- `q` Return to the previous view/quit
- `?` View/leave builtin help
- `Ctrl` + `]` Abort the prompt
- `Ctrl` + `r` Reset the current session state. The session state includes things like filters, bookmarks, and hidden fields.


- `/` Search for lines matching a regular expression
- `n` / `Shift + n` Next/previous search hit
- `e` / `Shift + e` Next/previous error
- `w` / `Shift + w` Next/previous warning
- `o` / `Shift + o` Forward/backward through log messages with a matching "opid" field


- `x` Toggle the hiding of log message fields
- `p` Toggle the display of the log parser results


Please check the full cheat sheet on [lnav hotkeys](https://docs.lnav.org/en/latest/hotkeys.html)

## Formats

This is intended to be a reference of formats so that is easier to build / modify / test them.

| Log       | table            | opid       | identifiers                   | hidden                                                                                                              | Regex name  | Regex                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|-----------|------------------|------------|-------------------------------|---------------------------------------------------------------------------------------------------------------------|-------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| error_log | gerrit_error_log | -          | logger                        | thread                                                                                                              | std         | ^\\\[\(?<timestamp>\\d\{4\}\-\\d\{2\}\-\\d\{2\}T\\d\{2\}:\\d\{2\}:\\d\{2\}\(?:\\\.\\d\{3,6\}\)?\)\(?:Z\|\(?<timezone>\[\\\+\\\-\]\\d\{2\}:\\d\{2\}\)\)?\\\]\\s\\\[\(?<thread>\.\*?\)\\\]\\s\(?<level>\\w\+\)\(?:\\s\)\*\(?<logger>\.\*?\)\\s:\\s\(?<message>\(?<msg>\[^\\n\\r\]\*\)\)\(?:\\r?\\n\(?\!\\\[\)\(?<first\_stack\_class>\[\\w\.\]\+\)\(?::\\s\(?<first\_stack\_msg>\[^\\n\\r\]\*\)\)?\)?\(?:\(?:\\r?\\n\(?\!\\\[\)\(?\!Caused\)\[^\\n\\r\]\*\)\*\(?:\\r?\\n\(?:Caused\\sby:\\s\(?<caused\_by\_class>\[\\w\.\]\+\)\(?::\\s\(?<caused\_by\_msg>\[^\\n\\r\]\*\)\)?\)\)\+\)\*\(?:\\r?\\n\(?\!\\\[\)\(\.\)\*\)\*                                                                                                                                                                                                                                                                                       |
| httpd_log | gerrit_httpd_log | -          | username, method, status_code | thread, host                                                                                                        | std         | ^\(?<host>\(\[0\-9\]\{1,3\}\.\)\{3\}\[0\-9\]\{1,3\}\)\[\[:blank:\]\]\[\(?<thread>\[^\]\]\+\)\]\[\[:blank:\]\]\-\[\[:blank:\]\]\(?<username>S\+\)\[\[:blank:\]\]\[\(?<timestamp>d\{4\}\-d\{2\}\-d\{2\}Td\{2\}:d\{2\}:d\{2\}\(?:\.d\{3,6\}\)\)\(?:Z\|\(\[\+\-\]d\{2\}:d\{2\}\)\)?\]\[\[:blank:\]\]"\(?<method>\[\[:word:\]\]\+\)\[\[:blank:\]\]\(?<request>S\+\)\[\[:blank:\]\]\(?<protocol>\[^"\]\+\)"\[\[:blank:\]\]\(?<status\_code>d\+\)\[\[:blank:\]\]\(?<response\_size>\(\-\)\|d\+\)\[\[:blank:\]\]\(?<latency>\(\-\)\|d\+\)\[\[:blank:\]\]\(?<referer>S\+\)\[\[:blank:\]\]\(?<client\_agent>\-\|\(\("\)?\[^"\]\*\("\)?\)\)\[\[:blank:\]\]\(?<total\_cpu>\(\-\)\|d\+\)\[\[:blank:\]\]\(?<user\_cpu>\(\-\)\|d\+\)\[\[:blank:\]\]\(?<memory>d\+\)\[\[:blank:\]\]\(?<command\_status>\("\-1"\)\|\(\-\)\|\("0"\)\)$<br>                                                                                     |
|           |                  |            |                               |                                                                                                                     | ipv6        | ^\(?<host>\[\(\[0\-9\]:\)\{7\}d\]\)\[\[:blank:\]\]\[\(?<thread>\[^\]\]\+\)\]\[\[:blank:\]\]\-\[\[:blank:\]\]\(?<username>S\+\)\[\[:blank:\]\]\[\(?<timestamp>d\{4\}\-d\{2\}\-d\{2\}Td\{2\}:d\{2\}:d\{2\}\(?:\.d\{3,6\}\)\)\(?:Z\|\(\[\+\-\]d\{2\}:d\{2\}\)\)?\]\[\[:blank:\]\]"\(?<method>\[\[:word:\]\]\+\)\[\[:blank:\]\]\(?<request>S\+\)\[\[:blank:\]\]\(?<protocol>\[^"\]\+\)"\[\[:blank:\]\]\(?<status\_code>d\+\)\[\[:blank:\]\]\(?<response\_size>\(\-\)\|d\+\)\[\[:blank:\]\]\(?<latency>\(\-\)\|d\+\)\[\[:blank:\]\]\(?<referer>S\+\)\[\[:blank:\]\]\(?<client\_agent>\-\|\(\("\)?\[^"\]\*\("\)?\)\)\[\[:blank:\]\]\(?<total\_cpu>\(\-\)\|d\+\)\[\[:blank:\]\]\(?<user\_cpu>\(\-\)\|d\+\)\[\[:blank:\]\]\(?<memory>d\+\)\[\[:blank:\]\]\(?<command\_status>\("\-1"\)\|\(\-\)\|\("0"\)\)$<br>                                                                                                       |
|           |                  |            |                               |                                                                                                                     | 2.1x        | ^\(?<host>\(\[0\-9\]\{1,3\}\.\)\{3\}\[0\-9\]\{1,3\}\)\[\[:blank:\]\]\-\[\[:blank:\]\]\(?<username>S\+\)\[\[:blank:\]\]\[\(?<timestamp>d\{2\}/\[A\-Za\-z\]\{3\}/d\{4\}:d\{2\}:d\{2\}:d\{2\}\[\[:blank:\]\]\[\+\-\]\[0\-9\]\{4\}\)\]\[\[:blank:\]\]"\(?<method>\[\[:word:\]\]\+\)\[\[:blank:\]\]\(?<request>S\+\)\[\[:blank:\]\]\(?<protocol>\[^"\]\+\)"\[\[:blank:\]\]\(?<status\_code>d\+\)\[\[:blank:\]\]\(?<response\_size>\(\-\)\|d\+\)\[\[:blank:\]\]\(?<referer>\(\-\)\|"S\+"\)\[\[:blank:\]\]\(?<client\_agent>\-\|\(\("\)?\[^"\]\*\("\)?\)\)$<br>                                                                                                                                                                                                                                                                                                                                                     |
| sshd_log  | gerrit_sshd_log  | session_id | session_id                    | time_compressing, time_counting, time_negotiating, time_searching_for_reuse, time_searching_for_sizes, time_writing | std         | ^\\\[\(?<timestamp>\\d\{4\}\-\\d\{2\}\-\\d\{2\}T\\d\{2\}:\\d\{2\}:\\d\{2\}\(?:\\\.\\d\{3,6\}\)\)\(?:Z\|\(?<timezone>\[\\\+\\\-\]\\d\{2\}:\\d\{2\}\)\)?\\\]\\s\(?<session\_id>\\S\+\)\\s\\\[\(?<thread>\.\+?\)\\\]\\s\(?<username>\\S\+\)\\sa\\/\(?<account\_id>\\S\+\)\\s\(?<operation>\\S\+\)\\s\(?<wait>\\S\+\)\\s\(?<exec>\\S\+\)\\s\(?<unknown>\\S\+\)\\s\(?<status>\\S\+\)\\s\(?<client\_agent>\-?\\S\+\)\\s\(?<total\_cpu>\\S\+\)\\s\(?<user\_cpu>\\S\+\)\\s\(?<memory>\\S\+\)$                                                                                                                                                                                                                                                                                                                                                                                                                        |
|           |                  |            |                               |                                                                                                                     | login       | ^\\\[\(?<timestamp>\\d\{4\}\-\\d\{2\}\-\\d\{2\}T\\d\{2\}:\\d\{2\}:\\d\{2\}\(?:\\\.\\d\{3,6\}\)\)\(?:Z\|\(?<timezone>\[\\\+\\\-\]\\d\{2\}:\\d\{2\}\)\)?\\\]\\s\(?<session\_id>\\S\+\)\\s\\\[\(?<thread>\.\+?\)\\\]\\s\(?<username>\\S\+\)\\sa\\/\(?<account\_id>\[\\S\]\+\)\\s\(?<operation>\(LOGOUT\)\|\(LOGIN FROM\)\.\*\)$                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|           |                  |            |                               |                                                                                                                     | upload-pack | ^\\\[\(?<timestamp>\\d\{4\}\-\\d\{2\}\-\\d\{2\}T\\d\{2\}:\\d\{2\}:\\d\{2\}\(?:\\\.\\d\{3,6\}\)\)\(?:Z\|\(?<timezone>\[\\\+\\\-\]\\d\{2\}:\\d\{2\}\)\)?\\\]\\s\(?<session\_id>\\S\+\)\\s\\\[\(?<thread>\.\+?\)\\\]\\s\(?<username>\\S\+\)\\sa\\/\(?<account\_id>\[\\S\]\+\)\\s\(?<operation>git\-upload\-pack\.\(\\S\)\*\)\\s\(?<wait>\\S\+\)\\s\(?<exec>\\S\+\)\\s'\(?<time\_negotiating>\\S\+\)\\s\(?<time\_searching\_for\_reuse>\\S\+\)\\s\(?<time\_searching\_for\_sizes>\\S\+\)\\s\(?<time\_counting>\\S\+\)\\s\(?<time\_compressing>\\S\+\)\\s\(?<time\_writing>\\S\+\)\\s\(?<total\_time\_in\_uploadpack>\\S\+\)\\s\(?<bitmap\_index\_misses>\(\-1\)\|\\d\+\)\\s\(?<total\_deltas>\(\-1\)\|\\d\+\)\\s\(?<total\_objects>\(\-1\)\|\\d\+\)\\s\(?<total\_bytes>\(\-1\)\|\\d\+\)'\\s\(?<status>\\d\+\)\\s\(?<client\_agent>\\S\+\)\\s\(?<total\_cpu>\\S\+\)\\s\(?<user\_cpu>\\S\+\)\\s\(?<memory>\\d\+\)$ |

### Add and test a new format

To import and test a format starting from [regex101](https://regex101.com):

1. test your regex with some test strings in https://regex101.com
2. save the regex
3. generate the format from it, with `lnav -m` i.e. `lnav -m regex101 import https://regex101.com/r/XXXXX/1 test`, the resulting format will be installed in `~/.lnav/formats/installed/test.json`
4. modify the format setting opid, fields etc
5. don't forget to copy to this repo once ready, give it a proper name and remove the generated one (in this case test.json) form `~/.lnav/formats/installed`
6. run the gerrit_lnav installer again to add the format


Note: When lnav loads a file, it tries each log format against the first 15,000 lines of the file trying to find a match.
To check if the format you defined is the one that is used when viewing a gerrit log file in lnav, simply lunch lnav
in debug mode i.e.

`truncate -s 0 /tmp/lnav.log && lnav -d /tmp/lnav.log ${YOUR_LOG_FILE_TO_TEST}`
