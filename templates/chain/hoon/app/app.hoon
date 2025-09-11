::  /ker/wallet/wallet: nockchain wallet
/=  bip39  /common/bip39
/=  slip10  /common/slip10
/=  m  /common/markdown/types
/=  md  /common/markdown/markdown
/=  transact  /common/tx-engine
/=  z   /common/zeke
/=  zo  /common/zoon
/=  dumb  /app/dumbnet/lib/types
/=  *   /common/zose
/=  *  /common/wrapper
/=  wt  /app/wallet/lib/types
/=  wutils  /app/wallet/lib/utils
/=  tx-builder  /app/wallet/lib/tx-builder
=>
=|  bug=_&
|%
++  utils  ~(. wutils bug)
::
::  re-exporting names from wallet types while passing the bug flag
++  debug  debug:utils
++  warn  warn:utils
++  s10  s10:utils
++  moat  (keep state:wt)
--
::
%-  (moat &)
^-  fort:moat
|_  =state:wt
+*  v  ~(. vault:utils state)
    d  ~(. draw:utils state)
    e  ~(. edit:utils state)
    p  ~(. plan:utils transaction-tree.state)
::
++  load
  |=  old=versioned-state:wt
  ^-  state:wt
  |^
  ?-  -.old
    %0  state-0-1
    %1  old
  ==
  ::
  ++  state-0-1
    ^-  state:wt
    ?>  ?=(%0 -.old)
    :*  %1
        balance.old
        master.old
        keys.old
        last-block.old
        peek-requests.old
        active-transaction.old
        active-input.old
        active-seed.old
        transaction-tree.old
        pending-commands.old
    ==
  --
::
++  peek
  |=  =path
  ^-  (unit (unit *))
  ~>  %slog.[0 'Peeks awaiting implementation']
  ~
::
++  poke
  |=  =ovum:moat
  |^
  ^-  [(list effect:wt) state:wt]
  =/  cause=(unit cause:wt)
    %-  (soft cause:wt)
    cause.input.ovum
  =/  failure=effect:wt  [%markdown '## Poke failed']
  ?~  cause
    %-  (warn "input does not have a proper cause: {<cause.input.ovum>}")
    [~[failure] state]
  =/  =cause:wt  u.cause
  =/  wir=(pole)  wire.ovum
  ::  B3:  Route on wire before [value], never [value] before wire.
  ::  "When we send a message to another ... app, we send it on a wire.
  ::  When we get a response to that message, we should care first about
  ::  the wire it was sent on.""  (Philip Monk, https://urbit.org/blog/precepts-discussion)
  ?+    wir  ~|("unsupported wire: {<wire.ovum>}" !!)
  ::  gRPC response.
  ::    /poke/grpc/ver/pid/tag
      [%poke %grpc ver=@ pid=@ tag=@tas ~]
    ~&  wire+wir
    ~&  >  cause+cause
    ::  Sort on tag
    ?+    tag.wir  ~|((crip "Unexpected tag {<tag.wir>}") !!)
        %chain
      =^  effs  state
        (do-grpc-bind cause tag.wir)
      [(weld effs ~[[%exit ~]]) state]
    ==
  ::  Main poke from Rust.
  ::    /poke/one-punch/ver/* etc.
      [%poke ?(%one-punch %sys %wallet) ver=@ *]
    ?+    -.cause  ~|("unsupported cause: {<-.cause>}" !!)
        %get-heaviest-block
      ~&  >  'heavy'
      =/  pid  generate-pid:v
      :_  state
      ^-  (list effect:wt)
      :~  [%grpc %peek pid %chain /heavy]
      ==
    ==
  ==
  ::
  ++  do-grpc-bind
    |=  [=cause:wt typ=@tas]
    %-  (debug "grpc-bind")
    ?>  ?=(%grpc-bind -.cause)
    ?+    typ  ~|('No matching cause type for gRPC binding.' !!)
        %chain
      =/  softed=(unit (unit (unit (unit block-id:transact))))
        %-  (soft (unit (unit (unit block-id:transact))))
        result.cause
      ?~  softed
        ~|  'Invalid block ID returned.'
        !!
      ~&  "Heaviest block is {<(to-b58:hash:transact +>+:u.softed)>}"
      [~ state]
    ==
  ::
  --  ::+poke
--
