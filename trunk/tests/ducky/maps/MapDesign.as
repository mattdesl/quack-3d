package ducky.maps {
	import ducky.game.LevelMap;
	import sandy.materials.Appearance;
	import sandy.materials.attributes.LightAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	import sandy.materials.ColorMaterial;
	import sandy.primitive.Box;
	import sandy.primitive.Sphere;
	
	public class MapDesign {
		
		public var obstacles:Array;
		public var startX:Number;
		public var startZ:Number;
		public var width:Number;
		public var height:Number;
		
		protected function createSphere(name:String, x:Number, z:Number, radius:Number, pan:Number, color:uint):Sphere {
			var shape:Sphere = new Sphere(name, radius);
			shape.x = x;
			shape.y = radius;
			shape.z = z;
			shape.pan = pan;
			shape.appearance = createColorAppearance(color);
			return shape;
		}
		
		protected function createBox(name:String, x:Number, z:Number, width:Number, height:Number, depth:Number, pan:Number, color:uint):Box {
			var shape:Box = new Box(name, width, height, depth, "quad");
			shape.x = x;
			shape.y = height / 2;
			shape.z = z;
			shape.pan = pan;
			shape.appearance = createColorAppearance(color);
			return shape;
		}
		
		protected function createColorAppearance(color:uint):Appearance {
			var materialAttr:MaterialAttributes = new MaterialAttributes( 
				new LightAttributes(true, 0.3)
			);
			var material:ColorMaterial = new ColorMaterial(color, 1, materialAttr);
			material.lightingEnable = true;
			return new Appearance(material);
		}

	}
}