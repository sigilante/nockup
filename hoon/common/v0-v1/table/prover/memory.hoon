/=  common  /common/v0-v1/table/memory
/=  verifier-memory  /common/v0-v1/table/verifier/memory
/=  *  /common/zeke
=/  util  constraint-util
~%  %memory-table-v0-v1  ..ride  ~
|%
+$  ion-triple-alt  [size=pelt dyck=pelt leaf=pelt]
+$  memory-bank
  $:(n=^ ax=@ op-l=@ op-r=@)
+$  memory-bank-ex
  $:  parent=ion-triple-alt
      left=ion-triple-alt
      right=ion-triple-alt
  ==
::
::
++  ids
  |%
  ::  belts
  ++  pad-idx            0
  ++  axis-idx           1
  ++  axis-ioz-idx       2
  ++  axis-flag-idx      3
  ++  leaf-l-idx         4
  ++  leaf-r-idx         5
  ++  op-l-idx           6
  ++  op-r-idx           7
  ++  count-idx          8
  ++  count-inv-idx      9
  ++  dmult-idx          10
  ++  mult-idx           11
  ++  mult-lc-idx        12
  ++  mult-rc-idx        13
  ::  pelts
  ++  input-idx          14
  ++  parent-size-idx    17
  ++  parent-dyck-idx    20
  ++  parent-leaf-idx    23
  ++  lc-size-idx        26
  ++  lc-dyck-idx        29
  ++  lc-leaf-idx        32
  ++  rc-size-idx        35
  ++  rc-dyck-idx        38
  ++  rc-leaf-idx        41
  ++  inv-idx            44
  ::  mega-ext
  ++  ln-idx             47
  ++  nc-idx             50
  ++  kvs-idx            53
  ++  kvs-ioz-idx        56
  ++  kvsf-idx           59
  ++  decode-mset-idx    62
  ++  op0-mset-idx       65
  ++  data-k-idx         68
  --
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
  =/  base-table=table-mary  (pad:funcs (build:funcs q.dat))
  =/  ext-table  (extend:funcs base-table ext-chals q.dat)
  =/  mid-table  (weld-exts:tlib base-table ext-table)
  =/  mega-ext-table  (mega-extend:funcs mid-table mega-ext-chals q.dat)
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
::
::  gen-nock
::
::     generates nock=[s f], parametrized by n, which evaluates to prod
::     s.t. the Nock reduction rules only use Nock 2 and Nock 0's into
::     the subject s
++  gen-nock
  ~/  %gen-nock
  |=  [n=@ prod=*]
  |^
  =+  %+  roll  (reap n 0)
      |=  [i=@ accx=_2 axs=(list @)]
      =/  new-accx  (mul 2 +(accx))
      :-  new-accx
      [new-accx axs]
  :_  (sf 2)
  %+  roll  axs
  |=  [a=@ nock=_`*`[[0 +(accx)] prod]]
  ^-  ^
  [(sf a) nock]
  ++  sf
    |=  a=@
    ^-  *
    [2 [0 1] [0 a]]
  --
::
++  bioz
  ~/  %bioz
  |=  b=belt
  ^-  belt
  ?:(=(b 0) 0 (binv b))
::
++  pioz
  ~/  %pioz
  |=  p=pelt
  ^-  pelt
  ?:(=(p pzero) pzero (pinv p))
::
++  ifp-compress
  ~/  %ifp-compress
  |=  [ifp=ion-triple-alt a=pelt b=pelt c=pelt]
  ^-  pelt
  :(padd (pmul a size.ifp) (pmul b dyck.ifp) (pmul c leaf.ifp))
::
++  variable-indices
  ^-  (map col-name @)  ^~
  %-  ~(gas by *(map term @))
  (zip-up column-names:static:common (range (lent column-names:static:common)))
::
++  grab
  ~/  %grab
  |=  [idx=@ =row]
  ^-  belt
  (~(snag bop row) idx)
::
++  grab-pelt
  ~/  %grab-pelt
  |=  [idx=@ =row]
  ^-  pelt
  dat:(~(swag bop row) idx 3)
::
::  bft: breadth-first traversal
++  bft
  ~/  %bft
  |=  tres=(list *)
  ^-  (list *)
  =/  qu=(list *)  tres
  =|  out=(list *)
  |-
  ?~  qu
    (flop out)
  =+  %+  roll  `(list *)`qu
      |=  [q=* nu-qu=(list *) nu-out=_out]
      ^-  [(list *) (list *)]
      ?@  q  [nu-qu [q nu-out]]
      [[+:q -:q nu-qu] [q nu-out]]
  $(qu (flop nu-qu), out nu-out)
