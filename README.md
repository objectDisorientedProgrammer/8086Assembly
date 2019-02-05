# 8086 Assembly
A collection of assembly programs written for educational purposes.

# Dependencies
**Any executable must run through DOSBox or very old hardware**
* [Download the appropriate version of DOSBox](https://www.dosbox.com/download.php?main=1) for your environment.

# Projects

## FailDos
Final project for CS131: FAILDOS. A simple operating system GUI built to mimic an early MS Windows.

User may hit `esc` at any time to exit.

## Menu
A menu containing several options to select. The user can select an option and press `enter` (this will exit the program).

User may hit `esc` at any time to exit.

# Running
This example was written for a Linux environment and may need to be adapted slightly to fit your needs.

Start DOSBox and enter the following commands:

    Z:\>mount c: ~/<path to folder containing executable>/
    Z:\>c:
    C:\>FAILDOS.EXE

For example, if you download FAILDOS.EXE to ~/Downloads, the `mount` command will make ~/Downloads your root (c:) directory:

    Z:\>mount c: ~/Downloads/
    Z:\>c:
    C:\>FAILDOS.EXE

