/=  common  /common/v2/table/compute
/=  verifier-compute  /common/v2/table/verifier/compute
/=  *  /common/zeke
::
~%  %compute-table-v2  ..ride  ~
|%
++  num-randomizers  1
++  header
  ^-  header:table  ^~
  :*  name:static:common
      p
      (lent basic-column-names:static:common)
      (lent ext-column-names:static:common)
      (lent mega-ext-column-names:static:common)
      (lent column-names:static:common)
      num-randomizers
  ==
::
++  test-nocks
  ^-  (list ^)
  :~  [[1 2 3] 3 0 1]
      [[1 2 3] 3 0 2]
      [[1 2 3] 3 1 4]
      [[1 2 3] 3 4 0 2]
      [[1 2 3] 3 4 1 99]
      [[1 2 3] 4 0 2]
      [[1 2 3] 5 [0 1] 0 1]
      [[1 2 3] 5 [0 1] 0 2]
      [42 6 [1 0] [1 2] 1 3]
      [42 6 [1 1] [1 2] 1 3]
      [42 7 [4 0 1] 1 15]
      [42 8 [4 0 1] 1 15]
      [[1 2 3] [4 0 2] 4 1 2]
      [[1 2 3] 2 [0 1] 1 0 2]
      new-pow-5
      new-pow-10
  ==
::
++  new-pow-5
  [ [1 2 3 4 5 0]
    [6 [3 0 62] [0 0] 4 0 62]
    [6 [3 0 30] [0 0] 4 0 30]
    [6 [3 0 14] [0 0] 4 0 14]
    [6 [3 0 6] [0 0] 4 0 6]
    [6 [3 0 2] [0 0] 4 0 2]
    1
    0
  ]
::
++  new-pow-10
  [ [1 2 3 4 5 6 7 8 9 10 0]
    [6 [3 0 2.046] [0 0] 4 0 2.046]
    [6 [3 0 1.022] [0 0] 4 0 1.022]
    [6 [3 0 510] [0 0] 4 0 510]
    [6 [3 0 254] [0 0] 4 0 254]
    [6 [3 0 126] [0 0] 4 0 126]
    [6 [3 0 62] [0 0] 4 0 62]
    [6 [3 0 30] [0 0] 4 0 30]
    [6 [3 0 14] [0 0] 4 0 14]
    [6 [3 0 6] [0 0] 4 0 6]
    [6 [3 0 2] [0 0] 4 0 2]
    1
    0
  ]
::
++  test-all
  ^-  ?
  %-  levy
  :_  same
  %+  iturn  test-nocks
  |=  [i=@ n=^]
  ~&  "testing #{<i>}: {<n>}"
  ?:  (test n)
    ~&  "  result #{<i>}: PASS"
    %.y
  ~&  "  result #{<i>}: FAIL"
  !!
::
++  test-n
  ~/  %test-n
  |=  id=@ud
  ^-  ?
  =/  nock  (snag id test-nocks)
  ~&  "testing #{<id>}: {<nock>}"
  ?:  (test nock)
    ~&  "  #{<id>} {<nock>} passed"
    %.y
  ~&  "  #{<id>} {<nock>} failed"
  %.n
::
++  test
  ~/  %test
  |=  nock=^
  ^-  ?
  =/  ext-chals
    (turn (gulf 1 num-chals-rd1:chal) |=(n=@ (mod (digest-to-atom:tip5 (hash-leaf:tip5 n)) p)))
  =/  mega-ext-chals
    (turn (gulf 1 (lent chal-names-basic:chal)) |=(n=@ (mod (digest-to-atom:tip5 (hash-leaf:tip5 n)) p)))
  =/  dat  (fink:fock nock)
  =/  base-table=table-mary  (pad:funcs (build q.dat))
  =/  ext-table  (extend base-table ext-chals q.dat)
  =/  mega-ext-table  (mega-extend base-table mega-ext-chals q.dat)
  ::
  =/  num-rows  len.array.p.base-table
  =/  tab=table-mary
    :: %-  print-table
    :(weld-exts:tlib base-table ext-table mega-ext-table)
  =/  terminals  (terminal:funcs tab)
  %-  (test:zkvm-debug tab nock)
  :*  mega-ext-chals
      terminals
      (table-to-verifier-funcs:tlib funcs)
   ==