::
::  na-bft: non-atomic breadth-first traversal
::
::    i.e. only internal nodes are counted, not atoms.
++  na-bft
  ~/  %na-bft
  |=  tres=(list *)
  ^-  (list ^)
  =/  qu=(list ^)
    %-  flop
    %+  roll  tres
    |=  [n=* acc=(list ^)]
    ?@  n  acc  [n acc]
  =|  out=(list ^)
  |-
  ?~  qu
    (flop out)
  =-  $(qu (flop nu-qu), out nu-out)
  %+  roll  `(list ^)`qu
  |=  [q=^ nu-qu=(list ^) nu-out=_out]
  ^-  [(list ^) (list ^)]
  ?@  -.q
    ?@  +.q
      [nu-qu [q nu-out]]
    [[+.q nu-qu] [q nu-out]]
  ?@  +.q
    [[-.q nu-qu] [q nu-out]]
  [[+.q -.q nu-qu] [q nu-out]]
::
::  bfta: breadth-first traversal w/ axis labelling
++  bfta
  ~/  %bfta
  |=  tres=(list *)
  ^-  (list [* @])
  =/  qu=(list [* @])  (turn tres |=(n=* [n 1]))
  =|  out=(list [* @])
  |-
  ?~  qu
    (flop out)
  =+  %+  roll  `(list [* @])`qu
      |=  [q=[n=* a=@] nu-qu=(list [* @]) nu-out=_out]
      ^-  [(list [* @]) (list [* @])]
      ?@  n.q  [nu-qu [q nu-out]]
      [[[+.n.q (succ (mul 2 a.q))] [-.n.q (mul 2 a.q)] nu-qu] [q nu-out]]
  $(qu (flop nu-qu), out nu-out)
::
++  go-left
  ~/  %go-left
  |=  a=@
  (mul 2 a)
::
++  go-right
  ~/  %go-right
  |=  a=@
  ?:(=(a 0) 0 (succ (mul 2 a)))
::
::  rna-bfta: reversed non-atomic breadth-first traversal w axes
::
::    Returns the breadth-first traversal in reverse order bc the output is
::    piped to add-ions, which is most efficient if constructed from the bottom
::    of the tree to the top.
++  rna-bfta
  ~/  %rna-bfta
  |=  tres=(list [* ?])
  ^-  (list memory-bank)
  =/  qu=(list [^ @])
    %-  flop
    %+  roll  tres
    |=  [[n=* f=?] acc=(list [^ @])]
    ?@  n  acc
    ?:(f [[n 1] acc] [[n 0] acc])
  =|  mbl=(list memory-bank)
  |-
  ?~  qu
    mbl
  =-  $(qu (flop nu-qu), mbl nu-mbl)
  %+  roll  `(list [^ @])`qu
  |=  [[n=^ a=@] nu-qu=(list [^ @]) nu-mbl=_mbl]
  ^-  [(list [^ @]) (list memory-bank)]
  ?@  -.n
    ?@  +.n
      [nu-qu [[n a 0 0] nu-mbl]]
    [[[+.n (go-right a)] nu-qu] [[n a 0 1] nu-mbl]]
  ?@  +.n
    [[[-.n (go-left a)] nu-qu] [[n a 1 0] nu-mbl]]
  [[[+.n (go-right a)] [-.n (go-left a)] nu-qu] [[n a 1 1] nu-mbl]]
::
::  add-ions: adds ions to the output of rna-bfta
++  add-ions
  ~/  %add-ions
  |=  $:  rna-bfta-lst=(list memory-bank)
          alf=pelt
          a=pelt  b=pelt  c=pelt
          d=pelt
          e=pelt  f=pelt  g=pelt
      ==
  ^-  (list memory-bank-ex)
  =-  ion-list
  %+  roll  rna-bfta-lst
  |=  $:  mb=memory-bank
          ion-map=(map * ion-triple-alt)
          ion-list=(list memory-bank-ex)
      ==
  =/  left=ion-triple-alt
    ?@  -.n.mb  (atom-ion -.n.mb alf)
    (~(got by ion-map) -.n.mb)
  =/  right=ion-triple-alt
    ?@  +.n.mb  (atom-ion +.n.mb alf)
    (~(got by ion-map) +.n.mb)
  =/  parent  (cons-ion alf left right)
  :*  (~(put by ion-map) [n.mb parent])
      :_  ion-list
      [parent left right]
  ==
