|%
::  Commands
+$  peek-command
  $%  [%path =path]
  ==
::
+$  poke-command
  $%  [%poke-simple ~]
      [%poke-value val=@]
  ==
::  Causes
+$  cause
  $%  other-cause
      grpc-bind-cause
  ==
::
+$  other-cause
  $%  [%born command=peek-command]
  ==
::
+$  grpc-bind-cause
  $%  [%grpc-bind result=(unit (unit *))]
  ==
::  Effects
+$  effect
  $%  [%exit code=@]
      [%grpc grpc-effect]
  ==
::
+$  grpc-effect
  $%  [%peek pid=@ typ=@tas =path]
  ==
--