::
++  variable-indices
  ^-  (map col-name @)  ^~
  %-  ~(gas by *(map term @))
  (zip-up column-names:static:common (range (lent column-names:static:common)))
::
++  grab
  ~/  %grab
  |=  [label=col-name =row]
  (grab-bf:constraint-util label row variable-indices)
::
++  grab-pelt
  ~/  %grab-pelt
  |=  [label=col-name =row]
  ^-  pelt
  =<  dat
  %-  init-bpoly
  :~  (grab-bf:constraint-util (crip (weld (trip label) "-a")) row variable-indices)
      (grab-bf:constraint-util (crip (weld (trip label) "-b")) row variable-indices)
      (grab-bf:constraint-util (crip (weld (trip label) "-c")) row variable-indices)
  ==
::
++  print-table  (print-table:zkvm-debug column-names:static:common)
++  print-row
  ~/  %print-row
  |=  row=(list belt)
  ^-  (list belt)
  =-  row
  (print-row:zkvm-debug row ext-column-names:static:common)
::
++  print-full-row
  ~/  %print-full-row
  |=  row=(list belt)
  ^-  (list belt)
  =-  row
  (print-row:zkvm-debug row column-names:static:common)
::
+$  op-flags
  $:  o0=belt
      o1=belt
      o2=belt
      o3=belt
      o4=belt
      o5=belt
      o6=belt
      o7=belt
      o8=belt
      o9=belt
  ==
++  op-map
  ^-  (map @ op-flags)
  %-  ~(gas by *(map @ op-flags))
  :~  :-  0   [1 0 0 0 0 0 0 0 0 0]
      :-  1   [0 1 0 0 0 0 0 0 0 0]
      :-  2   [0 0 1 0 0 0 0 0 0 0]
      :-  3   [0 0 0 1 0 0 0 0 0 0]
      :-  4   [0 0 0 0 1 0 0 0 0 0]
      :-  5   [0 0 0 0 0 1 0 0 0 0]
      :-  6   [0 0 0 0 0 0 1 0 0 0]
      :-  7   [0 0 0 0 0 0 0 1 0 0]
      :-  8   [0 0 0 0 0 0 0 0 1 0]
      :-  9   [0 0 0 0 0 0 0 0 0 1]
  ==
::
++  write-noun
  ~/  %write-noun
  |=  alf=pelt
  |=  [n=tree-data tail=(list belt)]
  ^-  (list belt)
  %+  print-pelt  size.n
  %+  print-pelt  leaf.n
  %+  print-pelt  dyck.n
  tail
::
++  compress-nouns
  ~/  %compress-nouns
  |=  chals=mega-ext-chals:chal
  |=  [s=tree-data f=tree-data e=tree-data]
  ^-  pelt
  ;:  padd
    %+  pmul  m.chals
    ;:  padd
      (pmul j.chals size.s)
      (pmul k.chals dyck.s)
      (pmul l.chals leaf.s)
    ==
  ::
    %+  pmul  n.chals
    ;:  padd
      (pmul j.chals size.f)
      (pmul k.chals dyck.f)
      (pmul l.chals leaf.f)
    ==
  ::
    %+  pmul  o.chals
    ;:  padd
      (pmul j.chals size.e)
      (pmul k.chals dyck.e)
      (pmul l.chals leaf.e)
    ==
  ==
::
++  update-mset
  ~/  %update-mset
  |=  [chals=mega-ext-chals:chal mset=pelt s=tree-data axis=tree-data e=tree-data]
  ^-  pelt
  =/  mroot=pelt
    ;:  padd
      (pmul a.chals size.s)
      (pmul b.chals dyck.s)
      (pmul c.chals leaf.s)
    ==
  =/  maxis=pelt
    (pmul m.chals leaf.axis)
  =/  mval=pelt
    ;:  padd
      (pmul j.chals size.e)
      (pmul k.chals dyck.e)
      (pmul l.chals leaf.e)
    ==
  =/  mvar=pelt
    :(padd mroot maxis mval)
  ::
  (padd mset (pinv (psub bet.chals mvar)))
