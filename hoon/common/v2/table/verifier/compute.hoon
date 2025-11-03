/=  common  /common/v2/table/compute
/=  *  /common/zeke
=,  mp-to-mega
=,  constraint-util
|%
++  one        (mp-c 1)
++  zero       (mp-c 0)
++  one-pelt   [(mp-c 1) (mp-c 0) (mp-c 0)]
++  zero-pelt  [(mp-c 0) (mp-c 0) (mp-c 0)]
++  v  ~(v var:tlib variables:static:common)
++  w  ~(v var-pelt:tlib variables:static:common)
++  w-n  ~(v-n var-pelt:tlib variables:static:common)
++  w-c  ~(c var-pelt:tlib variables:static:common)
++  d  ~(d dyn:dyn (make-dyn-mps:dyn terminal-names:static:common))
::
+$  nounp  [size=mp-pelt dyck=mp-pelt leaf=mp-pelt]
++  make-nounp
  |=  nam=term
  ^-  nounp
  :+  (w (crip (weld (trip nam) "-size")))
    (w (crip (weld (trip nam) "-dyck")))
  (w (crip (weld (trip nam) "-leaf")))
::
::
++  zero-during-padding
  |=  [nam=term tail=(list [term mp-ultra])]
  ^-  (list [term mp-ultra])
  :_  tail
  :-  (crip (weld (trip nam) "-zero-during-padding"))
  %-  lift-to-mega
  (mpmul (v %pad) (v nam))
::
++  zero-during-padding-pelt
  |=  [nam=term tail=(list [term mp-ultra])]
  ^-  (list [term mp-ultra])
  %^  tag-mp-pelt
      (crip (weld (trip nam) "-zero-during-padding"))
    (mpscal-pelt (v %pad) (w nam))
  tail
::
++  make-cons
  |=  alf-inv=mp-pelt
  |=  [[nam=term p=term l=term r=term sel=mp-mega] tail=(list [term mp-ultra])]
  ^-  (list [term mp-ultra])
  =/  p  (make-nounp p)
  =/  l  (make-nounp l)
  =/  r  (make-nounp r)
  %^  tag-mp-pelt  (crip (weld (trip nam) "-size"))
    %+  mpscal-pelt  sel
    %+  mpsub-pelt  size.p
    (mpmul-pelt size.l size.r)
  ::
  %^  tag-mp-pelt  (crip (weld (trip nam) "-dyck"))
    %+  mpscal-pelt  sel
    %+  mpsub-pelt  dyck.p
    ;:  mpadd-pelt
      dyck.r
      :(mpmul-pelt dyck.l size.r size.r alf-inv)
      :(mpmul-pelt size.r size.r alf-inv alf-inv)
    ==
  ::
  %^  tag-mp-pelt
      (crip (weld (trip nam) "-leaf"))
    %+  mpscal-pelt  sel
    %+  mpsub-pelt  leaf.p
    %+  mpadd-pelt
      (mpmul-pelt leaf.l size.r)
    leaf.r
  ::
  tail
::
::  Set ions n=m
++  ion-equal
  |=  [[nam=term ion-l=term ion-r=term sel=mp-mega] tail=(list [term mp-ultra])]
  ^-  (list [term mp-ultra])
  =/  l  (make-nounp ion-l)
  =/  r  (make-nounp ion-r)
  %^  tag-mp-pelt  (crip (weld (trip nam) "-size"))
    %+  mpscal-pelt  sel
    (mpsub-pelt size.l size.r)
  ::
  %^  tag-mp-pelt  (crip (weld (trip nam) "-leaf"))
    %+  mpscal-pelt  sel
    (mpsub-pelt leaf.l leaf.r)
  ::
  %^  tag-mp-pelt  (crip (weld (trip nam) "-dyck"))
    %+  mpscal-pelt  sel
    (mpsub-pelt dyck.l dyck.r)
  ::
  tail
::
::  set ion to be 0
++  zero-ion
  |=  [[nam=term ion=term sel=mp-mega] tail=(list [term mp-ultra])]
  ^-  (list [term mp-ultra])
  %^  tag-mp-pelt  (crip (weld (trip nam) "-s-size"))
    %+  mpscal-pelt  sel
    (mpsub-pelt (w (crip (weld (trip ion) "-s-size"))) one-pelt)
  ::
  %^  tag-mp-pelt  (crip (weld (trip nam) "-s-leaf"))
    %+  mpscal-pelt  sel
    (mpsub-pelt (w (crip (weld (trip ion) "-s-leaf"))) zero-pelt)
  ::
  %^  tag-mp-pelt  (crip (weld (trip nam) "-s-dyck"))
    %+  mpscal-pelt  sel
    (mpsub-pelt (w (crip (weld (trip ion) "-s-dyck"))) zero-pelt)
  ::
  %^  tag-mp-pelt  (crip (weld (trip nam) "-f-size"))
    %+  mpscal-pelt  sel
    (mpsub-pelt (w (crip (weld (trip ion) "-f-size"))) one-pelt)
  ::
  %^  tag-mp-pelt  (crip (weld (trip nam) "-f-leaf"))
    %+  mpscal-pelt  sel
    (mpsub-pelt (w (crip (weld (trip ion) "-f-leaf"))) zero-pelt)
  ::
  %^  tag-mp-pelt  (crip (weld (trip nam) "-f-dyck"))
    %+  mpscal-pelt  sel
    (mpsub-pelt (w (crip (weld (trip ion) "-f-dyck"))) zero-pelt)
  ::
  %^  tag-mp-pelt  (crip (weld (trip nam) "-e-size"))
    %+  mpscal-pelt  sel
    (mpsub-pelt (w (crip (weld (trip ion) "-e-size"))) one-pelt)
  ::
  %^  tag-mp-pelt  (crip (weld (trip nam) "-e-leaf"))
    %+  mpscal-pelt  sel
    (mpsub-pelt (w (crip (weld (trip ion) "-e-leaf"))) zero-pelt)
  ::
  %^  tag-mp-pelt  (crip (weld (trip nam) "-e-dyck"))
    %+  mpscal-pelt  sel
    (mpsub-pelt (w (crip (weld (trip ion) "-e-dyck"))) zero-pelt)
  ::
  tail
