:: nock-common: common arms between nock-prover and nock-verifier
/=  compute-table  /common/v2/table/verifier/compute
/=  memory-table   /common/v2/table/verifier/memory
/=  *  /common/zeke
|%
::  all values in this table must generally be in the order of the tables
::  specified in the following arm.
++  static-table-names
  ^-  (list term)  ^~
  %-  sort
  :_  t-order
  :~  name:static:common:compute-table
      name:static:common:memory-table
  ==
::
::  +core-table-names: tables utilized for every proof
++  core-table-names
  ^~  ^-  (list term)
  %-  sort
  :_  t-order
  :~  name:static:common:compute-table
      name:static:common:memory-table
  ==
::  +opt-static-table-names: static tables only used when jute-flag=%.y
::
::    TODO make these tables optional depending on whether these jutes are
::    actually used
++  opt-static-table-names
  ^~  ^-  (list term)
  ~
::
::  +opt-dynamic-table-names: dynamic tables only used when jute-flag=%.y
++  opt-dynamic-table-names
  ^~  ^-  (list term)
  ~
::
++  gen-table-names
  ^-  (list term)
  %-  sort
  :_  t-order
  %+  weld
    core-table-names
  (weld opt-static-table-names opt-dynamic-table-names)
::
++  dynamic-table-names
  ^~  ^-  (list term)
  ~
::
++  all-table-names
  ^~  ^-  (list term)
  %-  sort
  :_  t-order
  (weld static-table-names dynamic-table-names)
::
::  Widths of static tables. Dynamic tables (ie jute) need to be computed separately and passed
::  in specific data needed for each table.
++  table-base-widths-static
  ^~  ^-  (list @)
  %+  turn  all-static-table-widths
  |=([name=term base-width=@ ext-width=@ mega-ext-width=@ full-width=@] base-width)
::
++  table-ext-widths-static
  ^~  ^-  (list @)
  %+  turn  all-static-table-widths
  |=([name=term base-width=@ ext-width=@ mega-ext-width=@ full-width=@] ext-width)
::
++  table-mega-ext-widths-static
  ^~  ^-  (list @)
  %+  turn  all-static-table-widths
  |=([name=term base-width=@ ext-width=@ mega-ext-width=@ full-width=@] mega-ext-width)
::
++  table-full-widths-static
  ^~  ^-  (list @)
  %+  turn  all-static-table-widths
  |=([name=term base-width=@ ext-width=@ mega-ext-width=@ full-width=@] full-width)
::
++  core-table-base-widths-static
  ^~  ^-  (list @)
  %+  turn  core-table-names
  |=(name=term base-width:(~(got by width-map) name))
::
++  core-table-full-widths-static
  ^~  ^-  (list @)
  %+  turn  core-table-names
  |=(name=term full-width:(~(got by width-map) name))
::
++  custom-table-base-widths-static
  |=  table-names=(list term)
  ^-  (list @)
  %+  turn  table-names
  |=(name=term base-width:(~(got by width-map) name))
::
++  custom-table-full-widths-static
  |=  table-names=(list term)
  ^-  (list @)
  %+  turn  table-names
  |=(name=term full-width:(~(got by width-map) name))
::
++  width-map
  ^~  ^-  (map name=term [base-width=@ ext-width=@ mega-ext-width=@ full-width=@])
  %.  all-static-table-widths
  %~  gas  by
  ^*  %+  map  name=term
  [base-width=@ ext-width=@ mega-ext-width=@ full-width=@]
::
++  all-static-table-widths
  ^~  ^-  (list [name=term base-width=@ ext-width=@ mega-ext-width=@ full-width=@])
  %-  sort
  :_  tg-order
  :~
    ::
      :*  name:static:common:compute-table
          (lent basic-column-names:static:common:compute-table)
          (lent ext-column-names:static:common:compute-table)
          (lent mega-ext-column-names:static:common:compute-table)
          (lent column-names:static:common:compute-table)
      ==
    ::
      :*  name:static:common:memory-table
          (lent basic-column-names:static:common:memory-table)
          (lent ext-column-names:static:common:memory-table)
          (lent mega-ext-column-names:static:common:memory-table)
          (lent column-names:static:common:memory-table)
      ==
  ==
::
++  all-verifier-funcs
  ^~  ^-  (list verifier-funcs)
  %-  turn
  :_  tail
  %-  sort
  :_  tg-order
  :~  [name:static:common:compute-table funcs:engine:compute-table]
      [name:static:common:memory-table funcs:engine:memory-table]
  ==
::
++  all-terminal-names
  ^~  ^-  (list (list term))
  %-  turn
  :_  tail
  %-  sort
  :_  tg-order
  :~  [name:static:common:compute-table terminal-names:static:common:compute-table]
      [name:static:common:memory-table terminal-names:static:common:memory-table]
  ==
::
++  all-verifier-funcs-map
  ^~  ^-  (map term verifier-funcs)
  %-  ~(gas by *(map term verifier-funcs))
  :~  :-  name:static:common:compute-table
      funcs:engine:compute-table
      :-  name:static:common:memory-table
      funcs:engine:memory-table
  ==
--
