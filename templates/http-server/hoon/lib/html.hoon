/+  http
^?
=>
|%
+$  json                                                ::  normal json value
  $@  ~                                                 ::  null
  $%  [%a p=(list json)]                                ::  array
      [%b p=?]                                          ::  boolean
      [%o p=(map @t json)]                              ::  object
      [%n p=@ta]                                        ::  number
      [%s p=@t]                                         ::  string
  ==                                                    ::
+$  hart  [p=? q=(unit @ud) r=host]                   ::  http sec+port+host
+$  hiss  [p=purl q=moth]                             ::  outbound request
+$  hoke  %+  each  [%localhost ~]                    ::  local host
          ?(%.0.0.0.0 %.127.0.0.1)                    ::
+$  host  (each turf @if)                             ::  http host
+$  math  (map @t (list @t))                          ::  semiparsed headers
:: +$  mess  (list [p=@t q=@t])                          ::  raw http headers
+$  meth                                              ::  http methods
  $?  %conn                                           ::  CONNECT
      %delt                                           ::  DELETE
      %get                                            ::  GET
      %head                                           ::  HEAD
      %opts                                           ::  OPTIONS
      %post                                           ::  POST
      %put                                            ::  PUT
      %trac                                           ::  TRACE
  ==                                                  ::
+$  moth  [p=meth q=math r=(unit octs)]               ::  http operation
::  $octs: length in bytes and payload
::
+$  octs  [p=@ q=@]
+$  pork  [p=(unit @ta) q=(list @t)]                  ::  fully parsed url
+$  purf  (pair purl (unit @t))                       ::  url with fragment
+$  purl  [p=hart q=pork r=quay]                      ::  parsed url
+$  quay  (list [p=@t q=@t])                          ::  parsed url query
+$  quri                                              ::  request-uri
  $%  [%& p=purl]                                     ::  absolute
      [%| p=pork q=quay]                              ::  relative
  ==                                                  ::
+$  turf  (list @t)                                     ::  domain, tld first
+$  user  knot                                        ::  username
--
|%
::                                                    ::
::::                    ++mimes:html                  ::  (2e1) MIME
  ::                                                  ::::
