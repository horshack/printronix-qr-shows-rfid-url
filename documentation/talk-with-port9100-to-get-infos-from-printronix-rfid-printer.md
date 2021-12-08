# Printronix T4000, talk with port 9100 to get info from the printer

## Author

Richard Lippmann, Stadt Zirndorf, EDV


## Documentinformation

* name: talk-with-port9100-to-get-infos-from-printronix-rfid-printer.md
* revision: 2021-12-02 - init


## What I want to achieve

I want to know the RFID-code from the label which is under the print-head.
With this information I am able to build a printjob with Qrcode which includes
the RFID-EPC.

I was not able to find out how to create a print-job with a qr-code.

* I do not want this information in qrcode: ABC1234...567
* But I want this information in qrcode: http://qr.mydomain.com/rfid/epc/ABC1234...567

With that I am able to take a picture of the label and go to a web-application
which helps me further with the device the label is on.


## Documenation, where to find information

* The printer language is described in the document which is easy to google: PTX_PRM_PGL_P7_253642C.pdf


## My environment

Printronix T4000 printer with RFID-unit to read the RFID from the current label.


## How to get info back from my printer

Usually Port 9100 is used to send a printjob to the Printronix-printer. Send job,
don't receive data. But you can switch the printer to be verbose, to send you
back information over the 9100-connection.

## Glossary

* EPC = this is the unique number which is in every RFID-label, just like 
  a MAC-address in a network card

* PGL = the printer language. We can send printjobs with it, but also get information
  from the printer about Configuration etc.


## Errors which can happen

* Put only one 9100-session at a time. One session seems to lock
  the other sessions
* The printer has to be in READY state! This is where the orange
lamp is burning on the top of the printer!!
* Attention! It seems that you can send the "SNOOP;STATUS"
  5 times to the printer, all that is put on a stack!
  When making the reverse operation you have to put 5 time
  "SNOOP;OFF"


## Human connect to the printer via Linux commandline

```shell
ssh me@shell.mydomain.com
export MYPRINTER=192.168.100.3
nc -v $MYPRINTER 9100
```


### Put verbose mode on

The printer usually only receives information, but does not talk back.

You have to "switch on" the back-communication.

```
~CONFIG 
SNOOP;STATUS
END
```


### Put verbose mode off

I you are programming this interface with a programming
language like python, perl, ... it's a good idea to switch
verbose mode off after you did your job.

```
~CONFIG
SNOOP;OFF 
END
```


### IDENTITY

To see information:

1. put verbose mode on
2. send ~IDENTITY command
3. put verbose mode off

```
~CONFIG 
SNOOP;STATUS
END

~IDENTITY
```

The result is:

```
T43040,V1.21A,12,131072KB 
```


### STATUS

To see information:

1. put verbose mode on
2. send ~IDENTITY command
3. put verbose mode off

```
~CONFIG 
SNOOP;STATUS
END

~STATUS
```

The result is:

```
BUSY;0
PAPER;0
RIBBON;0
PRINT HEAD;0
COUNT;000
GAP;0
HEAD HOT;0
CUT COUNT;000000000
PRINT DIST;000001529
PRCT COMPLETE;000
TOF SYNCED;1
SENSED DIST;00450
END
```


## Read one RFID-EPC-code from current label

These are things mentioned in this command:

* ~CREATE - start creating a new "form" (or subroutine to execute later)
* VERIFY - the name of the subroutine we are creating. Keep it simple, 
  less than 15 characters, no special signs (see docu PTX_PRM_PGL_P7_253642C
  page 60 under "CREATE" and page 29 under "Form Name" for exact informations)
* NOMOTION - don't move the label to the next one after executing this job
* DF511 = This is a variable-name, there seem to be a lot of variables in the printer
  which are called by their numbers: DF1, DF2, ... I don't know which one I am 
  allowed to use, DF511 seems to work
* 96 = the RFID-EPC on _my_ labels are 96 Bits long
* H = Hexnumbers, the code is 96 Bit long, but I would like to see it like this: 
  ABC1234...567
* VERIFY - a command to send information to the commandline. 
* ~EXECUTE;VERIFY;1 - execute the form 1 time

```
~CONFIG 
SNOOP;STATUS
END

~CREATE;VERIFY;NOMOTION 
RFRTAG;96;EPC
96;DF511;H 
STOP
VERIFY;DF511;H;*STARTEPC=*;*=ENDEPC\n*
END 
~EXECUTE;VERIFY;1 
~NORMAL

```

The result is:

```
STARTEPC=E28068940000501EC931EC87=ENDEPC
```


## Read two RFID-EPC-codes

Reads 2 Barcodes and gives back the EPC-codes. With this command the label get
sent (moved) through the printer.

These are things mentioned in this command:

* ~CREATE - start creating a new "form" (or subroutine to execute later)
* VERIFY - the name of the subroutine we are creating. Keep it simple, 
  less than 15 characters, no special signs (see docu PTX_PRM_PGL_P7_253642C
  page 60 under "CREATE" and page 29 under "Form Name" for exact informations)
* NOMOTION - don't move the label to the next one after executing this job
* DF511 = This is a variable-name, there seem to be a lot of variables in the printer
  which are called by their numbers: DF1, DF2, ... I don't know which one I am 
  allowed to use, DF511 seems to work
* 96 = the RFID-EPC on _my_ labels are 96 Bits long
* H = Hexnumbers, the code is 96 Bit long, but I would like to see it like this: 
  ABC1234...567
* VERIFY - a command to send information to the commandline. 
* ~EXECUTE;VERIFY;1 - execute the form 1 time

```
~CONFIG 
SNOOP;STATUS
END

~CREATE;VERIFY;432
RFRTAG;96;EPC
96;DF511;H 
STOP
VERIFY;DF511;H;*STARTEPC=*;*=ENDEPC\n*
END 
~EXECUTE;VERIFY;2 
~NORMAL

```

The result is:

```
STARTEPC=E28068940000501EC931EC87=ENDEPC
STARTEPC=E28068940000401EC931EC86=ENDEPC
```
