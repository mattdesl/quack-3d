package ducky.game.menus {
	import ducky.loader.Preloader;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import gs.easing.Elastic;
	import gs.easing.Quad;
	import gs.TweenMax;
	
	/**
	 * A movie clip that shows the progress of the game loading.
	 */
	public class PreloaderClip extends Sprite {
		
		private var context:MenuContext;
		private var preloader:Preloader;
				
		private var labelText:Bitmap = new Bitmap(new ProgressTextImage(0, 0));
		
		//private var myTween:TweenMax = TweenMax.to(mc, 1, {x:200});
		
		private var percentText:TextField;
		private var percentFormat:TextFormat;
		private var textGroup:Sprite;
		private var progressTop:Bitmap;
		private var progressMid:Bitmap;
		
		public function PreloaderClip(context:MenuContext, preloader:Preloader) {
			this.context = context;
			this.preloader = preloader;
			
			this.progressTop = context.progressTopImage;
			this.progressMid = context.progressMidImage;
			
			percentFormat = new TextFormat();
			percentFormat.font = "Bebas";
			percentFormat.size = 26;
			percentFormat.color = 0x000000;
			percentFormat.letterSpacing = 3;
			
			percentText = new TextField();
			percentText.text = "0%";
			percentText.setTextFormat(percentFormat);
			percentText.antiAliasType = AntiAliasType.NORMAL; 
			percentText.autoSize = TextFieldAutoSize.LEFT;
			percentText.x = labelText.width + 4;
			percentText.y = labelText.height - percentText.textHeight;
			percentText.selectable = false;
			
			textGroup = new Sprite();
			textGroup.addChild(labelText);
			textGroup.addChild(percentText);
			
			var xPercent:Number = 0.45;
			var yPercent:Number = 0.56;
			textGroup.x = context.stage.stageWidth * xPercent;
			textGroup.y = context.stage.stageHeight * yPercent;
			
			progressTop.x = textGroup.x + labelText.width + 1;
			progressTop.y = context.stage.stageHeight;
			progressMid.x = progressTop.x;
			progressMid.y = progressTop.y + progressTop.height;
			progressMid.height = context.stage.stageHeight - progressMid.y;
			
			addChild(progressTop);
			addChild(progressMid);
			addChild(textGroup);
			
			preloader.onProgress = onProgress;			
			preloader.onComplete = onComplete;
			preloader.start();
		}
		
		private function onProgress():void {
			percentText.text = Math.round(preloader.progress * 100) + "%";
			percentText.setTextFormat(percentFormat);
			
			progressTop.y = context.stage.stageHeight - context.stage.stageHeight * preloader.progress - progressTop.height;
			progressMid.y = progressTop.y + progressTop.height;
			progressMid.height = context.stage.stageHeight - progressMid.y;
		}
		
		
		private function onComplete():void {
			var time:Number = 0.75;
			
			var ptop:TweenMax = TweenMax.to(progressMid, time, { x:context.stage.stageWidth + 1, ease:Quad.easeIn } );
			var pmid:TweenMax = TweenMax.to(progressMid, time, { x:context.stage.stageWidth + 1, ease:Quad.easeIn } );
			
			var txt:TweenMax = TweenMax.to(textGroup, time, { x: -textGroup.width - 1, ease:Quad.easeIn } );
			ptop = null;
			pmid = null;
			txt = null;
			
			context.goToMainMenu();
		}
	}
}