++  mimes  ^?
  :: ~%  %mimes  ..part  ~
  |%
  ::                                                  ::  ++as-octs:mimes:html
  ++  as-octs                                         ::  atom to octstream
    |=  tam=@  ^-  octs
    [(met 3 tam) tam]
  ::                                                  ::  ++as-octt:mimes:html
  ++  as-octt                                         ::  tape to octstream
    |=  tep=tape  ^-  octs
    (as-octs (rap 3 tep))
  ::                                                  ::  ++en-mite:mimes:html
  ++  en-mite                                         ::  mime type to text
    |=  myn=mite
    %-  crip
    |-  ^-  tape
    ?~  myn  ~
    ?:  =(~ t.myn)  (trip i.myn)
    (weld (trip i.myn) `tape`['/' $(myn t.myn)])
  ::
  ::  |base16: en/decode arbitrary MSB-first hex strings
  ::
  ++  base16
    :: ~%  %base16  +  ~
    |%
    ++  en
      :: ~/  %en
      |=  a=octs  ^-  cord
      (crip ((x-co:co (mul p.a 2)) (end [3 p.a] q.a)))
    ::
    ++  de
      :: ~/  %de
      |=  a=cord  ^-  (unit octs)
      (rush a rule)
    ::
    ++  rule
      %+  cook
        |=  a=(list @)  ^-  octs
        [(add (dvr (lent a) 2)) (rep [0 4] (flop a))]
      (star hit)
    --
  ::  |base64: flexible base64 encoding for little-endian atoms
  ::
  ++  base64
    =>  |%
        +$  byte    @D
        +$  word24  @
        ::
        ++  div-ceil
          ::  divide, rounding up.
          |=  [x=@ y=@]  ^-  @
          ?:  =(0 (mod x y))
            (div x y)
          +((div x y))
        ::
        ++  explode-bytes
          ::  Explode a bytestring into list of bytes. Result is in LSB order.
          |=  =octs  ^-  (list byte)
          =/  atom-byte-width  (met 3 q.octs)
          =/  leading-zeros    (sub p.octs atom-byte-width)
          (weld (reap leading-zeros 0) (rip 3 q.octs))
        ::
        ++  explode-words
          ::  Explode a bytestring to words of bit-width `wid`. Result is in LSW order.
          |=  [wid=@ =octs]
          ^-  (list @)
          =/  atom-bit-width   (met 0 q.octs)
          =/  octs-bit-width   (mul 8 p.octs)
          =/  atom-word-width  (div-ceil atom-bit-width wid)
          =/  rslt-word-width  (div-ceil octs-bit-width wid)
          =/  pad              (sub rslt-word-width atom-word-width)
          =/  x  (rip [0 wid] q.octs)
          %+  weld  x
          (reap pad 0)
        --
    ::
    ::  pad: include padding when encoding, require when decoding
    ::  url: use url-safe characters '-' for '+' and '_' for '/'
    ::
    =+  [pad=& url=|]
    |%
    ::  +en:base64: encode +octs to base64 cord
    ::
    ::  Encode an `octs` into a base64 string.
    ::
    ::  First, we break up the input into a list of 24-bit words. The input
    ::  might not be a multiple of 24-bits, so we add 0-2 padding bytes at
    ::  the end (to the least-significant side, with a left-shift).
    ::
    ::  Then, we encode each block into four base64 characters.
    ::
    ::  Finally we remove the padding that we added at the beginning: for
    ::  each byte that was added, we replace one character with an = (unless
    ::  `pad` is false, in which case we just remove the extra characters).
    ::
    ++  en
      ^-  $-(octs cord)
      ::
      =/  cha
        ?:  url
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
      ::
      |^  |=  bs=octs  ^-  cord
          =/  [padding=@ blocks=(list word24)]
            (octs-to-blocks bs)
          (crip (flop (unpad padding (encode-blocks blocks))))
      ::
      ++  octs-to-blocks
        |=  bs=octs  ^-  [padding=@ud (list word24)]
        =/  padding=@ud  (~(dif fo 3) 0 p.bs)
        =/  padded=octs  [(add padding p.bs) (lsh [3 padding] (rev 3 bs))]
        [padding (explode-words 24 padded)]
      ::
      ++  unpad
        |=  [extra=@ t=tape]  ^-  tape
        =/  without  (slag extra t)
        ?.  pad  without
        (weld (reap extra '=') without)
      ::
      ++  encode-blocks
        |=  ws=(list word24)  ^-  tape
        (zing (turn ws encode-block))
      ::
      ++  encode-block
        |=  w=word24  ^-  tape
        =/  a  (cut 3 [(cut 0 [0 6] w) 1] cha)
        =/  b  (cut 3 [(cut 0 [6 6] w) 1] cha)
        =/  c  (cut 3 [(cut 0 [12 6] w) 1] cha)
        =/  d  (cut 3 [(cut 0 [18 6] w) 1] cha)
        ~[a b c d]
      --
    ::
    ::  +de:base64: decode base64 cord to (unit @)
    ::
    ++  de
      |=  a=cord
      ^-  (unit octs)
      (rush a parse)
    ::  +parse:base64: parse base64 cord to +octs
    ::
    ++  parse
      =<  ^-  $-(nail (like octs))
          %+  sear  reduce
          ;~  plug
            %-  plus  ;~  pose
              (cook |=(a=@ (sub a 'A')) (shim 'A' 'Z'))
              (cook |=(a=@ (sub a 'G')) (shim 'a' 'z'))
              (cook |=(a=@ (add a 4)) (shim '0' '9'))
              (cold 62 (just ?:(url '-' '+')))
              (cold 63 (just ?:(url '_' '/')))
            ==
            (stun 0^2 (cold %0 tis))
          ==
      |%
      ::  +reduce:parse:base64: reduce, measure, and swap base64 digits
      ::
      ++  reduce
        |=  [dat=(list @) dap=(list @)]
        ^-  (unit octs)
        =/  lat  (lent dat)
        =/  lap  (lent dap)
        =/  dif  (~(dif fo 4) 0 lat)
        ?:  &(pad !=(dif lap))
          ::  padding required and incorrect
          ~&(%base-64-padding-err-one ~)
        ?:  &(!pad !=(0 lap))
          ::  padding not required but present
          ~&(%base-64-padding-err-two ~)
        =/  len  (sub (mul 3 (div (add lat dif) 4)) dif)
        :+  ~  len
        =/  res  (rsh [1 dif] (rep [0 6] (flop dat)))
        =/  amt  (met 3 res)
        ::  left shift trailing zeroes in after byte swap
        =/  trl  ?:  (lth len amt)  0  (sub len amt)
        (lsh [3 trl] (swp 3 res))
      --
    --
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
  --  ::mimes
::                                                    ::
::::                    ++json:html                   ::  (2e2) JSON
  ::                                                  ::::
