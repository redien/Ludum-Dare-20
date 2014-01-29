
package Game 
{
	import gameobjects.AnimatedObject;

	public class Cat extends AnimatedObject 
	{
		public var cat_type : String;
		public var moved_this_turn : Boolean = false;
		public var gx : uint, gy : uint;

		public function Cat(type : String, x : Number, y : Number) 
		{
			var image : * = Images.cat1;
			
			super(x * GameConstants.TileWidth + GameConstants.BoardOffsetX, y * GameConstants.TileHeight + GameConstants.BoardOffsetY, image, GameConstants.TileWidth, GameConstants.TileHeight);
			
			add("selected", [0, 1, 2, 1], 4);
			add("not_selected", [2], 4);
			
			play("not_selected");
			
			cat_type = type;
			gx = x;
			gy = y;
		}
		
		public function move(dx : int, dy : int) : Boolean {
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

			if (!moved_this_turn) {
				gx += dx;
				gy += dy;
				x = gx * GameConstants.TileWidth + GameConstants.BoardOffsetX;
				y = gy * GameConstants.TileHeight + GameConstants.BoardOffsetY;
				moved_this_turn = true;
			}

			return true;
		}
	}
}
