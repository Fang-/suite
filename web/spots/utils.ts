//  xx

import Overlay from "ol/Overlay";
import { Coordinate } from "ol/coordinate";

export function pollJson(url: string, time: number, next: (any)=>void, fail: ()=>void, delay = true): ()=>void {
  const doFetch = async () => {
    try {
      let pon = await fetch(url);
      pon = await pon.json();
      if (!pon) {
        console.log('fetch failed', url, 'no pon');
        fail();
      }
      next(pon);
    } catch(err) {
      console.error('fetch failed', url, err);
      fail();
    };
  };
  let id: number | undefined;
  const f = async () => {
    await doFetch();
    id = setTimeout(f, time);
  }
  if (delay) {
    id = setTimeout(f, time);
  } else {
    f();
  }
  return () => { clearTimeout(id); }
}

export function tweenOverlayPosition(
  overlay: Overlay & { spots?: any },
  position: Coordinate,
  duration: number,
  bonus: Function | null = null) {
  if (overlay.spots && overlay.spots.animation) {
    window.cancelAnimationFrame(overlay.spots.animation);
  } else if (!overlay.spots) {
    overlay.spots = {};
  }

  const startPos = overlay.getPosition()!;
  let startTime: number;
  let step: FrameRequestCallback = (timestamp) => {
    if (!startTime) startTime = timestamp;
    const time = timestamp - startTime;
    if (time >= duration) {
      overlay.setPosition(position);
      overlay.spots.animation = undefined;
      return;
    } else {
      const progress = time / duration;
      overlay.setPosition([
        startPos[0] + (position[0] - startPos[0])*progress,
        startPos[1] + (position[1] - startPos[1])*progress
      ]);
      if (bonus) bonus();
      overlay.spots.animation = window.requestAnimationFrame(step);
      return;
    }
  }
  if (!overlay.spots) overlay.spots = {};
  overlay.spots.animation = window.requestAnimationFrame(step);
}

//  from grecha.js

export type gElement = HTMLElement & {
  att$: (k:string,v:string)=>gElement,
  onclick$: (c:(e:MouseEvent)=>void)=>gElement
};
function tag(name: string, ...children: (string | gElement)[]) {
  const el: HTMLElement = document.createElement(name);
  for (const child of children) {
    if (typeof (child) === 'string') {
      el.appendChild(document.createTextNode(child));
    } else {
      el.appendChild(child);
    }
  }

  (el as gElement).att$ = function (name: string, value: string) {
    this.setAttribute(name, value);
    return this;
  };

  (el as gElement).onclick$ = function (callback) {
    this.onclick = callback;
    return this;
  };

  return el as gElement;
}

export const a = (...children) => tag('a', ...children);
export const h1 = (...children) => tag('h1', ...children);
export const div = (...children) => tag('div', ...children);
export const span = (...children) => tag('span', ...children);
