package ducky.game.entity {
	import ducky.game.Config;
	import ducky.game.LevelMap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import sandy.core.data.Point3D;
	import sandy.core.scenegraph.Shape3D;
	
	public class SimpleEntity implements Entity {
		
		/** The border size for hit tests (i.e. amount to ignore around edge). */
		//public var collisionBorder:Number = Config.defaultCollisionBorder;
				
		/** The Shape3D of the obstacle. */
		protected var _mesh:Shape3D;
				
		/** The level the entity is currently in. */
		protected var _level:LevelMap;
		
		/** The shape which defines the collidable area of the entity. */
		protected var _shape:Shape;
		
		private var origRotX:Number;
		private var origRotY:Number;
		private var origX:Number;
		private var origY:Number;
		
		public static const CIRCLE:String = "circle";
		public static const RECTANGLE:String = "rectangle";
		
		private var _type:String = RECTANGLE;
		
		/** Whether the point intersects this entity's bounding box. */
		public function contains(dx:Number, dy:Number):Boolean {
			if (_mesh == null)
				return false;
			if (_shape == null) { // get the shape
				_shape = createShape();
				if (_shape == null)
					return false;
			}
			return _shape.hitTestPoint(dx, dy);			
		}
		
		/*var s:Point3D = _mesh.boundingBox.getSize();
			var p:Point3D = _mesh.getPosition();
			return dx > p.x - s.x/2 + collisionBorder 
				&& dx < p.x + s.x/2 - collisionBorder
				&& dy > p.z - s.z/2 + collisionBorder 
				&& dy < p.z + s.z/2 - collisionBorder;*/
		
		public function set type(t:String):void {
			if (t != CIRCLE && t != RECTANGLE)
				throw new ArgumentError("invalid type; must be CIRCLE or RECTANGLE");
			var old:String = this._type;
			this._type = t;
			if (old != this._type) {
				this._shape = createShape();
			}
		}
		
		public function get type():String {
			return _type;
		}
		
		/** Used to create a shape for the current entity. */
		protected function createShape():Shape {
			if (_mesh == null)
				return null;
			var s:Point3D = _mesh.boundingBox.getSize();
			var p:Point3D = _mesh.getPosition();
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x00);
			if (_type == RECTANGLE) {
				shape.graphics.drawRect(0, 0, s.x, s.z);
			} else {
				shape.graphics.drawEllipse(0, 0, s.x, s.z);
			}
			shape.graphics.endFill();
			shape.x = p.x - s.x / 2;
			shape.y = p.z - s.z / 2;
			origX = shape.x;
			origY = shape.y;
			origRotX = origX + shape.width / 2;
			origRotY = origY + shape.height / 2;
			rotateAroundCenter(shape, _mesh.pan);
			
			return shape;
		}
		
		private function rotateAroundCenter(shape:Shape, angle:Number):void {
			var m:Matrix = shape.transform.matrix;
			m.tx -= origRotX;
			m.ty -= origRotY;
			m.rotate(angle*(Math.PI/180));
			m.tx += origRotX;
			m.ty += origRotY;
			shape.transform.matrix = m;
		}
		
		protected function meshChanged():void {
			if (shape != null) {
				var s:Point3D = _mesh.boundingBox.getSize();
				var p:Point3D = _mesh.getPosition();
				
				shape.rotation = 0;
				origX = p.x - s.x / 2;
				origY = p.z - s.z / 2;
				shape.x = origX;
				shape.y = origY;
				origRotX = origX + shape.width / 2;
				origRotY = origY + shape.height / 2;
				rotateAroundCenter(shape, _mesh.pan);
			}
		}
		
		public function get shape():Shape {
			return _shape;
		}
		
		public function set x(value:Number):void {
			if (mesh != null) {
				mesh.x = value;
				meshChanged();
			}
		}
		
		public function get x():Number {
			return mesh != null ? mesh.x : 0;
		}
		
		public function set y(value:Number):void {
			if (mesh != null)
				mesh.y = value;
		}
		
		public function get y():Number {
			return mesh != null ? mesh.y : 0;
		}
		
		public function set z(value:Number):void {
			if (mesh != null) {
				mesh.z = value;
				meshChanged();
			}
		}
		
		public function get z():Number {
			return mesh != null ? mesh.z : 0;
		}
				
		public function set pan(value:Number):void {
			if (mesh != null) {
				mesh.pan = value;
				meshChanged();
			}
		}
		
		public function get pan():Number {
			return mesh!=null ? mesh.pan : 0;
		}
		
		public function set mesh(m:Shape3D):void {
			var old:Shape3D = this._mesh;
			this._mesh = m;
			if (this._mesh != null && this._mesh != old) {
				_shape = createShape();
			} else if (this._mesh == null) {
				origX = 0;
				origY = 0;
				origRotX = 0;
				origRotY = 0;
				this._shape = null;
			}
		}
		
		public function get mesh():Shape3D {
			return _mesh;
		}
		
		public function get level():LevelMap {
			return _level;
		}
				
		public function set level(l:LevelMap):void {
			this._level = l;
		}
	}
}