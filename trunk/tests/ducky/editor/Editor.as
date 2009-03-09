package ducky.editor {
	import ducky.game.Config;
	import ducky.game.entity.Player;
	import ducky.game.entity.SimpleEntity;
	import ducky.game.LevelMap;
	import ducky.game.SimpleGame;
	import ducky.maps.BasicMap;
	import ducky.maps.MapDesign;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import sandy.bounds.BBox;
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
	import sandy.primitive.Sphere;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Editor extends SimpleGame implements LevelMap {
		
		/////////////////////////////////////////////////////////
		// ADD YOUR LEVELS TO THIS ARRAY
		/////////////////////////////////////////////////////////
		private const LEVELS:Array = [
			new BasicMap()      //A simple test by Matt DesLauriers
		];
		
		private var levelIndex:int = 0;
		
		private var player:Player = new Player();
		private var parserStack:ParserStack;
		
		private var groundWidth:Number = 1500;
		private var groundHeight:Number = 500;
		private var ground:Plane3D;
		
		private var cameraOff:Number = -200;
		private var chase:Boolean = true;
		
		private var startPlane:Plane3D;
		private var startPlaneSpeed:Number = 7.5;
		private var selectEntity:SimpleEntity = new SimpleEntity();;
		private const SELECT_SIZE:int = 50;
		
		private var bboxDraw:Box;
		
		//movement keys for select/start locations
		private var ctrlKey:Boolean = false;
		private var keyLeft:Boolean = false;
		private var keyRight:Boolean = false;
		private var keyUp:Boolean = false;
		private var keyDown:Boolean = false;
		
		private var help:Bitmap = new Bitmap(new HelpTexture(0, 0));
		
		private var scalar:Number = Math.sqrt(0.5);
		
		private var obstacleMeshes:Array;
		
		private var currentObstacleMeshIndex:int = -1;
		private var currentObstacleMesh:Shape3D;
		private var hoverFilter:Array = [ new GlowFilter(0xC82820, 0.5, 12, 12) ];
		
		//obstacle over select marker
		private var selectedObstacle:SimpleEntity;
		
		private var mapObstacles:Array = new Array();
		private var obstacleCount:int = 0;
				
		//SPACE: select next obstacle
		//ARROWS: move obstacle
		//ESCAPE: cancel obstacle place
		//ENTER: place obstacle
		//DELETE: delete obstacle at location
		
		override protected function init():void {
			createEnvironment();
			loadModel();
			populateObstacleList();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
			
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = "Press F1 to show/hide help.";
			tf.x = 100;
			tf.y = 10;
			addChild(tf);
			
			help.visible = false;
			help.x = stage.stageWidth / 2 - help.width / 2;
			help.y = stage.stageHeight / 2 - help.height / 2;
			addChild(help);
			
			
		}
				
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
			var material:ColorMaterial = new ColorMaterial(0x96c6ea, 0.25, materialAttr);
			material.lightingEnable = true;
			var app:Appearance = new Appearance(material);
			ground.appearance = app;
			rootGroup.addChild(ground);
			
			startPlane = new Plane3D("start", 50, 50, 2, 2);
			startPlane.rotateX = 90;
			startPlane.y = 2;
			var bmat:BitmapMaterial = new BitmapMaterial( new StartTexture(0, 0) );
			bmat.lightingEnable = true;
			app = new Appearance(bmat);
			startPlane.appearance = app;
			rootGroup.addChild(startPlane);
			
			var selectPlane:Plane3D = new Plane3D("select", SELECT_SIZE, SELECT_SIZE, 2, 2, Plane3D.ZX_ALIGNED);
			//selectPlane.rotateX = 90;
			selectPlane.y = 5;
			bmat = new BitmapMaterial( new SelectTexture(0, 0) );
			bmat.lightingEnable = true;
			app = new Appearance(bmat);
			selectPlane.appearance = app;
			rootGroup.addChild(selectPlane);
			
			selectEntity.mesh = selectPlane;
			selectEntity.level = this;
		}
		
		private function loadModel():void {
			var parser:IParser = Parser.create("res/duck.3DS", Parser.MAX_3DS, 1, "PNG");
			parserStack = new ParserStack();
			parserStack.add("duck", parser);
			
			parserStack.addEventListener(ParserStack.COMPLETE, onModelLoad);
			parserStack.start();
		}
		
		private function onModelLoad(e:Event):void {
			var duck:Shape3D = parserStack.getGroupByName("duck").children[0] as Shape3D;
			duck.pan = 90;
			player.mesh = duck;
			player.level = this;
			player.pan = 90;
			rootGroup.addChild(duck);
			
			camera.x = cameraOff;
			camera.y = 600;
			camera.z = cameraOff;
			camera.lookAt(duck.x, duck.y, duck.z);
			
			var s:Point3D = duck.boundingBox.getSize();
			//update duck position based on simple start
			player.x = 0;
			player.z = -groundWidth / 2 + s.z;
			startPlane.x = player.x;
			startPlane.z = player.z;
			selectEntity.x = player.x;
			selectEntity.z = player.z;
			updateCamera();
		}
		
		
		private function populateObstacleList(len:int=10):void {
			obstacleMeshes = new Array();
			
			for (var i:int = 0; i < len; i++) {
				var shape:Shape3D;
				if (i < 5) {
					var height:Number = rnd(15, 85);
					shape = new Box("defaultObstacle"+i, rnd(10, 75), height, rnd(10, 75), "quad");
					shape.y = height / 2;		
				} else {
					var radius:Number = rnd(15, 55);
					shape = new Sphere("defaultObstacle"+i, radius);
					shape.y = radius;
				}
				
				var materialAttr:MaterialAttributes = new MaterialAttributes( 
					new LightAttributes(true, 0.3)
				);
				var material:ColorMaterial = new ColorMaterial(Math.round( Math.random()*0xFFFFFF ), 1, materialAttr);
				material.lightingEnable = true;
				var app:Appearance = new Appearance(material);
				shape.appearance = app;
				
				//shape.visible = false;
				obstacleMeshes.push(shape);
				//rootGroup.addChild(shape);
			}
		}		
		
		
		private function insideTub(dx:Number, dy:Number):Boolean {
			return dy > ground.x + groundWidth - groundWidth/2 || dy < ground.x - groundWidth / 2
				|| dx > ground.z + groundHeight - groundHeight / 2 || dx < ground.z - groundHeight / 2;
		}
		
		public function isBlocked(dx:Number, dy:Number):Boolean {
			if (insideTub(dx, dy))
				return true;
			for (var i:int = 0; i < mapObstacles.length; i++) {
				var e:SimpleEntity = mapObstacles[i];
				if (e.contains(dx, dy))
					return true;
			}
			return false;
		}
		
		private function updateCamera():void {
			camera.x = player.x + cameraOff;
			camera.z = player.z + cameraOff;
			camera.lookAt(player.x, player.y, player.z);
			
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
				
		override protected function update():void {
			super.update();
			player.update();
			
			var s:Number = 1;
			if (keyLeft && keyUp || keyLeft && keyDown 
				|| keyRight && keyUp || keyRight && keyDown) {
				s = scalar;
			}
			
			var spx:Number = selectEntity.x;
			var spz:Number = selectEntity.z;
			
			if (ctrlKey) {
				if (keyLeft)  startPlane.x -= startPlaneSpeed * s;
				if (keyRight) startPlane.x += startPlaneSpeed * s;
				if (keyUp)    startPlane.z += startPlaneSpeed * s;
				if (keyDown)  startPlane.z -= startPlaneSpeed * s;
			} else {
				if (keyLeft)  selectEntity.x -= startPlaneSpeed * s;
				if (keyRight) selectEntity.x += startPlaneSpeed * s;
				if (keyUp)    selectEntity.z += startPlaneSpeed * s;
				if (keyDown)  selectEntity.z -= startPlaneSpeed * s;
			}
			
			//select plane has moved, so move the obstacle
			if (selectEntity.x != spx || selectEntity.z != spz) {
				selectMoved();
			}
			
			if (chase && player.moving) {
				updateCamera();
			}
		}
		
		private function selectMoved():void {
			if (currentObstacleMesh != null) {
				currentObstacleMesh.x = selectEntity.x;
				currentObstacleMesh.z = selectEntity.z;
			}
			setSelectedObstacle(getSelectedObstacle());
		}
		
		private function getSelectedObstacle():SimpleEntity {
			for (var i:int = 0; i < mapObstacles.length; i++) {
				var ob:SimpleEntity = mapObstacles[i];
				if (ob.shape.hitTestObject(selectEntity.shape)) {
					return ob;
				}
			}
			return null;
		}
		
		private function setSelectedObstacle(obs:SimpleEntity):void {
			if (selectedObstacle != null) {
				selectedObstacle.mesh.container.filters = null;
			}
			selectedObstacle = obs;
			if (selectedObstacle != null)
				selectedObstacle.mesh.container.filters = hoverFilter;
		}
		
		private function onKeyPress(e:KeyboardEvent):void {
			ctrlKey = e.ctrlKey;
			switch(e.keyCode) {
				case Config.keyLeft:
					player.steeringLeft   = true; break;
				case Config.keyRight:
					player.steeringRight  = true; break;
				case Config.keyForward:
					player.drivingForward = true; break;
				case Config.keyReverse:
					player.drivingReverse = true; break;
				case Keyboard.LEFT:
					keyLeft  = true; break;
				case Keyboard.RIGHT:
					keyRight = true; break;				
				case Keyboard.UP:
					keyUp    = true; break;
				case Keyboard.DOWN:
					keyDown  = true; break;
				case Keyboard.SPACE:
					if (currentObstacleMesh != null) {
						rootGroup.removeChildByName(currentObstacleMesh.name);
						//currentObstacleMesh.visible = false;
					}
					currentObstacleMeshIndex++;
					if (currentObstacleMeshIndex > obstacleMeshes.length-1) {
						currentObstacleMeshIndex = 0;
					}
					currentObstacleMesh = obstacleMeshes[currentObstacleMeshIndex];
					currentObstacleMesh.x = selectEntity.x;
					currentObstacleMesh.z = selectEntity.z;
					ColorMaterial(currentObstacleMesh.appearance.frontMaterial).alpha = 0.25;
					//currentObstacleMesh.visible = true;
					rootGroup.addChild(currentObstacleMesh);
					break;
				case Keyboard.ESCAPE:
					currentObstacleMeshIndex = -1;
					if (currentObstacleMesh != null) {
						//currentObstacleMesh.visible = false;
						rootGroup.removeChildByName(currentObstacleMesh.name);
						currentObstacleMesh = null;
					}
					break;
				case Keyboard.DELETE:
					if (selectedObstacle != null) {
						rootGroup.removeChildByName(selectedObstacle.mesh.name);
						setSelectedObstacle(getSelectedObstacle());
					}
					break;
				case Keyboard.ENTER:
					if (currentObstacleMesh != null) {
						var circle:Boolean = currentObstacleMesh is Sphere;
						var obs:Shape3D = currentObstacleMesh.clone("entity_" + (obstacleCount++));
						
						var color:uint = ColorMaterial(obs.appearance.frontMaterial).color;
						
						var materialAttr:MaterialAttributes = new MaterialAttributes( 
							new LightAttributes(true, 0.3)
						);
						var material:ColorMaterial = new ColorMaterial(color, 1, materialAttr);
						material.lightingEnable = true;
						var app:Appearance = new Appearance(material);
						obs.appearance = app;
						obs.useSingleContainer = true;
						obs.x = currentObstacleMesh.x;
						obs.y = currentObstacleMesh.y;
						obs.z = currentObstacleMesh.z;
						obs.pan = currentObstacleMesh.pan;
						rootGroup.addChild(obs);
												
						var entity:SimpleEntity = new SimpleEntity();
						entity.type = circle ? SimpleEntity.CIRCLE : SimpleEntity.RECTANGLE;
						entity.mesh = obs;
						entity.level = this;
						
						setSelectedObstacle(entity);
						
						mapObstacles.push(entity);
					}
					break;
				case 67: //C - center select entity
					selectEntity.x = player.x;
					selectEntity.z = player.z;
					selectMoved();
					break;
				case 82: //R - reset player
					resetPlayer();
					break;
				case 86: //V - move player to select plane
					player.x = selectEntity.x;
					player.z = selectEntity.z;
					player.stop();
					player.pan = 90;
					updateCamera();
					break;
				case 219: //[ - rotate left
					if (currentObstacleMesh != null) {
						currentObstacleMesh.pan -= 90;
					}
					break;
				case 221: //] - rotate right
					if (currentObstacleMesh != null) {
						currentObstacleMesh.pan += 90;
					}
					break;
				case 70: //CTRL + F - re-populate obstacle list
					if (ctrlKey) {
						populateObstacleList();
						currentObstacleMeshIndex = -1;
						if (currentObstacleMesh != null) {
							//currentObstacleMesh.visible = false;
							rootGroup.removeChildByName(currentObstacleMesh.name);
							currentObstacleMesh = null;
						}
					}
					break;
				case Keyboard.F1:
					help.visible = !help.visible;
					break;
				case Keyboard.F2: //F2 - output obstacle info
					trace("hey");
					traceMap();
					break;
				case Keyboard.F5:
					chase = !chase;
					break;
				case Keyboard.TAB:
					if (ctrlKey) {
						clearMap();
						levelIndex++;
						if (levelIndex > LEVELS.length - 1)
							levelIndex = 0;
						loadLevel(LEVELS[levelIndex]);
						resetPlayer();
					}
					break;
				case 81: //Ctrl + Q - clear map
					if (ctrlKey) {
						clearMap();
						levelIndex = -1;
						resetPlayer();
					}
					break;
				default:
					return;
			}
		}
		
		public function clearMap():void {
			for (var i:int = 0; i < mapObstacles.length; i++) {
				rootGroup.removeChildByName(mapObstacles[i].mesh.name);
			}
			currentObstacleMeshIndex = -1;
			if (currentObstacleMesh != null) {
				//currentObstacleMesh.visible = false;
				rootGroup.removeChildByName(currentObstacleMesh.name);
				currentObstacleMesh = null;
			}
			mapObstacles = new Array();
		}
		
		public function loadLevel(level:MapDesign):void {
			mapObstacles = level.obstacles;
			startPlane.x = level.startX;
			startPlane.z = level.startZ;
			//TODO: resize ground
			//groundWidth = level.width;
			//groundHeight = level.height;
			
			for (var i:int = 0; i < mapObstacles.length; i++) {
				mapObstacles[i].level = this;
				rootGroup.addChild(mapObstacles[i].mesh);
			}
		}
		
		private function resetPlayer():void {
			player.x = startPlane.x;
			player.z = startPlane.z;
			player.stop();
			player.pan = 90;
			selectEntity.x = player.x;
			selectEntity.z = player.z;
			selectMoved();
			updateCamera();
		}
		
		private function traceMap(className:String="MyMap", pkgName:String="ducky.maps"):void {
			trace("package "+pkgName+" {");
			trace("\timport ducky.game.entity.SimpleEntity;\n");
			trace("\tpublic class "+className+" extends MapDesign {");
			trace("\t\tpublic function "+className+"() {");
			trace("\t\t\tstartX = " + startPlane.x + "; startZ = " + startPlane.z + ";");
			trace("\t\t\twidth = " + groundWidth + "; height = " + groundHeight + ";");
			trace("\t\t\tobstacles = new Array();\n");
			
			for (var i:int = 0; i < mapObstacles.length; i++) {
				var ob:SimpleEntity = mapObstacles[i];
				var name:String = "obstacle" + i;
				
				var p:Point3D = ob.mesh.getPosition();
				var color:uint = ColorMaterial(ob.mesh.appearance.frontMaterial).color;
				
				trace("\t\t\tvar " + name + ":SimpleEntity = new SimpleEntity();");
				var msh:String = "\t\t\t" + name + ".mesh = create";
				
				if (ob.type == SimpleEntity.RECTANGLE) {
					var s:Point3D = ob.mesh.boundingBox.getSize();
					msh += "Box(\"" + name + "\", " +
								p.x + ", " + p.z + ", " +
								s.x + ", " + s.y + ", " + 
								s.z + ", " + ob.mesh.pan + ", " + color + ");";
				} else {
					msh += "Sphere(\"" + name + "\", " + 
								p.x + ", " + p.z + ", " +
								ob.mesh.boundingBox.getSize().x/2 + ", " +
								ob.mesh.pan + ", " + color + ");";
				}
				trace(msh);
				trace("\t\t\tobstacles.push("+name+");\n");
			}
			trace("\t\t}");
			
			trace("\t}");
			trace("}");
		}

		/*
		private function createMapObstacles():Array {
			var obstacles:Array = new Array();
			
			var obstacle0:SimpleEntity = new SimpleEntity();
			obstacle0.mesh = createBox("tt", 25);
			obstacle0.level = this;
			obstacles.push(obstacle0);
		}
		
		private function createSphere(name:String, x:Number, z:Number, radius:Number, pan:Number, color:uint):Sphere {
			var shape:Sphere = new Sphere(name, radius);
			shape.x = x;
			shape.y = radius;
			shape.z = z;
			shape.pan = pan;
			shape.appearance = createColorAppearance(color);
			return shape;
		}
		
		private function createBox(name:String, x:Number, z:Number, width:Number, height:Number, depth:Number, pan:Number, color:uint):Box {
			var shape:Box = new Box(name, width, height, depth, "quad");
			shape.x = x;
			shape.y = height / 2;
			shape.z = z;
			shape.pan = pan;
			shape.appearance = createColorAppearance(color);
			return shape;
		}
		
		private function createColorAppearance(color:uint):Appearance {
			var materialAttr:MaterialAttributes = new MaterialAttributes( 
				new LightAttributes(true, 0.3)
			);
			var material:ColorMaterial = new ColorMaterial(color, 1, materialAttr);
			material.lightingEnable = true;
			return new Appearance(material);
		}
		
		*/
		
		private function onKeyRelease(e:KeyboardEvent):void {
			ctrlKey = e.ctrlKey;
			switch(e.keyCode) {
				case Config.keyLeft:
					player.steeringLeft   = false; break;
				case Config.keyRight:
					player.steeringRight  = false; break;
				case Config.keyForward:
					player.drivingForward = false; break;
				case Config.keyReverse:
					player.drivingReverse = false; break;
				case Keyboard.LEFT:
					keyLeft  = false; break;
				case Keyboard.RIGHT:
					keyRight = false; break;				
				case Keyboard.UP:
					keyUp    = false; break;
				case Keyboard.DOWN:
					keyDown  = false; break;
				default:
					return;
			}
		}
		
		public function get start():Point {
			return new Point(startPlane.x, startPlane.z);
		}
		
		public function isFinished(x:Number, y:Number):Boolean {
			return false;
		}
		
		private function rnd(low:int, high:int):int {
			return Math.round(Math.random() * (high - low)) + low;
		} 
	}	
}