package game.Jumper 
{
	import flash.display.Shape;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mark Wonnacott
	 */
	public class Coin extends Shape
	{
		private var _game:Jumper;
		private var _position:Vector3D;
		
		public function Coin(game_:Jumper, position:Vector3D) 
		{
			_game = game_;
			_position = position;
			x = _position.x;
			y = _position.y;
			
			graphics.lineStyle(1, 0, 1);
			graphics.beginFill(0x807060, 1);
			graphics.drawCircle(0.5, 0.5, 3);
			graphics.endFill();
		}
		
		public function update():void
		{
			var distance:Number = _position.subtract(new Vector3D(_game._player.x, _game._player.y)).length;
			
			if (distance <= 3 + 8) {
				_game.pickup(this);
			}
		}
	}

}