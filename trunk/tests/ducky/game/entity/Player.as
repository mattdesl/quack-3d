package ducky.game.entity {
	
	import ducky.game.Config;
	import ducky.game.LevelMap;
	import flash.display.Shape;
	import sandy.core.scenegraph.Shape3D;
	
	public class Player extends SimpleEntity {
				
		//variables for the 2D physics body
		public var steering:Number = 0;
		public var speed:Number = 0;
		protected var pX:Number = 0;
		protected var pY:Number = 0;
		protected var pRot:Number = 0;
		protected var velocityX:Number = 0;
		protected var velocityY:Number = 0;
		protected var radiance:Number = 0 * Math.PI / 180; 
		
		//input variables
		public var steeringLeft  :Boolean = false;
		public var steeringRight :Boolean = false;
		public var drivingForward:Boolean = false;
		public var drivingReverse:Boolean = false;
			
		private var _moving:Boolean = false;
		
		/** Will update the duck's physics only if its mesh and level are not null. */
		public function update():void {
			if (mesh!=null && level!=null) {
				//reset _moving
				_moving = false;
				
				var oldX:Number = pX;
				var oldY:Number = pY;
				var oldSteer:Number = steering;
				var oldSpeed:Number = speed;
				var oldRot:Number = pRot;
				
				if (drivingForward) {
					//check if below speedMax
					if (speed < Config.speedMax) {
						//speed up
						speed += Config.speedAcceleration;
						//check if above speedMax
						if (speed > Config.speedMax) {
							//reset to speedMax
							speed = Config.speedMax;
						}
					}
				}
				if (drivingReverse) {
					//check if below speedMaxReverse
					if (speed > Config.speedMaxReverse){
						//speed up (in reverse)
						speed -= Config.speedAcceleration;
						//check if above speedMaxReverse
						if (speed < Config.speedMaxReverse){
							//reset to speedMaxReverse
							speed = Config.speedMaxReverse;
						}
					}
				}
				if (steeringRight) {
					//turn right
					steering -= Config.steeringAcceleration;
					//check if above steeringMax
					if (steering > Config.steeringMax){
						//reset to steeringMax
						steering = Config.steeringMax;
					}
				}
				if (steeringLeft) {
					//turn left
					steering += Config.steeringAcceleration;
					//check if above steeringMax
					if (steering < -Config.steeringMax){
						//reset to steeringMax
						steering = -Config.steeringMax;
					}
				}	
					
				// friction    
				speed *= Config.groundFriction;
				
				// ideal changes
				var idealXMovement:Number = speed*Math.cos(radiance);
				var idealYMovement:Number = speed*Math.sin(radiance);
				
				// real change
				velocityX += (idealXMovement-velocityX)*Config.groundFriction;
				velocityY += (idealYMovement-velocityY)*Config.groundFriction;
				
				var dx:Number = pX+velocityX;
				var dy:Number = pY+velocityY;
				
				// update position; we try multiple tests so that the duck 
				// "slides" along walls
				if (level.isBlocked(dx, dy)) { //first try real move
					if (level.isBlocked(dx, pY)) { //try x axis
						if (level.isBlocked(pX, dy)) { //try y axis
							//speed *= -0.6;
						} else {
							pY = dy;
						}
					} else {
						pX = dx;
					}
				} else { // all is dandy, just move the duck
					pX = dx;
					pY = dy;
				}
			
				// rotate
				radiance += (steering*speed)*.025;
				pRot = radiance * (180 / Math.PI);
				
				//Fix Steering (make car go straight after driver stops turning)
				steering -= (steering * 0.1);
				
				//tilt the duck
				if (Math.floor(oldRot) != Math.floor(pRot)) {
					mesh.rotateY = pRot;
					_moving = true;
				}
				if (Config.tiltEnabled) {
					if (Math.abs(speed - oldSpeed) > 0.001) {
						mesh.tilt = speed * -2;
						_moving = true;
					}
					if (Math.abs(steering - oldSteer) > 0.001) {
						mesh.roll = steering * 20;
						_moving = true;
					}
				} else {
					if (mesh.roll != 0)
						mesh.roll = 0;
					if (mesh.tilt != 0)
						mesh.tilt = 0;
				}
				
				//change camera if necessary
				if (Math.floor(oldX) != Math.floor(pX) || Math.floor(oldY) != Math.floor(pY)) {
					mesh.x = pX;
					mesh.z = pY;
					_moving = true;
				}
			}
		}
		
		public function get moving():Boolean {
			return _moving;
		}
		
		override protected function createShape():Shape {
			return null;
		}
		
		override public function set mesh(m:Shape3D):void {
			this._mesh = m;
		}
		
		override public function set x(value:Number):void {
			pX = value;
			super.x = value;
		}
				
		override public function set z(value:Number):void {
			pY = value;
			super.z = value;
		}
		
		override public function set pan(value:Number):void {
			radiance = value * Math.PI / 180;
		}
		
		//TODO: fix pan [read] for player
		override public function get pan():Number {
			return radiance * 180 / Math.PI;
		}
		
		public function stop():void {
			steering = 0;
			speed = 0;
		}
	}
	
}