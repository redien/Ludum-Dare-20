
package Game
{
	import gameobjects.GameObject;
	
	public class Board extends GameObject
	{
		private var cells : Vector.<Cell> = new Vector.<Cell>();

		public function Board() 
		{
			var i : int;
			for (i = 0; i < GameConstants.BoardWidth * GameConstants.BoardHeight; ++i) {
				var cell : Cell = new Cell(i % GameConstants.BoardWidth, Math.floor(i / GameConstants.BoardWidth));
				cells.push(cell);
				addChild(cell);
			}
		}
		
		public function getCell(x : int, y : int) : Cell {
			if (x < 0 || y < 0 || x >= GameConstants.BoardWidth || y >= GameConstants.BoardHeight)
				return null;
			return cells[y * GameConstants.BoardWidth + x];
		}
	}
}
