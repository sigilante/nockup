/=  dk  /app/dumbnet/lib/types
/=  sp  /common/stark/prover
/=  dumb-transact  /common/tx-engine
/=  *  /common/zoon
::
:: everything to do with mining and mining state
::
|_  [m=mining-state:dk =blockchain-constants:dumb-transact]
+*  t  ~(. dumb-transact blockchain-constants)
+|  %admin
::  +set-mining: set .mining
++  set-mining
  |=  mine=?
  ^-  mining-state:dk
  m(mining mine)
::
::  +set-pubkey: set .pubkey
++  set-pubkeys
  |=  pks=(list lock:t)
  ^-  mining-state:dk
  =.  pubkeys.m
    (~(gas z-in *(z-set lock:t)) pks)
  m
::
::  +set-shares validate and set .shares
++  set-shares
  |=  shr=(list [lock:t @])
  =/  s=shares:t  (~(gas z-by *(z-map lock:t @)) shr)
  ?.  (validate:shares:t s)
    ~|('invalid shares' !!)
  m(shares s)
::
++  mining-pubkeys-set
  !=(*(z-set lock:t) pubkeys.m)
::
+|  %candidate-block
++  set-pow
  |=  prf=proof:sp
  ^-  mining-state:dk
  m(pow.candidate-block (some prf))
::
++  set-digest
  ^-  mining-state:dk
  m(digest.candidate-block (compute-digest:page:t candidate-block.m))
::
++  candidate-block-below-max-size
  %+  lte
    %+  add  (compute-size-without-txs:page:t candidate-block.m)
    (txs-size-by-set:tx-acc:t candidate-acc.m)
  max-block-size:t
::
::  grab all raw-txs that could possibly be included in block.
::  note that this set could include txs that are not spendable
::  from the current heaviest balance. we rely on the logic inside
::  of process:tx-acc
::  to catch these txs and reject them.
++  candidate-txs
  |=  c=consensus-state:dk
  ^-  (z-set raw-tx:t)
  |^
    %-  ~(rep z-in candidate-tx-ids)
    |=  [=tx-id:t txs=(set raw-tx:t)]
    =/  raw  raw-tx:(~(got z-by raw-txs.c) tx-id)
    (~(put z-in txs) raw)
  ::
  ::  union of excluded tx-ids and pending block tx ids
  ::  excluding tx-ids already included in candidate block
  ++  candidate-tx-ids
    %-  %~  dif  z-in
        (~(uni z-in excluded-txs.c) pending-block-tx-ids)
    tx-ids.candidate-block.m
  ::
  ::  set of available raw-txs from pending blocks
  ++  pending-block-tx-ids
    ^-  (z-set tx-id:t)
    %-  ~(rep z-by pending-blocks.c)
    |=  [[block-id:t pag=page:t *] all=(z-set tx-id:t)]
    ^-  (z-set tx-id:t)
    %-  ~(rep z-in tx-ids.pag)
    |=  [=tx-id:t all=_all]
    ?:  (~(has z-by raw-txs.c) tx-id)
      (~(put z-in all) tx-id)
    all
  --
::
::  +update-candidate-block: updates candidate block if interval is hit
::
::  updates timestamp and adds txs to candidate block. this should be run
::  every time we get a poke.
::
++  update-candidate-block
  |=  [c=consensus-state:dk now=@da]
  ^-  [? mining-state:dk]
  ?:  ?|  =(*page:t candidate-block.m)
          !mining-pubkeys-set
      ==
    ::  not mining or no candidate block is set so no need to update
    [%.n m]
  ?:  %+  gte  timestamp.candidate-block.m
      (time-in-secs:page:t (sub now update-candidate-interval:t))
    ::  has not reached interval (default ~m2), so leave timestamp alone
    [%.n m]
  =.  timestamp.candidate-block.m  (time-in-secs:page:t now)
  =/  log-message
    %^  cat  3
      'update-candidate-block: Candidate block timestamp updated: '
    (scot %$ timestamp.candidate-block.m)
  ~>  %slog.[0 log-message]
  :-  %.y
  (add-txs-to-candidate c)
::
++  add-txs-to-candidate
  |=  c=consensus-state:dk
  ^-  mining-state:dk
  ::  if the mining pubkey is not set, do nothing
  ?:  =(*(z-set lock:t) pubkeys.m)  m
  %-  ~(rep z-in (candidate-txs c))
  |=  [raw=raw-tx:t min=_m]
  =.  m  min
  (heard-new-tx raw)
