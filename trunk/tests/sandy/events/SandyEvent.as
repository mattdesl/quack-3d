/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.mozilla.org/MPL/MPL-1.1.html
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# ***** END LICENSE BLOCK *****
*/

package sandy.events
{
	import flash.events.Event;

	/**
	 * Conatains custom Sandy events.
	 *
	 * @author	Dennis Ippel
	 * @version	3.0
	 *
	 * @see BubbleEventBroadcaster
	 */
	public class SandyEvent extends Event
	{
	    /**
		 * Defines the value of the <code>type</code> property of a <code>lightAdded</code> event object.
	     *
	     * @eventType lightAdded
	     *
	     * @see sandy.core.Scene3D
	     */
		public static const LIGHT_ADDED:String = "lightAdded";

	    /**
		 * Defines the value of the <code>type</code> property of a <code>lightUpdated</code> event object.
	     *
	     * @eventType lightUpdated
	     *
	     * @see sandy.core.light.Light3D
	     */
		public static const LIGHT_UPDATED:String = "lightUpdated";

	    /**
		 * Defines the value of the <code>type</code> property of a <code>lightColorChanged</code> event object.
	     *
	     * @eventType lightColorChanged
	     *
	     * @see sandy.core.light.Light3D
	     */
		public static const LIGHT_COLOR_CHANGED:String = "lightColorChanged";

	    /**
		 * Defines the value of the <code>type</code> property of a <code>scene_render</code> event object.
	     *
	     * @eventType scene_render
	     *
	     * @see sandy.core.Scene3D
	     */
		public static const SCENE_RENDER:String = "scene_render";

 		/**
		 * Defines the value of the <code>type</code> property of a <code>scene_render_finish</code> event object.
	     *
	     * @eventType scene_render_finish
	     *
	     * @see sandy.core.Scene3D
	     */
		public static const SCENE_RENDER_FINISH:String = "scene_render_finish";
		
	    /**
		 * Defines the value of the <code>type</code> property of a <code>scene_cull</code> event object.
	     *
	     * @eventType scene_cull
	     *
	     * @see sandy.core.Scene3D
	     */
		public static const SCENE_CULL:String = "scene_cull";

	    /**
		 * Defines the value of the <code>type</code> property of a <code>scene_update</code> event object.
	     *
	     * @eventType scene_update
	     *
	     * @see sandy.core.Scene3D
	     */
		public static const SCENE_UPDATE:String = "scene_update";

	    /**
		 * Defines the value of the <code>type</code> property of a <code>scene_render_display_list</code> event object.
	     *
	     * @eventType scene_render_display_list
	     *
	     * @see sandy.core.Scene3D
	     */
		public static const SCENE_RENDER_DISPLAYLIST:String = "scene_render_display_list";

	    /**
		 * Defines the value of the <code>type</code> property of a <code>containerCreated</code> event object.
	     * Not in use?
	     *
	     * @eventType containerCreated
	     *
	     * @see sandy.core.World3D
	     */
		public static const CONTAINER_CREATED:String = "containerCreated";

	    /**
		 * Defines the value of the <code>type</code> property of a <code>queueComplete</code> event object.
	     * Deprecated, use QueueEvent.QUEUE_COMPLETE instead.
	     *
	     * @eventType queueComplete
	     *
	     * @see sandy.util.LoaderQueue
	     */
		public static const QUEUE_COMPLETE:String = "queueComplete";

	    /**
		 * Defines the value of the <code>type</code> property of a <code>queueLoaderError</code> event object.
	     * Deprecated, use QueueEvent.QUEUE_LOADER_ERROR instead.
	     *
	     * @eventType queueLoaderError
	     *
	     * @see sandy.util.LoaderQueue
	     */
		public static const QUEUE_LOADER_ERROR:String = "queueLoaderError";

	 	/**
		 * Constructor.
		 *
		 * @param type The event type; indicates the action that caused the event.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
	     */
		public function SandyEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}

		/**
		 * @private
		 */
		override public function clone():Event
	    {
	        return new SandyEvent(type, bubbles, cancelable);
	    }
	}
}