::  bip39 implementation in hoon
::
/=  bip39-english  /common/bip39-english
/=  *  /common/zose
::
|%
++  from-entropy
  |=  byts
  ^-  tape
  =.  wid  (mul wid 8)
  ~|  [%unsupported-entropy-bit-length wid]
  ?>  &((gte wid 128) (lte wid 256))
  ::
  =+  cs=(div wid 32)
  =/  check=@
    %+  rsh  [0 (sub 256 cs)]
    (sha-256l:sha (div wid 8) dat)
  =/  bits=byts
    :-  (add wid cs)
    %+  can  0
    :~  cs^check
        wid^dat
    ==
  ::
  =/  pieces
    |-  ^-  (list @)
    :-  (end [0 11] dat.bits)
    ?:  (lte wid.bits 11)  ~
    $(bits [(sub wid.bits 11) (rsh [0 11] dat.bits)])
  ::
  =/  words=(list tape)
    %+  turn  pieces
    |=  ind=@ud
    (snag ind `(list tape)`bip39-english)
  ::
  %+  roll  (flop words)
  |=  [nex=tape all=tape]
  ?~  all  nex
  :(weld all " " nex)
::
::NOTE  always produces a 512-bit result
++  to-seed
  |=  [mnem=tape pass=tape]
  ^-  @
  %-  hmac-sha512t:pbkdf:crypto
  [(crip mnem) (crip (weld "mnemonic" pass)) 2.048 64]
::
++  en-base58
  |=  dat=@
  =/  cha
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
  %-  flop
  |-  ^-  tape
  ?:  =(0 dat)  ~
  :-  (cut 3 [(mod dat 58) 1] cha)
  $(dat (div dat 58))
::
++  de-base58
      |=  t=tape
      =-  (scan t (bass 58 (plus -)))
      ;~  pose
        (cook |=(a=@ (sub a 56)) (shim 'A' 'H'))
        (cook |=(a=@ (sub a 57)) (shim 'J' 'N'))
        (cook |=(a=@ (sub a 58)) (shim 'P' 'Z'))
        (cook |=(a=@ (sub a 64)) (shim 'a' 'k'))
        (cook |=(a=@ (sub a 65)) (shim 'm' 'z'))
        (cook |=(a=@ (sub a 49)) (shim '1' '9'))
      ==
--