++  json  ^?
  :: ~%  %json  ..part  ~
  |%
  ::                                                  ::  ++en:json:html
  ++  en                                              ::  encode JSON to cord
    :: ~%  %en  +>+  ~
    |^  |=  jon=^json
        ^-  cord
        (rap 3 (flop (onto jon ~)))
    ::                                                ::  ++onto:en:json:html
    ++  onto
      |=  [val=^json out=(list @t)]
      ^+  out
      ?~  val  ['null' out]
      ?-    -.val
          %a
        ?~  p.val  ['[]' out]
        =.  out    ['[' out]
        !.
        |-  ^+  out
        =.  out  ^$(val i.p.val)
        ?~(t.p.val [']' out] $(p.val t.p.val, out [',' out]))
      ::
          %b
        [?:(p.val 'true' 'false') out]
      ::
          %n
        [p.val out]
      ::
          %s
        [(scap p.val) out]
      ::
          %o
        =/  viz  ~(tap by p.val)
        ?~  viz  ['{}' out]
        =.  out  ['{' out]
        !.
        |-  ^+  out
        =.  out  ^$(val q.i.viz, out [':' [(scap p.i.viz) out]])
        ?~(t.viz ['}' out] $(viz t.viz, out [',' out]))
      ==
    ::                                                ::  ++scap:en:json:html
    ++  scap
      |=  val=@t
      ^-  @t
      =/  out=(list @t)  ['"' ~]
      =/  len  (met 3 val)
      =|  [i=@ud pos=@ud]
      |-  ^-  @t
      ?:  =(len i)
        (rap 3 (flop ['"' (rsh [3 pos] val) out]))
      =/  car  (cut 3 [i 1] val)
      ?:  ?&  (gth car 0x1f)
              !=(car 0x22)
              !=(car 0x5C)
              !=(car 0x7F)
          ==
        $(i +(i))
      =/  cap
        ?+  car  (crip '\\' 'u' ((x-co 4):co car))
          %10    '\\n'
          %'"'   '\\"'
          %'\\'  '\\\\'
        ==
      $(i +(i), pos +(i), out [cap (cut 3 [pos (sub i pos)] val) out])
    --  ::en
  ::                                                  ::  ++de:json:html
  ++  de                                              ::  parse cord to JSON
    :: ~%  %de  +>+  ~
    |^  |=  txt=cord
        ^-  (unit ^json)
        (rush txt apex)
    ::                                                ::  ++abox:de:json:html
    ++  abox                                          ::  array
      %+  stag  %a
      (ifix [sel (wish ser)] (more (wish com) apex))
    ::                                                ::  ++apex:de:json:html
    ++  apex                                          ::  any value
      %+  knee  *^json  |.  ~+
      %+  ifix  [spac spac]
      ;~  pose
        (cold ~ (jest 'null'))
        (stag %b bool)
        (stag %s stri)
        (cook |=(s=tape [%n p=(rap 3 s)]) numb)
        abox
        obox
      ==
    ::                                                ::  ++bool:de:json:html
    ++  bool                                          ::  boolean
      ;~  pose
        (cold & (jest 'true'))
        (cold | (jest 'false'))
      ==
    ::                                                ::  ++esca:de:json:html
    ++  esca                                          ::  escaped character
      ;~  pfix  bas
        =*  loo
          =*  lip
            ^-  (list (pair @t @))
            [b+8 t+9 n+10 f+12 r+13 ~]
          =*  wow
            ^~
            ^-  (map @t @)
            (malt lip)
          (sear ~(get by wow) low)
        ;~(pose doq fas bas loo unic)
      ==
    ::                                                ::  ++expo:de:json:html
    ++  expo                                          ::  exponent
      ;~  (comp weld)
        (piec (mask "eE"))
        (mayb (piec (mask "+-")))
        (plus nud)
      ==
    ::                                                ::  ++frac:de:json:html
    ++  frac                                          ::  fraction
      ;~(plug dot (plus nud))
    ::                                                ::  ++jcha:de:json:html
    ++  jcha                                          ::  string character
      ;~(pose ;~(less doq bas (shim 32 255)) esca)
    ::                                                ::  ++mayb:de:json:html
    ++  mayb                                          ::  optional
      |*(bus=rule ;~(pose bus (easy ~)))
    ::                                                ::  ++numb:de:json:html
    ++  numb                                          ::  number
      ;~  (comp weld)
        (mayb (piec hep))
        ;~  pose
          (piec (just '0'))
          ;~(plug (shim '1' '9') (star nud))
        ==
        (mayb frac)
        (mayb expo)
      ==
    ::                                                ::  ++obje:de:json:html
    ++  obje                                          ::  object list
      %+  ifix  [(wish kel) (wish ker)]
      (more (wish com) pear)
    ::                                                ::  ++obox:de:json:html
    ++  obox                                          ::  object
      (stag %o (cook malt obje))
    ::                                                ::  ++pear:de:json:html
    ++  pear                                          ::  key-value
      ;~(plug ;~(sfix (wish stri) (wish col)) apex)
    ::                                                ::  ++piec:de:json:html
    ++  piec                                          ::  listify
      |*  bus=rule
      (cook |=(a=@ [a ~]) bus)
    ::                                                ::  ++stri:de:json:html
    ++  stri                                          ::  string
      %+  sear
        |=  a=cord
        ?.  (sune a)  ~
        (some a)
      (cook crip (ifix [doq doq] (star jcha)))
    ::                                                ::  ++spac:de:json:html
    ++  spac                                          ::  whitespace
      (star (mask [`@`9 `@`10 `@`13 ' ' ~]))
    ::                                                ::  ++unic:de:json:html
    ++  unic                                          ::  escaped UTF16
      =*  lob  0x0
      =*  hsb  0xd800
      =*  lsb  0xdc00
      =*  hib  0xe000
      =*  hil  0x1.0000
      |^
        %+  cook
          |=  a=@
          ^-  @t
          (tuft a)
        ;~  pfix  (just 'u')
          ;~(pose solo pair)
        ==
      ++  quad                                        ::  parse num from 4 hex
        (bass 16 (stun [4 4] hit))
      ++  meat                                        ::  gen gate for sear:
        |=  [bot=@ux top=@ux flp=?]                   ::  accept num in range,
        |=  sur=@ux                                   ::  optionally reduce
        ^-  (unit @)
        ?.  &((gte sur bot) (lth sur top))
          ~
        %-  some
        ?.  flp  sur
        (sub sur bot)
      ++  solo                                        ::  single valid UTF16
        ;~  pose
          (sear (meat lob hsb |) quad)
          (sear (meat hib hil |) quad)
        ==
      ++  pair                                        ::  UTF16 surrogate pair
        %+  cook
          |=  [hig=@ low=@]
            ^-  @t
            :(add hil low (lsh [1 5] hig))
        ;~  plug
          (sear (meat hsb lsb &) quad)
          ;~  pfix  (jest '\\u')
            (sear (meat lsb hib &) quad)
          ==
        ==
      --
    ::                                                ::  ++utfe:de:json:html
    ++  utfe                                          ::  UTF-8 sequence
      ;~  less  doq  bas
        =*  qua
          %+  cook
          |=  [a=@ b=@ c=@ d=@]
            (rap 3 a b c d ~)
          ;~  pose
            ;~  plug
              (shim 241 243)
              (shim 128 191)
              (shim 128 191)
              (shim 128 191)
            ==
            ;~  plug
              (just '\F0')
              (shim 144 191)
              (shim 128 191)
              (shim 128 191)
            ==
            ;~  plug
              (just '\F4')
              (shim 128 143)
              (shim 128 191)
              (shim 128 191)
            ==
          ==
        =*  tre
          %+  cook
          |=  [a=@ b=@ c=@]
            (rap 3 a b c ~)
          ;~  pose
            ;~  plug
              ;~  pose
                (shim 225 236)
                (shim 238 239)
              ==
              (shim 128 191)
              (shim 128 191)
            ==
            ;~  plug
              (just '\E0')
              (shim 160 191)
              (shim 128 191)
            ==
            ;~  plug
              (just '\ED')
              (shim 128 159)
              (shim 128 191)
            ==
          ==
        =*  dos
          %+  cook
          |=  [a=@ b=@]
            (cat 3 a b)
          ;~  plug
            (shim 194 223)
            (shim 128 191)
          ==
        ;~(pose qua tre dos)
      ==
    ::                                                ::  ++wish:de:json:html
    ++  wish                                          ::  with whitespace
      |*(sef=rule ;~(pfix spac sef))
    ::  XX: These gates should be moved to hoon.hoon
    ::                                                ::  ++sune:de:json:html
    ++  sune                                          ::  cord UTF-8 sanity
      |=  b=@t
      ^-  ?
      ?:  =(0 b)  &
      ?.  (sung b)  |
      $(b (rsh [3 (teff b)] b))
    ::                                                ::  ++sung:de:json:html
    ++  sung                                          ::  char UTF-8 sanity
      |^  |=  b=@t
          ^-  ?
          =+  len=(teff b)
          ?:  =(4 len)  (quad b)
          ?:  =(3 len)  (tres b)
          ?:  =(2 len)  (dos b)
          (lte (end 3 b) 127)
      ::
      ++  dos
        |=  b=@t
        ^-  ?
        =+  :-  one=(cut 3 [0 1] b)
                two=(cut 3 [1 1] b)
        ?&  (rang one 194 223)
            (cont two)
        ==
      ::
      ++  tres
        |=  b=@t
        ^-  ?
        =+  :+  one=(cut 3 [0 1] b)
                two=(cut 3 [1 1] b)
                tre=(cut 3 [2 1] b)
        ?&
          ?|
            ?&  |((rang one 225 236) (rang one 238 239))
                (cont two)
            ==
            ::
            ?&  =(224 one)
                (rang two 160 191)
            ==
            ::
            ?&  =(237 one)
                (rang two 128 159)
            ==
          ==
          ::
          (cont tre)
        ==
      ::
      ++  quad
        |=  b=@t
        ^-  ?
        =+  :^  one=(cut 3 [0 1] b)
                two=(cut 3 [1 1] b)
                tre=(cut 3 [2 1] b)
                for=(cut 3 [3 1] b)
        ?&
          ?|
            ?&  (rang one 241 243)
                (cont two)
            ==
            ::
            ?&  =(240 one)
                (rang two 144 191)
            ==
            ::
            ?&  =(244 one)
                (rang two 128 143)
            ==
          ==
          ::
          (cont tre)
          (cont for)
        ==
      ::
      ++  cont
        |=  a=@
        ^-  ?
        (rang a 128 191)
      ::
      ++  rang
        |=  [a=@ bot=@ top=@]
        ^-  ?
        ?>  (lte bot top)
        &((gte a bot) (lte a top))
      --
    ::  XX: This +teff should overwrite the existing +teff
    ::                                                ::  ++teff:de:json:html
    ++  teff                                          ::  UTF-8 length
      |=  a=@t
      ^-  @
      =+  b=(end 3 a)
      ?:  =(0 b)
        ?>  =(`@`0 a)  0
      ?:  (lte b 127)  1
      ?:  (lte b 223)  2
      ?:  (lte b 239)  3
      4
    --  ::de
  --  ::json
