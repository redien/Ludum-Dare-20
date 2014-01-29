
package Game
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
	public class Main extends Engine
	{
		public function Main()
		{
			super(400, 400, 60, false);
			FP.world = new Gameplay();
			this.scaleX = 1;
			this.scaleY = 1;
		}
	}
}
