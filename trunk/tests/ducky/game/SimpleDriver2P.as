package ducky.game {
	import ducky.game.entity.Player;
	import ducky.game.entity.SimpleEntity;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import sandy.core.data.Point3D;
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	import sandy.materials.attributes.LightAttributes;
	import sandy.materials.attributes.LineAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.materials.BitmapMaterial;
	import sandy.materials.ColorMaterial;
	import sandy.parser.IParser;
	import sandy.parser.Parser;
	import sandy.parser.ParserStack;
	import sandy.primitive.Box;
	import sandy.primitive.Plane3D;
	
	/**
	 * A simple game. 
	 * 
	 * @author Matt
	 */
	public class SimpleDriver2P extends SimpleGame implements LevelMap {
		
		private var groundWidth:Number = 500;
		private var groundHeight:Number = 500;
		private var ground:Plane3D;
		
		private var cameraOff:Number = -200;
		
		private var player1:Player = new Player();
		private var player2:Player = new Player();
		
		private var parserStack:ParserStack;
			
		private var box:Shape;
		private var box3D:Box;
		private var obstacle:SimpleEntity;
		
		private var boundingBox:Box;
		private var bmp:Bitmap;
		
		private function createEnvironment():void {
			ground = new Plane3D("ground", groundWidth, groundHeight, 2, 2);
			ground.rotateX = 90;
			ground.enableForcedDepth = true;
			ground.forcedDepth = 9999999999999;
			ground.x = 0;
			ground.z = 0;
			ground.y = 0;
			ground.enableClipping = true;
			
			var materialAttr:MaterialAttributes = new MaterialAttributes( 
				new LightAttributes(true, 0.3)
			);
			var material:ColorMaterial = new ColorMaterial(0x96c6ea, 1, materialAttr);
			material.lightingEnable = true;
			var app:Appearance = new Appearance(material);
			ground.appearance = app;
			rootGroup.addChild(ground);
			
			
			box3D = new Box("obj", 40, 50, 50, "quad");
			box3D.x = 100;
			box3D.z = 25;
			
			
			var materialAttr2:MaterialAttributes = new MaterialAttributes( 
				new LightAttributes(true, 0.3),
				new LineAttributes(1, 0x00)
			);
			var material2:ColorMaterial = new ColorMaterial(0xff0f0f, 1, materialAttr2);
			material2.lightingEnable = true;
			var app2:Appearance = new Appearance(material2);
			box3D.appearance = app2;
			//box3D.useSingleContainer = true;
						
			rootGroup.addChild(box3D);
			
			obstacle = new SimpleEntity();
			obstacle.mesh = box3D;
			
			addChild(obstacle.shape);
		}
		
		private function loadModel():void {
			var parser:IParser = Parser.create("res/duck.3DS", Parser.MAX_3DS, 1, "PNG");
			parserStack = new ParserStack();
			parserStack.add("duck", parser);
			
			parserStack.addEventListener(ParserStack.COMPLETE, onModelLoad);
			parserStack.start();
		}
		
		override protected function init():void {
			createEnvironment();
			loadModel();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		
		private function onModelLoad(e:Event):void {
			var duck:Shape3D = parserStack.getGroupByName("duck").children[0] as Shape3D;
			duck.pan = 90;
			player1.mesh = duck;
			
			var duck2:Shape3D = duck.clone();
			duck2.pan = 90;
			
			player2.mesh = duck2;
			
			var mat:BitmapMaterial = new BitmapMaterial( new SecondaryTexture(0, 0) );
			mat.lightingEnable = true;
			var app:Appearance = new Appearance(mat);
			duck2.appearance = app;
			
			//change start location for both players
			player2.x += 50;
			player2.z += 50;
			player1.pan = 180;
			
			//drop players into this level
			rootGroup.addChild(duck);
			player1.level = this;
			
			rootGroup.addChild(duck2);
			player2.level = this;
			
			camera.x = cameraOff;
			camera.y = 600;
			camera.z = cameraOff;
			camera.lookAt(duck.x, duck.y, duck.z);
			
			var p:Point3D = duck2.boundingBox.getSize();
			trace(p);
			boundingBox = new Box("grid", p.x, p.y, p.z, "quad");
			boundingBox.x = duck2.x;
			boundingBox.y = duck2.y;
			boundingBox.z = duck2.z;
			boundingBox.pan = duck2.pan;
			//rootGroup.addChild(boundingBox);
			
		}
		
		
		public function isBlocked(dx:Number, dy:Number):Boolean {
			if (dy > ground.x + groundWidth - groundWidth/2 || dy < ground.x - groundWidth / 2
				|| dx > ground.z + groundHeight - groundHeight / 2 || dx < ground.z - groundHeight / 2)
				return true;
			//var s:Point3D = box3D.boundingBox.getSize();
			//var p:Point3D = box3D.getPosition();
			//if (dx > p.x - s.x/2 && dx < p.x + s.x/2 && dy > p.z - s.z/2 && dy < p.z + s.z/2) {
			//	return true;
			//}
			
			return obstacle.contains(dx, dy);
		}
		
		override protected function update():void {
			super.update();
			player1.update();
			player2.update();
			
			//IDEAS: find bottommost poly, convert to Polygon2D, use hittest()
			//OR steal code from Polygon2D, use it on poly
			//http://www.codeguru.com/forum/showthread.php?t=346093
			//http://www.gamedev.net/reference/articles/article2604.asp
			//Use 
			
			
			/*if (player2.moving) {
				boundingBox.x = player2.x;
				boundingBox.y = player2.y;
				boundingBox.z = player2.z;
				boundingBox.rotateY = player2.mesh.rotateY;
			}*/
			if (player1.moving) {
				/*camera.x = player1.x + cameraOff;
				camera.z = player1.z + cameraOff;
				camera.lookAt(player1.x, player1.y, player1.z);*/
				
				/*camera.x = player1.x;
				camera.z = player1.z;
				var cy:int = Math.abs((3+player2.speed) * 25);
				//max distance
				if (cy >= 1225)
					cy = 1225;
				//min
				if (cy <= 230)
					cy = 230;
				camera.y += (cy - camera.y) / 10;
				camera.lookAt(player2.x, player2.y, player2.z);*/
			}
		}
		
		private function onKeyPress(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case Config.keyLeft:
					player1.steeringLeft   = true; break;
				case Config.keyRight:
					player1.steeringRight  = true; break;
				case Config.keyForward:
					player1.drivingForward = true; break;
				case Config.keyReverse:
					player1.drivingReverse = true; break;
				case Config.keyLeftAlt:
					player2.steeringLeft   = true; break;
				case Config.keyRightAlt:
					player2.steeringRight  = true; break;
				case Config.keyForwardAlt:
					player2.drivingForward = true; break;
				case Config.keyReverseAlt:
					player2.drivingReverse = true; break;
				case Keyboard.SPACE: //inc box3d rot
					//obstacle.pan += 10;
					break;
				case Keyboard.BACKSPACE: 
					//obstacle.x += 10;
					break;
				default:
					return;
			}
		}
		
		private function onKeyRelease(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case Config.keyLeft:
					player1.steeringLeft   = false; break;
				case Config.keyRight:
					player1.steeringRight  = false; break;
				case Config.keyForward:
					player1.drivingForward = false; break;
				case Config.keyReverse:
					player1.drivingReverse = false; break;
				case Config.keyLeftAlt:
					player2.steeringLeft   = false; break;
				case Config.keyRightAlt:
					player2.steeringRight  = false; break;
				case Config.keyForwardAlt:
					player2.drivingForward = false; break;
				case Config.keyReverseAlt:
					player2.drivingReverse = false; break;
				default:
					return;
			}
		}
		
		public function get start():Point {
			return new Point(0, 0);
		}
		
		public function isFinished(x:Number, y:Number):Boolean {
			return false;
		}
		
	}
	
}