::                                                    ::  ++en-xml:html
++  en-xml                                            ::  xml printer
  =<  |=(a=manx `tape`(apex a ~))
  |_  _[unq=`?`| cot=`?`|]
  ::                                                  ::  ++apex:en-xml:html
  ++  apex                                            ::  top level
    |=  [mex=manx rez=tape]
    ^-  tape
    ?:  ?=([%$ [[%$ *] ~]] g.mex)
      (escp v.i.a.g.mex rez)
    =+  man=`mane`n.g.mex
    =.  unq  |(unq =(%script man) =(%style man))
    =+  tam=(name man)
    =+  att=`mart`a.g.mex
    :-  '<'
    %+  welp  tam
    =-  ?~(att rez [' ' (attr att rez)])
    ^-  rez=tape
    ?:  &(?=(~ c.mex) |(cot ?^(man | (clot man))))
      [' ' '/' '>' rez]
    :-  '>'
    (many c.mex :(weld "</" tam ">" rez))
  ::                                                  ::  ++attr:en-xml:html
  ++  attr                                            ::  attributes to tape
    |=  [tat=mart rez=tape]
    ^-  tape
    ?~  tat  rez
    =.  rez  $(tat t.tat)
    ;:  weld
      (name n.i.tat)
      "=\""
      (escp(unq |) v.i.tat '"' ?~(t.tat rez [' ' rez]))
    ==
  ::                                                  ::  ++escp:en-xml:html
  ++  escp                                            ::  escape for xml
    |=  [tex=tape rez=tape]
    ?:  unq
      (weld tex rez)
    =+  xet=`tape`(flop tex)
    !.
    |-  ^-  tape
    ?~  xet  rez
    %=    $
      xet  t.xet
      rez  ?-  i.xet
              %34  ['&' 'q' 'u' 'o' 't' ';' rez]
              %38  ['&' 'a' 'm' 'p' ';' rez]
              %39  ['&' '#' '3' '9' ';' rez]
              %60  ['&' 'l' 't' ';' rez]
              %62  ['&' 'g' 't' ';' rez]
              *    [i.xet rez]
            ==
    ==
  ::                                                  ::  ++many:en-xml:html
  ++  many                                            ::  nodelist to tape
    |=  [lix=(list manx) rez=tape]
    |-  ^-  tape
    ?~  lix  rez
    (apex i.lix $(lix t.lix))
  ::                                                  ::  ++name:en-xml:html
  ++  name                                            ::  name to tape
    |=  man=mane  ^-  tape
    ?@  man  (trip man)
    (weld (trip -.man) `tape`[':' (trip +.man)])
  ::                                                  ::  ++clot:en-xml:html
  ++  clot  ~+                                        ::  self-closing tags
    %~  has  in
    %-  silt  ^-  (list term)  :~
      %area  %base  %br  %col  %command  %embed  %hr  %img  %input
      %keygen  %link  %meta  %param     %source   %track  %wbr
    ==
  --  ::en-xml
