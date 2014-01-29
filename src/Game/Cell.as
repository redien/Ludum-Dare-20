
package Game 
{
	import gameobjects.AnimatedObject;

	public class Cell extends AnimatedObject
	{
		public function Cell(x : int = 0, y : int = 0)
		{
			super(x * GameConstants.TileWidth, y * GameConstants.TileHeight, Images.tiles, GameConstants.TileWidth, GameConstants.TileHeight);
			add("default", [0]);
			add("selectable", [4]);
			add("lasor", [0, 1, 2, 0], 8, false);
			add("lasorable", [1]);
		}
	}
}