::
++  update-decoder
  ~/  %update-decoder
  |=  [chals=mega-ext-chals:chal mset=pelt s=tree-data h=tree-data t=tree-data]
  ^-  pelt
  =/  trip=pelt
    ;:  padd
      (pmul j.chals size.s)
      (pmul k.chals dyck.s)
      (pmul l.chals leaf.s)
      (pmul m.chals size.h)
      (pmul n.chals dyck.h)
      (pmul o.chals leaf.h)
      (pmul w.chals size.t)
      (pmul x.chals dyck.t)
      (pmul y.chals leaf.t)
    ==
  ::
  (padd mset (pinv (psub gam.chals trip)))
::
++  update-stack
  ~/  %update-stack
  |=  [state=state-data row=row-data chals=mega-ext-chals:chal]
  ^-  pelt
  =/  c  (compress-nouns chals)
  =/  program  (c s.row f.row e.row)
  =/  sp1  (c sf1-s.row sf1-f.row sf1-e.row)
  =/  sp2  (c sf2-s.row sf2-f.row sf2-e.row)
  =/  sp3  (c sf3-s.row sf3-f.row sf3-e.row)
  =/  op  (need op.row)
  ;:  padd
    stack-kv.state
  ::
    ?:  ?=(?(%0 %1) op)
      pzero
    :(pmul sp1 opc.state z.chals)
  ::
    ?:  ?=(?(%0 %1 %3 %4) op)
      pzero
    :(pmul sp2 opc.state z.chals z.chals)
  ::
    ?.  ?=(%2 op)
      pzero
    :(pmul sp3 opc.state z.chals z.chals z.chals)
  ::
    (pneg (pmul program ln.state))
  ==
::
+$  row-data
  $:  op=(unit @)
      pad=@
      s=tree-data  f=tree-data  e=tree-data
      sf1-s=tree-data  sf1-f=tree-data  sf1-e=tree-data
      sf2-s=tree-data  sf2-f=tree-data  sf2-e=tree-data
      sf3-s=tree-data  sf3-f=tree-data  sf3-e=tree-data
      f-h=tree-data    f-t=tree-data    f-th=tree-data
      f-tt=tree-data   f-tth=tree-data  f-ttt=tree-data
      fcons-inv=pelt
  ==
::
+$  state-data
  $:  ln=pelt
      sfcons-inv=pelt
      opc=pelt
      stack-kv=pelt
      decode-mset=pelt
      op0-mset=pelt
  ==
::
++  to-ext-chals
  ~/  %to-ext-chals
  |=  chals=mega-ext-chals:chal
  ^-  ext-chals:chal
  [a b c d e f g p q r s t u alf]:chals
::
::  pinv but 1/0 = 0
++  make-invs
  ~/  %make-invs
  |=  p=pelt
  ^-  pelt
  ?:  =(pzero p)
    pzero
  (pinv p)
::
++  compute-gen
  ~/  %compute-gen
  |=  [row=row-data chals=ext-chals:chal]
  ^-  pelt
  ?~  op.row  pzero
  ?+  u.op.row  pzero
    %0  (make-invs (psub leaf.f-t.row pone))
    %3  (make-invs (psub alf.chals size.sf1-e.row))
  ==
