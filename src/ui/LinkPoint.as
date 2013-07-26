package ui 
{
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Mark Wonnacott
	 */
	public class LinkPoint extends Sprite
	{
		private var _app:SfxrApp;
		private var _individual:Individual;
		private var _update:Function;
		
		private var _linked:Shape;
		private var _unlinked:Shape;
		private var _links:Shape;
		
		public function get linked():Boolean
		{
			return (_individual != null);
		}
		
		public function get individual():Individual { return _individual; }
		public function set individual(value:Individual):void
		{	
			_individual = value;
			
			redrawLinks();
			
			_update(this, _individual != null);
		}
		
		public function LinkPoint(app:SfxrApp, update:Function)
		{
			_app = app;
			_update = update;
			
			_linked   = drawRect(0, 0x807060, false);
			_unlinked = drawRect(0, 0x807060, true); 
			
			addChild(_linked);
			
			_links = new Shape();
			addChild(_links);
			
			_app.addLinkListener(this.onLink);
		}
		
		private function onLink(individual:Individual, x:int, y:int):void
		{
			if (new Rectangle(this.x, this.y, 16, 16).contains(x, y))
			{
				if (individual != this.individual) {
					this.individual = individual;
					this.individual._connects[this] = true;
				} else {
					delete this.individual._connects[this];
					this.individual = null;
				}
			}
		}
		
		public function unlink(individual:Individual):void
		{
			this.individual = null;
		}
		
		private function drawRect(borderColour:uint, fillColour:uint, linked:Boolean):Shape
		{
			var rect:Shape = new Shape();
			rect.graphics.lineStyle(1, borderColour, 1, true);
			rect.graphics.beginFill(fillColour, 1);
			rect.graphics.drawRect(0, 0, 16, 16);
			rect.graphics.drawCircle(8.5, 8.5, 4);
			rect.graphics.endFill();
			return rect;
		}
		
		public function onDrawFrame(e:Event):void
		{
			redrawLinks();
		}
		
		private function redrawLinks():void
		{
			removeChild(_links);
			_links = new Shape();
			addChild(_links);
		
			if (_individual == null) { return; }
			
			var start:Vector3D = new Vector3D(8.5, 8.5, 0);
			var end:Vector3D = new Vector3D(_individual.x - x, _individual.y - y, 0);
			
			var vector:Vector3D = end.subtract(start);
			vector.normalize();
			
			vector.scaleBy(_individual.radius);
			
			//start.incrementBy(vector);
			end.decrementBy(vector);
			
			_links.graphics.moveTo(start.x, start.y);
			_links.graphics.lineStyle(1, 0x000000, 1, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
			_links.graphics.lineTo(end.x, end.y);
			
			_links.graphics.beginFill(0xF0C090, 1);
			_links.graphics.drawCircle(Math.floor(start.x) + 0.5, Math.floor(start.y) + 0.5, 4);
			_links.graphics.drawCircle(Math.floor(end.x) + 0.5,   Math.floor(end.y) + 0.5, 4);
			_links.graphics.endFill();
		}
	}
}