::
::
::  +heard-new-tx: potentially changes candidate block in reaction to a raw-tx
++  heard-new-tx
  |=  raw=raw-tx:t
  ^-  mining-state:dk
  =/  log-message
    %+  rap  3
    :~  'heard-new-tx: '
        'Miner received new transaction: '
        (to-b58:hash:t id.raw)
    ==
  ~>  %slog.[0 log-message]
  ::  if the mining pubkey is not set, do nothing
  ?:  =(*(z-set lock:t) pubkeys.m)  m
  ::
  ::  if the transaction is already in the candidate block, do nothing
  ?:  (~(has z-in tx-ids.candidate-block.m) id.raw)
    m
  ::  check to see if block is valid with tx - this checks whether the inputs
  ::  exist, whether the new size will exceed block size, and whether timelocks
  ::  are valid
  =/  tx=(unit tx:t)  (mole |.((new:tx:t raw height.candidate-block.m)))
  ?~  tx
    ::  invalid tx. we don't emit a %liar effect from this because it might
    ::  just not be valid for this particular block
    m
  =/  new-acc=(unit tx-acc:t)
    (process:tx-acc:t candidate-acc.m u.tx height.candidate-block.m)
  ?~  new-acc
    =/  log-message
        %+  rap  3
        :~  'heard-new-tx: '
            'Transaction '
            (to-b58:hash:t id.raw)
            ' cannot be added to candidate block.'
        ==
    ~>  %slog.[3 log-message]
    m
  =/  old-mining-state  m
  ::  we can add tx to candidate-block
  =.  tx-ids.candidate-block.m
    (~(put z-in tx-ids.candidate-block.m) id.raw)
  =/  old-fees=coins:t  fees.candidate-acc.m
  =.  candidate-acc.m  u.new-acc
  =/  new-fees=coins:t  fees.candidate-acc.m
  =/  log-message-added-tx
      %+  rap  3
      :~  'heard-new-tx: '
          'Added transaction '
          (to-b58:hash:t id.raw)
          ' to the candidate block.'
      ==
  =/  log-message-exceeds-max-size
    %+  rap  3
    :~  'heard-new-tx: '
        'Exceeds max block size, not adding tx: '
        (to-b58:hash:t id.raw)
    ==
  ::  check if new-fees != old-fees to determine if split should be recalculated.
  ::  since we don't have replace-by-fee
  ?:  =(new-fees old-fees)
    ::  fees are equal so no need to recalculate split
    ?.  candidate-block-below-max-size
      ~>  %slog.[3 log-message-exceeds-max-size]
      old-mining-state
    ~>  %slog.[3 log-message-added-tx]
    m
  ::  fees are unequal. for this miner, fees are only ever monotonically
  ::  incremented and so this assertion should never fail.
  ?>  (gth new-fees old-fees)
  =/  fee-diff=coins:t  (sub new-fees old-fees)
  ::  compute old emission+fees
  =/  old-assets=coins:t
    %+  roll  ~(val z-by coinbase.candidate-block.m)
    |=  [c=coins:t sum=coins:t]
    (add c sum)
  =/  new-assets=coins:t  (add old-assets fee-diff)
  =.  coinbase.candidate-block.m
    (new:coinbase-split:t new-assets shares.m)
  ::  check size of candidate block
  ?.  candidate-block-below-max-size
    ~>  %slog.[3 log-message-exceeds-max-size]
    old-mining-state
  ~>  %slog.[3 log-message-added-tx]
  m
::
::  +heard-new-block: refreshes the candidate block to be mined in reaction to a new block
::
::    when we hear a new heaviest block, we need to update the candidate we're attempting
::    to mine. that means we should update the parent and page number of the block, and carry
::    over any transactions we had previously been attempting to include that werent
::    included in the most recent block.
++  heard-new-block
  |=  [c=consensus-state:dk now=@da]
  ^-  mining-state:dk
  ::
  ::  do a sanity check that we have a heaviest block, and that the heaviest block
  ::  is not the parent of our current candidate block
  ?~  heaviest-block.c
    ::  genesis block has its own codepath, which is why this conditional does not attempt
    ::  to generate the genesis block
    =/  log-message
      %+  rap  3
      :~  'heard-new-block: '
          'Attempted to generate new candidate block when we have no genesis block'
      ==
    ~>  %slog.[0 log-message]
    m
  ?:  =(u.heaviest-block.c parent.candidate-block.m)
    =/  log-message
      %+  rap  3
      :~  'heard-new-block: '
          'Heaviest block unchanged, do not generate new candidate block'
      ==
    ~>  %slog.[0 log-message]
    m
  ?.  mining-pubkeys-set
    =/  log-message
      %+  rap  3
      :~  'heard-new-block: '
          'No pubkey(s) set so no new candidate block will be generated'
      ==
    ~>  %slog.[0 log-message]
    m
  =/  log-message
    ^-  @t
    %+  rap  3
    :~  'heard-new-block: '
        'Generating new candidate block with parent: '
        (to-b58:hash:t u.heaviest-block.c)
    ==
  ~>  %slog.[0 log-message]
  =.  candidate-block.m
    %-  new-candidate:page:t
    :*  (to-page:local-page:t (~(got z-by blocks.c) u.heaviest-block.c))
        now
        (~(got z-by targets.c) u.heaviest-block.c)
        shares.m
    ==
  =.  candidate-acc.m
    (new:tx-acc:t (~(get z-by balance.c) u.heaviest-block.c))
  ::
  ::  roll over the candidate txs and try to include them in the new candidate block
  (add-txs-to-candidate c)
--