::
++  write-extend-row
  ~/  %write-extend-row
  |=  [row=row-data chals=ext-chals:chal]
  ^-  bpoly
  =/  p  print-pelt
  =/  n  (write-noun alf.chals)
  %-  init-bpoly
  %+  n  s.row
  %+  n  f.row
  %+  n  e.row
  %+  n  sf1-s.row
  %+  n  sf1-f.row
  %+  n  sf1-e.row
  %+  n  sf2-s.row
  %+  n  sf2-f.row
  %+  n  sf2-e.row
  %+  n  sf3-s.row
  %+  n  sf3-f.row
  %+  n  sf3-e.row
  %+  n  f-h.row
  %+  n  f-t.row
  %+  n  f-th.row
  %+  n  f-tt.row
  %+  n  f-tth.row
  %+  n  f-ttt.row
  %+  p  fcons-inv.row
  ~
::
++  write-mega-extend-row
  ~/  %write-mega-extend-row
  |=  state=state-data
  ^-  bpoly
  =/  p  print-pelt
  %-  init-bpoly
  %+  p  ln.state
  %+  p  sfcons-inv.state
  %+  p  opc.state
  %+  p  stack-kv.state
  %+  p  decode-mset.state
  %+  p  op0-mset.state
  ~
::
++  compute-fcons-inv
  ~/  %compute-fcons-inv
  |=  row=row-data
  ^-  pelt
  %-  pinv
  ;:  pmul
    size.f-h.row
    size.f-th.row
    size.f-tt.row
  ==
::
++  compute-sfcons-inv
  ~/  %compute-sfcons-inv
  |=  [row=row-data state=state-data chals=mega-ext-chals:chal]
  ^-  pelt
  ?:  =(1 pad.row)
    (pinv (psub z.chals ln.state))
  ?+  (need op.row)  pone
      %0
    (make-invs (psub leaf.f-t.row pone))
  ::
      %3
    (make-invs (psub alf.chals size.sf1-e.row))
  ::
      %5
    %-  pinv
    ;:  padd
      (pmul a.chals (psub size.sf1-e.row size.sf2-e.row))
      (pmul b.chals (psub dyck.sf1-e.row dyck.sf2-e.row))
      (pmul c.chals (psub leaf.sf1-e.row leaf.sf2-e.row))
      (psub pone leaf.e.row)
    ==
  ::
      %8
    (pinv (pmul size.s.row size.sf2-e.row))
  ::
      %9
    (pinv (pmul size.sf1-e.row size.sf2-e.row))
  ==
::
++  build
  ~/  %build
  |=  fock-meta=fock-return
  ^-  table-mary
  =/  queue=(list *)  queue.fock-meta
  =|  rows=(list bpoly)
  |-  ^-  table-mary
  ?:  =(0 (lent queue))
    :-  header
    %-  zing-bpolys
    %-  flop
    :_  rows
    (init-bpoly [1 (reap (dec (lent basic-column-names:static:common)) 0)])
  =|  row=row-data
  =/  f      (snag 1 queue)
  =.  queue  (slag 3 queue)
  ?>  ?=(^ f)
  =/  op     ?^(-.f %9 -.f)
  =/  ops    (~(got by op-map) op)
  =.  rows
    :_  rows
    %-  init-bpoly
    :~  0  :: pad
        o0.ops
        o1.ops
        o2.ops
        o3.ops
        o4.ops
        o5.ops
        o6.ops
        o7.ops
        o8.ops
        o9.ops
    ==
  =.  queue
    ?+  op  !!
      %0   queue
      %1   queue
      %2   (slag 2 queue)
      %3   (slag 1 queue)
      %4   (slag 1 queue)
      %5   (slag 2 queue)
      %6   (slag 3 queue)
      %7   (slag 1 queue)
      %8   (slag 2 queue)
      %9   (slag 2 queue)
    ==
  $
