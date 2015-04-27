# Script for bulk change of MAC OS passwords

This script uses SSH to remotely change the password of the admin user of a list of MAC OS X Machines.
To use, edit the script changing the variables HOST_LIST (list of machines to be accessed), NEW_PASSWORD and OLD_PASSWORD.


After that the scripts tries to acess the machine using the new password and prints a report based on that.

