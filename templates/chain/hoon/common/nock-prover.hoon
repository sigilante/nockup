/=  *  /common/zeke
/=  stark-prover  /common/stark/prover
/#  softed-constraints
::
|%
::
++  prover
  =|  in=stark-input
  ::  +<+< = stark-engine door sample wrt stark-verifier core
  =/  sc=stark-config
    %*  .  *stark-config
      prep  softed-constraints
    ==
  %_    stark-prover
      +<+<
    %_  in
      stark-config        sc
    ==
  ==
::
++  prove
  |=  input=prover-input:stark-prover
  (prove:prover input)
--
