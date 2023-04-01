::  million webui: general css style
::
'''
* { margin: 0; padding: 0; box-sizing: border-box; }

body {
  background-color: grey;
  font-family: Tahoma, sans-serif;
}

#head {
  position: relative;;
  width: 1002px;
  height: 80px;
  padding: 10px;
  margin: 0 auto 0;
  background-color: white;
  border: 1px solid goldenrod;
  border-bottom-width: 2px;
}

#head h1 {
  font-family: Georgia, serif;
  font-size: 20px;
  margin-bottom: 10px;
}
#head span {
  font-size: 12px;
  color: black;
}

#grid {
  position: relative;
  width: 1002px; height: 1002px;
  margin: 0 auto 20px;
  border: 1px solid black;
  background-color: white;
  background-image: url('data:image/gif;base64,R0lGODlhCgAKAPAAAN7e3v///yH/C05FVFNDQVBFMi4wAwEAAAAsAAAAAAoACgAAAhCMf4Crm/5gaJA6y+QEvPsCADs=');
  background-repeat: repeat;
  background-o
}

.tile {
  position: absolute;
  width: 10px; height: 10px;
}
.tile a {
  position: absolute;
  top: 0; bottom: 0;
  left: 0; right: 0;
}

.tile.pending {
  background-color: #f0f;
  animation: pending-bg 5s ease infinite;
}
@keyframes pending-bg {
  0% { background-color: #eee; }
  30% { background-color: #cbc; }
  100% { background-color: #eee; }
}


'''
