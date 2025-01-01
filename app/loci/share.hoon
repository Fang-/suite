/-  *loci
/+  rudder
::
|=  [did=@t til=(unit @da) device]
^-  reply:rudder
=+  loc=(snag 0 bac)
|^  [%page page]
++  page
  ;html
    ;head
      ;title:"loci: home"
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;link(rel "stylesheet", href "https://pal.dev/props/owntracks/ol/10.3.1/ol.css");
      ;script(src "https://pal.dev/props/owntracks/ol/10.3.1/full/ol.js");
      ;style:".map \{ width: 100%; height: 400px; }"
    ==
    ;body
      ; battery
      ;span#battery:"{?~(bat "??" (a-co:co cen.u.bat))}%"
      ; % at
      ;span#stamp:"{(scow %da msg.wen.loc)}"
      ;div#map.map;

      ;script:"{vars}"
      ;script:"{(trip script)}"
    ==
  ==
::
++  vars
  """
  const loc = [
    {(trip (rsh 3^2 (scot %rd lon.loc)))},
    {(trip (rsh 3^2 (scot %rd lat.loc)))}
  ];
  """
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

  const view = new ol.View({
    center: loc,
    zoom: 10,
  });
  const map = new ol.Map({
    layers: [raster, vector],
    target: 'map',
    view: view,
  });

  const feat = new ol.Feature({
    geometry: new ol.geom.Point(loc),
  });
  const style = new ol.style.Style({
    image: new ol.style.Circle({
      radius: 8,
      fill: new ol.style.Fill({color: 'red'}),
      stroke: new ol.style.Stroke({color: 'white', width: 2})
    })
  });
  feat.setStyle(style);
  source.addFeature(feat);

  const feat2 = new ol.Feature({
    geometry: new ol.geom.Point(loc),
  });
  const style2 = new ol.style.Style({
    image: new ol.style.Circle({
      radius: 16,
      stroke: new ol.style.Stroke({color: 'white', width: 1})
    })
  });
  feat2.setStyle(style2);
  source.addFeature(feat2);

  const bat = document.getElementById('battery');
  const wen = document.getElementById('stamp');
  const updateLocation = async () => {
    console.log('would work...');
    fetch(window.location + '.json')
    .then(res => res.json())
    .then(pon => {
      if (!pon) {
        console.log('disappeared...');
        return location.reload();  //REVIEW  rude?
      }
      bat.innerText = pon.bat || '??';
      wen.innerText = pon.wen;
      loc[0] = pon.lon;
      loc[1] = pon.lat;
      console.log('new', loc[0], loc[1]);
      feat.setGeometry(new ol.geom.Point(loc));
      feat2.setGeometry(new ol.geom.Point(loc));
      view.setCenter(loc);
      //view.animate({center: loc});
    }).catch(err => {
      console.error('update location failed', err);
      //TODO  render failure
    });
  }


  //TODO  initial delay too
  const f = () => { updateLocation(); setTimeout(f, 7000); };
  f();
  '''
--
