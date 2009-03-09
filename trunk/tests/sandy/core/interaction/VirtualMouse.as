

package sandy.core.interaction
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import sandy.core.data.Polygon;
	import sandy.core.data.UVCoord;
	import sandy.materials.MovieMaterial;
	
	
	/**
	 * VirtualMouse interacting with MovieMaterial
	 * Based on the VirtualMouse by senocular
	 *
	 * @author		Xavier MARTIN - zeflasher - http://dev.webbymx.net
	 * @author		Thomas PFEIFFER - kiroukou
	 * @version		1.0
	 * @date 		24.10.2007
	 */
	public class VirtualMouse
		extends EventDispatcher 
	{
		private static var _oI		: VirtualMouse;
		
	//	target
		private var m_ioTarget		: Sprite;
	//	old target
		private var m_ioOldTarget	: Sprite;
		private var location		: Point;
		private var lastLocation	: Point;
		private var lastWithinStage	: Boolean = true;
		private var _lastEvent		: Event;
		private var lastDownTarget:InteractiveObject;
		
	/* ****************************************************************************
	* CONSTRUCTOR
	**************************************************************************** */
		public function VirtualMouse( access : PrivateConstructorAccess )
		{
			super();
			location = new Point(0, 0);
			lastLocation = location.clone();
		}
		
		public static function getInstance() : VirtualMouse
		{
			if ( !_oI ) _oI = new VirtualMouse( new PrivateConstructorAccess() );
			return _oI;
		}
		
	/* ****************************************************************************
	* PUBLIC FUNCTION
	**************************************************************************** */	
		public function interactWithTexture(  p_oPoly : Polygon, p_uvTexture : UVCoord, p_event : MouseEvent ) : void
		{
			// -- recuperation du material applique sur le polygone
			var l_oMaterial:MovieMaterial = (p_oPoly.visible ? p_oPoly.appearance.frontMaterial : p_oPoly.appearance.backMaterial) as MovieMaterial;
			if( l_oMaterial == null ) return;

			m_ioTarget = l_oMaterial.movie;
			location = new Point( p_uvTexture.u * l_oMaterial.texture.width, p_uvTexture.v * l_oMaterial.texture.height );
			
			// go through each objectsUnderPoint checking:
			//		1) is not ignored
			//		2) is InteractiveObject
			//		3) mouseEnabled
			var objectsUnderPoint:Array = m_ioTarget.getObjectsUnderPoint( m_ioTarget.localToGlobal( location ) );
			var currentTarget:Sprite;
			var currentParent:DisplayObject;
			
			var i:int = objectsUnderPoint.length;
			while ( --i > -1 ) 
			{
				currentParent = objectsUnderPoint[i];
				
				// go through parent hierarchy
				while (currentParent) 
				{		
					// invalid target if in a SimpleButton
					if (currentTarget && currentParent is SimpleButton) 
					{
						currentTarget = null;
						
					// invalid target if a parent has a
					// false mouseChildren
					} 
					else if ( currentTarget && currentParent is DisplayObjectContainer && !DisplayObjectContainer(currentParent).mouseChildren ) 
					{
						currentTarget = null;
					}
					
					// define target if an InteractiveObject
					// and mouseEnabled is true
					if (!currentTarget && currentParent is DisplayObjectContainer && DisplayObjectContainer(currentParent).mouseEnabled) 
					{
						currentTarget = ( currentParent as Sprite );
					}
					
					// next parent in hierarchy
					currentParent = currentParent.parent;
				}
			}

			// if a currentTarget was not found
			// the currentTarget is the texture
			if (!currentTarget)
			{
				currentTarget = m_ioTarget;
			}
			
			if ( !m_ioOldTarget ) currentTarget.stage;
						
			//	if the target is a textfield
			/*	if ( currentTarget is TextField ) 
			{
				_checkLinks( currentTarget as TextField );
				return;
			}*/

			// get local coordinate locations
			var targetLocal:Point = p_oPoly.container.globalToLocal(location);
			var currentTargetLocal:Point = currentTarget.globalToLocal(location);
			
			// move event
			if (lastLocation.x != location.x || lastLocation.y != location.y) 
			{	
				var withinStage:Boolean = Boolean(location.x >= 0 && location.y >= 0 && location.x <= p_oPoly.container.stage.stageWidth && location.y <= p_oPoly.container.stage.stageHeight);
				// mouse leave if left stage
				if ( !withinStage && lastWithinStage )
				{
					_lastEvent = new MouseEvent(Event.MOUSE_LEAVE, false, false);
					p_oPoly.container.stage.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
				}
				// only mouse move if within stage
				if ( withinStage )
				{	
					//_lastEvent = new MouseEvent( MouseEvent.MOUSE_MOVE, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta );
					_lastEvent = new MouseEvent(Event.MOUSE_LEAVE, false, false);
					currentTarget.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
				}
				
				// remember if within stage
				lastWithinStage = withinStage;
			}
			
			// roll/mouse (out and over) events 
			if ( currentTarget != m_ioOldTarget ) 
			{	
				// off of last target
				_lastEvent = new MouseEvent(MouseEvent.MOUSE_OUT, true, false, targetLocal.x, targetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				m_ioTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);	
				// rolls do not propagate
				_lastEvent = new MouseEvent(MouseEvent.ROLL_OUT, false, false, targetLocal.x, targetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				m_ioTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);
				// on to current target
				_lastEvent = new MouseEvent(MouseEvent.MOUSE_OVER, true, false, currentTargetLocal.x, currentTargetLocal.y, m_ioOldTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				currentTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);
				// rolls do not propagate
				_lastEvent = new MouseEvent( MouseEvent.ROLL_OVER, false, false, currentTargetLocal.x, currentTargetLocal.y, m_ioOldTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				currentTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);
			}
			
			// click/up/down events
			if ( p_event.type == MouseEvent.MOUSE_DOWN ) 
			{
				_lastEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				currentTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);
				// remember last down
				lastDownTarget = currentTarget;
				// mouse is up
			} 
			else if ( p_event.type == MouseEvent.MOUSE_UP )
			{
				_lastEvent = new MouseEvent(MouseEvent.MOUSE_UP, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				currentTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);
			}
			else if ( p_event.type == MouseEvent.CLICK ) 
			{
				_lastEvent = new MouseEvent(MouseEvent.CLICK, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				currentTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);
				// clear last down
				lastDownTarget = null;
			} 
			else if ( p_event.type == MouseEvent.DOUBLE_CLICK && currentTarget.doubleClickEnabled )
			{
				_lastEvent = new MouseEvent(MouseEvent.DOUBLE_CLICK, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				currentTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);
			}
			
			// remember last values
			lastLocation = location.clone();
			m_ioOldTarget = currentTarget;
		}
		
	/* ****************************************************************************
	* PRIVATE FUNCTIONS
	**************************************************************************** */		
		private function _checkLinks( tf : TextField ) : void
		{
			var currentTargetLocal:Point = tf.globalToLocal(location);
			var a : Array = TextLink.getTextLinks( tf );
			var l : Number = a.length;
			for ( var i : Number = 0; i < l; ++i )
			{
				if ( ( ( a[i] as TextLink ).getBounds() as Rectangle ).containsPoint( currentTargetLocal ) )
					;
			}
		}
		
	}
}

internal class PrivateConstructorAccess {}