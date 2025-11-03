/=  common  /common/v2/table/memory
/=  *  /common/zeke
=,  mp-to-mega
|%
++  v  ~(v var:tlib variables:static:common)
++  w  ~(v var-pelt:tlib variables:static:common)
++  w-n  ~(v-n var-pelt:tlib variables:static:common)
++  w-c  ~(c var-pelt:tlib variables:static:common)
++  d  ~(d dyn:dyn (make-dyn-mps:dyn terminal-names:static:common))
++  engine
  |%
  ++  funcs
    ^-  verifier-funcs
    |%
    ++  boundary-constraints
      ^-  (map term mp-ultra)
      =,  constraint-util
      =/  r   ~(r rnd:chal:chal (make-chal-mps:chal chal-names-basic:chal))
      =/  z  (r %z)
      %-  roll
      :_  |=  [[nam=col-name mp=mp-ultra] constraints=(map col-name mp-ultra)]
          ::  asserts we haven't seen this name before to prevent
          ::  constraint overwriting in the case of accidental name doubling
          ?>  ?=(~ (~(get by constraints) nam))
          (~(put by constraints) [nam mp])
      ^-  (list [col-name mp-ultra])
      ::
      %^  tag-mp-pelt  %mem-ln-init
        (mpsub-pelt (w %ln) z)
      ::
      %^  tag-mp-pelt  %mem-nc-input
        (mpsub-pelt (w %nc) (d %memory-nc))
      ::
      %^  tag-mp-pelt  %mem-kvs-input
        (mpsub-pelt (w %kvs) (d %memory-kvs))
      ::
      %^  tag-mp-pelt  %mem-decode-starts-at-0
        (w %decode-mset)
      ::
      %^  tag-mp-pelt  %mem-op0-mset-starts-at-0
        (w %op0-mset)
      ~
    ::
    ++  terminal-constraints
      ^-  (map term mp-ultra)
      =,  constraint-util
      =/  r   ~(r rnd:chal:chal (make-chal-mps:chal chal-names-basic:chal))
      =/  bet  (r %bet)  :: multisets
      =/  a    (r %a)
      =/  b    (r %b)
      =/  c    (r %c)
      =/  one  (mp-c 1)
      %-  roll
      :_  |=  [[nam=col-name mp=mp-ultra] constraints=(map col-name mp-ultra)]
          ::  asserts we haven't seen this name before to prevent
          ::  constraint overwriting in the case of accidental name doubling
          ?>  ?=(~ (~(get by constraints) nam))
          (~(put by constraints) [nam mp])
      ^-  (list [col-name mp-ultra])
      %^  tag-mp-pelt  %mem-kvs-empty
        (w %kvs)
      %^  tag-mp-pelt  %mem-decode-mset-output
        (mpsub-pelt (w %decode-mset) (d %memory-decode-mset))
      %^  tag-mp-pelt  %mem-op0-mset-output
        (mpsub-pelt (w %op0-mset) (d %memory-op0-mset))
      ~
    ::
    ++  row-constraints
      ^-  (map term mp-ultra)
      ~+
      =,  constraint-util
      =/  r   ~(r rnd:chal (make-chal-mps:chal chal-names-all:chal))
      =/  [a=mp-pelt b=mp-pelt c=mp-pelt d=mp-pelt e=mp-pelt f=mp-pelt g=mp-pelt]
        [(r %a) (r %b) (r %c) (r %d) (r %e) (r %f) (r %g)]
      =/  [alf=mp-pelt bet=mp-pelt z=mp-pelt]
        [(r %alf) (r %bet) (r %z)]
      =/  one  (mp-c 1)
      =/  invalf  (r %inv-alf)
      %-  roll
      :_  |=  [[nam=col-name mp=mp-ultra] constraints=(map col-name mp-ultra)]
          ::  asserts we haven't seen this name before to prevent
          ::  constraint overwriting in the case of accidental name doubling
          ?>  ?=(~ (~(get by constraints) nam))
          (~(put by constraints) [nam mp])
      ^-  (list [col-name mp-ultra])
      ::
      ::  pad is binary
      :-  :-  %mem-pad-binary
        %-  lift-to-mega
        (mpmul (v %pad) (mpsub one (v %pad)))
      ::
      ::  //cons relations\\
      %^  tag-mp-pelt  %mem-cons-size
        %+  mpscal-pelt  (v %pad)
        %+  mpsub-pelt  (w %parent-size)
        (mpmul-pelt (w %lc-size) (w %rc-size))
      ::
      %^  tag-mp-pelt  %mem-cons-dyck
        %+  mpscal-pelt  (v %pad)
        %+  mpsub-pelt  (w %parent-dyck)
        ;:  mpadd-pelt
          (w %rc-dyck)
          :(mpmul-pelt (w %rc-size) (w %rc-size) invalf invalf)
          :(mpmul-pelt (w %lc-dyck) (w %rc-size) (w %rc-size) invalf)
        ==
      ::
      %^  tag-mp-pelt  %mem-cons-leaf
        %+  mpscal-pelt  (v %pad)
        %+  mpsub-pelt  (w %parent-leaf)
        ;:  mpadd-pelt
          (w %rc-leaf)
          (mpmul-pelt (w %lc-leaf) (w %rc-size))
        ==
      ::  \\cons relations//
      ::
      ::  //when lc is an atom\\
      %^  tag-mp-pelt  %mem-lc-size-when-atom
        %+  mpscal-pelt  (v %pad)
        (mpscal-pelt (mpsub one (v %op-l)) (mpsub-pelt (w %lc-size) alf))
      ::
      %^  tag-mp-pelt  %mem-lc-dyck-when-atom
        (mpscal-pelt (mpsub one (v %op-l)) (w %lc-dyck))
      ::
      %^  tag-mp-pelt  %mem-lc-leaf-when-atom
        %+  mpscal-pelt  (mpsub one (v %op-l))
        (mpsub-pelt [(v %leaf-l) (mp-c 0) (mp-c 0)] (w %lc-leaf))
      ::  \\when lc is an atom//
      ::
      ::  //when lc not an atom\\
      :-  :-  %mem-leaf-l-zero-when-lc-not-atom
        %-  lift-to-mega
        (mpmul (v %op-l) (v %leaf-l))
      ::  \\when lc not an atom//
      ::
      ::  //when rc is an atom\\
      %^  tag-mp-pelt  %mem-rc-size-when-atom
        %+  mpscal-pelt  (v %pad)
        (mpscal-pelt (mpsub one (v %op-r)) (mpsub-pelt (w %rc-size) alf))
      ::
      %^  tag-mp-pelt  %mem-rc-dyck-when-atom
        (mpscal-pelt (mpsub one (v %op-r)) (w %rc-dyck))
      ::
      %^  tag-mp-pelt  %mem-rc-leaf-when-atom
        %+  mpscal-pelt  (mpsub one (v %op-r))
        (mpsub-pelt [(v %leaf-r) (mp-c 0) (mp-c 0)] (w %rc-leaf))
      ::  \\when rc is an atom//
      ::
      ::  //when rc not an atom\\
      :-  :-  %mem-leaf-r-zero-when-rc-not-atom
        %-  lift-to-mega
        (mpmul (v %op-r) (v %leaf-r))
      ::  \\when rc not an atom//
      ::
      ::  sizes cannot hit one
      %^  tag-mp-pelt  %mem-sizes-cannot-hit-one
        %+  mpsub-pelt  (lift-to-mp-pelt one)
        ;:  mpmul-pelt
          (mpsub-pelt (w %parent-size) (lift-to-mp-pelt one))
          (mpsub-pelt (w %lc-size) (lift-to-mp-pelt one))
          (mpsub-pelt (w %rc-size) (lift-to-mp-pelt one))
          (w %inv)
        ==
      ::
      ::  //parent and children 0 in padding\\
      %^  tag-mp-pelt  %mem-parent-size-zero-in-pad
        (mpscal-pelt (mpsub one (v %pad)) (w %parent-size))
      ::
      %^  tag-mp-pelt  %mem-parent-dyck-zero-in-pad
        (mpscal-pelt (mpsub one (v %pad)) (w %parent-dyck))
      ::
      %^  tag-mp-pelt  %mem-parent-leaf-zero-in-pad
        (mpscal-pelt (mpsub one (v %pad)) (w %parent-leaf))
      ::
      %^  tag-mp-pelt  %mem-lc-size-zero-in-pad
        (mpscal-pelt (mpsub one (v %pad)) (w %lc-size))
      ::
      %^  tag-mp-pelt  %mem-lc-dyck-zero-in-pad
        (mpscal-pelt (mpsub one (v %pad)) (w %lc-dyck))
      ::
      %^  tag-mp-pelt  %mem-lc-leaf-zero-in-pad
        (mpscal-pelt (mpsub one (v %pad)) (w %lc-leaf))
      ::
      %^  tag-mp-pelt  %mem-rc-size-zero-in-pad
        (mpscal-pelt (mpsub one (v %pad)) (w %rc-size))
      ::
      %^  tag-mp-pelt  %mem-rc-dyck-zero-in-pad
        (mpscal-pelt (mpsub one (v %pad)) (w %rc-dyck))
      ::
      %^  tag-mp-pelt  %mem-rc-leaf-zero-in-pad
        (mpscal-pelt (mpsub one (v %pad)) (w %rc-leaf))
      ::
      ::  \\parent and children 0 in padding//
      ::
      ::  //axis and inverse system\\
      :-  :-  %mem-axis-and-inverse-0
        %-  lift-to-mega
        (mpmul (v %axis) (mpsub one (v %axis-flag)))
      ::
      :-  :-  %mem-axis-and-inverse-1
        %-  lift-to-mega
        (mpmul (v %axis-ioz) (mpsub one (v %axis-flag)))
      ::
      :-  :-  %mem-axis-and-inverse-2
        %-  lift-to-mega
        (mpsub (v %axis-flag) (mpmul (v %axis) (v %axis-ioz)))
      ::  \\axis and inverse system//
      ::
      ::  axis is zero in padding
      :-  :-  %mem-axis-zero-in-pad
        %-  lift-to-mega
        (mpmul (mpsub one (v %pad)) (v %axis))
      ::
      ::  //op-l/r constraints\\
      ::  left opcode is binary
      :-  :-  %mem-op-l-binary
        %-  lift-to-mega
        (mpmul (v %op-l) (mpsub one (v %op-l)))
      ::
      ::  right opcode is binary
      :-  :-  %mem-op-r-binary
        %-  lift-to-mega
        (mpmul (v %op-r) (mpsub one (v %op-r)))
      ::
      ::  left opcode zero in padding
      :-  :-  %mem-op-l-zero-in-pad
        %-  lift-to-mega
        (mpmul (mpsub one (v %pad)) (v %op-l))
      ::
      ::  right opcode zero in padding
      :-  :-  %mem-op-r-zero-in-pad
        %-  lift-to-mega
        (mpmul (mpsub one (v %pad)) (v %op-r))
      ::  \\op-l/r constraints//
      ::
      ::  count-inv is count's inverse
      :-  :-  %mem-count-inverse
        %-  lift-to-mega
        (mpsub one (mpmul (v %count) (v %count-inv)))
      ::
      ::  //kvs-ioz constraint system\\
      %^  tag-mp-pelt  %mem-kvs-ioz-system-0
        (mpmul-pelt (w %kvs) (mpsub-pelt (w %kvsf) (lift-to-mp-pelt one)))
      ::
      %^  tag-mp-pelt  %mem-kvs-ioz-system-1
        (mpmul-pelt (w %kvs-ioz) (mpsub-pelt (w %kvsf) (lift-to-mp-pelt one)))
      ::
      %^  tag-mp-pelt  %mem-kvs-ioz-system-2
        (mpsub-pelt (w %kvsf) (mpmul-pelt (w %kvs) (w %kvs-ioz)))
      ::  \\kvs-ioz constraint system//
      ::
      ::  kvs empty triggers padding
      %^  tag-mp-pelt  %mem-pad-kvsf-relation
        %+  mpscal-pelt  (v %pad)
        (mpsub-pelt (lift-to-mp-pelt one) (w %kvsf))
      ::
      ::  dmult 0 when axis isn't labelled 0
      :-  :-  %mem-axis-nonzero-dmult-zero
        %-  lift-to-mega
        (mpmul (v %axis-flag) (v %dmult))
      ::
      ::  dmult can only be 0 or 1
      :-  :-  %mem-dmult-is-binary
        %-  lift-to-mega
        (mpmul (v %dmult) (mpsub one (v %dmult)))
      ::
      ::  dmult 0 in padding
      :-  :-  %mem-dmult-zero-in-padding
        %-  lift-to-mega
        (mpmul (mpsub one (v %pad)) (v %dmult))
      ::
      ::  //formula subnodes (axis=0) don't go in the multiset\\
      :-  :-  %mem-axis-zero-mult-zero
        %-  lift-to-mega
        (mpmul (v %mult) (mpsub one (v %axis-flag)))
      ::
      :-  :-  %mem-axis-zero-mult-lc-zero
        %-  lift-to-mega
        (mpmul (v %mult-lc) (mpsub one (v %axis-flag)))
      ::
      :-  :-  %mem-axis-zero-mult-rc-zero
        %-  lift-to-mega
        (mpmul (v %mult-rc) (mpsub one (v %axis-flag)))
      ::  \\formula subnodes (axis=0) don't go in the multiset//
      ::
      ::  //multiplicities zero in padding\\
      :-  :-  %mem-mult-zero-in-pad
        %-  lift-to-mega
        (mpmul (mpsub one (v %pad)) (v %mult))
      ::
      :-  :-  %mem-mult-lc-zero-in-pad
        %-  lift-to-mega
        (mpmul (mpsub one (v %pad)) (v %mult-lc))
      ::
      :-  :-  %mem-mult-rc-zero-in-pad
        %-  lift-to-mega
        (mpmul (mpsub one (v %pad)) (v %mult-rc))
      ::  \\multiplicities zero in padding//
      ~
    ::
    ++  transition-constraints
      ^-  (map term mp-ultra)
      ~+
      =,  constraint-util
      =/  r   ~(r rnd:chal (make-chal-mps:chal chal-names-all:chal))
      =/  [a=mp-pelt b=mp-pelt c=mp-pelt d=mp-pelt e=mp-pelt f=mp-pelt g=mp-pelt]
        [(r %a) (r %b) (r %c) (r %d) (r %e) (r %f) (r %g)]
      =/  [j=mp-pelt k=mp-pelt l=mp-pelt m=mp-pelt n=mp-pelt o=mp-pelt ww=mp-pelt x=mp-pelt y=mp-pelt]
        [(r %j) (r %k) (r %l) (r %m) (r %n) (r %o) (r %w) (r %x) (r %y)]
      =/  [alf=mp-pelt bet=mp-pelt gam=mp-pelt z=mp-pelt]
        [(r %alf) (r %bet) (r %gam) (r %z)]
      =/  ion-chals
        :+  [a.a a.b a.c a.alf]
          [b.a b.b b.c b.alf]
        [c.a c.b c.c c.alf]
      ::=/  invalf  (mpinv-pelt alf)
      =/  one  (mp-c 1)
      =/  input  (r %input)
      =/  l-axis  (mpmul (mp-c 2) (v %axis))
      =/  r-axis  (mpadd (mpmul (mp-c 2) (v %axis)) (v %axis-flag))
      %-  roll
      :_  |=  [[nam=col-name mp=mp-ultra] constraints=(map col-name mp-ultra)]
          ::  asserts we haven't seen this name before to prevent
          ::  constraint overwriting in the case of accidental name doubling
          ?>  ?=(~ (~(get by constraints) nam))
          (~(put by constraints) [nam mp])
      ^-  (list [col-name mp-ultra])
      ::
      ::  padding section stays the padding section
      :-  :-  %mem-pad-stay-pad
        %-  lift-to-mega
        (mpmul (mpsub one (v %pad)) (v %pad-n))
      ::
      ::  count update
      :-  :-  %mem-count-update
        %-  lift-to-mega
        %+  mpsub  (v %count-n)
        %+  mpadd
          (mpmul (v %pad) (mpadd (v %count) one))
        (mpmul (mpsub one (v %pad)) (mpsub (v %count) one))
      ::
      ::  ln=line-number evolution
      %^  tag-mp-pelt  %mem-line-number-update
        (mpsub-pelt (w-n %ln) (mpmul-pelt (w %ln) z))
      ::
      ::  nc=node-count evolution
      %^  tag-mp-pelt  %mem-node-count-update
        %+  mpsub-pelt  (w-n %nc)
        ;:  mpadd-pelt
          %-  mpscal-pelt
          :_  (w %nc)
          (mpmul (mpsub one (v %op-l)) (mpsub one (v %op-r)))
        ::
          %+  mpscal-pelt
            %+  mpadd  (mpmul (v %op-l) (mpsub one (v %op-r)))
            (mpmul (v %op-r) (mpsub one (v %op-l)))
          (mpmul-pelt (w %nc) z)
        ::
          %+  mpscal-pelt
            (mpmul (v %op-l) (v %op-r))
          :(mpmul-pelt (w %nc) z z)
        ==
      ::
      ::  kvs update
      %^  tag-mp-pelt  %mem-kvs-update
        %+  mpsub-pelt
          %+  mpadd-pelt  (w-n %kvs)
          %+  mpmul-pelt  (w %ln)
          %-  ~(compress poly-tupler-pelt ~[j k l m])
          :~  (w %parent-size)
              (w %parent-dyck)
              (w %parent-leaf)
              [(v %axis) (mp-c 0) (mp-c 0)]
          ==
        ;:  mpadd-pelt
          (w %kvs)
        ::
          %+  mpscal-pelt  (v %op-l)
          ;:  mpmul-pelt
            z
            (w %nc)
            %-  ~(compress poly-tupler-pelt ~[j k l m])
            :~  (w %lc-size)
                (w %lc-dyck)
                (w %lc-leaf)
                [l-axis (mp-c 0) (mp-c 0)]
            ==
          ==
        ::
          %+  mpscal-pelt  (mpmul (mpsub one (v %op-l)) (v %op-r))
          ;:  mpmul-pelt
            z
            (w %nc)
            %-  ~(compress poly-tupler-pelt ~[j k l m])
            :~  (w %rc-size)
                (w %rc-dyck)
                (w %rc-leaf)
                [r-axis (mp-c 0) (mp-c 0)]
            ==
          ==
        ::
          %+  mpscal-pelt  (mpmul (v %op-l) (v %op-r))
          ;:  mpmul-pelt
            z  z
            (w %nc)
            %-  ~(compress poly-tupler-pelt ~[j k l m])
            :~  (w %rc-size)
                (w %rc-dyck)
                (w %rc-leaf)
                [r-axis (mp-c 0) (mp-c 0)]
            ==
          ==
        ==
      ::
      ::  decode mset transition constraint
      :-  :-  %mem-decode-mset-update
        =/  trip
          %-  ~(compress poly-tupler-pelt ~[j k l m n o ww x y])
          :~  (w %parent-size)
              (w %parent-dyck)
              (w %parent-leaf)
              (w %lc-size)
              (w %lc-dyck)
              (w %lc-leaf)
              (w %rc-size)
              (w %rc-dyck)
              (w %rc-leaf)
          ==
        =/  com
          %+  mpsub-pelt
            %+  mpmul-pelt
              (mpsub-pelt (w-n %decode-mset) (w %decode-mset))
            (mpsub-pelt gam [(mp-com 0) (mp-com 1) (mp-com 2)])
          %-  lift-to-mp-pelt
          (mpmul (mpsub one (v %axis-flag)) (v %dmult))
        :+  %comp
          ~[a.trip b.trip c.trip]
        ~[a.com b.com c.com]
      ::
      ::  op0 mset transition constraint
      %^  tag-mp-comp  %mem-op0-mset-update
        =/  mvar
          %+  mpadd-pelt
            input
          %-  ~(compress poly-tupler-pelt ~[m j k l])
          :~  [(v %axis) (mp-c 0) (mp-c 0)]
              (w %parent-size)
              (w %parent-dyck)
              (w %parent-leaf)
          ==
        =/  mvar-lc
          %+  mpadd-pelt
            input
          %-  ~(compress poly-tupler-pelt ~[m j k l])
          :~  [l-axis (mp-c 0) (mp-c 0)]
              (w %lc-size)
              (w %lc-dyck)
              (w %lc-leaf)
          ==
        =/  mvar-rc
          %+  mpadd-pelt
            input
          %-  ~(compress poly-tupler-pelt ~[m j k l])
          :~  [r-axis (mp-c 0) (mp-c 0)]
              (w %rc-size)
              (w %rc-dyck)
              (w %rc-leaf)
          ==
        %+  mpcomp-pelt
          ::  Dependency
          ;:  mpmul-pelt
            (mpsub-pelt (w-n %op0-mset) (w %op0-mset))
            (mpsub-pelt bet mvar)
            (mpsub-pelt bet mvar-lc)
          ==
        ::  Computation using dependency
        %+  mpsub-pelt
          %+  mpmul-pelt
            :: Symbolic representation of dependency
            [a=(mp-com 0) b=(mp-com 1) c=(mp-com 2)]
          (mpsub-pelt bet mvar-rc)
        ;:  mpadd-pelt
          %+  mpscal-pelt  (v %mult)
          (mpmul-pelt (mpsub-pelt bet mvar-lc) (mpsub-pelt bet mvar-rc))
        ::
          %+  mpscal-pelt  (mpmul (mpsub one (v %op-l)) (v %mult-lc))
          (mpmul-pelt (mpsub-pelt bet mvar) (mpsub-pelt bet mvar-rc))
        ::
          %+  mpscal-pelt  (mpmul (mpsub one (v %op-r)) (v %mult-rc))
          (mpmul-pelt (mpsub-pelt bet mvar) (mpsub-pelt bet mvar-lc))
        ==
      ~
    ::
    ++  extra-constraints
      ^-  (map term mp-ultra)
      ~+
      ~&  %processing-extra-constraints
      =,  constraint-util
      =/  r   ~(r rnd:chal (make-chal-mps:chal chal-names-all:chal))
      =/  [j=mp-pelt k=mp-pelt l=mp-pelt m=mp-pelt n=mp-pelt o=mp-pelt ww=mp-pelt x=mp-pelt y=mp-pelt]
        [(r %j) (r %k) (r %l) (r %m) (r %n) (r %o) (r %w) (r %x) (r %y)]
      =/  [alf=mp-pelt bet=mp-pelt gam=mp-pelt z=mp-pelt]
        [(r %alf) (r %bet) (r %gam) (r %z)]
      %-  ~(gas by *(map term mp-ultra))
      ::
      %^  tag-mp-pelt  %data-constraint-1
        =/  p1
          %-  ~(compress poly-tupler-pelt ~[j k l m])
          :~  (w %ln)
              (w %nc)
              (w %kvs)
              (w %kvs-ioz)
          ==
        =/  p2
          %-  ~(compress poly-tupler-pelt ~[n o ww x])
          :~  (w %ln)
              (w %nc)
              (w %kvs)
              (w %kvs-ioz)
          ==
        %+  mpsub-pelt  (w %data-k)
        ;:  mpmul-pelt
          p1
          p2
          (mpadd-pelt p1 p2)
          (w %kvs-ioz)
        ==
      ~
    --
  --
--
