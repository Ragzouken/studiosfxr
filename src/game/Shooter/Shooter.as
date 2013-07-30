package game.Shooter 
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import game.Game;
	import ui.LinkPoint;
	/**
	 * ...
	 * @author Mark Wonnacott
	 */
	public class Shooter extends Game
	{
		private var _player:Shape;
		private var _enemy:Enemy;
		
		public function Shooter(linkpoints:Vector.<LinkPoint>)
		{
			super(linkpoints);
		}
		
		override protected function init():void
		{
			labels = Vector.<String>(["SHOOT", "HIT", "DIE", "THROW", "EXPLODE"]);
			
			_player = new Shape();
			_player.x = 0;
			_player.y = 30;
			
			_player.graphics.beginFill(0x000000, 1);
			_player.graphics.drawCircle(0.5, 0.5, 8);
			_player.graphics.endFill();
			
			addChild(_player);
			
			_enemy = new Enemy(this, new Vector3D(160, 90));
			addObject(_enemy);
		}
		
		override protected function update(e:Event):void
		{
			_player.x += 1;
			
			if (_player.x > 320) { _player.x -= 320; }
			
			if (_player.x % 20 < 9 && _player.x % 3 == 0 && _enemy.health > 0) {
				shoot(new Bullet(this, new Vector3D(_player.x, _player.y), new Vector3D(_enemy.x, _enemy.y)));
			}
			
			for (var object:* in _objects) {
				object.update()
			}
		}
		
		public function shoot(bullet:Bullet):void
		{
			play(0);
			addObject(bullet);
		}
		
		public function hit(bullet:Bullet):void
		{
			play(1);
			_enemy.hurt();
			removeObject(bullet);
		}
		
		public function die():void
		{
			play(2);
		}
	}
}