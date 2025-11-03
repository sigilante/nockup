/=  *  /common/zeke
/=  stark-verifier  /common/stark/verifier
/#  softed-constraints
::
|%
::
++  verifier
  =|  in=stark-input
  ::  +<+< = stark-engine door sample wrt stark-verifier core
  =/  sc=stark-config
    %*  .  *stark-config
      prep  softed-constraints
    ==
  %_    stark-verifier
      +<+<
    %_  in
      stark-config        sc
    ==
  ==
::
++  verify
  |=  [=proof override=(unit (list term)) eny=@]
  (verify:verifier proof override eny)
--
