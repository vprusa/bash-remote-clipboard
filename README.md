# bash-remote-clipboard

## Motivation

I frequently copy-past from/to terminal.
I have run into troubles with texts containing escape characters, wierd enconding and EOF characters with which it was annoying to copy text from remote machines and I have ended up with using tmp files and scp. 

I want to share data across localhost and remote machines effortlessely (no need to use mouse and deal with intermediate subtasks of copying it), smoothly (having it as bash function so I can use pipe), persistently (if needed keep the data somewhere), modular (I have many remote machines and some of them may be under some circumstances 'local' machines to other remote machines), fail-safe (catching errors) and securely (I can NOT share physically localhost clipboard and having it under SSH seems like a valid option here).

## Installation

On both local and remote machines execute:

```
git clone https://github.com/VUTBR-CVIS/bash-remote-clipboard.git
```

On local machine it is necessary to configure SSH access to remote machine.

When executing ./main.sh for the first time the config-sample.sh is copied to config.sh and in the newly copied config.sh file it is necessary to define content of array varibale RCB_SERVERS (and if needed POSTFIX variable, which is basicaly string parametrization).

Default location of remote clipboard is
~/.local/clipboard/cb-(p|c)
the location can be modified by adding variable  
CLIPBOARD_FILE="/path/to/cb" to ~/.bashrc

## Usage

On remote machine with configured RCB_SERVERS as in config-sample.sh executing

```
echo "Hello, World!" | _rc
```

will sore output of echo to remote clipboard cb-c.
Which can be then read on local machine executing

```
_rp AAAA | cat
```

## Results

- config.sh
- main.sh
- clipboard files on local and remote machines at appropiate location

There will be

- 2 files on remote machine 'cb-c' - containing data copied from remote - and 'cb-p' - contianing data copied to remote.
- 2 files per each remote server on local machine

## TODO ..

- core idea is wirtten down, after writing this README.md I have realized that I need to rewrite some parts of it...