::                                                    ::  ++de-xml:html
++  de-xml                                            ::  xml parser
  =<  |=(a=cord (rush a apex))
  |_  ent=_`(map term @t)`[[%apos '\''] ~ ~]
  ::                                                  ::  ++apex:de-xml:html
  ++  apex                                            ::  top level
    =+  spa=;~(pose comt whit)
    %+  knee  *manx  |.  ~+
    %+  ifix
      [;~(plug (more spa decl) (star spa)) (star spa)]
    ;~  pose
      %+  sear  |=([a=marx b=marl c=mane] ?.(=(c n.a) ~ (some [a b])))
        ;~(plug head many tail)
      empt
    ==
  ::                                                  ::  ++attr:de-xml:html
  ++  attr                                            ::  attributes
    %+  knee  *mart  |.  ~+
    %-  star
    ;~  plug
      ;~(pfix (plus whit) name)
      ;~  pose
        %+  ifix
          :_  doq
          ;~(plug (ifix [. .]:(star whit) tis) doq)
        (star ;~(less doq escp))
      ::
        %+  ifix
          :_  soq
          ;~(plug (ifix [. .]:(star whit) tis) soq)
        (star ;~(less soq escp))
      ::
        (easy ~)
      ==
    ==
  ::                                                  ::  ++cdat:de-xml:html
  ++  cdat                                            ::  CDATA section
    %+  cook
      |=(a=tape ^-(mars ;/(a)))
    %+  ifix
      [(jest '<![CDATA[') (jest ']]>')]
    %-  star
    ;~(less (jest ']]>') next)
  ::                                                  ::  ++chrd:de-xml:html
  ++  chrd                                            ::  character data
    %+  cook  |=(a=tape ^-(mars ;/(a)))
    (plus ;~(pose (just `@`10) escp))
  ::                                                  ::  ++comt:de-xml:html
  ++  comt                                            ::  comments
    =-  (ifix [(jest '<!--') (jest '-->')] (star -))
    ;~  pose
      ;~(less hep prn)
      whit
      ;~(less (jest '-->') hep)
    ==
  ::
  ++  decl                                            ::  ++decl:de-xml:html
    %+  ifix                                          ::  XML declaration
      [(jest '<?xml') (jest '?>')]
    %-  star
    ;~(less (jest '?>') prn)
  ::                                                  ::  ++escp:de-xml:html
  ++  escp                                            ::
    ;~(pose ;~(less gal gar pam prn) enty)
  ::                                                  ::  ++enty:de-xml:html
  ++  enty                                            ::  entity
    %+  ifix  pam^mic
    ;~  pose
      =+  def=^+(ent (my:nl [%gt '>'] [%lt '<'] [%amp '&'] [%quot '"'] ~))
      %+  sear  ~(get by (~(uni by def) ent))
      (cook crip ;~(plug alf (stun 1^31 aln)))
      %+  cook  |=(a=@c ?:((gth a 0x10.ffff) '�' (tuft a)))
      =<  ;~(pfix hax ;~(pose - +))
      :-  (bass 10 (stun 1^8 dit))
      (bass 16 ;~(pfix (mask "xX") (stun 1^8 hit)))
    ==
  ::                                                  ::  ++empt:de-xml:html
  ++  empt                                            ::  self-closing tag
    %+  ifix  [gal (jest '/>')]
    ;~(plug ;~(plug name attr) (cold ~ (star whit)))
  ::                                                  ::  ++head:de-xml:html
  ++  head                                            ::  opening tag
    (ifix [gal gar] ;~(plug name attr))
  ::                                                  ::  ++many:de-xml:html
  ++  many                                            ::  contents
    ;~(pfix (star comt) (star ;~(sfix ;~(pose apex chrd cdat) (star comt))))
  ::                                                  ::  ++name:de-xml:html
  ++  name                                            ::  tag name
    =+  ^=  chx
        %+  cook  crip
        ;~  plug
            ;~(pose cab alf)
            (star ;~(pose cab dot alp))
        ==
    ;~(pose ;~(plug ;~(sfix chx col) chx) chx)
  ::                                                  ::  ++tail:de-xml:html
  ++  tail                                            ::  closing tag
    (ifix [(jest '</') gar] name)
  ::                                                  ::  ++whit:de-xml:html
  ++  whit                                            ::  whitespace
    (mask ~[' ' `@`0x9 `@`0xa])
  --  ::de-xml
