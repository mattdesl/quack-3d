/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER
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

package sandy.core.data
{
	import sandy.core.scenegraph.Shape3D;
	import sandy.materials.Appearance;
	/** 
	 * PrimitiveFace is a tool for generated primitive, allowing users (for some specifics primitives) to get the face polygon array
	 * to have an easier manipulation.
	 * @author		Thomas Pfeiffer - kiroukou
	 * @author		Xavier Martin - zeflasher
	 * @version		3.0
	 * @date 		20.09.2007
	 **/
	public final class PrimitiveFace
	{
		private var m_iPrimitive	: Shape3D;
		private var m_oAppearance	: Appearance;
		
		/**
		 * The array containing the polygon instances own by this primitive face
		 */
		public var aPolygons		: Array = new Array();
	
		/**
		 * PrimitiveFace class
		 * This class is a tool for the primitives. It will stores all the polygons that are owned by the visible primitive face.
		 * 
		 * @param p_iPrimitive The primitive this face will be linked to
		 */
		public function PrimitiveFace( p_iPrimitive:Shape3D )
		{
			m_iPrimitive = p_iPrimitive;
		}

		public function get primitive():Shape3D
		{
			return m_iPrimitive;
		}
		
		public function addPolygon( p_oPolyId:uint ):void
		{
			aPolygons.push( m_iPrimitive.aPolygons[p_oPolyId] );
		}
		
		/**
		 * The appearance of this face.
		 */
		public function set appearance( p_oApp:Appearance ):void
		{
			// Now we register to the update event
			m_oAppearance = p_oApp;
			// --
			if( m_iPrimitive.geometry )	// ?? is it needed?
			{
				for each( var v:Polygon in aPolygons )
					v.appearance = m_oAppearance;
			}
		}
		
		public function get appearance():Appearance
		{
			return m_oAppearance;
		}
	}
}
