
package Game 
{
	import gameobjects.AnimatedObject;

	public class Enemy extends AnimatedObject 
	{
		public var gx : uint, gy : uint;
		public var dead : Boolean = false;

		public function Enemy(x : Number, y : Number) 
		{
			var image : * = Images.enemy1;
			
			super(x * GameConstants.TileWidth + GameConstants.BoardOffsetX, y * GameConstants.TileHeight + GameConstants.BoardOffsetY, image, GameConstants.TileWidth, GameConstants.TileHeight);
			
			add("right", [0], 1);
			add("left", [1], 1);
			
			gx = x;
			gy = y;
		}

		public function move(dx : int, dy : int) : Boolean {
			if (dead)
				return false;

			if (gx + dx < 0 || gx + dx >= GameConstants.BoardWidth)
				return false;
			
			if (gy + dy < 0 || gy + dy >= GameConstants.BoardHeight)
				return false;
			
			if (Math.abs(dx) + Math.abs(dy) > 2)
				return false;
			if (Math.abs(dx) > 1)
				return false;
			if (Math.abs(dy) > 1)
				return false;

			if (dx < 0)
				play("left");
			else if (dx > 0)
				play("right");
				
			gx += dx;
			gy += dy;
			x = gx * GameConstants.TileWidth + GameConstants.BoardOffsetX;
			y = gy * GameConstants.TileHeight + GameConstants.BoardOffsetY;
			return true;
		}
		
		public function kill() : void {
			dead = true;
			visible = false;
		}
	}
}
