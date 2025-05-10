::  owntracks: tests
::
/+  ot=owntracks, test
|%
++  test-parse-msg-location
  %+  expect-eq:test
    !>  ^-  (unit message:ot)
    %-  some
    :*  %location
        acc=`13
        alt=`--52
        batt=~
        bs=%unknown
        cog=`0
        lat=.~12.345678
        lon=.~1.2345678
        rad=~
        t=`%u
        tid='zo'
        tst=~2025.5.3..19.15.19
        vac=`0  ::REVIEW  should be ~ if 0? (same q for .vel, .cog)
        vel=`0
        p=~
        poi=~
        conn=~
        tag=~
        topic='owntracks/~zod/phoneee'
        inregions=~['aavvcc']
        inrids=~
        ssid=~
        bssid=~
        created-at=`~2025.5.3..19.15.20
        m=~
        id=~
    ==
  !>  ^-  (unit message:ot)
  %-  message:dejs:ot
  %-  need
  %-  de:json:html
  '''
  {
    "_type": "location",
    "_id": "03f72725",
    "acc": 13,
    "alt": 52,
    "cog": 0,
    "created_at": 1746299720,
    "inregions": [
      "aavvcc"
    ],
    "lat": 12.345678,
    "lon": 1.2345678,
    "t": "u",
    "tid": "zo",
    "topic": "owntracks/~zod/phoneee",
    "tst": 1746299719,
    "vac": 0,
    "vel": 0
  }
  '''
::
++  test-parse-msg-location-no-t
  %+  expect-eq:test
    !>  ^-  (unit message:ot)
    %-  some
    :*  %location
        acc=`13
        alt=`--52
        batt=~
        bs=%unknown
        cog=`0
        lat=.~12.345678
        lon=.~1.2345678
        rad=~
        t=~
        tid='zo'
        tst=~2025.5.3..19.15.19
        vac=`0  ::REVIEW  should be ~ if 0? (same q for .vel, .cog)
        vel=`0
        p=~
        poi=~
        conn=~
        tag=~
        topic='owntracks/~zod/phoneee'
        inregions=~['aavvcc']
        inrids=~
        ssid=~
        bssid=~
        created-at=`~2025.5.3..19.15.20
        m=~
        id=~
    ==
  !>  ^-  (unit message:ot)
  %-  message:dejs:ot
  %-  need
  %-  de:json:html
  '''
  {
    "_type": "location",
    "_id": "03f72725",
    "acc": 13,
    "alt": 52,
    "cog": 0,
    "created_at": 1746299720,
    "inregions": [
      "aavvcc"
    ],
    "lat": 12.345678,
    "lon": 1.2345678,
    "tid": "zo",
    "topic": "owntracks/~zod/phoneee",
    "tst": 1746299719,
    "vac": 0,
    "vel": 0
  }
  '''
::
++  test-parse-msg-location-extended
  ::NOTE  capitalized keys, space in topic, odd mode
  %+  expect-eq:test
    !>  ^-  (unit message:ot)
    %-  some
    :*  %location
        acc=`21
        alt=`--52
        batt=`48
        bs=%unplugged
        cog=`250
        lat=.~12.345678
        lon=.~1.2345678
        rad=~
        t=`%u
        tid='zo'
        tst=~2025.5.3..19.07.43
        vac=`1
        vel=`1
        p=~
        poi=~
        conn=`%w
        tag=~
        topic='owntracks/~zod/phone 3'
        inregions=~
        inrids=~
        ssid=`'~'
        bssid=`'55:44:33:dd:d0:84'
        created-at=`~2025.5.3..19.07.44
        m=`%manual
        id=~
    ==
  !>  ^-  (unit message:ot)
  %-  message:dejs:ot
  %-  need
  %-  de:json:html
  '''
  {
    "_type": "location",
    "BSSID": "55:44:33:dd:d0:84",
    "SSID": "~",
    "_id": "b85f2944",
    "acc": 21,
    "alt": 52,
    "batt": 48,
    "bs": 1,
    "cog": 250,
    "conn": "w",
    "created_at": 1746299264,
    "lat": 12.345678,
    "lon": 1.2345678,
    "m": 0,
    "t": "u",
    "tid": "zo",
    "topic": "owntracks/~zod/phone 3",
    "tst": 1746299263,
    "vac": 1,
    "vel": 1
  }
  '''
::
++  test-parse-waypoints-empty
  %+  expect-eq:test
    !>  ^-  (unit message:ot)
    %-  some
    [%waypoints ~]
  !>  ^-  (unit message:ot)
  %-  message:dejs:ot
  %-  need
  %-  de:json:html
  '''
  {"_type":"waypoints","_id":"a5ee66f6","topic":"owntracks/~zod/phonee/waypoints"}
  '''
::
++  test-parse-waypoints
  %+  expect-eq:test
    !>  ^-  (unit message:ot)
    %-  some
    :-  %waypoints
    :~  :*  desc='aavvcc'
            lat=`.~12.345678
            lon=`.~1.2345678
            rad=`20
            tst=~2025.5.3..19.10.39
            uuid=~
            major=~
            minor=~
            rid=~
    ==  ==
  !>  ^-  (unit message:ot)
  %-  message:dejs:ot
  %-  need
  %-  de:json:html
  '''
  {
    "_type": "waypoints",
    "_id": "a2b52a9f",
    "topic": "owntracks/~zod/phoneee/waypoints",
    "waypoints": [
      {
        "_type": "waypoint",
        "_id": "06a42106",
        "desc": "aavvcc",
        "lat": 12.345678,
        "lon": 1.2345678,
        "rad": 20,
        "tst": 1746299439
      }
    ]
  }
  '''
::
++  test-parse-waypoint
  %+  expect-eq:test
    !>  ^-  (unit message:ot)
    %-  some
    :*  %waypoint
        desc='here'
        lat=`.~12.345678
        lon=`.~1.2345678
        rad=`20
        tst=~2025.5.3..19.47.03
        uuid=~
        major=~
        minor=~
        rid=~
    ==
  !>  ^-  (unit message:ot)
  %-  message:dejs:ot
  %-  need
  %-  de:json:html
  '''
  {
    "_type": "waypoint",
    "_id": "16c3629f",
    "desc": "here",
    "lat": 12.345678,
    "lon": 1.2345678,
    "rad": 20,
    "topic": "owntracks/~zod/phoneee/waypoint",
    "tst": 1746301623
  }
  '''
--
