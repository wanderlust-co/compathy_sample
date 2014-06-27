var ua          = window.navigator.userAgent.toLowerCase();
var is_mobile   = ua.indexOf('iphone') != -1 || ua.indexOf('ipod')!= -1 || ua.indexOf('android') != -1;
Debug ={}
Debug.Log = function(log) {
  console.log(log);
  //if(is_mobile)open("cy://log/" + log);
}

window.onerror = function (message, url, line) {
  Debug.Log( 'message:' + message + 'url:' + url + 'line:' + line)
}

// NOTE receive native data from iPhone
var _reserve_callback = null;
function dataReceiver(data)
{
  if(_reserve_callback)_reserve_callback(data);
}
