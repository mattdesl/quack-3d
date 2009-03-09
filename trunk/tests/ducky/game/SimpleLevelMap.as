package ducky.game {
	import flash.geom.Point;
	import sandy.primitive.Box;
	
	public class SimpleLevelMap {
		
		private var boxCount:int;
		private var sphereCount:int;
		
		private var boxes:Array;
		private var spheres:Array;
		
		public function SimpleLevelMap(Group parent, boxCount:int = -1, sphereCount:int = -1) {
			this.boxCount = boxCount;
			if (boxCount < 0) 
				this.boxCount = rnd(5, 15);
			this.sphereCount = sphereCount;
			if (sphereCount < 0) 
				this.sphereCount = rnd(5, 10);
			
			boxes = new Array(boxCount);
			for (var i:int = 0; i < boxCount; i++) {
				boxes[i] = new Box("box", rnd(25, 50), rnd(25, 50), rnd(25, 50), "tri");
				
			}
		}
		
		
		
		public function isBlocked(x:Number, y:Number):Boolean {
			return false;
		}
		
		public function get start():Point {
			return new Point(0, 0);
		}
		
		public function get isFinished(x:Number, y:Number):Boolean {
			return false;
		}
		
		

		private function rnd(low:int=0, high:int):int {
			return Math.round(Math.random() * (high - low)) + low;
		} 
	}
}