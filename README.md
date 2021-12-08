# printronix-qr-shows-rfid-url
Create labels with RFID-EPC-QRCode with Printronix T4000


# Prepare your printer

Printer Printronix T4000 in your network ready to print


# Prepare your environment on the computer

```
cd printronix-qr-shows-rfid-url
perl t/000-perlmodules-installed.t
```

* Edit this file for your network settings: create_qrcode_with_rfid.ini

```
cp myprintjob_metal.tt.example myprintjob_metal.tt
cp myprintjob_normal.tt.example myprintjob_normal.tt
```

# First try, find identity

```
perl find_identity.pl

Printer.Printronix.Talk DEBUG - Sending: ~CONFIG
Printer.Printronix.Talk DEBUG - Sending: SNOOP;STATUS
Printer.Printronix.Talk DEBUG - Sending: END
Printer.Printronix.Talk DEBUG - All commands sent to let our printer be verbose
Printer.Printronix.Talk DEBUG - sending IDENTITY-command to check wether I get a result back
Printer.Printronix.Talk DEBUG - I received this message: T43040,V1.21A,12,131072KB

Printer.Printronix.Talk DEBUG - Sending: ~CONFIG
Printer.Printronix.Talk DEBUG - Sending: SNOOP;OFF
Printer.Printronix.Talk DEBUG - Sending: END
Printer.Printronix.Talk DEBUG - All commands sent to let our printer be silent
main INFO - Ready with find_identity.pl
```

# Next try, print a label with the epc-code as barcode

```
perl find_rfid_epc_code.pl

Printer.Printronix.Talk DEBUG - Sending: ~CONFIG
Printer.Printronix.Talk DEBUG - Sending: SNOOP;STATUS
Printer.Printronix.Talk DEBUG - Sending: END
Printer.Printronix.Talk DEBUG - All commands sent to let our printer be verbose
Printer.Printronix.Talk DEBUG - sending IDENTITY-command to check wether I get a result back
Printer.Printronix.Talk DEBUG - I received this message: T43040,V1.21A,12,131072KB

Printer.Printronix.Talk DEBUG - Sending: ~CREATE;VERIFY;NOMOTION
Printer.Printronix.Talk DEBUG - Sending: RFRTAG;96;EPC
Printer.Printronix.Talk DEBUG - Sending: 96;DF511;H
Printer.Printronix.Talk DEBUG - Sending: STOP
Printer.Printronix.Talk DEBUG - Sending: VERIFY;DF511;H;*STARTEPC=*;*=ENDEPC\n*
Printer.Printronix.Talk DEBUG - Sending: END
Printer.Printronix.Talk DEBUG - Sending: ~EXECUTE;VERIFY;1
Printer.Printronix.Talk DEBUG - Sending: ~NORMAL
Printer.Printronix.Talk DEBUG - I am ready sending the commands to get current epc-code
Printer.Printronix.Talk DEBUG - Now waiting for result from printer, the awaited epc-code
Printer.Printronix.Talk DEBUG - I received this message: STARTEPC=E28011710000020D61B3222E=ENDEPC

Printer.Printronix.Talk DEBUG - Found epc-code: E28011710000020D61B3222E
main INFO - EPC-Code is E28011710000020D61B3222E
Printer.Printronix.Talk DEBUG - Sending: ~CONFIG
Printer.Printronix.Talk DEBUG - Sending: SNOOP;OFF
Printer.Printronix.Talk DEBUG - Sending: END
Printer.Printronix.Talk DEBUG - All commands sent to let our printer be silent
main INFO - Ready with find_rfid_epc_code.pl
```
