// club-setup.ts
var config = {};
var input;
var anchor;
function update() {
  config["deviceId"] = input.value;
  anchor.href = "owntracks:///config?inline=" + btoa(JSON.stringify(config));
}
function clubSetupStart(configObj) {
  config = configObj;
  input = document.getElementById("name");
  anchor = document.getElementById("config");
  input.onchange = update;
  input.onkeyup = update;
  input.onpaste = update;
  input.oninput = update;
  update();
}
export {
  clubSetupStart
};
