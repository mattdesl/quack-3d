package ducky.game {
	import flash.ui.Keyboard;
	
	public class Config {
		
		public static var tiltEnabled:Boolean = true;
		public static var speedMax:Number = 5;
		public static var speedMaxReverse:Number = -4;
		public static var speedAcceleration:Number = 0.5;
		public static var groundFriction:Number = .95;

		public static var steeringMax:Number = 1;
		public static var steeringAcceleration:Number = .10;
		public static var steeringFriction:Number = 0.95;
		
		public static var keyForward:uint = 87; //W
		public static var keyLeft:uint    = 65; //A
		public static var keyReverse:uint = 83; //S
		public static var keyRight:uint   = 68; //D
		
		public static var keyForwardAlt:uint = Keyboard.UP;
		public static var keyLeftAlt:uint    = Keyboard.LEFT;
		public static var keyReverseAlt:uint = Keyboard.DOWN;
		public static var keyRightAlt:uint   = Keyboard.RIGHT;
		
		public static var defaultCollisionBorder:int = -20;
	}
	
}