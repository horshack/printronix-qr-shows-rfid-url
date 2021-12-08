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
perl find_rfid_epc_code.pl
```
