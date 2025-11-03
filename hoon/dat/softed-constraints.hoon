/=  *  /common/zeke
/*  constraints-0-1  %jam  /jams/constraints-0-1/jam
/*  constraints-2    %jam  /jams/constraints-2/jam
^-  preprocess
::
=/  cue-0-1=*  (cue q.constraints-0-1)
=/  soft-0-1  ((soft preprocess-0-1) cue-0-1)
?~  soft-0-1
  ~&  "fatal: failed to soft constraints!"  !!
::
=/  cue-2=*  (cue q.constraints-2)
=/  soft-2  ((soft preprocess-2) cue-2)
?~  soft-2
  ~&  "fatal: failed to soft constraints!"  !!
[u.soft-0-1 u.soft-2]