::
++  mega-extend
  ~/  %mega-extend
  |=  [table=table-mary all-chals=(list belt) fock-meta=fock-return]
  ^-  table-mary
  ::
  ::  challenges
  =/  chals=mega-ext-chals:chal  (init-mega-ext-chals:chal all-chals)
  =/  z=pelt-chal:constraint-util  z.chals
  =/  z2=pelt-chal:constraint-util  (pmul z z)
  =/  z3=pelt-chal:constraint-util  (pmul z2 z)
  =/  compress  (compress-nouns chals)
  =/  stack=(list tree-data)
    (build-compute-queue:fock queue.fock-meta alf.chals)
  =|  rows=(list bpoly)
  =|  state=state-data
  =.  state
    =/  [s=tree-data f=tree-data e=tree-data]
      [(snag 0 stack) (snag 1 stack) (snag 2 stack)]
    %_  state
      ln  z
      opc  z
      stack-kv  (pmul z (compress s f e))
    ==
  |-  ^-  table-mary
  ?:  =(0 (lent stack))
    :: computation is finished
    :-  header
    ::  write one final row that will contain the final kv stores and multisets
    ::  then decrement ln during padding
    =/  z-inv  (pinv z)
    =|  row=row-data
    =.  row  row(pad 1)
    =.  state  state(sfcons-inv (compute-sfcons-inv row state chals))
    =/  last-row  (write-mega-extend-row state)
    =.  rows  [last-row rows]
    %-  zing-bpolys
    %-  flop
    =-  acc
    %+  roll  (range (sub len.array.p.table (lent rows)))
    |=  [@ state=_state acc=_rows]
    =.  state  state(ln (pmul ln.state z-inv))
    =.  state  state(sfcons-inv (compute-sfcons-inv row state chals))
    :-  state
    [(write-mega-extend-row state) acc]
  ::
  =|  row=row-data
  =/  old-state  state
  =.  state      state(ln (pmul z ln.state))
  =.  s.row      (snag 0 stack)
  =.  f.row      (snag 1 stack)
  =.  e.row      (snag 2 stack)
  =.  stack      (slag 3 stack)
  =.  f-h.row
    (build-tree-data:fock -.n.f.row alf.chals)
  =.  f-t.row
    (build-tree-data:fock +.n.f.row alf.chals)
  ::
  =.  op.row  (some ?^(-.n.f.row %9 -.n.f.row))
  =.  f-th.row
    ?:  ?=(?(%2 %5 %6 %7 %8) (need op.row))
      (build-tree-data:fock -.n.f-t.row alf.chals)
    *tree-data
  =.  f-tt.row
    ?:  ?=(?(%2 %5 %6 %7 %8) (need op.row))
      (build-tree-data:fock +.n.f-t.row alf.chals)
    *tree-data
  =.  f-tth.row
    ?:  ?=(%6 (need op.row))
      (build-tree-data:fock -.n.f-tt.row alf.chals)
    *tree-data
  =.  f-ttt.row
    ?:  ?=(%6 (need op.row))
      (build-tree-data:fock +.n.f-tt.row alf.chals)
    *tree-data
  ::
  =/  [new-stack=(list tree-data) new-state=state-data new-row=row-data]
    ?+  (need op.row)  !!
        %0
      :+  stack
        %_  state
          decode-mset
            (update-decoder chals decode-mset.state f.row f-h.row f-t.row)
          op0-mset
            ?:  =(1 n.f-t.row)
              op0-mset.state  :: for axis=1 don't use memory table
            (update-mset chals op0-mset.state s.row f-t.row e.row)
        ==
      row
    ::
        %1
      :+  stack
        %_  state
          decode-mset
            (update-decoder chals decode-mset.state f.row f-h.row f-t.row)
        ==
      row
    ::
        %2
      =/  sf1-e  (snag 0 stack)
      =/  sf2-e  (snag 1 stack)
      =.  opc.state  (pmul opc.state z3)
      =.  decode-mset.state
        (update-decoder chals decode-mset.state f.row f-h.row f-t.row)
      =.  decode-mset.state
        (update-decoder chals decode-mset.state f-t.row f-th.row f-tt.row)
      :+  (slag 2 stack)
        state
      %_  row
        sf1-s  s.row
        sf1-f  f-th.row
        sf1-e  sf1-e
        sf2-s  s.row
        sf2-f  f-tt.row
        sf2-e  sf2-e
        sf3-s  sf1-e
        sf3-f  sf2-e
        sf3-e  e.row
      ==
    ::
        %3
      =/  sf1-e  (snag 0 stack)
      :+   (slag 1 stack)
        %_  state
          opc  (pmul opc.state z)
          decode-mset
            (update-decoder chals decode-mset.state f.row f-h.row f-t.row)
        ==
      %_  row
        sf1-s  s.row
        sf1-f  f-t.row
        sf1-e  sf1-e
      ==
    ::
        %4
      =/  sf1-e  (snag 0 stack)
      :+   (slag 1 stack)
        %_  state
          opc  (pmul opc.state z)
          decode-mset
            (update-decoder chals decode-mset.state f.row f-h.row f-t.row)
        ==
      %_  row
        sf1-s  s.row
        sf1-f  f-t.row
        sf1-e  sf1-e
      ==
    ::
        %5
      =/  sf1-e  (snag 0 stack)
      =/  sf2-e  (snag 1 stack)
      =.  opc.state  (pmul opc.state z2)
      =.  decode-mset.state
        (update-decoder chals decode-mset.state f.row f-h.row f-t.row)
      =.  decode-mset.state
        (update-decoder chals decode-mset.state f-t.row f-th.row f-tt.row)
      :+  (slag 2 stack)
        state
      %_  row
        sf1-s  s.row
        sf1-f  f-th.row
        sf1-e  sf1-e
        sf2-s  s.row
        sf2-f  f-tt.row
        sf2-e  sf2-e
      ==
    ::
        %6
      =/  sf1-f  (snag 0 stack)
      =/  sf1-e  (snag 1 stack)
      =/  sf2-e  (snag 2 stack)
      =.  opc.state  (pmul opc.state z2)
      =.  decode-mset.state
        (update-decoder chals decode-mset.state f.row f-h.row f-t.row)
      =.  decode-mset.state
        (update-decoder chals decode-mset.state f-t.row f-th.row f-tt.row)
      =.  decode-mset.state
        (update-decoder chals decode-mset.state f-tt.row f-tth.row f-ttt.row)
      :+  (slag 3 stack)
        state
      %_  row
        sf1-s  s.row
        sf1-f  sf1-f
        sf1-e  sf1-e
        sf2-s  s.row
        sf2-f  f-th.row
        sf2-e  sf2-e
      ==
    ::
        %7
      =/  sf2-e  (snag 0 stack)
      =.  opc.state  (pmul opc.state z2)
      =.  decode-mset.state
        (update-decoder chals decode-mset.state f.row f-h.row f-t.row)
      =.  decode-mset.state
        (update-decoder chals decode-mset.state f-t.row f-th.row f-tt.row)
      :+  (slag 1 stack)
        state
      %_  row
        sf1-s  sf2-e
        sf1-f  f-tt.row
        sf1-e  e.row
        sf2-s  s.row
        sf2-f  f-th.row
        sf2-e  sf2-e
      ==
    ::
        %8
      =/  sf1-s  (snag 0 stack)
      =/  sf2-e  (snag 1 stack)
      =.  opc.state  (pmul opc.state z2)
      =.  decode-mset.state
        (update-decoder chals decode-mset.state f.row f-h.row f-t.row)
      =.  decode-mset.state
        (update-decoder chals decode-mset.state f-t.row f-th.row f-tt.row)
      :+  (slag 2 stack)
        state(opc (pmul opc.state z2))
      %_  row
        sf1-s  sf1-s
        sf1-f  f-tt.row
        sf1-e  e.row
        sf2-s  s.row
        sf2-f  f-th.row
        sf2-e  sf2-e
      ==
    ::
        %9
      =/  left-e  (snag 0 stack)
      =/  right-e  (snag 1 stack)
      :+  (slag 2 stack)
        %_  state
          opc  (pmul opc.state z2)
          decode-mset
            (update-decoder chals decode-mset.state f.row f-h.row f-t.row)
        ==
      %_  row
        sf1-s  s.row
        sf1-f  f-h.row
        sf1-e  left-e
        sf2-s  s.row
        sf2-f  f-t.row
        sf2-e  right-e
      ==
    ::
    ==
    =.  stack  new-stack
    =.  state  new-state
    =.  row  new-row
    =.  old-state  old-state(sfcons-inv (compute-sfcons-inv row old-state chals))
    =.  stack-kv.state  (update-stack old-state row chals)
    =.  rows
      :_  rows
      (write-mega-extend-row old-state)
    $
