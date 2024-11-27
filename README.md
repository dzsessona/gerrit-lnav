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
  * [Queries](#queries)
  * [Scripts](#scripts)
  * [Headless mode](#headless-mode)
* [Resources](#resources)
  * [Lnav cheatsheet](#lnav-cheatsheet)
  * [Regex](#regex)
* [Development](#development)
  * [Add and test a new format](#add-and-test-a-new-format)
  * [Add and test a new script](#add-and-test-a-new-script)


## Installation

### Pre-requisites

Please install [lnav](https://lnav.org/) in your system. On MacOS it is as simple as running:

```shell
brew install lnav
```

Please check the [lnav download page](https://lnav.org/downloads) for other options.
After installing it, running `lnav` without any arguments, lnav will try to open the syslog file on your system.
Press `q` to exit lnav.

### Install

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

### Update

1. Update the repository
2. Run the `install.sh` script again.

### Uninstall

To remove all resources that this repository is adding to lnav, either remove the folder `~/.lnav/formats/installed`
or run the install script with the --remove flag i.e

```shell
install.sh --remove
```

### Switch to a different Gerrit version

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

## Usage

### Queries

### Scripts

### Headless mode

## Resources

### Lnav cheatsheet

### Regex

## Development

### Add and test a new format

### Add and test a new script
