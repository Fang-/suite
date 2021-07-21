::  youtube/get-videos: query youtube api for video details
::
/+  strandio
::
|=  args=vase
=/  video-ids=(list @t)
  ~|  args
  !<((list @t) args)
=/  m  (strand:strandio ,vase)
|^  =|  out=(map @t video-details)
    |-  ^-  form:m
    =*  loop  $
    ?~  video-ids  (pure:m !>(out))
    ;<  res=video-details  bind:m
      (get-video-details i.video-ids)
    =.  out  (~(put by out) i.video-ids res)
    loop(video-ids t.video-ids)
::
+$  video-id  cord
+$  video-details
  $:  name=cord
      duration=@dr
      channel-id=cord
  ==
::
++  build-request
  |=  [=path data=(list [@t @t])]
  ^-  request:http
  =;  url=cord
    ~&  [%url url]
    :*  method=%'GET'
        url=url
        header-list=['Content-Type'^'application/json' ~]
        body=~
    ==
  ;:  (cury cat 3)
    'https://www.googleapis.com/youtube/v3'
    (spat path)
  ::
    %+  roll
      ::TODO  load api key from disk or something?
      `_data`[['key' 'XX your api key here XX'] data]
    |=  [[key=cord value=cord] all=cord]
    ;:  (cury cat 3)
      all
      ?:(=('' all) '?' '&')
      key
      '='
      value
    ==
  ==
::
++  youtube-api-request
  |=  [=path data=(list [@t @t])]
  =/  m  (strand:strandio ,json)
  ^-  form:m
  =/  request  (build-request path data)
  ;<  ~  bind:m  (send-request:strandio request)
  ;<  rep=(unit client-response:iris)  bind:m
    take-maybe-response:strandio
  ?~  rep
    (pure:m ~)
  =*  client-response  u.rep
  ?>  ?=(%finished -.client-response)
  ?~  full-file.client-response
    (pure:m `json`~)
  =*  body=@t  q.data.u.full-file.client-response
  ~|  body
  (pure:m (need (de-json:html body)))
::
++  get-video-details
  |=  =video-id
  =/  m  (strand:strandio video-details)
  ;<  res=json  bind:m
    %+  youtube-api-request  /videos
    :~  ['part' 'snippet,contentDetails']
        ['id' video-id]
    ==
  %-  pure:m
  ~|  res
  |^  =,  dejs:format
      ^-  video-details
      =-  ~!  -  -
      %+  snag  0
      ((ot 'items'^(ar item) ~) res)
  ::
  ++  item
    =,  dejs:format
    |=  =json
    ~|  json
    %.  json
    %-  ot
    :~  'snippet'^(ot 'title'^so ~)
        'contentDetails'^(ot 'duration'^(cu yule (su dure)) ~)
        'snippet'^(ot 'channelId'^so ~)
    ==
  ::  +dure: parse ISO 8401 duration (excluding months, years)
  ::TODO  stdlib?
  ::
  ++  dure
    ;~  pfix  (jest 'PT')
      ;~  plug
        (easy 0)
        ;~(pose ;~(sfix dum:ag (just 'H')) (easy 0))
        ;~(pose ;~(sfix dum:ag (just 'M')) (easy 0))
        ;~(pose ;~(sfix dum:ag (just 'S')) (easy 0))
        (easy ~)
      ==
    ==
  --
--
