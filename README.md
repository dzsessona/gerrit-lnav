# GERRIT_LNAV

Formats and other resources to support [Gerrit log files](https://gerrit-review.googlesource.com/Documentation/logs.html) in [lnav](https://lnav.org/).
**The Log File Navigator** (lnav) is an advanced log file viewer for the console.

* [Installation](#installation)
  * [Pre-requisites](#pre-requisites)
  * [Install](#install)
  * [Update](#update)
  * [Uninstall](#uninstall)
* [Usage](#usage)
* [Resources](#resources)
* [Development](#development)

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
or run the install script with the --remove flag i.e. `install.sh --remove`

## Usage

## Resources

## Development
