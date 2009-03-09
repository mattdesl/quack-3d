package ducky.loader {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class TestPreloader implements Preloader {
		
		private var _progress:Number = 0;
		private var _onComplete:Function;
		private var _onProgress:Function;
		public var count:int;
		private var timer:Timer = new Timer(rnd());
		private var i:int;
		
		private static function rnd():Number {
			return Math.random() * 200;
		}
		
		public function TestPreloader(count:int = 15) {
			this.count = count;
			timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
		}
		
		/** Gets the progress of the preloader out of 1.0. */
		public function get progress():Number {
			return _progress;
		}
				
		/** The method to call upon completion. */
		public function set onComplete(handler:Function):void {
			this._onComplete = handler;
		}
		
		/** The method to call upon completion. */
		public function get onComplete():Function {
			return _onComplete;
		}
		
		/** The method to call on progress update. */
		public function set onProgress(handler:Function):void {
			this._onProgress = handler;
		}
		
		/** The method to call on progress update. */
		public function get onProgress():Function {
			return _onProgress;
		}
		
		public function start():void {
			timer.start();
		}
		
		private function onTimerEvent(e:TimerEvent):void {
			//number of counts we've made
			i++;
			
			//update progress
			if (i >= count) { //if we are done
				timer.stop();
				_progress = 1;
				if (_onProgress != null) {
					_onProgress.call();
				}
				if (_onComplete != null) {
					_onComplete.call();
				}
			} else if (_onProgress != null) { //not yet done...
				_progress = i / count;
				_onProgress.call();
				timer.delay = rnd();
				timer.reset();
				timer.start();
			}
		}
		
	}
}