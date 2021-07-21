::  podium: unauthenticated gall subscriptions for outsiders
::
::    use this lib to poke /app/podium for setup
::
|_  =bowl:gall
++  expose
  |=  =path
  ^-  card:agent:gall
  :*  %pass
      [%podium %expose dap.bowl path]
      %agent
      [our.bowl %podium]
      %poke
      %podium-action
      !>([%expose dap.bowl path])
  ==
::
++  censor
  |=  =path
  ^-  card:agent:gall
  :*  %pass
      [%podium %censor dap.bowl path]
      %agent
      [our.bowl %podium]
      %poke
      %podium-action
      !>([%censor dap.bowl path])
  ==
--
