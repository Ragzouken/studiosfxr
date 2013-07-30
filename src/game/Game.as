package game 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import ui.LinkPoint;
	/**
	 * ...
	 * @author Mark Wonnacott
	 */
	 
	public class Game extends Sprite
	{
		public var labels:Vector.<String>;
		protected var _paused:Boolean;
		
		protected var _linkpoints:Vector.<LinkPoint>;
		protected var _objects:Dictionary;
		
		public function get paused():Boolean { return _paused; }
		public function set paused(v:Boolean):void
		{
			removeEventListener(Event.EXIT_FRAME, update);
			
			_paused = v;
			
			if (!_paused) {
				addEventListener(Event.EXIT_FRAME, update);
			}
		}
		
		public function Game(linkpoints:Vector.<LinkPoint>)
		{
			_linkpoints = linkpoints;
			_objects = new Dictionary();
			_paused = true;
			
			init();
		}
		
		protected function init():void
		{
		}
		
		protected function update(e:Event):void
		{
		}
		
		protected function play(sound:int):void
		{
			_linkpoints[sound].play();
		}
		
		protected function addObject(object:Shape):void
		{
			_objects[object] = true;
			addChild(object);
		}
		
		protected function removeObject(object:Shape):void
		{
			delete _objects[object];
			removeChild(object);
		}
	}

}