package ducky.game.menus {
	import ducky.loader.Preloader;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import gs.easing.Bounce;
	import gs.easing.Elastic;
	import gs.easing.Quad;
	import gs.easing.Quint;
	import gs.TweenMax;
	import flash.events.MouseEvent;
	
	/**
	 * A movie clip that shows the progress of the game loading.
	 */
	public class MainMenu extends Sprite {
		
		private var titleImage:Bitmap = new Bitmap(new TitleImage(0, 0));
		
		private var mainImage:Bitmap = new Bitmap(new MainImage(0, 0));
		
		private var context:MenuContext;
		
		private var progressTop:Bitmap;
		private var progressMid:Bitmap;
		
		private var buttonsText:Array = ["Timed Race", "2-Player", "Options"];
		private var buttons:Array = [];
		private var hideTimer:Timer = new Timer(1000, 1);
		private var trans:Function = Quad.easeOut;
		
		private var current:MinimalButton = null;
		
		public function MainMenu(context:MenuContext) {
			this.context = context;
			this.progressTop = new Bitmap(context.progressTopImage.bitmapData);
			this.progressMid = new Bitmap(context.progressMidImage.bitmapData);
			
			hideTimer.addEventListener(TimerEvent.TIMER, onHide);
			
			titleImage.x = 0.62 * context.stage.stageWidth;
			titleImage.y = 0.12 * context.stage.stageHeight;
			titleImage.scaleX = 1.5;
			titleImage.scaleY = 1.5;
			titleImage.smoothing = true;
			titleImage.width = -titleImage.width;
			var titleFall:TweenMax = TweenMax.to(titleImage, 1, { scaleX:1, scaleY:1, 
								ease:Quint.easeOut, onComplete:onTitleLanded } );
			titleFall = null;
			
			
			var oldW:Number = mainImage.width;
			mainImage.width = context.stage.stageWidth / 2;
			mainImage.scaleY = mainImage.width / oldW;
			mainImage.smoothing = true;
			mainImage.y = context.stage.stageHeight - mainImage.height;
			mainImage.alpha = 0;
			
			progressTop.x = 0.58 * context.stage.stageWidth;
			progressTop.y = context.stage.stageHeight;
			progressMid.y = progressTop.y + progressTop.height;
			progressMid.height = context.stage.stageHeight - progressMid.y;
			progressMid.x = progressTop.x;
			
			addChild(progressMid);
			addChild(progressTop);
			addChild(titleImage);
			addChild(mainImage);
			
			addButtons();
		}
		
		private function addButtons():void {
			for (var i:int = 0; i < buttonsText.length; i++) {
				var btn:MinimalButton = new MinimalButton(this, buttonsText[i]);
				buttons.push(btn);
				btn.x = progressTop.x + 20;
				btn.y = 0.44 * context.stage.stageHeight + (i*btn.height+(i*30));
				btn.addEventListener(MouseEvent.CLICK, onButtonPress);
				addChild(btn);
			}
		}
		
		public function onRollOver(btn:MinimalButton):void {
			current = btn;
			var time:Number = 0.5;
			var ptop:TweenMax = TweenMax.to(progressTop, time, { y:btn.y-progressTop.height+5,
								ease:trans } );
			ptop = null;
			var pmid:TweenMax = TweenMax.to(progressMid, time, { y:btn.y+4,
								ease:trans, onUpdate:onUpdateProgressMove } );
			pmid = null;
		}
		
		private function onUpdateProgressMove():void {
			progressMid.x = progressTop.x;
			progressMid.height = context.stage.stageHeight - progressMid.y;
		}
		
		public function onRollOut(btn:MinimalButton):void {
			if (current == btn)
				current = null;
			hideTimer.reset();
			hideTimer.start();
		}
		
		private function onHide(e:TimerEvent):void {
			if (current != null)
				return;
			var time:Number = 0.5;
			var ptop:TweenMax = TweenMax.to(progressTop, time, { y:context.stage.stageHeight,
								ease:trans } );
			ptop = null;
			var pmid:TweenMax = TweenMax.to(progressMid, time, { y:context.stage.stageHeight+progressTop.height,
								ease:trans, onUpdate:onUpdateProgressMove } );
			pmid = null;
		}
		
		private function onTitleLanded():void {
			var mainShow:TweenMax = TweenMax.to(mainImage, 2, { alpha:1,
								ease:Quad.easeOut } );
			mainShow = null;
			
			var titleRot:TweenMax = TweenMax.to(titleImage, 1.8, { rotation:10,
								ease:Bounce.easeOut } );

			titleRot = null;
		}
		
		private function onButtonPress(e:MouseEvent):void {
			context.restart();
		}
	}
}
		