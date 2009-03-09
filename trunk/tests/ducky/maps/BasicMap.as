package ducky.maps {
	import ducky.game.entity.SimpleEntity;
	
	public class BasicMap extends MapDesign {

		public function BasicMap() {
			startX = 0; startZ = -691.9868469238281;
			width = 1500; height = 500;
			obstacles = new Array();

			var obstacle0:SimpleEntity = new SimpleEntity();
			obstacle0.mesh = createBox("obstacle0", -150, -556.9868469238281, 38, 55, 54, 0, 8088439);
			obstacles.push(obstacle0);

			var obstacle1:SimpleEntity = new SimpleEntity();
			obstacle1.mesh = createBox("obstacle1", 7.5, -579.4868469238281, 25, 65, 73, -90, 13578734);
			obstacles.push(obstacle1);

			var obstacle2:SimpleEntity = new SimpleEntity();
			obstacle2.mesh = createSphere("obstacle2", 135, -504.4868469238281, 94/2, 0, 13955759);
			obstacles.push(obstacle2);
		}
	}
}
