package ducky {
	import ducky.game.menus.MainMenu;
	import ducky.game.menus.MenuContext;
	import ducky.game.menus.PreloaderClip;
	import ducky.loader.Preloader;
	import ducky.loader.TestPreloader;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import gs.TweenMax;
	
	public class Boot extends Sprite implements MenuContext {
		
		private var _titleFont:Font = new TitleFont();
		
		private var progressMid:Bitmap = new Bitmap(new ProgressMidImage(0, 0));
		
		private var progressTop:Bitmap = new Bitmap(new ProgressTopImage(0, 0));
		
		private var main:MainMenu;
		
		public function Boot() {
			var p:Preloader = new TestPreloader();
			
			var clip:PreloaderClip = new PreloaderClip(this, p);
			addChild(clip);
		}
		
		public function get titleFont():Font {
			return _titleFont;
		}
		
		public function get progressTopImage():Bitmap {
			return progressTop;
		}
		
		public function get progressMidImage():Bitmap {
			return progressMid;
		}
		
		public function goToMainMenu():void {
			if (main == null) {
				main = new MainMenu(this);
				addChild(main);
			}
			main.visible = true;
		}
		
		private function start():void {
			var p:Preloader = new TestPreloader();
			var clip:PreloaderClip = new PreloaderClip(this, p);
			addChild(clip);
		}
		
		public function restart():void {
			TweenMax.killAllTweens(true);
			for (var i:int = numChildren-1; i>=0; i--) {
				removeChildAt(i);
			}
			main = null;
			start();
		}
	}
}