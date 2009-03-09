package ducky.game.menus {
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	/**
	 * A movie clip that shows the progress of the game loading.
	 */
	public class MinimalButton extends SimpleButton {
		
		private var field:TextField;
		private var format:TextFormat;
		private var menu:MainMenu;
		
		private var c1:uint = 0x333333;
		private var c2:uint = 0x000000;
		
		public function MinimalButton(menu:MainMenu, text:String) {
			this.menu = menu;
			format = new TextFormat();
			format.font = "Bebas";
			format.size = 18;
			format.color = c1;
			format.letterSpacing = 3;
			
			field = new TextField();
			field.text = text;
			field.setTextFormat(format);
			field.antiAliasType = AntiAliasType.ADVANCED; 
			field.autoSize = TextFieldAutoSize.LEFT;
			field.selectable = false;
			
			downState = field;
			upState = field;
			overState = field;
			hitTestState = field;
						
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}
		
		public function onRollOver(e:MouseEvent):void {
			format.color = c2;
			field.setTextFormat(format);
			menu.onRollOver(this);
		}
		
		public function onRollOut(e:MouseEvent):void {
			format.color = c1;
			field.setTextFormat(format);
			menu.onRollOut(this);
		}
	}	
}