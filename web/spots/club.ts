import { pollJson, tweenOverlayPosition, div, a, gElement } from './utils';
import { useGeographic } from 'ol/proj';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import View from 'ol/View';
import Map from 'ol/Map';
import { Coordinate } from 'ol/coordinate';
import { boundingExtent } from 'ol/extent';
import Overlay from 'ol/Overlay';
import Control from 'ol/control/Control';

type bums = { [did: string]: bum };
type bum = {
  nom: string,
  lat: number,
  lon: number,
  acc: number | null,
  bat: number | null,
  wen: string, //TODO
}

let our: string;
let bums: bums = {};
let overs: { [did: string]: Overlay } = {};
let items: { [did: string]: HTMLElement } = {};
let map: Map;
let panel: HTMLDivElement;
let focus: string | null = null;
let focusView: gElement;

function bumCoord(b: bum) {
  return [b.lon, b.lat];
}

function bumCoords(): Coordinate[] {
  return Object.values(bums).map(bumCoord);
}

function setFocus(did: string | null, pan = true) {
  if (focus) {
    panel.classList.remove('focus');
    overs[focus].getElement()?.classList.remove('focus');
    items[focus].classList.remove('focus');
    focus = null;
    focusView.classList.remove('focus');
  }
  if (did) {
    panel.classList.add('focus');
    overs[did].getElement()?.classList.add('focus');
    items[did].classList.add('focus');
    //
    focusView.classList.add('focus');
    const k = focusView.children;
    console.log('setting focus deets', bums[did].wen);
    k[0].textContent = bums[did].nom.slice(0, 2);
    k[1].textContent = bums[did].nom;
    k[2].textContent = bums[did].wen;
    k[3].textContent = bums[did].bat ? (bums[did].bat?.toString()+'%') : '??%';
    const locString = bums[did].lat + ',' + bums[did].lon;
    k[4].replaceChildren(
      a(`${locString.replace(',', ' • ')} ↗️`)
      .att$('href', 'https://www.google.com/maps/place/'+locString)
      .att$('target', '_blank')
    );
    k[5].textContent = bums[did].acc ? (bums[did].acc?.toString()+'m') : '??m';
    if (did === our) {
      k[6].replaceChildren(a('🗑️ delete').att$('href', './nuke'));
    } else {
      k[6].replaceChildren();
    }
    //
    if (pan) {
      map.getView().animate({
        center: overs[did].getPosition(),
        duration: 500,
      });
    }
    focus = did;
  }
}

function clickBum(did: string) {
  return (e: MouseEvent) => {
    if (e.target instanceof Element) {
      e.stopPropagation();
    }
    setFocus(did);
  };
}

function updateBumOverlay(did: string, b: bum | null) {
  //  removal
  if (!b) {
    map.removeOverlay(overs[did]);
    delete overs[did];
    return;
  } else
  //  addition
  if (!overs[did]) {
    //  create overlay
    const el = document.createElement('div');
    el.className = 'bum';
    if (did === our) {
      el.classList.add('our');
    }
    el.innerText = b.nom.slice(0, 2);
    el.onclick = clickBum(did);
    const over = new Overlay({
      element: el,
      stopEvent: false,
      positioning: 'center-center',
      position: bumCoord(b),
    });
    overs[did] = over;
    map.addOverlay(over);
  //  update
  } else {
    //NOTE  careful, these get tweened separately, so there's desync risk!
    tweenOverlayPosition(overs[did], bumCoord(b), 200);
    if (focus === did) {
      map.getView().animate({
        center: bumCoord(b),
        duration: 200,
      });
    }
  }
}

function updateBumListItem(did: string, b: bum | null) {
  // console.log('update bum list item', did, b);
  //  removal
  if (!b) {
    if (items[did]) {
      items[did].remove();
      delete items[did];
    }
    return;
  } else
  //  addition
  if (!items[did]) {
    const i = div(
      div('').att$('class', 'shorthand'),
      div('').att$('class', 'name')
    ).att$('class', 'item').onclick$(clickBum(did));
    if (did === our) {
      i.att$('class', 'item our');
    }
    items[did] = i;
    console.log('appending child', did, panel);
    panel.prepend(i);
  }
  //  edit
  //@ts-ignore
  items[did].children[0].innerText = b.nom.slice(0, 2);
  //@ts-ignore
  items[did].children[1].innerText = b.nom;
}

function updateBum(did: string, b: bum | null) {
  if (b) {
    bums[did] = b;
  } else {
    delete bums[did];
  }
  updateBumOverlay(did, b);
  updateBumListItem(did, b);
  if (focus === did) {
    setFocus(did, false);
  }
}

export function clubStart(title: string, newOur: string, newBums: bums) {
  our = newOur;
  bums = newBums;
  console.log('bums', bums);

  //  set up locations polling
  pollJson('view.json', 5000,
    (b: bums) => {
      bums = b;
      //TODO  set missing keys to null, and/or run updateBum for missing keys
      Object.entries(bums).forEach(([k, v]) => updateBum(k, v));
    },
    () => {
      console.warn('sync failed');
      //TODO  indicate disconnected
    }
  );

  //  basic map setup
  useGeographic();
  const view = new View({ center: [0, 0], zoom: 10 });
  const extent = boundingExtent(bumCoords());
  view.fit(extent, {padding: [5, 5, 5, 5]});
  map = new Map({
    target: 'map',
    layers: [new TileLayer({source: new OSM()})],
    view: view,
  });

  //  controls setup
  panel = document.createElement('div');
  panel.id = 'panel';
  panel.className = 'open';
  if (!bums[our]) {
    const a = document.createElement('a');
    a.href = './setup';
    a.innerText = '+ add';
    a.id = 'adder';
    a.className = 'item';
    panel.appendChild(a);
  }
  focusView = div(
    div().att$('id', 'focusIcon'),
    div().att$('id', 'focusName'),
    div().att$('id', 'focusTime'),
    div().att$('id', 'focusBattery'),
    div().att$('id', 'focusLocation'),
    div().att$('id', 'focusAccuracy'),
    div().att$('id', 'focusDelete')
  ).att$('id', 'focusView');
  panel.appendChild(focusView);

  const ctrl = new Control({ element: panel });
  map.addControl(ctrl);

  //  insert initial bums
  Object.entries(bums).forEach(([k, v]) => updateBum(k, v));

  //  map interaction handling
  map.on('click', () => {
    setFocus(null);
  });
  //TODO  handle others? mb lock panning if focus is set?
}
