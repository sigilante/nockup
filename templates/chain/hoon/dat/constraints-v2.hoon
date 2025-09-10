/=  z  /common/zeke
/=  nock-common  /common/v2/nock-common
=<  preprocess-data
|%
::  +preprocess-data: precompute all data necessary to run the prover/verifier
++  preprocess-data
  ^-  preprocess-2:z
  |^
  ~&  %computing-preprocess-data
  =/  cd  compute-table-to-constraint-degree
  =/  constraints  compute-constraints
  =/  count-map  count-constraints
  :*  %2
      cd
      constraints
      count-map
  ==
  ::
  ::    compute max degree of the constraints for each table
  ++  compute-table-to-constraint-degree
    ^-  table-to-constraint-degree:z
    %-  ~(gas by *(map @ constraint-degrees:z))
    %+  iturn:z  all-verifier-funcs:nock-common
    |=  [i=@ funcs=verifier-funcs:z]
    ^-  [@ constraint-degrees:z]
    [i (compute-constraint-degree funcs)]
  ::
  ++  compute-constraint-degree
    |=  funcs=verifier-funcs:z
    ^-  constraint-degrees:z
    =-  [(snag 0 -) (snag 1 -) (snag 2 -) (snag 3 -) (snag 4 -)]
    %+  turn
      :~  (unlabel-constraints:constraint-util:z boundary-constraints:funcs)
          (unlabel-constraints:constraint-util:z row-constraints:funcs)
          (unlabel-constraints:constraint-util:z transition-constraints:funcs)
          (unlabel-constraints:constraint-util:z terminal-constraints:funcs)
          (unlabel-constraints:constraint-util:z extra-constraints:funcs)
      ==
    |=  l=(list mp-ultra:z)
    %+  roll
      l
    |=  [constraint=mp-ultra:z d=@]
    %+  roll
      (mp-degree-ultra:z constraint)
    |=  [a=@ d=_d]
    (max d a)
  ::
  ++  compute-constraints
    ^-  (map @ constraints:z)
    |^
    %-  ~(gas by *(map @ constraints:z))
    %+  iturn:z  all-verifier-funcs:nock-common
    |=  [i=@ funcs=verifier-funcs:z]
    :-  i
    :*  (build-constraint-data boundary-constraints:funcs)
        (build-constraint-data row-constraints:funcs)
        (build-constraint-data transition-constraints:funcs)
        (build-constraint-data terminal-constraints:funcs)
        (build-constraint-data extra-constraints:funcs)
    ==
    ::
    ++  build-constraint-data
      |=  cs=(map term mp-ultra:z)
      ^-  (list constraint-data:z)
      %+  turn  (unlabel-constraints:constraint-util:z cs)
      |=  c=mp-ultra:z
      [c (mp-degree-ultra:z c)]
    --
  ::
  ++  count-constraints
    ^-  (map @ constraint-counts:z)
    |^
    =/  vrf-funcs  all-verifier-funcs:nock-common
    %-  ~(gas by *(map @ constraint-counts:z))
    %+  iturn:z
      all-verifier-funcs:nock-common
    |=  [i=@ funcs=verifier-funcs:z]
    :-  i
    :*  (count (unlabel-constraints:constraint-util:z boundary-constraints:funcs))
        (count (unlabel-constraints:constraint-util:z row-constraints:funcs))
        (count (unlabel-constraints:constraint-util:z transition-constraints:funcs))
        (count (unlabel-constraints:constraint-util:z terminal-constraints:funcs))
        (count (unlabel-constraints:constraint-util:z extra-constraints:funcs))
    ==
    ::
    ++  count
      |=  cs=(list mp-ultra:z)
      ^-  @
      %+  roll
        cs
      |=  [mp=mp-ultra:z num=@]
      ?-    -.mp
          %mega  +(num)
          %comp  (add num (lent com.mp))
      ==
    --
  --  :: |^
--