::                                                    ::  ++en-urlt:html
++  en-urlt                                           ::  url encode
  |=  tep=tape
  ^-  tape
  %-  zing
  %+  turn  tep
  |=  tap=char
  =+  xen=|=(tig=@ ?:((gte tig 10) (add tig 55) (add tig '0')))
  ?:  ?|  &((gte tap 'a') (lte tap 'z'))
          &((gte tap 'A') (lte tap 'Z'))
          &((gte tap '0') (lte tap '9'))
          =('.' tap)
          =('-' tap)
          =('~' tap)
          =('_' tap)
      ==
    [tap ~]
  ['%' (xen (rsh [0 4] tap)) (xen (end [0 4] tap)) ~]
::                                                    ::  ++de-urlt:html
++  de-urlt                                           ::  url decode
  |=  tep=tape
  ^-  (unit tape)
  ?~  tep  [~ ~]
  ?:  =('%' i.tep)
    ?.  ?=([@ @ *] t.tep)  ~
    =+  nag=(mix i.t.tep (lsh 3 i.t.t.tep))
    =+  val=(rush nag hex:ag)
    ?~  val  ~
    =+  nex=$(tep t.t.t.tep)
    ?~(nex ~ [~ [`@`u.val u.nex]])
  =+  nex=$(tep t.tep)
  ?~(nex ~ [~ i.tep u.nex])