::
++  engine
  |%
  ::
  ++  funcs
    ^-  verifier-funcs
    |%
    ++  boundary-constraints
      ^-  (map term mp-ultra)
      =,  constraint-util
      =/  r   ~(r rnd:chal:chal (make-chal-mps:chal chal-names-all:chal))
      =/  z=mp-pelt  (r %z)
      =/  a=mp-pelt    (r %a)
      =/  b=mp-pelt    (r %b)
      =/  c=mp-pelt    (r %c)
      =/  d-chal=mp-pelt    (r %d)
      =/  e=mp-pelt    (r %e)
      =/  f=mp-pelt    (r %f)
      =/  j=mp-pelt    (r %j)
      =/  k=mp-pelt    (r %k)
      =/  l=mp-pelt    (r %l)
      =/  m=mp-pelt    (r %m)
      =/  n=mp-pelt    (r %n)
      =/  o=mp-pelt    (r %o)
      ::
      %-  roll
      :_  |=  [[nam=col-name mp=mp-ultra] constraints=(map col-name mp-ultra)]
          ::  asserts we haven't seen this name before to prevent
          ::  constraint overwriting in the case of accidental name doubling
          ?>  ?=(~ (~(get by constraints) nam))
          (~(put by constraints) [nam mp])
      ^-  (list [col-name mp-ultra])
      ::
      :-  :-  %pad-starts-at-0
        (lift-to-mega (v %pad))
      ::
      %^  tag-mp-pelt  %opc-starts-at-z
        (mpsub-pelt z (w %opc))
      ::
      %^  tag-mp-pelt  %ln-starts-at-z
        (mpsub-pelt z (w %ln))
      ::
      %^  tag-mp-pelt  %op0-decode-starts-at-0
        (w %decode-mset)
      ::
      %^  tag-mp-pelt  %op0-mset-starts-at-0
        (w %op0-mset)
      ::
      %^  tag-mp-pelt  %kv-store-starts-with-input
        %+  mpsub-pelt  (w %stack-kv)
        %+  mpmul-pelt  z
        ;:  mpadd-pelt
          %+  mpmul-pelt  m
          ;:  mpadd-pelt
            (mpmul-pelt j (w %s-size))
            (mpmul-pelt k (w %s-dyck))
            (mpmul-pelt l (w %s-leaf))
          ==
        ::
          %+  mpmul-pelt  n
          ;:  mpadd-pelt
            (mpmul-pelt j (w %f-size))
            (mpmul-pelt k (w %f-dyck))
            (mpmul-pelt l (w %f-leaf))
          ==
        ::
          %+  mpmul-pelt  o
          ;:  mpadd-pelt
            (mpmul-pelt j (w %e-size))
            (mpmul-pelt k (w %e-dyck))
            (mpmul-pelt l (w %e-leaf))
          ==
        ==
      ::
      %^  tag-mp-pelt  %compute-s-size-input
        (mpsub-pelt (w %s-size) (d %compute-s-size))
      ::
      %^  tag-mp-pelt  %compute-s-dyck-input
        (mpsub-pelt (w %s-dyck) (d %compute-s-dyck))
      ::
      %^  tag-mp-pelt  %compute-s-leaf-input
        (mpsub-pelt (w %s-leaf) (d %compute-s-leaf))
      ::
      %^  tag-mp-pelt  %compute-f-size-input
        (mpsub-pelt (w %f-size) (d %compute-f-size))
      ::
      %^  tag-mp-pelt  %compute-f-dyck-input
        (mpsub-pelt (w %f-dyck) (d %compute-f-dyck))
      ::
      %^  tag-mp-pelt  %compute-f-leaf-input
        (mpsub-pelt (w %f-leaf) (d %compute-f-leaf))
      ::
      %^  tag-mp-pelt  %compute-e-size-input
        (mpsub-pelt (w %e-size) (d %compute-e-size))
      ::
      %^  tag-mp-pelt  %compute-e-dyck-input
        (mpsub-pelt (w %e-dyck) (d %compute-e-dyck))
      ::
      %^  tag-mp-pelt  %compute-e-leaf-input
        (mpsub-pelt (w %e-leaf) (d %compute-e-leaf))
      ~
    ::
    ++  terminal-constraints
      ^-  (map term mp-ultra)
      =,  constraint-util
      :: stack kv must be 0 at end
      %-  roll
      :_  |=  [[nam=col-name mp=mp-ultra] constraints=(map col-name mp-ultra)]
          ::  asserts we haven't seen this name before to prevent
          ::  constraint overwriting in the case of accidental name doubling
          ?>  ?=(~ (~(get by constraints) nam))
          (~(put by constraints) [nam mp])
      ^-  (list [col-name mp-ultra])
      ::
      %^  tag-mp-pelt  %stack-kv-end-0
        (w %stack-kv)
      ::
      %^  tag-mp-pelt  %compute-decode-mset-output
        (mpsub-pelt (w %decode-mset) (d %compute-decode-mset))
      ::
      %^  tag-mp-pelt  %compute-op0-mset-output
        (mpsub-pelt (w %op0-mset) (d %compute-op0-mset))
      ~
    ::
    ++  row-constraints
      ^-  (map term mp-ultra)
      =,  chal
      =,  constraint-util
      =/  r   ~(r rnd:chal:chal (make-chal-mps:chal chal-names-all:chal))
      =/  a=mp-pelt    (r %a)
      =/  b=mp-pelt    (r %b)
      =/  c=mp-pelt    (r %c)
      =/  d=mp-pelt    (r %d)
      =/  e=mp-pelt    (r %e)
      =/  f=mp-pelt    (r %f)
      =/  g=mp-pelt    (r %g)
      =/  alf=mp-pelt  (r %alf)    :: ion
      =/  alf-inv=mp-pelt  (r %inv-alf)    :: ion
      =/  bet=mp-pelt  (r %bet)  :: multiset
      =/  z=mp-pelt    (r %z)    :: kv store
      =/  z2=mp-pelt   (mpmul-pelt z z)
      =/  z3=mp-pelt   (mpmul-pelt z2 z)
      =/  make-cons  (make-cons alf-inv)
      =/  pd  zero-during-padding
      =/  pd-pelt  zero-during-padding-pelt
      ::
      %-  roll
      :_  |=  [[nam=col-name mp=mp-ultra] constraints=(map col-name mp-ultra)]
          ::  asserts we haven't seen this name before to prevent
          ::  constraint overwriting in the case of accidental name doubling
          ?>  ?=(~ (~(get by constraints) nam))
          (~(put by constraints) [nam mp])
      ^-  (list [col-name mp-ultra])
      ::
      ::  Indexing & Selector Constraints
      ::
      :: opcode flags must be binary
      :: o0(1-o0)=0 ...
      :-  :-  %op0
          %-  lift-to-mega
          (mpmul (v %op0) (mpsub one (v %op0)))
      :-  :-  %op1
          %-  lift-to-mega
          (mpmul (v %op1) (mpsub one (v %op1)))
      :-  :-  %op2
          %-  lift-to-mega
          (mpmul (v %op2) (mpsub one (v %op2)))
      :-  :-  %op3
          %-  lift-to-mega
          (mpmul (v %op3) (mpsub one (v %op3)))
      :-  :-  %op4
          %-  lift-to-mega
          (mpmul (v %op4) (mpsub one (v %op4)))
      :-  :-  %op5
          %-  lift-to-mega
          (mpmul (v %op5) (mpsub one (v %op5)))
      :-  :-  %op6
          %-  lift-to-mega
          (mpmul (v %op6) (mpsub one (v %op6)))
      :-  :-  %op7
          %-  lift-to-mega
          (mpmul (v %op7) (mpsub one (v %op7)))
      :-  :-  %op8
          %-  lift-to-mega
          (mpmul (v %op8) (mpsub one (v %op8)))
      :-  :-  %op9
          %-  lift-to-mega
          (mpmul (v %op9) (mpsub one (v %op9)))
      ::
      :: only one opcode flag can be 1 so they must sum to (1 - pad)
      :-  :-  %opflags-add-to-one
        %-  lift-to-mega
        %+  mpsub  (mpsub one (v %pad))
        ;:  mpadd
          (v %op0)  (v %op1)  (v %op2)  (v %op3)  (v %op4)
          (v %op5)  (v %op6)  (v %op7)  (v %op8)  (v %op9)
        ==
      ::
      ::
      ::  Opcode Selector Constraints
      ::
      ::  This constraint needs to ensure that the correct opcode is chosen and agrees
      ::  with the initial formula decomposition for j ∈ {0, ..., 8}, remaining
      ::  unconstrained for cons operations (opcode 9).
      ::
      %^  tag-mp-pelt  %f-h-size-opcode
        %+  mpsub-pelt
          (mpscal-pelt (mpsub one (v %op9)) (w %f-h-size))
        %-  mpscal-pelt
        :_  alf
        ;:  mpadd
          (v %op0)  (v %op1)  (v %op2)  (v %op3)  (v %op4)
          (v %op5)  (v %op6)  (v %op7)  (v %op8)
        ==
      ::
      %^  tag-mp-pelt  %f-h-leaf-opcode
        %+  mpsub-pelt
          (mpscal-pelt (mpsub one (v %op9)) (w %f-h-leaf))
        %-  lift-to-mp-pelt
        ;:  mpadd
          (v %op1)
          (mpmul (mp-c 2) (v %op2))  (mpmul (mp-c 3) (v %op3))  (mpmul (mp-c 4) (v %op4))
          (mpmul (mp-c 5) (v %op5))  (mpmul (mp-c 6) (v %op6))  (mpmul (mp-c 7) (v %op7))
          (mpmul (mp-c 8) (v %op8))
        ==
      ::
      %^  tag-mp-pelt  %f-h-dyck-opcode
        (mpscal-pelt (mpsub one (v %op9)) (w %f-h-dyck))
      ::
      ::
      ::
      %^  tag-mp-pelt  %fcons-inv
        %+  mpsub-pelt
          (lift-to-mp-pelt (mpsub one (v %pad)))
        ;:  mpmul-pelt
          (w %f-h-size)
          (w %f-th-size)
          (w %f-tt-size)
          (w %fcons-inv)
        ==
      ::
      %^  tag-mp-pelt  %sfcons-inv
        %-  mpsub-pelt
        :_  (lift-to-mp-pelt (mpsub one (mpadd (v %op0) (v %op3))))
        ;:  mpadd-pelt
          %+  mpscal-pelt  (v %op8)
          ;:  mpmul-pelt
            (w %s-size)
            (w %sf2-e-size)
            (w %sfcons-inv)
          ==
        ::
          %+  mpscal-pelt  (v %op9)
          ;:  mpmul-pelt
            (w %sf1-e-size)
            (w %sf2-e-size)
            (w %sfcons-inv)
          ==
        ::
          %+  mpscal-pelt  (v %op5)
          ;:  mpmul-pelt
            (w %sfcons-inv)
            ;:  mpadd-pelt
              %+  mpmul-pelt  a
              (mpsub-pelt (w %sf1-e-size) (w %sf2-e-size))
            ::
              %+  mpmul-pelt  b
              (mpsub-pelt (w %sf1-e-dyck) (w %sf2-e-dyck))
            ::
              %+  mpmul-pelt  c
              (mpsub-pelt (w %sf1-e-leaf) (w %sf2-e-leaf))
            ::
              (mpsub-pelt one-pelt (w %e-leaf))
            ==
          ==
        ::
          %+  mpscal-pelt  (v %pad)
          %+  mpmul-pelt  (w %sfcons-inv)
          (mpsub-pelt z (w %ln))
        ::
          %-  mpscal-pelt
          :_  (w %sfcons-inv)
          ;:  mpadd
            (v %op1)  (v %op2)  (v %op4)
            (v %op6)  (v %op7)
          ==
        ==
      ::
      ::
      ::  %pad must be binary
      :-  :-  %pad-binary
          %-  lift-to-mega
          (mpmul (v %pad) (mpsub one (v %pad)))
      ::
      ::  Formula decoding constraints
      ::
      ::
      ::
      ::  f = (cons f_h, f_t)
      %+  make-cons
        :*  %f-fh-ft-cons
            %f  %f-h  %f-t
            (mpsub one (v %pad))
        ==
      ::
      ::  f-t = (cons f_th, f_tt)
      %+  make-cons
        :*  %ft-fth-ftt-cons
            %f-t  %f-th  %f-tt
            :(mpadd (v %op2) (v %op5) (v %op6) (v %op7) (v %op8))
        ==
      ::
      ::  f-tt = (cons f-tth, f-ttt)
      %+  make-cons
        :*  %ftt-ftth-fttt-cons
            %f-tt  %f-tth  %f-ttt
            (v %op6)
        ==
      ::
      ::  decoding columns must be 0 if not used
      %^  tag-mp-pelt  %f-th-zero-size
        %+  mpscal-pelt
          (mpsub one (v %pad))
        %+  mpscal-pelt
          :(mpadd (v %op0) (v %op1) (v %op3) (v %op4) (v %op9))
        (mpsub-pelt one-pelt (w %f-th-size))
      ::
      %^  tag-mp-pelt  %f-th-zero-leaf
        %+  mpscal-pelt
          :(mpadd (v %op0) (v %op1) (v %op3) (v %op4) (v %op9))
        (w %f-th-leaf)
      ::
      %^  tag-mp-pelt  %f-th-zero-dyck
        %+  mpscal-pelt
          :(mpadd (v %op0) (v %op1) (v %op3) (v %op4) (v %op9))
        (w %f-th-dyck)
      ::
      %^  tag-mp-pelt  %f-tt-zero-size
        %+  mpscal-pelt
          (mpsub one (v %pad))
        %+  mpscal-pelt
          :(mpadd (v %op0) (v %op1) (v %op3) (v %op4) (v %op9))
        (mpsub-pelt one-pelt (w %f-tt-size))
      ::
      %^  tag-mp-pelt  %f-tt-zero-leaf
        %+  mpscal-pelt
          :(mpadd (v %op0) (v %op1) (v %op3) (v %op4) (v %op9))
        (w %f-tt-leaf)
      ::
      %^  tag-mp-pelt  %f-tt-zero-dyck
        %+  mpscal-pelt
          :(mpadd (v %op0) (v %op1) (v %op3) (v %op4) (v %op9))
        (w %f-tt-dyck)
      ::
      %^  tag-mp-pelt  %f-tth-zero-size
        %+  mpscal-pelt
          (mpsub one (v %pad))
        %+  mpscal-pelt
          (mpsub one (v %op6))
        (mpsub-pelt (w %f-tth-size) one-pelt)
      ::
      %^  tag-mp-pelt  %f-tth-zero-leaf
        %+  mpscal-pelt
          (mpsub one (v %op6))
        (w %f-tth-leaf)
      ::
      %^  tag-mp-pelt  %f-tth-zero-dyck
        %+  mpscal-pelt
          (mpsub one (v %op6))
        (w %f-tth-dyck)
      ::
      %^  tag-mp-pelt  %f-ttt-zero-size
        %+  mpscal-pelt
          (mpsub one (v %pad))
        %+  mpscal-pelt
          (mpsub one (v %op6))
        (mpsub-pelt (w %f-ttt-size) one-pelt)
      ::
      %^  tag-mp-pelt  %f-ttt-zero-leaf
        %+  mpscal-pelt
          (mpsub one (v %op6))
        (w %f-ttt-leaf)
      ::
      %^  tag-mp-pelt  %f-ttt-zero-dyck
        %+  mpscal-pelt
          (mpsub one (v %op6))
        (w %f-ttt-dyck)
      ::
      ::
      :: Evaluation Constraints
      ::
      ::
      ::  Constraints to set unused sf's to 0
      ::
      :: sf1 = 0
      :: used by nock 0 and 1
      ::
      %+  zero-ion
        [%sf1-zero %sf1 (mpadd (v %op0) (v %op1))]
      ::
      :: sf2 = 0
      :: used by nock 0, 1, 3, 4
      %+  zero-ion
        :*  %sf2-zero  %sf2
          ;:(mpadd (v %op0) (v %op1) (v %op3) (v %op4))
        ==
      ::
      ::
      :: sf3 = 0
      :: used by everything except 2
      ::
      %+  zero-ion
        :*  %sf3-zero  %sf3
          ;:  mpadd
            (v %op0)  (v %op1)  (v %op3)  (v %op4)
            (v %op5)  (v %op6)  (v %op7)  (v %op8)
            (v %op9)
          ==
        ==
      ::
      :: Opcode 0
      ::
      :: f-t-size = 1
      ::
      %^  tag-mp-pelt  %op0-f-t-size-1
        %+  mpscal-pelt  (v %op0)
        (mpsub-pelt (w %f-t-size) alf)
      ::
      :: f-t-dyck = 0
      ::
      %^  tag-mp-pelt  %op0-f-t-dyck-0
        %+  mpscal-pelt  (v %op0)
        (mpsub-pelt (w %f-t-dyck) zero-pelt)
      ::
      ::  if axis=1 just copy s to e
      %^  tag-mp-pelt  %op0-axis-1-size
        %+  mpscal-pelt  (v %op0)
        %+  mpmul-pelt
          (mpsub-pelt (w %s-size) (w %e-size))
        %+  mpsub-pelt  one-pelt
        %+  mpmul-pelt
          (mpsub-pelt (w %f-t-leaf) one-pelt)
        (w %sfcons-inv)
      ::
      %^  tag-mp-pelt  %op0-axis-1-leaf
        %+  mpscal-pelt  (v %op0)
        %+  mpmul-pelt
          (mpsub-pelt (w %s-leaf) (w %e-leaf))
        %+  mpsub-pelt  one-pelt
        %+  mpmul-pelt
          (mpsub-pelt (w %f-t-leaf) one-pelt)
        (w %sfcons-inv)
      ::
      %^  tag-mp-pelt  %op0-axis-1-dyck
        %+  mpscal-pelt  (v %op0)
        %+  mpmul-pelt
          (mpsub-pelt (w %s-dyck) (w %e-dyck))
        %+  mpsub-pelt  one-pelt
        %+  mpmul-pelt
          (mpsub-pelt (w %f-t-leaf) one-pelt)
        (w %sfcons-inv)
      ::
      ::
      :: Opcode 1
      ::
      :: e = f_t
      %+  ion-equal
        [%op1-e-f-t %e %f-t (v %op1)]
      ::
      :: Opcode 2
      ::
      :: sf1_s = s
      %+  ion-equal
        [%op2-sf1-s %sf1-s %s (v %op2)]
      ::
      :: sf1_f = f_th
      %+  ion-equal
        [%op2-sf1-f-f-th %sf1-f %f-th (v %op2)]
      ::
      :: sf2_s = s
      ::
      %+  ion-equal
        [%op2-sf2-s-s %sf2-s %s (v %op2)]
      ::
      :: sf2_f = f_tt
      ::
      %+  ion-equal
        [%op2-sf2-f-f-tt %sf2-f %f-tt (v %op2)]
      ::
      :: sf3_s = sf1_e
      ::
      %+  ion-equal
        [%op2-sf3-s-sf1-e %sf3-s %sf1-e (v %op2)]
      ::
      :: sf3_f = sf2_e
      ::
      %+  ion-equal
        [%op2-sf3-f-sf2-e %sf3-f %sf2-e (v %op2)]
      ::
      ::  e = sf3-e
      %+  ion-equal
        [%op2-e-sf3-e %e %sf3-e (v %op2)]
      ::
      ::
      :: Opcode 3
      ::
      :: e.size = alpha
      %^  tag-mp-pelt  %op3-e-size-1
        %+  mpscal-pelt  (v %op3)
        (mpsub-pelt (w %e-size) alf)
      ::
      :: e.dyck = 0
      %^  tag-mp-pelt  %op3-e-dyck-0
        %+  mpscal-pelt  (v %op3)
        (mpsub-pelt (w %e-dyck) zero-pelt)
      ::
      ::  sfcons-inv * (alpha - sf1-e-size) + e-leaf = 1
      %^  tag-mp-pelt  %op3-e-leaf
        %+  mpscal-pelt  (v %op3)
        %-  mpsub-pelt
        :_  one-pelt
        %+  mpadd-pelt
          %+  mpmul-pelt  (w %sfcons-inv)
          (mpsub-pelt alf (w %sf1-e-size))
        (w %e-leaf)
      ::
      :: sf1_s = s
      %+  ion-equal
        [%op3-sf1-s-s %sf1-s %s (v %op3)]
      ::
      :: sf1_f = f_t
      %+  ion-equal
        [%op3-sf1-f-f-t %sf1-f %f-t (v %op3)]
      ::
      ::
      :: Opcode 4
      ::
      :: e.size = alpha
      %^  tag-mp-pelt  %op4-e-size-1
        %+  mpscal-pelt  (v %op4)
        (mpsub-pelt (w %e-size) alf)
      ::
      :: e.dyck = 0
      %^  tag-mp-pelt  %op4-e-dyck-0
        %+  mpscal-pelt  (v %op4)
        (w %e-dyck)
      ::
      :: e.leaf = 1 + sf1.e.leaf
      %^  tag-mp-pelt  %op4-e-leaf-0
        %+  mpscal-pelt  (v %op4)
        %+  mpsub-pelt  (w %e-leaf)
        (mpadd-pelt one-pelt (w %sf1-e-leaf))
      ::
      :: sf1.e.size = alpha
      %^  tag-mp-pelt  %op4-sf1-e-size-1
        %+  mpscal-pelt  (v %op4)
        (mpsub-pelt (w %sf1-e-size) alf)
      ::
      :: sf1.e.dyck = 0
      %^  tag-mp-pelt  %op4-sf1-dyck-0
        %+  mpscal-pelt  (v %op4)
        (w %sf1-e-dyck)
      ::
      :: sf1_s = s
      %+  ion-equal
        [%op4-sf1-s-s %sf1-s %s (v %op4)]
      ::
      :: sf1_f = f_t
      %+  ion-equal
        [%op4-sf1-f-f-t %sf1-f %f-t (v %op4)]
      ::
      :: Opcode 5
      ::
      :: e.size = alpha
      %^  tag-mp-pelt  %op5-e-size-1
        %+  mpscal-pelt  (v %op5)
        (mpsub-pelt (w %e-size) alf)
      ::
      :: e.dyck = 0
      %^  tag-mp-pelt  %op5-e-dyck-0
        %+  mpscal-pelt  (v %op5)
        (w %e-dyck)
      ::
      :: (1 - e.leaf) * (sf1.e.size - sf2.e.size) = 0
      %^  tag-mp-pelt  %op5-e-leaf-sf1-size
        %+  mpscal-pelt  (v %op5)
        %+  mpmul-pelt
          (mpsub-pelt one-pelt (w %e-leaf))
        (mpsub-pelt (w %sf1-e-size) (w %sf2-e-size))
      ::
      :: (1 - e.leaf) * (sf1.e.dyck - sf2.e.dyck) = 0
      %^  tag-mp-pelt  %op5-e-leaf-sf1-dyck
        %+  mpscal-pelt  (v %op5)
        %+  mpmul-pelt
          (mpsub-pelt one-pelt (w %e-leaf))
        (mpsub-pelt (w %sf1-e-dyck) (w %sf2-e-dyck))
      ::
      :: (1 - e.leaf) * (sf1.e.leaf - sf2.e.leaf) = 0
      %^  tag-mp-pelt  %op5-e-leaf-sf1-leaf
        %+  mpscal-pelt  (v %op5)
        %+  mpmul-pelt
          (mpsub-pelt one-pelt (w %e-leaf))
        (mpsub-pelt (w %sf1-e-leaf) (w %sf2-e-leaf))
      ::
      :: e.leaf * (1 - e.leaf) = 0
      %^  tag-mp-pelt  %op5-e-leaf-binary
        %+  mpscal-pelt  (v %op5)
        %+  mpmul-pelt  (w %e-leaf)
        (mpsub-pelt one-pelt (w %e-leaf))
      ::
      :: sf1_s = s
      %+  ion-equal
        [%op5-sf1-s-s %sf1-s %s (v %op5)]
      ::
      :: sf1_f = f-th
      %+  ion-equal
        [%op5-sf1-f-f-th %sf1-f %f-th (v %op5)]
      ::
      :: sf2_s = s
      %+  ion-equal
        [%op5-sf2-s-s %sf2-s %s (v %op5)]
      ::
      :: sf2_f = f-tt
      %+  ion-equal
        [%op5-sf2-f-f-tt %sf2-f %f-tt (v %op5)]
      ::
      ::
      :: Opcode 6
      ::
      :: sf1_s = s
      %+  ion-equal
        [%op6-sf1-s-s %sf1-s %s (v %op6)]
      ::
      :: sf1.f = sf2-e.leaf * f-ttt + (1 - sf2-e.leaf) * f-tth
      %^  tag-mp-pelt  %op6-sf1-f-e-leaf-tth-size
        %+  mpscal-pelt  (v %op6)
        %+  mpsub-pelt
          (w %sf1-f-size)
        %+  mpadd-pelt
          (mpmul-pelt (w %sf2-e-leaf) (w %f-ttt-size))
        (mpmul-pelt (mpsub-pelt one-pelt (w %sf2-e-leaf)) (w %f-tth-size))
      ::
      %^  tag-mp-pelt  %op6-sf1-f-e-leaf-tth-leaf
        %+  mpscal-pelt  (v %op6)
        %+  mpsub-pelt
          (w %sf1-f-leaf)
        %+  mpadd-pelt
          (mpmul-pelt (w %sf2-e-leaf) (w %f-ttt-leaf))
        (mpmul-pelt (mpsub-pelt one-pelt (w %sf2-e-leaf)) (w %f-tth-leaf))
      ::
      %^  tag-mp-pelt  %op6-sf1-f-e-leaf-tth-dyck
        %+  mpscal-pelt  (v %op6)
        %+  mpsub-pelt
          (w %sf1-f-dyck)
        %+  mpadd-pelt
          (mpmul-pelt (w %sf2-e-leaf) (w %f-ttt-dyck))
        (mpmul-pelt (mpsub-pelt one-pelt (w %sf2-e-leaf)) (w %f-tth-dyck))
      ::
      :: sf1-e = e
      %+  ion-equal
        [%op6-sf1-e-e %sf1-e %e (v %op6)]
      ::
      :: sf2-e.size = alpha
      %^  tag-mp-pelt  %op6-sf2-e-size-1
        %+  mpscal-pelt  (v %op6)
        (mpsub-pelt (w %sf2-e-size) alf)
      ::
      :: sf2-e.dyck = 0
      %^  tag-mp-pelt  %op6-sf2-e-dyck-0
        %+  mpscal-pelt  (v %op6)
        (w %sf2-e-dyck)
      ::
      :: sf2.e.leaf * (1 - sf2.e.leaf) = 0
      %^  tag-mp-pelt  %op6-sf2-e-leaf-binary
        %+  mpscal-pelt  (v %op6)
        %+  mpmul-pelt  (w %sf2-e-leaf)
        (mpsub-pelt one-pelt (w %sf2-e-leaf))
      ::
      :: sf2_s = s
      %+  ion-equal
        [%op6-sf2-e-s %sf2-s %s (v %op6)]
      ::
      :: sf2_f = f-th
      %+  ion-equal
        [%op6-sf2-f-f-th %sf2-f %f-th (v %op6)]
      ::
      ::
      :: Opcode 7
      ::
      :: sf1-s = sf2-e
      %+  ion-equal
        [%op7-sf1-s-sf2-e %sf1-s %sf2-e (v %op7)]
      ::
      :: sf1-f = f-tt
      %+  ion-equal
        [%op7-sf1-f-f-tt %sf1-f %f-tt (v %op7)]
      ::
      :: sf1-e = e
      %+  ion-equal
        [%op7-sf1-e-e %sf1-e %e (v %op7)]
      ::
      :: sf2-s = s
      %+  ion-equal
        [%op7-sf2-s-s %sf2-s %s (v %op7)]
      ::
      :: sf2-f = f-th
      %+  ion-equal
        [%op7-sf2-f-f-th %sf2-f %f-th (v %op7)]
      ::
      ::
      ::  Opcode 8
      ::
      :: sf1_s = cons(sf2-e, s)
      ::
      %+  make-cons
        :*  %op8-cons
            %sf1-s  %sf2-e  %s
            (v %op8)
        ==
      ::
      :: sf1-f = f-tt
      %+  ion-equal
        [%op8-sf1-f-f-tt %sf1-f %f-tt (v %op8)]
      ::
      :: sf1-e = e
      %+  ion-equal
        [%op8-sf1-e-e %sf1-e %e (v %op8)]
      ::
      :: sf2-s = s
      %+  ion-equal
        [%op8-sf2-s-s %sf2-s %s (v %op8)]
      ::
      :: sf2-f = f-th
      %+  ion-equal
        [%op8-sf2-f-f-th %sf2-f %f-th (v %op8)]
      ::
      ::
      ::  Opcode 9 (autocons)
      ::  sf1 s = cons(sf2 e,s)
      ::
      ::  e = cons(sf1-e, sf2-e)
      %+  make-cons
        :*  %op9-cons
            %e  %sf1-e  %sf2-e
            (v %op9)
        ==
      ::
      :: sf1-s = s
      %+  ion-equal
        [%autocons-sf1-s-s %sf1-s %s (v %op9)]
      ::
      :: sf1-f = f-h
      %+  ion-equal
        [%autocons-sf1-f-f-h %sf1-f %f-h (v %op9)]
      ::
      :: sf2-s = s
      %+  ion-equal
        [%autocons-sf2-s-s %sf2-s %s (v %op9)]
      ::
      :: sf2-f = f-t
      %+  ion-equal
        [%autocons-sf2-f-f-t %sf2-f %f-t (v %op9)]
      ::
      ::
      ::  for nock 0, %sfcons-inv must be inverse of (f-t-leaf - 1)
      %^  tag-mp-pelt  %gen-nock-0-1
        %+  mpscal-pelt  (v %op0)
        %+  mpmul-pelt
          (w %sfcons-inv)
        %-  mpsub-pelt
        :_  one-pelt
        %+  mpmul-pelt
          (w %sfcons-inv)
        (mpsub-pelt (w %f-t-leaf) one-pelt)
      ::
      %^  tag-mp-pelt  %gen-nock-0-2
        %+  mpscal-pelt  (v %op0)
        %+  mpmul-pelt
          (mpsub-pelt (w %f-t-leaf) one-pelt)
        %-  mpsub-pelt
        :_  one-pelt
        %+  mpmul-pelt
          (w %sfcons-inv)
        (mpsub-pelt (w %f-t-leaf) one-pelt)
      ::
      :: for nock 3, %gen must be inverse of (alpha - sf1-e-size)
      ::
      %^  tag-mp-pelt  %gen-nock-3-1
        %+  mpscal-pelt  (v %op3)
        %+  mpmul-pelt
          (w %sfcons-inv)
        %-  mpsub-pelt
        :_  one-pelt
        %+  mpmul-pelt
          (w %sfcons-inv)
        (mpsub-pelt alf (w %sf1-e-size))
      ::
      %^  tag-mp-pelt  %gen-nock-3-2
        %+  mpscal-pelt  (v %op3)
        %+  mpmul-pelt
          (mpsub-pelt alf (w %sf1-e-size))
        %-  mpsub-pelt
        :_  one-pelt
        %+  mpmul-pelt
          (w %sfcons-inv)
        (mpsub-pelt alf (w %sf1-e-size))
      ::
      ::
      ::
      ::  Padding constraints
      ::
      ::  Every column that isn't a multiset or kv store must be 0 during padding
      ::  (except %pad)
      ::
      %+  pd  %op0
      %+  pd  %op1
      %+  pd  %op2
      %+  pd  %op3
      %+  pd  %op4
      %+  pd  %op5
      %+  pd  %op6
      %+  pd  %op7
      %+  pd  %op8
      %+  pd  %op9
      %+  pd-pelt  %s-size
      %+  pd-pelt  %s-leaf
      %+  pd-pelt  %s-dyck
      %+  pd-pelt  %f-size
      %+  pd-pelt  %f-leaf
      %+  pd-pelt  %f-dyck
      %+  pd-pelt  %e-size
      %+  pd-pelt  %e-leaf
      %+  pd-pelt  %e-dyck
      %+  pd-pelt  %sf1-s-size
      %+  pd-pelt  %sf1-s-leaf
      %+  pd-pelt  %sf1-s-dyck
      %+  pd-pelt  %sf1-f-size
      %+  pd-pelt  %sf1-f-leaf
      %+  pd-pelt  %sf1-f-dyck
      %+  pd-pelt  %sf1-e-size
      %+  pd-pelt  %sf1-e-leaf
      %+  pd-pelt  %sf1-e-dyck
      %+  pd-pelt  %sf2-s-size
      %+  pd-pelt  %sf2-s-leaf
      %+  pd-pelt  %sf2-s-dyck
      %+  pd-pelt  %sf2-f-size
      %+  pd-pelt  %sf2-f-leaf
      %+  pd-pelt  %sf2-f-dyck
      %+  pd-pelt  %sf2-e-size
      %+  pd-pelt  %sf2-e-leaf
      %+  pd-pelt  %sf2-e-dyck
      %+  pd-pelt  %sf3-s-size
      %+  pd-pelt  %sf3-s-leaf
      %+  pd-pelt  %sf3-s-dyck
      %+  pd-pelt  %sf3-f-size
      %+  pd-pelt  %sf3-f-leaf
      %+  pd-pelt  %sf3-f-dyck
      %+  pd-pelt  %sf3-e-size
      %+  pd-pelt  %sf3-e-leaf
      %+  pd-pelt  %sf3-e-dyck
      %+  pd-pelt  %f-h-size
      %+  pd-pelt  %f-h-leaf
      %+  pd-pelt  %f-h-dyck
      %+  pd-pelt  %f-t-size
      %+  pd-pelt  %f-t-leaf
      %+  pd-pelt  %f-t-dyck
      %+  pd-pelt  %f-th-size
      %+  pd-pelt  %f-th-leaf
      %+  pd-pelt  %f-th-dyck
      %+  pd-pelt  %f-tt-size
      %+  pd-pelt  %f-tt-leaf
      %+  pd-pelt  %f-tt-dyck
      %+  pd-pelt  %f-tth-size
      %+  pd-pelt  %f-tth-leaf
      %+  pd-pelt  %f-tth-dyck
      %+  pd-pelt  %f-ttt-size
      %+  pd-pelt  %f-ttt-leaf
      %+  pd-pelt  %f-ttt-dyck
      %+  pd-pelt  %fcons-inv
      ~
    ::
    ++  transition-constraints
      ^-  (map term mp-ultra)
      ::  name challenges
      =,  chal
      =,  constraint-util
      =/  r   ~(r rnd:chal:chal (make-chal-mps:chal chal-names-all:chal))
      =/  a=mp-pelt    (r %a)
      =/  b=mp-pelt    (r %b)
      =/  c=mp-pelt    (r %c)
      =/  d=mp-pelt    (r %d)
      =/  e=mp-pelt    (r %e)
      =/  f=mp-pelt    (r %f)
      =/  g=mp-pelt    (r %g)
      =/  j=mp-pelt    (r %j)
      =/  k=mp-pelt    (r %k)
      =/  l=mp-pelt    (r %l)
      =/  m=mp-pelt    (r %m)
      =/  n=mp-pelt    (r %n)
      =/  o=mp-pelt    (r %o)
      =/  ww=mp-pelt   (r %w)  :: ww to avoid name-shadowing
      =/  x=mp-pelt    (r %x)
      =/  y=mp-pelt    (r %y)
      =/  alf=mp-pelt  (r %alf)    :: ion
      =/  bet=mp-pelt  (r %bet)  :: multiset
      =/  gam=mp-pelt  (r %gam)
      =/  z=mp-pelt    (r %z)    :: kv store
      =/  z2=mp-pelt   (mpmul-pelt z z)
      =/  z3=mp-pelt   (mpmul-pelt z2 z)
      =/  pd  zero-during-padding
      ::
      %-  roll
      :_  |=  [[nam=col-name mp=mp-ultra] constraints=(map col-name mp-ultra)]
          ::  asserts we haven't seen this name before to prevent
          ::  constraint overwriting in the case of accidental name doubling
          ?>  ?=(~ (~(get by constraints) nam))
          (~(put by constraints) [nam mp])
      ^-  (list [col-name mp-ultra])
      ::
      ::  Indexing & Selector Constraints
      ::
      ::  In order to keep track of the number of observed opcodes and total number of rows,
      ::  the transition function between rows i and i + 1 requires the following to always hold:
      ::
      %^  tag-mp-pelt  %ln-inc
        %+  mpscal-pelt  (mpsub one (v %pad))
        (mpsub-pelt (w-n %ln) (mpmul-pelt (w %ln) z))
      ::
      ::  if %pad is 1 then %lnc must count down instead of up
      %^  tag-mp-pelt  %ln-dec
        %+  mpscal-pelt  (v %pad)
        (mpsub-pelt (w %ln) (mpmul-pelt (w-n %ln) z))
      ::
      ::  once %pad is 1 it must stay 1
      ::  %pad * (%pad' - %pad) = 0
      :-  :-  %pad-stay-one
         %-  lift-to-mega
        (mpmul (v %pad) (mpsub (v %pad-n) (v %pad)))
      ::
      %^  tag-mp-pelt  %opc-counter
        %+  mpscal-pelt  (mpsub one (v %pad))
        %+  mpsub-pelt
          (w-n %opc)
        ;:  mpadd-pelt
          (mpscal-pelt (mpadd (v %op0) (v %op1)) (w %opc))
          ::
          %+  mpmul-pelt  z
          (mpscal-pelt (mpadd (v %op3) (v %op4)) (w %opc))
          ::
          %+  mpmul-pelt  z2
          %-  mpscal-pelt
          :_  (w %opc)
          ;:(mpadd (v %op5) (v %op6) (v %op7) (v %op8) (v %op9))
          ::
          %+  mpmul-pelt  z3
          (mpscal-pelt (v %op2) (w %opc))
        ==
      ::
      ::
      ::  KV Update Constraints
      ::
      ::  Stack Update
      :-  :-  %stack-update
        =/  program
          ;:  mpadd-pelt
            %+  mpmul-pelt  m
            ;:  mpadd-pelt
              (mpmul-pelt j (w %s-size))
              (mpmul-pelt k (w %s-dyck))
              (mpmul-pelt l (w %s-leaf))
            ==
          ::
            %+  mpmul-pelt  n
            ;:  mpadd-pelt
              (mpmul-pelt j (w %f-size))
              (mpmul-pelt k (w %f-dyck))
              (mpmul-pelt l (w %f-leaf))
            ==
          ::
            %+  mpmul-pelt  o
            ;:  mpadd-pelt
              (mpmul-pelt j (w %e-size))
              (mpmul-pelt k (w %e-dyck))
              (mpmul-pelt l (w %e-leaf))
            ==
          ==
        ::
        =/  sp1
          ;:  mpadd-pelt
            %+  mpmul-pelt  m
            ;:  mpadd-pelt
              (mpmul-pelt j (w %sf1-s-size))
              (mpmul-pelt k (w %sf1-s-dyck))
              (mpmul-pelt l (w %sf1-s-leaf))
            ==
          ::
            %+  mpmul-pelt  n
            ;:  mpadd-pelt
              (mpmul-pelt j (w %sf1-f-size))
              (mpmul-pelt k (w %sf1-f-dyck))
              (mpmul-pelt l (w %sf1-f-leaf))
            ==
          ::
            %+  mpmul-pelt  o
            ;:  mpadd-pelt
              (mpmul-pelt j (w %sf1-e-size))
              (mpmul-pelt k (w %sf1-e-dyck))
              (mpmul-pelt l (w %sf1-e-leaf))
            ==
          ==
        ::
        =/  sp2
          ;:  mpadd-pelt
            %+  mpmul-pelt  m
            ;:  mpadd-pelt
              (mpmul-pelt j (w %sf2-s-size))
              (mpmul-pelt k (w %sf2-s-dyck))
              (mpmul-pelt l (w %sf2-s-leaf))
            ==
          ::
            %+  mpmul-pelt  n
            ;:  mpadd-pelt
              (mpmul-pelt j (w %sf2-f-size))
              (mpmul-pelt k (w %sf2-f-dyck))
              (mpmul-pelt l (w %sf2-f-leaf))
            ==
          ::
            %+  mpmul-pelt  o
            ;:  mpadd-pelt
              (mpmul-pelt j (w %sf2-e-size))
              (mpmul-pelt k (w %sf2-e-dyck))
              (mpmul-pelt l (w %sf2-e-leaf))
            ==
          ==
        ::
        =/  sp3
          ;:  mpadd-pelt
            %+  mpmul-pelt  m
            ;:  mpadd-pelt
              (mpmul-pelt j (w %sf3-s-size))
              (mpmul-pelt k (w %sf3-s-dyck))
              (mpmul-pelt l (w %sf3-s-leaf))
            ==
          ::
            %+  mpmul-pelt  n
            ;:  mpadd-pelt
              (mpmul-pelt j (w %sf3-f-size))
              (mpmul-pelt k (w %sf3-f-dyck))
              (mpmul-pelt l (w %sf3-f-leaf))
            ==
          ::
            %+  mpmul-pelt  o
            ;:  mpadd-pelt
              (mpmul-pelt j (w %sf3-e-size))
              (mpmul-pelt k (w %sf3-e-dyck))
              (mpmul-pelt l (w %sf3-e-leaf))
            ==
          ==
        ::
        =/  com
          %-  mpsub-pelt
          :_  (w-n %stack-kv)
          %-  mpsub-pelt
          :_  (mpmul-pelt [(mp-com 0) (mp-com 1) (mp-com 2)] (w %ln))
          ;:  mpadd-pelt
            (w %stack-kv)
            ::
            %+  mpscal-pelt
              ;:  mpadd
                (v %op2)  (v %op3)  (v %op4)  (v %op5)
                (v %op6)  (v %op7)  (v %op8)  (v %op9)
              ==
            ;:  mpmul-pelt
              [(mp-com 3) (mp-com 4) (mp-com 5)]
              (w %opc)
              z
            ==
            ::
            %+  mpscal-pelt
              :(mpadd (v %op2) (v %op5) (v %op6) (v %op7) (v %op8) (v %op9))
            ;:  mpmul-pelt
              [(mp-com 6) (mp-com 7) (mp-com 8)]
              (w %opc)
              z2
            ==
            ::
            %+  mpscal-pelt  (v %op2)
            ;:  mpmul-pelt
              [(mp-com 9) (mp-com 10) (mp-com 11)]
              (w %opc)
              z3
            ==
          ==
        ::
        :+  %comp
          :~  a.program  b.program  c.program
              a.sp1  b.sp1  c.sp1
              a.sp2  b.sp2  c.sp2
              a.sp3  b.sp3  c.sp3
          ==
        ~[a.com b.com c.com]
      ::
      ::  decode mset multiset evolution
      :-  :-  %decode-multiset-update
        =/  make-val
          |=  [node=term hed=term tal=term]
          %-  ~(compress poly-tupler-pelt ~[j k l m n o ww x y])
          :~  (w (crip (weld (trip node) "-size")))
              (w (crip (weld (trip node) "-dyck")))
              (w (crip (weld (trip node) "-leaf")))
              (w (crip (weld (trip hed) "-size")))
              (w (crip (weld (trip hed) "-dyck")))
              (w (crip (weld (trip hed) "-leaf")))
              (w (crip (weld (trip tal) "-size")))
              (w (crip (weld (trip tal) "-dyck")))
              (w (crip (weld (trip tal) "-leaf")))
          ==
        =/  f-decode-val     (mpsub-pelt gam (make-val %f %f-h %f-t))
        =/  f-t-decode-val   (mpsub-pelt gam (make-val %f-t %f-th %f-tt))
        =/  f-tt-decode-val  (mpsub-pelt gam (make-val %f-tt %f-tth %f-ttt))
        =/  com
          %+  mpsub-pelt
            ;:  mpmul-pelt
              (mpsub-pelt (w-n %decode-mset) (w %decode-mset))
              [(mp-com 0) (mp-com 1) (mp-com 2)]
              [(mp-com 3) (mp-com 4) (mp-com 5)]
              [(mp-com 6) (mp-com 7) (mp-com 8)]
            ==
          ;:  mpadd-pelt
            %+  mpscal-pelt  (mpsub one (v %pad))
            (mpmul-pelt [(mp-com 3) (mp-com 4) (mp-com 5)] [(mp-com 6) (mp-com 7) (mp-com 8)])
          ::
            %+  mpscal-pelt  :(mpadd (v %op2) (v %op5) (v %op6) (v %op7) (v %op8))
            (mpmul-pelt [(mp-com 0) (mp-com 1) (mp-com 2)] [(mp-com 6) (mp-com 7) (mp-com 8)])
          ::
            %+  mpscal-pelt  (v %op6)
            (mpmul-pelt [(mp-com 0) (mp-com 1) (mp-com 2)] [(mp-com 3) (mp-com 4) (mp-com 5)])
          ==
        :+  %comp
          :~  a.f-decode-val  b.f-decode-val  c.f-decode-val
              a.f-t-decode-val  b.f-t-decode-val  c.f-t-decode-val
              a.f-tt-decode-val  b.f-tt-decode-val  c.f-tt-decode-val
          ==
        ~[a.com b.com c.com]
      ::
      ::
      ::
      ::
      ::  op0 mset multiset constraints
      ::
      ::  (these are all done in one constraint but broken up here for readability)
      ::
      ::  mroot = op0 * (a*s.size + b*s.dyck + c*s.leaf)
      ::  maxis = op0 * d * f-t.leaf
      ::  mval = op0 * (alf * e.size + bet * e.dyck + gam * e.leaf)
      ::  mvar = mroot + maxis + mval
      ::  (op0_mset' - op0_mset)(z-mvar) = op0(i)
      ::
      %^  tag-mp-pelt  %op0-multiset-update
        =/  mroot
          ;:  mpadd-pelt
            (mpmul-pelt a (w %s-size))
            (mpmul-pelt b (w %s-dyck))
            (mpmul-pelt c (w %s-leaf))
          ==
        =/  maxis
          (mpmul-pelt m (w %f-t-leaf))
        =/  mval
          ;:  mpadd-pelt
            (mpmul-pelt j (w %e-size))
            (mpmul-pelt k (w %e-dyck))
            (mpmul-pelt l (w %e-leaf))
          ==
        =/  mvar
          :(mpadd-pelt mroot maxis mval)
        ::
        %+  mpscal-pelt  (v %op0)
        %+  mpmul-pelt
          (mpsub-pelt one-pelt (w %f-t-leaf))
        %-  mpsub-pelt
        :_  one-pelt
        %+  mpmul-pelt
          (mpsub-pelt (w-n %op0-mset) (w %op0-mset))
        (mpsub-pelt bet mvar)
      ::
      %^  tag-mp-pelt  %op0-multiset-no-update
        %+  mpmul-pelt
          %+  mpadd-pelt
            (lift-to-mp-pelt (mpsub one (v %op0)))
          %+  mpsub-pelt  one-pelt
          %+  mpmul-pelt
            (mpsub-pelt (w %f-t-leaf) one-pelt)
          (w %sfcons-inv)
        (mpsub-pelt (w-n %op0-mset) (w %op0-mset))
      ::
      ::
      :: during padding, all the state stays the same (except for ln which counts down)
      %^  tag-mp-pelt  %opc-padding
        %+  mpscal-pelt  (v %pad)
        (mpsub-pelt (w %opc) (w-n %opc))
      ::
      %^  tag-mp-pelt  %stack-kv-padding
        %+  mpscal-pelt  (v %pad)
        (mpsub-pelt (w %stack-kv) (w-n %stack-kv))
      ::
      %^  tag-mp-pelt  %decode-mset-padding
        %+  mpscal-pelt  (v %pad)
        (mpsub-pelt (w %decode-mset) (w-n %decode-mset))
      ::
      %^  tag-mp-pelt  %op0-mset-padding
        %+  mpscal-pelt  (v %pad)
        (mpsub-pelt (w %op0-mset) (w-n %op0-mset))
      ~
    ::
    ++  extra-constraints
      ^-  (map term mp-ultra)
      ~
    --
  --
--
