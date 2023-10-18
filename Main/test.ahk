hex = 123456
MsgBox, 64, %hex%
 , % Format("{:i}, {:i}, {:i}"
          , "0x" SubStr(hex, 1, 2) ; First two digits
          , "0x" SubStr(hex, 3, 2) ; Middle two digits
          , "0x" SubStr(hex, 5))   ; Last two digits