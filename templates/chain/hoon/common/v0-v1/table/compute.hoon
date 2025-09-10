/=  *  /common/zeke
|%
++  static
  =,  constraint-util
  ^-  static-table-common
  |%
  ::  +name: name of the table
  ::  +basic-column-names: names for base columns as terms
  ::  +ext-column-names: names for extension columns as terms
  ::  +column-names: names for all columns as terms
  ++  name  %compute
  ++  column-names
    ^-  (list col-name)
    ^~(:(weld basic-column-names ext-column-names mega-ext-column-names))
::
  ++  basic-column-names
    ^-  (list col-name)
    :~  %pad
        %op0
        %op1
        %op2
        %op3
        %op4
        %op5
        %op6
        %op7
        %op8
        %op9
    ==
  ::
  ++  ext-column-names
    ^-  (list col-name)
    %+  pelt-col  %s-size
    %+  pelt-col  %s-leaf
    %+  pelt-col  %s-dyck
    %+  pelt-col  %f-size
    %+  pelt-col  %f-leaf
    %+  pelt-col  %f-dyck
    %+  pelt-col  %e-size
    %+  pelt-col  %e-leaf
    %+  pelt-col  %e-dyck
    %+  pelt-col  %sf1-s-size
    %+  pelt-col  %sf1-s-leaf
    %+  pelt-col  %sf1-s-dyck
    %+  pelt-col  %sf1-f-size
    %+  pelt-col  %sf1-f-leaf
    %+  pelt-col  %sf1-f-dyck
    %+  pelt-col  %sf1-e-size
    %+  pelt-col  %sf1-e-leaf
    %+  pelt-col  %sf1-e-dyck
    %+  pelt-col  %sf2-s-size
    %+  pelt-col  %sf2-s-leaf
    %+  pelt-col  %sf2-s-dyck
    %+  pelt-col  %sf2-f-size
    %+  pelt-col  %sf2-f-leaf
    %+  pelt-col  %sf2-f-dyck
    %+  pelt-col  %sf2-e-size
    %+  pelt-col  %sf2-e-leaf
    %+  pelt-col  %sf2-e-dyck
    %+  pelt-col  %sf3-s-size
    %+  pelt-col  %sf3-s-leaf
    %+  pelt-col  %sf3-s-dyck
    %+  pelt-col  %sf3-f-size
    %+  pelt-col  %sf3-f-leaf
    %+  pelt-col  %sf3-f-dyck
    %+  pelt-col  %sf3-e-size
    %+  pelt-col  %sf3-e-leaf
    %+  pelt-col  %sf3-e-dyck
    %+  pelt-col  %f-h-size
    %+  pelt-col  %f-h-leaf
    %+  pelt-col  %f-h-dyck
    %+  pelt-col  %f-t-size
    %+  pelt-col  %f-t-leaf
    %+  pelt-col  %f-t-dyck
    %+  pelt-col  %f-th-size
    %+  pelt-col  %f-th-leaf
    %+  pelt-col  %f-th-dyck
    %+  pelt-col  %f-tt-size
    %+  pelt-col  %f-tt-leaf
    %+  pelt-col  %f-tt-dyck
    %+  pelt-col  %f-tth-size
    %+  pelt-col  %f-tth-leaf
    %+  pelt-col  %f-tth-dyck
    %+  pelt-col  %f-ttt-size
    %+  pelt-col  %f-ttt-leaf
    %+  pelt-col  %f-ttt-dyck
    %+  pelt-col  %fcons-inv
    ~
  ::
  ++  mega-ext-column-names
    ^-  (list col-name)
    %+  pelt-col  %ln
    %+  pelt-col  %sfcons-inv
    %+  pelt-col  %opc
    %+  pelt-col  %stack-kv
    %+  pelt-col  %decode-mset
    %+  pelt-col  %op0-mset
    ~
  ::
  ++  variables
    ^-  (map col-name mp-mega)
    (make-vars:tlib column-names)
  ::
  ++  terminal-names
    ^-  (list col-name)
    %+  pelt-col  %compute-s-size
    %+  pelt-col  %compute-s-leaf
    %+  pelt-col  %compute-s-dyck
    %+  pelt-col  %compute-f-size
    %+  pelt-col  %compute-f-leaf
    %+  pelt-col  %compute-f-dyck
    %+  pelt-col  %compute-e-size
    %+  pelt-col  %compute-e-leaf
    %+  pelt-col  %compute-e-dyck
    %+  pelt-col  %compute-decode-mset
    %+  pelt-col  %compute-op0-mset
    ~
  --
--