::
++  extend
  ~/  %extend
  |=  [table=table-mary chals-rd1=(list belt) fock-meta=fock-return]
  ^-  table-mary
  ::
  ::  challenges
  =/  chals=ext-chals:chal  (init-ext-chals:chal chals-rd1)
  ::
  ::
  =/  stack=(list tree-data)
    (build-compute-queue:fock queue.fock-meta alf.chals)
  =|  rows=(list bpoly)
  |-  ^-  table-mary
  ?:  =(0 (lent stack))
    :-  header
    =/  last-row
      (init-bpoly (reap (lent ext-column-names:static:common) 0))
    %-  zing-bpolys
    %+  weld
      (flop rows)
    (reap (sub len.array.p.table (lent rows)) last-row)
  =|  row=row-data
  =.  s.row      (snag 0 stack)
  =.  f.row      (snag 1 stack)
  =.  e.row      (snag 2 stack)
  =.  stack      (slag 3 stack)
  =.  f-h.row
    (build-tree-data:fock -.n.f.row alf.chals)
  =.  f-t.row
    (build-tree-data:fock +.n.f.row alf.chals)
  ::
  =.  op.row  (some ?^(-.n.f.row %9 -.n.f.row))
  =.  f-th.row
    ?:  ?=(?(%2 %5 %6 %7 %8) (need op.row))
      (build-tree-data:fock -.n.f-t.row alf.chals)
    *tree-data
  =.  f-tt.row
    ?:  ?=(?(%2 %5 %6 %7 %8) (need op.row))
      (build-tree-data:fock +.n.f-t.row alf.chals)
    *tree-data
  =.  f-tth.row
    ?:  ?=(%6 (need op.row))
      (build-tree-data:fock -.n.f-tt.row alf.chals)
    *tree-data
  =.  f-ttt.row
    ?:  ?=(%6 (need op.row))
      (build-tree-data:fock +.n.f-tt.row alf.chals)
    *tree-data
  ::
  =/  [new-stack=(list tree-data) new-row=row-data]
    ?+  (need op.row)  !!
        %0
      :-  stack
      row
    ::
        %1
      :-  stack
      row
    ::
        %2
      =/  sf1-e  (snag 0 stack)
      =/  sf2-e  (snag 1 stack)
      :-  (slag 2 stack)
      %_  row
        sf1-s  s.row
        sf1-f  f-th.row
        sf1-e  sf1-e
        sf2-s  s.row
        sf2-f  f-tt.row
        sf2-e  sf2-e
        sf3-s  sf1-e
        sf3-f  sf2-e
        sf3-e  e.row
      ==
    ::
        %3
      =/  sf1-e  (snag 0 stack)
      :-   (slag 1 stack)
      %_  row
        sf1-s  s.row
        sf1-f  f-t.row
        sf1-e  sf1-e
      ==
    ::
        %4
      =/  sf1-e  (snag 0 stack)
      :-   (slag 1 stack)
      %_  row
        sf1-s  s.row
        sf1-f  f-t.row
        sf1-e  sf1-e
      ==
    ::
        %5
      =/  sf1-e  (snag 0 stack)
      =/  sf2-e  (snag 1 stack)
      :-  (slag 2 stack)
      %_  row
        sf1-s  s.row
        sf1-f  f-th.row
        sf1-e  sf1-e
        sf2-s  s.row
        sf2-f  f-tt.row
        sf2-e  sf2-e
      ==
    ::
        %6
      =/  sf1-f  (snag 0 stack)
      =/  sf1-e  (snag 1 stack)
      =/  sf2-e  (snag 2 stack)
      :-  (slag 3 stack)
      %_  row
        sf1-s  s.row
        sf1-f  sf1-f
        sf1-e  sf1-e
        sf2-s  s.row
        sf2-f  f-th.row
        sf2-e  sf2-e
      ==
    ::
        %7
      =/  sf2-e  (snag 0 stack)
      :-  (slag 1 stack)
      %_  row
        sf1-s  sf2-e
        sf1-f  f-tt.row
        sf1-e  e.row
        sf2-s  s.row
        sf2-f  f-th.row
        sf2-e  sf2-e
      ==
    ::
        %8
      =/  sf1-s  (snag 0 stack)
      =/  sf2-e  (snag 1 stack)
      :-  (slag 2 stack)
      %_  row
        sf1-s  sf1-s
        sf1-f  f-tt.row
        sf1-e  e.row
        sf2-s  s.row
        sf2-f  f-th.row
        sf2-e  sf2-e
      ==
    ::
        %9
      =/  left-e  (snag 0 stack)
      =/  right-e  (snag 1 stack)
      :-  (slag 2 stack)
      %_  row
        sf1-s  s.row
        sf1-f  f-h.row
        sf1-e  left-e
        sf2-s  s.row
        sf2-f  f-t.row
        sf2-e  right-e
      ==
    ::
    ==
    =.  stack  new-stack
    =.  row
      %_  new-row
        fcons-inv  (compute-fcons-inv new-row)
      ==
    =.  rows
      :_  rows
      (write-extend-row row chals)
    $