::                                                    ::  ++en-purl:html
++  en-purl                                           ::  print purl
  =<  |=(pul=purl `tape`(apex %& pul))
  |%
  ::                                                  ::  ++apex:en-purl:html
  ++  apex                                            ::
    |=  qur=quri  ^-  tape
    ?-  -.qur
      %&  (weld (head p.p.qur) `tape`$(qur [%| +.p.qur]))
      %|  ['/' (weld (body p.qur) (tail q.qur))]
    ==
  ::                                                  ::  ++apix:en-purl:html
  ++  apix                                            ::  purf to tape
    |=  purf
    (weld (apex %& p) ?~(q "" `tape`['#' (trip u.q)]))
  ::                                                  ::  ++body:en-purl:html
  ++  body                                            ::
    |=  pok=pork  ^-  tape
    ?~  q.pok  ~
    |-
    =+  seg=(en-urlt (trip i.q.pok))
    ?~  t.q.pok
      ?~(p.pok seg (welp seg '.' (trip u.p.pok)))
    (welp seg '/' $(q.pok t.q.pok))
  ::                                                  ::  ++head:en-purl:html
  ++  head                                            ::
    |=  har=hart
    ^-  tape
    ;:  weld
      ?:(&(p.har !?=(hoke r.har)) "https://" "http://")
    ::
      ?-  -.r.har
        %|  (trip (rsh 3 (scot %if p.r.har)))
        %&  =+  rit=(flop p.r.har)
            |-  ^-  tape
            ?~  rit  ~
            (weld (trip i.rit) ?~(t.rit "" `tape`['.' $(rit t.rit)]))
      ==
    ::
      ?~(q.har ~ `tape`[':' ((d-co:co 1) u.q.har)])
    ==
  ::                                                  ::  ++tail:en-purl:html
  ++  tail                                            ::
    |=  kay=quay
    ^-  tape
    ?:  =(~ kay)  ~
    :-  '?'
    |-  ^-  tape
    ?~  kay  ~
    ;:  welp
      (en-urlt (trip p.i.kay))
      ?~(q.i.kay ~ ['=' (en-urlt (trip q.i.kay))])
      ?~(t.kay ~ `tape`['&' $(kay t.kay)])
    ==
  --  ::
