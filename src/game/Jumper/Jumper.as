package game.Jumper 
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
	public class Jumper extends Game
	{
		public var _player:Shape;
		public var _vy:Number;
		//private var _enemy:Enemy;
		
		public function Jumper(linkpoints:Vector.<LinkPoint>)
		{
			super(linkpoints);
		}
		
		override protected function init():void
		{
			labels = Vector.<String>(["JUMP", "COIN", "KILL"]);
			
			_player = new Shape();
			_player.x = 0;
			_player.y = 80;
			
			_vy = 0;
			
			_player.graphics.beginFill(0x000000, 1);
			_player.graphics.drawCircle(0.5, 0.5, 8);
			_player.graphics.endFill();
			
			addChild(_player);
			
			//_enemy = new Enemy(this, new Vector3D(160, 160));
			//addObject(_enemy);
			
			addCoins();
		}
		
		private function addCoins():void
		{
			for (var i:int = 0; i < 5; ++i) {
				addObject(new Coin(this, new Vector3D(100 + 20 * i, 110)));
			}
			
			addObject(new Baddie(this, new Vector3D(268, 114)));
		}
		
		override protected function update(e:Event):void
		{
			_player.x += 2;
			
			if (_player.x > 320) {
				_player.x -= 320;
				
				addCoins();
			}
			
			if (_player.y <= 120-8) {
				_player.y = Math.min(120-8, _player.y + _vy);
				_vy = _vy + 0.65;
			}
			
			if (_player.y >= 120-8 && (_player.x < 60 || _player.x > 200)) {
				_vy = -10;
				play(0);
			}
			
			if (_player.x > 60 && _player.x < 180 && _player.x % 5 == 0) {
				//play(1);
			}
			
			for (var object:* in _objects) {
				object.update()
			}
		}
		
		public function pickup(coin:Coin):void
		{
			play(1);
			removeObject(coin);
		}
		
		public function kill(baddie:Baddie):void
		{
			play(2);
			removeObject(baddie);
		}
	}
}