::
++  atom-ion
  ~/  %atom-ion
  |=  [atom=@ alf=pelt]
  ^-  ion-triple-alt
  :+  alf
    pzero
  (pelt-lift atom)
::
::  +cons-ion: cons of 2 ion triples of nouns.
++  cons-ion
  ~/  %cons-ion
  |=  [alf=pelt left=ion-triple-alt right=ion-triple-alt]
  ^-  ion-triple-alt
  =/  alfinv=pelt  (pinv alf)
  :+  (pmul size.left size.right)
  ::
    ;:  padd
      :(pmul size.right size.right alfinv dyck.left)
      :(pmul size.right size.right alfinv alfinv)
      dyck.right
    ==
  ::
  (padd (pmul size.right leaf.left) leaf.right)
::
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
++  num-randomizers  1
::
++  funcs
  ^-  table-funcs
  ~%  %funcs  ..grab  ~
  |%
  ::
  ++  build
    ~/  %build
    |=  return=fock-return
    ^-  table-mary
    =/  in  [s.return f.return]
    =/  mult-mp=(map [* *] @)  (~(gut by zeroes.return) -.in *(map [* *] @))
    =/  traversal  (rna-bfta ~[[s.return %.y] [f.return %.n]])
    =/  len-traversal  (lent traversal)
    =/  end
      (init-bpoly ~[0 0 0 0 0 0 0 0 +(len-traversal) (binv +(len-traversal)) 0 0 0 0])
    =-  [header (zing-bpolys mtx)]
    %+  roll  traversal
    |=  [mb=memory-bank ct=_len-traversal mtx=_`matrix`~[end]]
    ^-  [belt matrix]
    :-  (dec ct)
    :_  mtx
    %-  init-bpoly
    :~  1  ax.mb  (bioz ax.mb)  ?:(=(ax.mb 0) 0 1)
      ::
        ?:(?=(@ -.n.mb) -.n.mb 0)  ?:(?=(@ +.n.mb) +.n.mb 0)
      ::
        op-l.mb  op-r.mb  ct  (binv ct)
      ::
        ?:  !=(ax.mb 0)  0
        ?:((~(has by decodes.return) [n.mb -:n.mb +:n.mb]) 1 0)
      ::
        ?:  =(ax.mb 1)  0
        (~(gut by mult-mp) [ax.mb -.in] 0)
      ::
        ?.  ?=(@ -.n.mb)  0
        (~(gut by mult-mp) [(go-left ax.mb) -.in] 0)
      ::
        ?.  ?=(@ +.n.mb)  0
        (~(gut by mult-mp) [(go-right ax.mb) -.in] 0)
    ==
  ::
  ++  pad
    ~/  %pad
    |=  table=table-mary
    ^-  table-mary
    =/  height  (height-mary:tlib p.table)
    ?:  =(height len.array.p.table)
      table
    =/  rows  p.table
    =/  len  len.array.rows
    ?:  =(height len)  table
    =;  padding=mary
      table(p (~(weld ave rows) padding))
    %-  zing-bpolys
    %-  head
    %^  spin  (range (sub height len))  (sub len 1)
    |=  [i=@ ct=@]
    :_  (bsub ct 1)
    (init-bpoly ~[0 0 0 0 0 0 0 0 ct (binv ct) 0 0 0 0])
  ::
  ++  extend
    ~/  %extend
    |=  [t=table-mary chals-rd1=(list belt) return=fock-return]
    ^-  table-mary
    :-  header
    =/  pr  print-pelt
    =/  tr  print-tri-mset:constraint-util
    =/  chals=ext-chals:chal  (init-ext-chals:chal chals-rd1)
    =/  len  len.array.p.t
    =/  build-and-bft=(list memory-bank-ex)
      =+  (add-ions (rna-bfta ~[[s.return %.y] [f.return %.n]]) [alf a b c d e f g]:chals)
      %+  weld  -
      %+  reap  (sub len (lent -))
      ^-  memory-bank-ex
      :*  *ion-triple-alt
          *ion-triple-alt
          *ion-triple-alt
      ==
    =/  subj-info=memory-bank-ex
      ?@  s.return  *memory-bank-ex
      (snag 0 build-and-bft)
    =/  subj-pc1
          (ifp-compress parent.subj-info [a b c]:chals)
    %-  zing-bpolys
    %+  turn  build-and-bft
    |=  mb=memory-bank-ex
    %-  init-bpoly
    %+  pr  subj-pc1
    %+  pr  size.parent.mb
    %+  pr  dyck.parent.mb
    %+  pr  leaf.parent.mb
    %+  pr  size.left.mb
    %+  pr  dyck.left.mb
    %+  pr  leaf.left.mb
    %+  pr  size.right.mb
    %+  pr  dyck.right.mb
    %+  pr  leaf.right.mb
    %+  pr
      %-  pinv
      ;:  pmul
        (psub size.parent.mb pone)
        (psub size.left.mb pone)
        (psub size.right.mb pone)
      ==
    ~
  ::
  ++  mega-extend
    ~/  %mega-extend
    |=  [table=table-mary all-chals=(list belt) return=fock-return]
    ^-  table-mary
    :-  header
    %-  zing-bpolys
    =/  pr  print-pelt
    =/  tr  print-tri-mset:constraint-util
    =/  chals=mega-ext-chals:chal  (init-mega-ext-chals:chal all-chals)
    =/  [first-row=row second-row=row]
      :-  (~(snag-as-bpoly ave p.table) 0)
      (~(snag-as-bpoly ave p.table) 1)
    =/  input  (grab-pelt input-idx:ids first-row)
    =/  first-row-ax  (grab axis-idx:ids first-row)
    =/  first-row-fp
      %-  ifp-compress
      :*  :+  (grab-pelt parent-size-idx:ids first-row)
            (grab-pelt parent-dyck-idx:ids first-row)
          (grab-pelt parent-leaf-idx:ids first-row)
          j.chals  k.chals  l.chals
      ==
    =/  second-row-ax  (grab axis-idx:ids second-row)
    =/  second-row-fp
      %-  ifp-compress
      :*  :+  (grab-pelt parent-size-idx:ids second-row)
            (grab-pelt parent-dyck-idx:ids second-row)
          (grab-pelt parent-leaf-idx:ids second-row)
          j.chals  k.chals  l.chals
      ==
    =/  subj-info=[ax=belt fp=pelt]
      ?@  s.return  [0 pzero]
      [first-row-ax first-row-fp]
    =/  form-info=[ax=belt fp=pelt]
      ?@  s.return
        [first-row-ax first-row-fp]
      [second-row-ax second-row-fp]
    =/  [input-subj-fp=pelt input-form-fp=pelt]
      :-  (padd fp.subj-info (pscal ax.subj-info m.chals))
      (padd fp.form-info (pscal ax.form-info m.chals))
    %-  head
    %^  spin  (range len.array.p.table)
      :*  z.chals
        ::
          ?@(s.return z.chals (pmul z.chals z.chals))
        ::
          (init-ld-mset-pelt:constraint-util gam.chals)
        ::
          (init-ld-mset-pelt:constraint-util bet.chals)
        ::
          ?@  s.return
            (pmul z.chals input-form-fp)
          %+  padd  (pmul z.chals input-subj-fp)
          :(pmul z.chals z.chals input-form-fp)
      ==
    |=  $:  i=@
            line-ct=pelt
            node-ct=pelt
            decode-mset=ld-mset-pelt:constraint-util
            op0-mset=ld-mset-pelt:constraint-util
            kvs=pelt
        ==
    =/  =row  (~(snag-as-bpoly ave p.table) i)
    =/  parent=ion-triple-alt
      [(grab-pelt parent-size-idx:ids row) (grab-pelt parent-dyck-idx:ids row) (grab-pelt parent-leaf-idx:ids row)]
    =/  left=ion-triple-alt
      [(grab-pelt lc-size-idx:ids row) (grab-pelt lc-dyck-idx:ids row) (grab-pelt lc-leaf-idx:ids row)]
    =/  right=ion-triple-alt
      [(grab-pelt rc-size-idx:ids row) (grab-pelt rc-dyck-idx:ids row) (grab-pelt rc-leaf-idx:ids row)]
    =/  left-is-atom  ?:(=((grab op-l-idx:ids row) 0) %.y %.n)
    =/  right-is-atom  ?:(=((grab op-r-idx:ids row) 0) %.y %.n)
    =/  ax  (grab axis-idx:ids row)
    =/  [par=pelt wt-pax=pelt]
      :-  (ifp-compress parent [j k l]:chals)
      (pscal ax m.chals)
    =/  [lc=pelt wt-lax=pelt]
      :-  (ifp-compress left [j k l]:chals)
      (pscal (go-left ax) m.chals)
    =/  [rc=pelt wt-rax=pelt]
      :-  (ifp-compress right [j k l]:chals)
      (pscal (go-right ax) m.chals)
    =/  new-line-ct  (pmul line-ct z.chals)
    =/  new-node-ct
      ?:  left-is-atom
        ?:  right-is-atom
          node-ct
        (pmul node-ct z.chals)
      ?:  right-is-atom
        (pmul node-ct z.chals)
      :(pmul node-ct z.chals z.chals)
    =/  new-kvs
      %+  psub
        ;:  padd
          kvs
        ::
          ?:  left-is-atom
            pzero
          ;:  pmul
            z.chals
            node-ct
            (padd lc wt-lax)
          ==
        ::
          ?.  ?&(left-is-atom !right-is-atom)
            pzero
          ;:  pmul
            z.chals
            node-ct
            (padd rc wt-rax)
          ==
        ::
          ?.  ?&(!left-is-atom !right-is-atom)
            pzero
          ;:  pmul
            z.chals  z.chals
            node-ct
            (padd rc wt-rax)
          ==
        ==
      (pmul (padd par wt-pax) line-ct)
    =/  new-decode-mset
      %-  rear
      %-  ~(add-all ld-pelt:constraint-util decode-mset)
      :_  ~
      :_  (grab dmult-idx:ids row)
      ;:  padd
        (pmul j.chals (grab-pelt parent-size-idx:ids row))
        (pmul k.chals (grab-pelt parent-dyck-idx:ids row))
        (pmul l.chals (grab-pelt parent-leaf-idx:ids row))
        (pmul m.chals (grab-pelt lc-size-idx:ids row))
        (pmul n.chals (grab-pelt lc-dyck-idx:ids row))
        (pmul o.chals (grab-pelt lc-leaf-idx:ids row))
        (pmul w.chals (grab-pelt rc-size-idx:ids row))
        (pmul x.chals (grab-pelt rc-dyck-idx:ids row))
        (pmul y.chals (grab-pelt rc-leaf-idx:ids row))
      ==
    =/  new-op0-mset
      %-  rear
      %-  ~(add-all ld-pelt:constraint-util op0-mset)
      ;:  weld
        ~[[:(padd input wt-pax par) (grab mult-idx:ids row)]]
      ::
        ?.  left-is-atom  ~
        ~[[:(padd input wt-lax lc) (grab mult-lc-idx:ids row)]]
      ::
        ?.  right-is-atom  ~
        ~[[:(padd input wt-rax rc) (grab mult-rc-idx:ids row)]]
      ==
    ::
    =/  data-k=pelt
      =/  p1=pelt
        ;:  padd
          (pmul j.chals line-ct)
          (pmul k.chals node-ct)
          (pmul l.chals kvs)
          (pmul m.chals (pioz kvs))
        ==
      =/  p2=pelt
        ;:  padd
          (pmul n.chals line-ct)
          (pmul o.chals node-ct)
          (pmul w.chals kvs)
          (pmul x.chals (pioz kvs))
        ==
      :(pmul p1 p2 (padd p1 p2) (pioz kvs))
    ::
    :_  [new-line-ct new-node-ct new-decode-mset new-op0-mset new-kvs]
    %-  init-bpoly
    %+  pr  line-ct
    %+  pr  node-ct
    %+  pr  kvs
    %+  pr  (pioz kvs)  ::  %kvs-ioz
    %+  pr  (pmul kvs (pioz kvs))  ::  %kvsf
    %+  pr  dat.decode-mset
    %+  pr  dat.op0-mset
    %+  pr  data-k
    ~
  ::
  ++  terminal
    ~/  %terminal
    |=  =table-mary
    ^-  bpoly
    =/  pr  print-pelt
    =/  first-row  (~(snag-as-bpoly ave p.table-mary) 0)
    =/  last-row  [step.p.table-mary ~(rear ave p.table-mary)]
    %-  init-bpoly
    %+  pr  (grab-pelt nc-idx:ids first-row)
    %+  pr  (grab-pelt kvs-idx:ids first-row)
    %+  pr  (grab-pelt decode-mset-idx:ids last-row)
    %+  pr  (grab-pelt op0-mset-idx:ids last-row)
    ~
  ::
  ++  boundary-constraints    boundary-constraints:funcs:engine:verifier-memory
  ++  row-constraints         row-constraints:funcs:engine:verifier-memory
  ++  transition-constraints  transition-constraints:funcs:engine:verifier-memory
  ++  terminal-constraints    terminal-constraints:funcs:engine:verifier-memory
  ++  extra-constraints       extra-constraints:funcs:engine:verifier-memory
  --
--
