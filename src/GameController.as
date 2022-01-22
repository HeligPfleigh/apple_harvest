package
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import Game.*;
	import flash.media.SoundChannel;
	
	public class GameController extends MovieClip
	{
		private var player:Bird;
		private var speed:Number;
		private var gravity:Number;
		private var randomChance:Number;
		private var stones:Array;
		private var apples:Array;
		private var score:Number;
		private var star:Array;
		
		private var mcBackground1:StarField;
		private var mcBackground2:StarField;
		private var mySound:Chew = new Chew();
		public var mySound2:Jungle = new Jungle();
		public var scn = new SoundChannel()
		
		
		public function GameController()
		{
			
		}
		
		public function startGame()
		{
			scn = mySound2.play(0, int.MAX_VALUE);
			speed = C.PLAYER_SPEED;
			gravity = C.GRAVITY;
			score = C.PLAYER_START_SCORE;
			randomChance = C.APPLE_SPAWN_CHANCE;
			apples = new Array();
			player = new Bird();
			stones = new Array();
			star = new Array();
			
			
			mcBackground1 = new StarField();
			mcBackground2 = new StarField();
			mcBackground2.x = mcBackground1.width;
			mcGameStage.addChildAt(mcBackground1,0);
			mcGameStage.addChildAt(mcBackground2,0);
			mcGameStage.addChild(player);			
			mcGameStage.addEventListener(Event.ENTER_FRAME,update);
			
			
		}
		

		private function gameOver()
		{
			mcGameStage.removeEventListener(Event.ENTER_FRAME,update);
			scn.stop();
			var gameOverMusic = new sndGameOver();
			var scnGameOver = new SoundChannel();
			scnGameOver = gameOverMusic.play();
			gotoAndStop("lose");
		}
		
		private function gameWin()
		{
			mcGameStage.removeEventListener(Event.ENTER_FRAME,update);
			scn.stop();
			var gameWinMusic = new SndMedal();
			var scnGameWin = new SoundChannel();
			scnGameWin = gameWinMusic.play();
			gotoAndStop("win");
		}
	
		private function update(evt:Event)
		{
			
			var moveX = 0;
			var moveY = 0;
			var currMouseX = mouseX;
			var currMouseY = mouseY;
			
			if (currMouseX > player.x)
			{
				moveX = 1;
			}
			else if (currMouseX < player.x)
			{
				moveX = -1;
			}
			if (currMouseY > player.y)
			{
				moveY = 1;				
			}
			else if (currMouseY < player.y)
			{
				moveY = -1;				
			}			
			
			
			if (moveX > 0)
			{
				if (player.x + C.PLAYER_SPEED <= currMouseX)
					player.x += C.PLAYER_SPEED;
			}
			else if (moveX < 0)
			{
				if (player.x - C.PLAYER_SPEED > currMouseX)
					player.x -= C.PLAYER_SPEED;
			}			
			if (moveY > 0)
			{
				if (player.y + C.PLAYER_SPEED <= currMouseY)
					player.y += C.PLAYER_SPEED;
			}
			else if (moveY < 0)
			{
				if (player.y - C.PLAYER_SPEED > currMouseY)
					player.y -= C.PLAYER_SPEED;	
			}	
			
			//Spawn new stones
			if(Math.random() < randomChance/10){
				var newStone = new Stone();
				newStone.x = Math.random()*C.APPLE_SPAWN_END_X+ C.APPLE_SPAWN_START_X;
				newStone.y = C.APPLE_START_Y;
				stones.push(newStone);
				mcGameStage.addChild(newStone);
				
			}
			
			//Move the stone
			for(var i = stones.length-1; i>=0; i--){
				stones[i].y += gravity*1.3;
				
				if (stones[i].y > C.APPLE_END_Y)
				{
					mcGameStage.removeChild(stones[i]);
					stones.splice(i,1);
				}
			}
			//Spawn new star
			if(Math.random() < randomChance/30){
				var newStar = new Star();
				newStar.x = Math.random()*C.APPLE_SPAWN_END_X+ C.APPLE_SPAWN_START_X;
				newStar.y = C.APPLE_START_Y;
				star.push(newStar);
				mcGameStage.addChild(newStar);
			}
			//Move the star
			for(i = star.length-1; i>=0; i--){
				star[i].y += gravity*1.5;
				if(star[i].y > C.APPLE_END_Y)
				{
					mcGameStage.removeChild(star[i]);
					star.splice(i,1);
				}
			}
			
			//Spawn new apples
			if (Math.random() < randomChance)
			{
				var newApple = new Apple();
				newApple.x = Math.random() * C.APPLE_SPAWN_END_X + C.APPLE_SPAWN_START_X;
				
				newApple.y = C.APPLE_START_Y;
				apples.push(newApple);
				
				mcGameStage.addChild(newApple);
			}			
			//Move Apples
			for (i = apples.length-1; i >= 0; i--)
			{
				apples[i].y += gravity;
				
				if (apples[i].y > C.APPLE_END_Y)
				{
					mcGameStage.removeChild(apples[i]);
					apples.splice(i,1);
					score -= 10;
				}
			}			
			
			//Check for collision with apple
			var playerPoint = new Point(player.x, player.y);
			for (i = apples.length-1; i >= 0; i--)
			{
				if (player.hitTestObject(apples[i]))
				{
					//Register hit
					score += 10;
					mySound.play();
					mcGameStage.removeChild(apples[i]);
					apples.splice(i,1);
				}
			}
			//Check for collision with stone
			for (i = stones.length-1; i>=0; i--){
				
				if (player.hitTestObject(stones[i]))
				{
					//Register hit
					score -= 50;
					
					mcGameStage.removeChild(stones[i]);
					stones.splice(i,1);
					
				}
			}
			//Check for collision with star
			for (i = star.length-1; i>=0; i--){
				if(player.hitTestObject(star[i])){
					score += 50;
					mcGameStage.removeChild(star[i]);
					star.splice(i,1);
				}
			}
			
			//Animate the player
			if (moveX > 0)
			{
				if (player.currentLabel != "right")
					player.gotoAndPlay("right");
			}
			else if (moveX < 0)
			{
				if (player.currentLabel != "left")
					player.gotoAndPlay("left");
			}	
			//Scrolling background
			mcBackground1.x -= C.SCROLL_SPEED;
			mcBackground2.x -= C.SCROLL_SPEED;
			if (mcBackground1.x <= -mcBackground1.width)
			{
				//switch it to the back of background 2
				mcBackground1.x = mcBackground2.x + mcBackground2.width;
			}
			else if (mcBackground2.x <= -mcBackground2.width)
			{
				//switch it to the back of background 1
				mcBackground2.x = mcBackground1.x + mcBackground1.width;
			}
			//Display new Score
			txtScore.text = String(score);
			//Win
			if(score >= 500){
				gameWin();
			}else if(score < 0){
				gameOver();
			}
		}
	}
}