package game.Shooter 
{
	import flash.display.Shape;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Mark Wonnacott
	 */
	public class Enemy extends Shape
	{
		private var _game:Shooter;
		private var _health:int;
		private var _respawn:int;
		
		public function get health():int { return _health; }
		
		public function Enemy(game_:Shooter, position:Vector3D) 
		{
			_game = game_;
			_health = 10;
			
			x = position.x;
			y = position.y;
			
			graphics.beginFill(0x000000, 1);
			graphics.drawCircle(0.5, 0.5, 8);
			graphics.endFill();
		}
		
		public function update():void
		{
			if (_health <= 0) {
				_respawn += 1;
				
				if (_respawn > 75) {
					_health = 10;
					graphics.beginFill(0x000000, 1);
					graphics.drawCircle(0.5, 0.5, 8);
					graphics.endFill();
				}
			}
		}
		
		public function hurt():void
		{
			_health -= 1;
			
			if (_health <= 0 && _health == 0) {
				_game.die();
				_respawn = 0;
				
				graphics.beginFill(0x807060, 1);
				graphics.drawCircle(0.5, 0.5, 8);
				graphics.endFill();
			}
		}
	}
}