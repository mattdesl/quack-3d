package ducky.game.entity {
	import ducky.game.LevelMap;
	import sandy.core.scenegraph.Shape3D;
	
	public interface Entity {
		
		//Don't include mesh setter, as different entities may not need t
		//function set mesh(mesh:Shape3D):void;
		function get mesh():Shape3D;
		
		function set level(level:LevelMap):void;
		function get level():LevelMap;
		
		function set x(value:Number):void;
		function get x():Number;
		
		function set y(value:Number):void;
		function get y():Number;
		
		function set z(value:Number):void;
		function get z():Number;
		
		function set pan(value:Number):void;
		function get pan():Number;
		
		function contains(dx:Number, dy:Number):Boolean;
	}
}