::
++  funcs
  ^-  table-funcs
  ~%  %funcs  ..grab  ~
  |%
  ++  build
    ~/  %build
    |=  fock-meta=fock-return
    ^-  table-mary
    (^build +<)
  ::
  ++  extend
    ~/  %extend
    |=  [table=table-mary challenges=(list belt) fock-meta=fock-return]
    ^-  table-mary
    ::~&  %outer-extend
    (^extend +<)
  ::
  ++  mega-extend
    ~/  %mega-extend
    |=  [table=table-mary challenges=(list belt) fock-meta=fock-return]
    ^-  table-mary
    (^mega-extend +<)
  ::
  ++  pad
    ~/  %pad
    |=  table=table-mary
    ^-  table-mary
    =/  height  (height-mary:tlib p.table)
    =/  rows  p.table
    =/  offset  (sub height len.array.rows)
    ?:  =(0 offset)
      table
    =/  pad-row=bpoly
      %-  init-bpoly
      :-  1
      (reap (dec (lent basic-column-names:static:common)) 0)
    =;  padding=mary
      table(p (~(weld ave rows) padding))
    %-  zing-bpolys
    (reap offset pad-row)
  ::
  ++  terminal
    ~/  %terminal
    |=  =table-mary
    ^-  bpoly
    =/  pr  print-pelt
    =/  first-row  (~(snag-as-bpoly ave p.table-mary) 0)
    =/  last-row  [step.p.table-mary ~(rear ave p.table-mary)]
    %-  init-bpoly
    %+  pr  (grab-pelt %s-size first-row)
    %+  pr  (grab-pelt %s-leaf first-row)
    %+  pr  (grab-pelt %s-dyck first-row)
    %+  pr  (grab-pelt %f-size first-row)
    %+  pr  (grab-pelt %f-leaf first-row)
    %+  pr  (grab-pelt %f-dyck first-row)
    %+  pr  (grab-pelt %e-size first-row)
    %+  pr  (grab-pelt %e-leaf first-row)
    %+  pr  (grab-pelt %e-dyck first-row)
    %+  pr  (grab-pelt %decode-mset last-row)
    %+  pr  (grab-pelt %op0-mset last-row)
    ~
  ::
  ++  boundary-constraints    boundary-constraints:funcs:engine:verifier-compute
  ++  row-constraints         row-constraints:funcs:engine:verifier-compute
  ++  transition-constraints  transition-constraints:funcs:engine:verifier-compute
  ++  terminal-constraints    terminal-constraints:funcs:engine:verifier-compute
  ++  extra-constraints       extra-constraints:funcs:engine:verifier-compute
  --
--
