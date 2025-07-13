
let config = {};
let input: HTMLInputElement;
let anchor: HTMLAnchorElement;

function update() {
  config['deviceId'] = input.value;
  anchor.href = 'owntracks:///config?inline=' + btoa(JSON.stringify(config));
}

export function clubSetupStart(configObj: Object) {
  config = configObj;
  input = document.getElementById('name') as HTMLInputElement;
  anchor = document.getElementById('config') as HTMLAnchorElement;

  input.onchange = update;
  input.onkeyup = update;
  input.onpaste = update;
  input.oninput = update;
  update();
}