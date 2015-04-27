#!/bin/bash

HOST_LIST="
criacao64
criacao57
criacao61
criacao58
criacao60
criacao59
"

NEW_PASSWORD=#ReplaceMeWithNewPassword#
OLD_PASSWORD=#ReplaceMeWithCurrentPassword#

test_password(){
  # Tests if password $1 is valid for accessing the user@machine in $2
  PASS="$1"
  DEST="$2"
  LANG=C expect -c "
  spawn ssh -oStrictHostKeyChecking=no \"$DEST\" echo PASSOK
  set timout 40
  expect {
      PASSOK {
          exit 0
      }
      Password: {
          send \"$PASS\r\"
          puts \"Enviado passwd para ssh-copy-id\"
          exp_continue
      }
      \"Could not resolve hostname\" {
          exit 3
      }
      \"Permission denied\" {
          exit 15
      }
      \"mkdir: .ssh: Permission\" {
         exit 16
      }
      \"No route to host\" {
          exit 5
      }
      password: {
          send \"$PASS\r\"
          puts \"Enviado passwd para ssh-copy-id\"
          exp_continue
      }
      timeout {
          puts \"\rtimeout ao conectar via ssh\"
          exit 10
      }
      exit 21
  }
 "
}

changeMacPassword(){
  # Changes the password in user@machine at $3 using $1 as current password and $2 as the new password
  OLDPASS="$1"
  NEWPASS="$2"
  DEST="$3"
  expect -c "
  spawn ssh -oStrictHostKeyChecking=no \"$DEST\" dscl . passwd /Users/admin
  set timout 30
  expect {
    \"New Password:\" {
      puts \"<<Sending new Password>>\"
      send \"$NEWPASS\r\"
      exp_continue
    }
    \"Please enter user's old password:\" {
       puts \"<<Sending old Password to authenticate dscl>>\"
       send \"$OLDPASS\r\"
       exp_continue
     }
    \"Password:\" {
      puts \"<<Sending old Password for login>>\"
      send \"$OLDPASS\r\"
      exp_continue
    }
    timeout {
      puts \"<<Timeout when connecting to $3>>\"
      exit 3
    }
  }
  "
}


for host in $HOST_LIST
do
    echo changing password for admin@$host
    changeMacPassword  $OLD_PASSWORD $NEW_PASSWORD admin@$host
done

echo "########################################################"
for host in $HOST_LIST
do
    if test_password  $NEW_PASSWORD admin@$host >/dev/null 2>&1 ; then
        echo "admin@$host: Success!"
    else
        echo "admin@$host: Failed!"
    fi
done

