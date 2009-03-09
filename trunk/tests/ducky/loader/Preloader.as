package ducky.loader {
	
	public interface Preloader {
		
		/** Gets the progress of the preloader out of 1.0. */
		function get progress():Number;
				
		/** The method to call upon completion. */
		function set onComplete(handler:Function):void;
		
		/** The method to call upon completion. */
		function get onComplete():Function;
		
		
		/** The method to call on progress update. */
		function set onProgress(handler:Function):void;
		
		/** The method to call on progress update. */
		function get onProgress():Function;
		
		/** Starts the preloading. */
		function start():void;
	}
}