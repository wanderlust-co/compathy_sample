/**
 * Change Element By Drag And Drop
 */
angular.module('cyDragDrop',[])
.directive('cyDd',['$rootScope','$parse',function($rootScope, $parse) {

  var drag;
  var images      = [];
  var copy_from  = null;
  var _on_move   = false;

  var tc_start = is_mobile ? 'touchstart' : 'mousedown';
  var tc_move  = is_mobile ? 'touchmove'  : 'mousemove';
  var tc_end   = is_mobile ? 'touchend'   : 'mouseup'  ;

  tc_start_func = function(e)
  {
    if(_on_move == false)
    {
      copy_from = $(e.target);

      var top  = e.pageY;
      var left = e.pageX;

      drag.src           = copy_from.attr('src');
      drag.style.display = 'block';
      jQuery(drag).offset( { top : top, left : left } );

      _on_move = true;
      event.preventDefault();
    }
  }

  tc_move_func = function(e)
  {
    if(_on_move==true)
    {
       var top  = e.pageY;
       var left = e.pageX;
       $(drag).offset( { top : top, left : left } );
    }
  }

  tc_end_func = function(e)
  {
    if(_on_move)
    {
      var drag_offset = $(drag).offset();
      for(i=0; i<images.length; i++)
      {
        var drop        = $(images[i]);
            drop_offset = drop.offset();

        if(   drop_offset.left <= drag_offset.left && drag_offset.left <= drop_offset.left + drop.width()
           && drop_offset.top  <= drag_offset.top  && drag_offset.top  <= drop_offset.top  + drop.height())
        {
          copy_from.attr('src',images[i].src);
          images[i].src       = drag.src
          drag.style.display = 'none';
          break;
        }
      }
    }
     _on_move = false;
     event.preventDefault();
  }

  //NOTE create temp picture
  drag = document.createElement('img');
  drag.style.position = 'relative';
  drag.style.width    = '50px';
  drag.style.height   = '50px';
  drag.style.zIndex   = 99;
  drag.style.display  = 'none';
  drag.addEventListener(tc_end  ,tc_end_func);


  return {
     restrict: 'A'
    ,link    : function(scope, element, attrs){

      //NOTE attach touch event
      images = element[0].getElementsByTagName('img');
      for(i=0; i<images.length; i++)
      {
        images[i].addEventListener(tc_start,tc_start_func);
        images[i].addEventListener(tc_move ,tc_move_func );
        images[i].addEventListener(tc_end  ,tc_end_func  );
      }

      element[0].appendChild(drag);
    }
  }
}]);
