/-  *spots
/+  rudder
::
^-  (page:rudder (map @t device) [%nop ~])
|_  [bowl:gall order:rudder mine=(map @t device)]
++  argue
  |=  [head=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder [%nop ~])
  'unimplemented'
::
++  final  (alert:rudder (cat 3 '/' dap) build)
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  |^  [%page page]
  ++  page
    ;html
      ;head
        ;title:"spots: home"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;link(rel "stylesheet", href "https://pal.dev/props/owntracks/ol/10.3.1/ol.css");
        ;script(src "https://pal.dev/props/owntracks/ol/10.3.1/full/ol.js");
        ;style:".map \{ width: 100%; height: 400px; }"
      ==
      ;body
        ; hello world!
        ;div#map.map;

        ;script:"{(trip points)}"
        ;script:"{(trip script)}"
      ==
    ==
  ::
  ++  points  ::TODO  separate for devices
    %^  rap  3
      'const points = ['
    =-  (snoc - ']')
    %+  join  ','
    ^-  (list @t)
    :: %-  zing
    :: ^-  (list (list @t))
    %+  turn  bac:(~(got by mine) 'flop')
    :: |=  [k=@t device]
    :: ^-  (list @t)
    :: %+  turn  bac
    |=  node
    (rap 3 '[' (rsh 3^2 (scot %rd lon)) ',' (rsh 3^2 (scot %rd lat)) ']' ~)
  ::
  ++  script
    '''
    ol.proj.useGeographic();

    const raster = new ol.layer.Tile({
      source: new ol.source.OSM(),
    });

    const source = new ol.source.Vector({wrapX: false});
    const vector = new ol.layer.Vector({
      source: source,
    });

    const map = new ol.Map({
      layers: [raster, vector],
      target: 'map',
      view: new ol.View({
        center: points[0],
        zoom: 10,
      }),
    });

    /* points.forEach(p => {
      const feat = new ol.Feature({
        geometry: new ol.geom.Point(p),
      });
      const style = new ol.style.Style({
        image: new ol.style.Circle({
          radius: 6,
          fill: new ol.style.Fill({color: 'red'}),
          stroke: new ol.style.Stroke({color: 'white', width: 2})
        })
      });
      feat.setStyle(style);
      source.addFeature(feat);
    }); */

    const feat = new ol.Feature({
      geometry: new ol.geom.LineString(points),
    });
    const style = new ol.style.Style({
      stroke: new ol.style.Stroke({
        width: 6,
        color: 'red',
      })
    });
    feat.setStyle(style);
    source.addFeature(feat);

    /* const draw = new ol.interaction.Draw({
      source: source,
      type: 'Point',
    });
    map.addInteraction(draw); */

    //TODO  use overlay for rendering friend locations
    const el = document.createElement('div');
    el.setAttribute('style', 'width: 50px; height: 50px; background-color: rgba(0,255,100,0.5); border-radius: 50%;')
    const popup = new ol.Overlay({
      element: el,
      positioning: 'bottom-center',
      stopEvent: false,
    });
    popup.setPosition(points[0]);
    map.addOverlay(popup);

    let i = 1;
    const f = () => { popup.setPosition(points[i++]); console.log('done'); setTimeout(f, 1000) };
    f();
    '''
  --
--
