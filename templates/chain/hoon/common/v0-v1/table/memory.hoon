/=  *  /common/zeke
=,  mp-to-graph
|%
++  static
  =,  constraint-util
  ^-  static-table-common
  |%
  ++  name  %memory
  ++  column-names
    ^-  (list col-name)
    ^~(:(weld basic-column-names ext-column-names mega-ext-column-names))
  ++  basic-column-names
    ^-  (list col-name)
    :~  %pad
        %axis
        %axis-ioz
        %axis-flag
        %leaf-l
        %leaf-r
        %op-l  ::  0 means atom
        %op-r  ::  0 means atom
        %count
        %count-inv
        %dmult
        %mult
        %mult-lc
        %mult-rc
    ==
  ++  ext-column-names
    ^-  (list col-name)
    %+  pelt-col  %input  ::  a*size + b*dyck + c*leaf
    %+  pelt-col  %parent-size
    %+  pelt-col  %parent-dyck
    %+  pelt-col  %parent-leaf
    %+  pelt-col  %lc-size
    %+  pelt-col  %lc-dyck
    %+  pelt-col  %lc-leaf
    %+  pelt-col  %rc-size
    %+  pelt-col  %rc-dyck
    %+  pelt-col  %rc-leaf
    %+  pelt-col  %inv
    ~
  ++  mega-ext-column-names
    ^-  (list col-name)
    %+  pelt-col  %ln
    %+  pelt-col  %nc
    %+  pelt-col  %kvs
    %+  pelt-col  %kvs-ioz  ::  key-value store inverse variables
    %+  pelt-col  %kvsf  ::  key-value flags
    %+  pelt-col  %decode-mset
    %+  pelt-col  %op0-mset
    %+  pelt-col  %data-k
    ~
  ++  variables
    ^-  (map col-name mp-mega)
    ^~  (make-vars:tlib column-names)
  ::
  ++  terminal-names
    ^-  (list term)
    ::  name of table should be first word in the term
    %+  pelt-col  %memory-nc
    %+  pelt-col  %memory-kvs
    %+  pelt-col  %memory-decode-mset
    %+  pelt-col  %memory-op0-mset
    ~
  --
--
