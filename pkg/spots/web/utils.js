// utils.ts
function pollJson(url, time, next, fail, delay = true) {
  const doFetch = async () => {
    try {
      let pon = await fetch(url);
      pon = await pon.json();
      if (!pon) {
        console.log("fetch failed", url, "no pon");
        fail();
      }
      next(pon);
    } catch (err) {
      console.error("fetch failed", url, err);
      fail();
    }
    ;
  };
  let id;
  const f = async () => {
    await doFetch();
    id = setTimeout(f, time);
  };
  if (delay) {
    id = setTimeout(f, time);
  } else {
    f();
  }
  return () => {
    clearTimeout(id);
  };
}
function tweenOverlayPosition(overlay, position, duration, bonus = null) {
  if (overlay.spots && overlay.spots.animation) {
    window.cancelAnimationFrame(overlay.spots.animation);
  } else if (!overlay.spots) {
    overlay.spots = {};
  }
  const startPos = overlay.getPosition();
  let startTime;
  let step = (timestamp) => {
    if (!startTime) startTime = timestamp;
    const time = timestamp - startTime;
    if (time >= duration) {
      overlay.setPosition(position);
      overlay.spots.animation = void 0;
      return;
    } else {
      const progress = time / duration;
      overlay.setPosition([
        startPos[0] + (position[0] - startPos[0]) * progress,
        startPos[1] + (position[1] - startPos[1]) * progress
      ]);
      if (bonus) bonus();
      overlay.spots.animation = window.requestAnimationFrame(step);
      return;
    }
  };
  if (!overlay.spots) overlay.spots = {};
  overlay.spots.animation = window.requestAnimationFrame(step);
}
function tag(name, ...children) {
  const el = document.createElement(name);
  for (const child of children) {
    if (typeof child === "string") {
      el.appendChild(document.createTextNode(child));
    } else {
      el.appendChild(child);
    }
  }
  el.att$ = function(name2, value) {
    this.setAttribute(name2, value);
    return this;
  };
  el.onclick$ = function(callback) {
    this.onclick = callback;
    return this;
  };
  return el;
}
var a = (...children) => tag("a", ...children);
var h1 = (...children) => tag("h1", ...children);
var div = (...children) => tag("div", ...children);
var span = (...children) => tag("span", ...children);
export {
  a,
  div,
  h1,
  pollJson,
  span,
  tweenOverlayPosition
};