::                                                    ::  ++de-purl:html
++  de-purl                                           ::  url+header parser
  =<  |=(a=cord `(unit purl)`(rush a auri))
  |%
  ::                                                  ::  ++deft:de-purl:html
  ++  deft                                            ::  parse url extension
    |=  rax=(list @t)
    |-  ^-  pork
    ?~  rax
      [~ ~]
    ?^  t.rax
      [p.pok [ire q.pok]]:[pok=$(rax t.rax) ire=i.rax]
    =/  raf=(like term)
      %-  ;~  sfix
            %+  sear
              |=(a=@ ((sand %ta) (crip (flop (trip a)))))
            (cook |=(a=tape (rap 3 ^-((list @) a))) (star aln))
            dot
          ==
      [1^1 (flop (trip i.rax))]
    ?~  q.raf
      [~ [i.rax ~]]
    =+  `[ext=term [@ @] fyl=tape]`u.q.raf
    :-  `ext
    ?:(=(~ fyl) ~ [(crip (flop fyl)) ~])
  ::                                                  ::  ++apat:de-purl:html
  ++  apat                                            ::  2396 abs_path
    %+  cook  deft
    ;~(pfix fas (more fas smeg))
  ::                                                  ::  ++aurf:de-purl:html
  ++  aurf                                            ::  2396 with fragment
    %+  cook  |~(a=purf a)
    ;~(plug auri (punt ;~(pfix hax (cook crip (star pque)))))
  ::                                                  ::  ++auri:de-purl:html
  ++  auri                                            ::  2396 URL
    ;~  plug
      ;~(plug htts thor)
      ;~(plug ;~(pose apat (easy *pork)) yque)
    ==
  ::                                                  ::  ++auru:de-purl:html
  ++  auru                                            ::  2396 with maybe user
    %+  cook
      |=  $:  a=[p=? q=(unit user) r=[(unit @ud) host]]
              b=[pork quay]
          ==
      ^-  (pair (unit user) purl)
      [q.a [[p.a r.a] b]]
    ::
    ;~  plug
      ;~(plug htts (punt ;~(sfix urt:ab pat)) thor)
      ;~(plug ;~(pose apat (easy *pork)) yque)
    ==
  ::                                                  ::  ++htts:de-purl:html
  ++  htts                                            ::  scheme
    %+  sear  ~(get by (malt `(list (pair term ?))`[http+| https+& ~]))
    ;~(sfix scem ;~(plug col fas fas))
  ::                                                  ::  ++cock:de-purl:html
  ++  cock                                            ::  cookie
    %+  most  ;~(plug mic ace)
    ;~(plug toke ;~(pfix tis tosk))
  ::                                                  ::  ++dlab:de-purl:html
  ++  dlab                                            ::  2396 domainlabel
    %+  sear
      |=  a=@ta
      ?.(=('-' (rsh [3 (dec (met 3 a))] a)) [~ u=a] ~)
    %+  cook  |=(a=tape (crip (cass a)))
    ;~(plug aln (star alp))
  ::                                                  ::  ++fque:de-purl:html
  ++  fque                                            ::  normal query field
    (cook crip (plus pquo))
  ::                                                  ::  ++fquu:de-purl:html
  ++  fquu                                            ::  optional query field
    (cook crip (star pquo))
  ::                                                  ::  ++pcar:de-purl:html
  ++  pcar                                            ::  2396 path char
    ;~(pose pure pesc psub col pat)
  ::                                                  ::  ++pcok:de-purl:html
  ++  pcok                                            ::  cookie char
    ;~(less bas mic com doq prn)
  ::                                                  ::  ++pesc:de-purl:html
  ++  pesc                                            ::  2396 escaped
    ;~(pfix cen mes)
  ::                                                  ::  ++pold:de-purl:html
  ++  pold                                            ::
    (cold ' ' (just '+'))
  ::                                                  ::  ++pque:de-purl:html
  ++  pque                                            ::  3986 query char
    ;~(pose pcar fas wut)
  ::                                                  ::  ++pquo:de-purl:html
  ++  pquo                                            ::  normal query char
    ;~(pose pure pesc pold fas wut col com)
  ::                                                  ::  ++pure:de-purl:html
  ++  pure                                            ::  2396 unreserved
    ;~(pose aln hep cab dot zap sig tar soq pal par)
  ::                                                  ::  ++psub:de-purl:html
  ++  psub                                            ::  3986 sub-delims
    ;~  pose
      zap  buc  pam  soq  pal  par
      tar  lus  com  mic  tis
    ==
  ::                                                  ::  ++ptok:de-purl:html
  ++  ptok                                            ::  2616 token
    ;~  pose
      aln  zap  hax  buc  cen  pam  soq  tar  lus
      hep  dot  ket  cab  tic  bar  sig
    ==
  ::                                                  ::  ++scem:de-purl:html
  ++  scem                                            ::  2396 scheme
    %+  cook  |=(a=tape (crip (cass a)))
    ;~(plug alf (star ;~(pose aln lus hep dot)))
  ::                                                  ::  ++smeg:de-purl:html
  ++  smeg                                            ::  2396 segment
    (cook crip (star pcar))
  ::                                                  ::  ++tock:de-purl:html
  ++  tock                                            ::  6265 raw value
    (cook crip (plus pcok))
  ::                                                  ::  ++tosk:de-purl:html
  ++  tosk                                            ::  6265 quoted value
    ;~(pose tock (ifix [doq doq] tock))
  ::                                                  ::  ++toke:de-purl:html
  ++  toke                                            ::  2616 token
    (cook crip (plus ptok))
  ::                                                  ::  ++thor:de-purl:html
  ++  thor                                            ::  2396 host+port
    %+  cook  |*([* *] [+<+ +<-])
    ;~  plug
      thos
      ;~((bend) (easy ~) ;~(pfix col dim:ag))
    ==
  ::                                                  ::  ++thos:de-purl:html
  ++  thos                                            ::  2396 host, no local
    ;~  plug
      ;~  pose
        %+  stag  %&
        %+  sear                                      ::  LL parser weak here
          |=  a=(list @t)
          =+  b=(flop a)
          ?>  ?=(^ b)
          =+  c=(end 3 i.b)
          ?.(&((gte c 'a') (lte c 'z')) ~ [~ u=b])
        (most dot dlab)
      ::
        %+  stag  %|
        =+  tod=(ape:ag ted:ab)
        %+  bass  256
        ;~(plug tod (stun [3 3] ;~(pfix dot tod)))
      ==
    ==
  ::                                                  ::  ++yque:de-purl:html
  ++  yque                                            ::  query ending
    ;~  pose
      ;~(pfix wut yquy)
      (easy ~)
    ==
  ::                                                  ::  ++yquy:de-purl:html
  ++  yquy                                            ::  query
    ;~  pose
      ::  proper query
      ::
      %+  more
        ;~(pose pam mic)
      ;~(plug fque ;~(pose ;~(pfix tis fquu) (easy '')))
      ::
      ::  funky query
      ::
      %+  cook
        |=(a=tape [[%$ (crip a)] ~])
      (star pque)
    ==
  ::                                                  ::  ++zest:de-purl:html
  ++  zest                                            ::  2616 request-uri
    ;~  pose
      (stag %& (cook |=(a=purl a) auri))
      (stag %| ;~(plug apat yque))
    ==
  --  ::de-purl
::  +en-turf: encode +turf as a TLD-last domain string
::
++  en-turf
  |=  =turf
  ^-  @t
  (rap 3 (flop (join '.' turf)))
::  +de-turf: parse a TLD-last domain string into a TLD first +turf
::
++  de-turf
  |=  host=@t
  ^-  (unit turf)
  %+  rush  host
  %+  sear
    |=  =^host
    ?.(?=(%& -.host) ~ (some p.host))
  thos:de-purl
::
++  hiss-to-request
  |=  =hiss
  ^-  request:http
  ::
  :*  ?-  p.q.hiss
        %conn  %'CONNECT'
        %delt  %'DELETE'
        %get   %'GET'
        %head  %'HEAD'
        %opts  %'OPTIONS'
        %post  %'POST'
        %put   %'PUT'
        %trac  %'TRACE'
      ==
  ::
    (crip (en-purl p.hiss))
  ::
    ^-  header-list:http
    ~!  q.q.hiss
    %+  turn  ~(tap by q.q.hiss)
    |=  [a=@t b=(list @t)]
    ^-  [@t @t]
    ?>  ?=(^ b)
    [a i.b]
  ::
    r.q.hiss
  ==
--  ::  html
