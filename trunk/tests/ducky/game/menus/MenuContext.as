package ducky.game.menus {
	import flash.display.Bitmap;
	import flash.display.Stage;
	import flash.text.Font;
	
	public interface MenuContext {
		
		function get titleFont():Font;
		function get stage():Stage;
		function goToMainMenu():void;
		function get progressTopImage():Bitmap;
		function get progressMidImage():Bitmap;
		function restart():void;
	}
}