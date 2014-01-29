
package Game 
{
	import flash.display.CapsStyle;
	import flash.events.AsyncErrorEvent;
	import flash.filters.ConvolutionFilter;
	import flash.net.NetStreamPlayOptions;
	import gameobjects.AnimatedObject;
	import gameobjects.ImageObject;
	import net.flashpunk.FP;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.graphics.TiledImage;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.World;
	import utils.WavSound;

	public class Gameplay extends World 
	{
		private var playing_field : TiledImage;
		private var enemies : Vector.<Enemy> = new Vector.<Enemy>();
		private var cats : Vector.<Cat> = new Vector.<Cat>();
		private var selected_cats : Vector.<Cat> = new Vector.<Cat>();
		private var type_text : Text;
		
		private var moved_cats : int = 0;
		private var board : Board = new Board();
		private var game_ended : Boolean = false;
		private var spawn_counter : int = 0;
		private var enemies_left : int;
		private var enemies_killed : int;
		private var enemy_count : int;
		private var seed : uint;
		private var lost : Boolean = false;
		
		private var ending_object : ImageObject;
		
		private var win_timer : Number = 3;
		private var take_this_timer : Number = 3;
		
		private var laser_sfx : WavSound;
		private var next_turn : AnimatedObject;
		
		private var fx_board : Board = new Board();
		
		public function Gameplay(seed : uint = 0, number_of_enemies : uint = 4, number_of_cats : uint = 2) 
		{
			var i : int;

			super();

			playing_field = new TiledImage(Images.background_tile, GameConstants.TileWidth * GameConstants.BoardWidth, GameConstants.TileHeight * GameConstants.BoardHeight);
			playing_field.x = GameConstants.BoardOffsetX;
			playing_field.y = GameConstants.BoardOffsetY;
			addGraphic(playing_field);

			cats.push(new Cat("Laser", 4, 4));
			cats.push(new Cat("Fire", 5, 4));
			if (number_of_cats > 2) {
				cats.push(new Cat("Fire", 4, 5));
			}
			if (number_of_cats > 3) {
				cats.push(new Cat("Fire", 5, 5));
			}
			if (number_of_cats > 4) {
				number_of_enemies += 2;
			}
			for (i = 0; i < cats.length; ++i) {
				add(cats[i]);
			}
			
			if (number_of_cats >= 4) {
				take_this_timer = 0;
			}

			type_text = new Text("", 0, 0, 300, 100);
			addGraphic(type_text);
			
			add(board);
			board.x = GameConstants.BoardOffsetX;
			board.y = GameConstants.BoardOffsetY;
			
			add(fx_board);
			fx_board.x = GameConstants.BoardOffsetX;
			fx_board.y = GameConstants.BoardOffsetY;
			
			FP.randomSeed = seed;
			this.seed = seed;
			enemies_left = number_of_enemies;
			enemy_count = number_of_enemies;
			spawnEnemy();
			
			laser_sfx = new WavSound(Sounds.laser);
			
			next_turn = new AnimatedObject(FP.width / 2 - 64, FP.height - 38, Images.next_turn, 128, 32);
			next_turn.add("default", [0]);
			next_turn.add("hover", [1]);
			next_turn.play("default");
			add(next_turn);
		}

		private function getClosestCat(x : int, y : int) : Cat {
			if (cats.length == 0)
				return null;

			var i : int;
			var closest : Cat = cats[0];
			var closest_distance : Number = Math.sqrt((cats[0].gx - x) * (cats[0].gx - x) + (cats[0].gy - y) * (cats[0].gy - y));
			for (i = 1; i < cats.length; ++i) {
				var distance : Number = Math.sqrt((cats[i].gx - x) * (cats[i].gx - x) + (cats[i].gy - y) * (cats[i].gy - y));
				if (distance < closest_distance) {
					closest = cats[i];
					closest_distance = distance;
				}
			}

			return closest;
		}

		private function rasterizeLine(x1 : int, y1 : int, x2 : int, y2 : int, raster : Function) : void {
			while (x1 != x2 || y1 != y2) {
				var dx : int = 0, dy : int = 0;

				if (x1 < x2)
					dx = 1;
				if (x1 > x2)
					dx = -1;
				if (y1 < y2)
					dy = 1;
				if (y1 > y2)
					dy = -1;

				x1 += dx;
				y1 += dy;
				
				if (x1 != x2 || y1 != y2)
					raster(x1, y1);
			}
		}
		
		private function lose() : void {
			game_ended = true;
			ending_object = new ImageObject(Images.fail);
			add(ending_object);
			ending_object.layer = -100;
			lost = true;
		}
		
		private function win() : void {
			game_ended = true;
			ending_object = new ImageObject(Images.win);
			ending_object.layer = -100;
			add(ending_object);
		}

		private function updateEnemy(e : int) : void {
			if (enemies[e].dead) 
				return;
			
			var x : int = 0, y : int = 0;
			var i : int;

			var closest_cat : Cat = getClosestCat(enemies[e].gx, enemies[e].gy);

			if (closest_cat.gx < enemies[e].gx) {
				x -= 1;
			}
			else if (closest_cat.gx > enemies[e].gx) {
				x += 1;
			}

			if (closest_cat.gy < enemies[e].gy) {
				y -= 1;
			}
			else if (closest_cat.gy > enemies[e].gy) {
				y += 1;
			}

			enemies[e].move(x, y);

			if (getCatAt(enemies[e].gx, enemies[e].gy) !== null) {
				lose();
			}
		}

		private function spawnEnemy() : void {
			if (enemies_left == 0)
				return;

			var border : int = FP.random * 4;
			var x : int, y : int;
			if (border == 0) {
				x = FP.random * GameConstants.BoardWidth;
				y = 0;
			}
			else if (border == 1) {
				x = FP.random * GameConstants.BoardWidth;
				y = GameConstants.BoardHeight - 1;
			}
			else if (border == 2) {
				x = 0;
				y = FP.random * GameConstants.BoardHeight;
			}
			else if (border == 3) {
				x = GameConstants.BoardWidth - 1;
				y = FP.random * GameConstants.BoardHeight;
			}
			
			var enemy : Enemy = new Enemy(x, y);
			enemies.push(enemy);
			add(enemy);
			
			enemies_left -= 1;
		}
		
		private function updateAI() : void {
			var i : int;
			for (i = 0; i < enemies.length; ++i) {
				updateEnemy(i);
			}

			cats.forEach(function(cat : Cat, i : int, vector : Vector.<Cat>) : void {
				cat.moved_this_turn = false;
			});
			
			spawn_counter += 1;
			if (spawn_counter > 1) {
				spawn_counter = 0;
				spawnEnemy();
			}
		}

		private function updateAbilityText() : void {
			if (selected_cats.length > 0) {
				type_text.text = "Ability: " + selected_cats[selected_cats.length - 1].cat_type;
			}
			else {
				type_text.text = "";
			}
		}

		private function selectCat(cat : Cat) : void {
			cat.play("selected");
			if (!cat.moved_this_turn) {
				for (var y : int = -1; y < 2; ++y) {
					for (var x : int = -1; x < 2; ++x) {
						if (y != 0 || x != 0) {
							var cell : Cell = board.getCell(x + cat.gx, y + cat.gy);
							if (cell) {
								cell.play("selectable");
							}
						}
					}
				}
			}
		}

		private function deselectCat(cat : Cat) : void {
			cat.play("not_selected");
			for (var y : int = -1; y < 2; ++y) {
				for (var x : int = -1; x < 2; ++x) {
					if (y != 0 || x != 0) {
						var cell : Cell = board.getCell(x + cat.gx, y + cat.gy);
						if (cell) {
							cell.play("default");
						}
					}
				}
			}
		}

		private function getCatAt(x : int, y : int) : Cat {
			var i : int;
			for (i = 0; i < cats.length; ++i) {
				if (cats[i].gx == x && cats[i].gy == y) {
					return cats[i];
				}
			}

			return null;
		}

		private function deselectAllCats() : void {
			var i : int;
			for (i = 0; i < selected_cats.length; ++i) {
				deselectCat(selected_cats[i]);
			}
			selected_cats.splice(0, selected_cats.length);
		}

		private function killAt(x : int, y : int) : int {
			var i : int;
			var killed : int = 0;
			for (i = 0; i < enemies.length; ++i) {
				if (enemies[i].gx == x && enemies[i].gy == y) {
					if (!enemies[i].dead) {
						enemies_killed += 1;
						enemies[i].kill();
						if (enemies_killed == enemy_count)
							win();
						killed += 1;
					}
				}
			}
			
			return killed;
		}

		private function fire() : void {
			if (cats.length < 2)
				return;
			
			var a : int, b : int;
			for (a = 0; a < cats.length; ++a) {
				for (b = 0; b < cats.length; ++b) {
					if (a != b && (cats[a].gx == cats[b].gx || cats[a].gy == cats[b].gy))
					{
						var killed : int = 0;
						rasterizeLine(cats[a].gx, cats[a].gy, cats[b].gx, cats[b].gy, function(x : int, y : int) : void {
							killed += killAt(x, y);
						});
						if (killed > 0) {
							laser_sfx.play();
							rasterizeLine(cats[a].gx, cats[a].gy, cats[b].gx, cats[b].gy, function(x : int, y : int) : void {
								var cell : Cell = board.getCell(x, y);
								cell.play("lasor", true);
							});
						}
					}
				}
			}
		}
		
		private function updateLaserable() : void {
			var x : int, y : int;
			for (y = 0; y < GameConstants.BoardHeight; ++y) {
				for (x = 0; x < GameConstants.BoardWidth; ++x) {
					fx_board.getCell(x, y).play("default", true);
				}
			}
			
			var a : int, b : int;
			for (a = 0; a < cats.length; ++a) {
				for (b = 0; b < cats.length; ++b) {
					if (a != b && (cats[a].gx == cats[b].gx || cats[a].gy == cats[b].gy))
					{
						rasterizeLine(cats[a].gx, cats[a].gy, cats[b].gx, cats[b].gy, function(x : int, y : int) : void {
							fx_board.getCell(x, y).play("lasorable", true);
						});
					}
				}
			}
		}
		
		private function nextTurn() : void {
			updateAI();
			deselectAllCats();
		}

		override public function update() : void {
			super.update();
			var i : int;

			if (lost && Input.mousePressed)
			{
				FP.world = new Gameplay(seed, enemy_count, cats.length);
			}
			
			if (game_ended && !lost) {
				if (win_timer <= 0) {
					take_this_timer -= FP.elapsed;
				}
				else {
					win_timer -= FP.elapsed;
				}

				if (win_timer <= 0) {
					remove(ending_object);
					ending_object = new ImageObject(Images.take_this);
					add(ending_object);
				}
				
				if (take_this_timer <= 0) {
					FP.world = new Gameplay(seed + FP.random * uint.MAX_VALUE, enemy_count + 2, cats.length + 1);
				}
			}
			
			if (!game_ended) {
				if (next_turn.collidePoint(next_turn.x, next_turn.y, Input.mouseX, Input.mouseY)) {
					next_turn.play("hover");
					
					if (Input.mousePressed) {
						nextTurn();
					}
				}
				else {
					next_turn.play("default");
				}

				if (Input.pressed(Key.SPACE)) {
					nextTurn();
				}
				
				fire();
				
				if (Input.mousePressed) {
					var inside_board : Boolean = Input.mouseX >= GameConstants.BoardOffsetX &&
												 Input.mouseY >= GameConstants.BoardOffsetY &&
												 Input.mouseX < GameConstants.BoardOffsetX + GameConstants.BoardWidthInPixels &&
												 Input.mouseY < GameConstants.BoardOffsetY + GameConstants.BoardHeightInPixels;
					var cat : Cat;
					if (inside_board) {
						var gx : int = Math.floor((Input.mouseX - GameConstants.BoardOffsetX) / GameConstants.TileWidth);
						var gy : int = Math.floor((Input.mouseY - GameConstants.BoardOffsetY) / GameConstants.TileHeight);
						
						cat = getCatAt(gx, gy);
						if (cat) {
							var index : int = selected_cats.indexOf(cat);
							if (index == -1) {
								deselectAllCats();
								selected_cats.push(cat);
								selectCat(cat);
							}
							else {
								deselectCat(cat);
								var popped : Cat = selected_cats.pop();
								if (popped != cat) {
									selected_cats[index] = popped;
								}
							}
						}
						else if (selected_cats.length == 1) {
							var selected_cat : Cat = selected_cats[0];
							deselectAllCats();
							selected_cat.move(gx - selected_cat.gx, gy - selected_cat.gy);
						}
					}

					if (!inside_board || (inside_board && !cat)) {
						deselectAllCats();
					}

					//updateAbilityText();
				}
			}
			
			updateLaserable();
		}
	}
}
