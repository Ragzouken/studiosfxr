package game.Shooter 
{
	import flash.display.Shape;
	import flash.geom.Vector3D;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author Mark Wonnacott
	 */
	public class Bullet extends Shape
	{
		private var _game:Shooter;
		private var _start:Vector3D, _end:Vector3D;
		private var _progress:Number;
		
		public function Bullet(game_:Shooter, start:Vector3D, end:Vector3D) 
		{
			graphics.beginFill(0x000000, 1);
			graphics.drawCircle(0, 0, 2);
			graphics.endFill();
			
			_game = game_;
			_start = start;
			_end = end;
			
			_progress = 0;
			
			x = _start.x;
			y = _start.y;
		}	
		
		public function update():void
		{
			_progress += 5;
			
			var vector:Vector3D = _end.subtract(_start);
			var length:Number = vector.length;
			
			vector.scaleBy(Math.min(_progress / length, 1));
			vector.incrementBy(_start);
			
			x = vector.x;
			y = vector.y;
			
			if (_progress >= length) {
				_game.hit(this);
			}
		}
	}
}