package ducky.game {
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import net.hires.debug.Stats;
	import sandy.core.Scene3D;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	
	/**
	 * A simple game. 
	 * 
	 * @author Matt
	 */
	public class SimpleGame extends Sprite {
		
		protected var scene:Scene3D;
		protected var camera:Camera3D;
		protected var rootGroup:Group;
		private var stats:Stats;
		
		public function SimpleGame() { 
			stage.scaleMode = StageScaleMode.NO_SCALE;
			camera = new Camera3D(stage.stageWidth, stage.stageHeight);
			camera.z = -400;
			
			rootGroup = new Group();
			init();

			scene = new Scene3D("scene", this, camera, rootGroup);

			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			addChild((stats = new Stats()));
		}

		public function get fps():uint {
			return stats.fps;
		}
		
		/** Called to set up the root group. */
		protected function init():void {
		}
		
		/** Updates the game, calling updateGame(). */
		protected function update():void {
		}
		
		/** Called to paint the physics and render the scene. */
		protected function render():void {
			scene.render();
		}
		
		/** Updates and renders the game. */
		private function enterFrameHandler(event:Event):void {
			update();
			render();
		}
	}
	
}