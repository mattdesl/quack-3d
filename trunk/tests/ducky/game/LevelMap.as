package ducky.game {
	import flash.geom.Point;
	
	public interface LevelMap {
		function isBlocked(x:Number, y:Number):Boolean;
		
		function get start():Point;
		
		function isFinished(x:Number, y:Number):Boolean;
	}
}