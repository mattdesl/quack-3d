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
package sandy.view 
{
	/**
	 * Used to identify the culling state of an object.
	 *
	 * <p>A 3D object can be completely or partly inside the frustum of the camera,
	 * or completely outside of it.</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class CullingState 
	{
		/**
		 * Specifies that the object intersects one or more planes of the frustum and should be partly rendered.
		 */
		public static const INTERSECT:CullingState = new CullingState("intersect");
		
		/**
		 * Specifies that the object completely inside the frustum and should be rendered.
		 */
		public static const INSIDE:CullingState = new CullingState("inside");
		
		/**
		 * Specifies that the object completely outside the frustum and should not be rendered.
		 */
		public static const OUTSIDE:CullingState = new CullingState("outside");
		
		/**
		 * Returns the string representation of the CullingState object.
		 */
		public function toString():String
		{
			return "[sandy.view.CullingState] :: state : "+m_sState;
		}
		
		/**
		 * Sets the value of this culling state.
		 */
		public function CullingState( p_sState:String )
		{
			m_sState = p_sState;
		}
		
		private var m_sState:String;
		
	}
}