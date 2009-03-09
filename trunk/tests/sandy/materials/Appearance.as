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
package sandy.materials 
{
	import sandy.core.Scene3D;
	
	/**
	 * Represents the appearance property of the visible objects.
	 *
	 * <p>The appearance holds the front and back materials of the object.</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 *
	 * @see 	sandy.core.scenegraph.Shape3D
	 */
	public class Appearance 
	{
		/**
		 * Creates an appearance with front and back materials.
		 *
		 * <p>If no material is passed, the default material for back and front is a default ColorMaterial.<br />
		 * If only a front material is passed, it will be used as back material as well.</p>
		 *
		 * @param p_oFront	The front material
		 * @param p_oBack	The back material
		 *
		 * @see sandy.materials.ColorMaterial
		 * @see sandy.materials.Material
		 */
		public function Appearance( p_oFront:Material=null, p_oBack:Material=null )
		{
			m_oFrontMaterial = (p_oFront != null) 	? p_oFront :	new ColorMaterial();
			m_oBackMaterial  = (p_oBack != null) 	? p_oBack  :	m_oFrontMaterial;
		}
		
		/**
		 * Get the use of vertex normal feature of the appearance.
		 *
		 * <p><b>Note: Only one of the materials is using this feature.</p>
		 */		
		public function get useVertexNormal():Boolean
		{ 
			return Boolean(m_oBackMaterial.useVertexNormal && m_oFrontMaterial.useVertexNormal); 
		}
		
		/**
		 * @private
		 */
		public function set frontMaterial( p_oMat:Material ):void
		{
			m_oFrontMaterial = p_oMat;
			if( m_oBackMaterial == null )
			{
				m_oBackMaterial = p_oMat;
			}
		}
		
		/**
		 * @private
		 */
		public function set backMaterial( p_oMat:Material ):void
		{
			m_oBackMaterial = p_oMat;
			if( m_oFrontMaterial == null )
			{
				m_oFrontMaterial = p_oMat;
			}
		}

		/**
		 * The front material held by this appearance.
		 */
		public function get frontMaterial():Material
		{
			return m_oFrontMaterial;
		}
		
		/**
		 * The back material held by this appearance.
		 */
		public function get backMaterial():Material
		{
			return m_oBackMaterial;
		}
		
		
		/**
		* Returns the flags for the front and back materials.
		*
		* @see sandy.core.SandyFlags
		*/
		public function get flags():uint
		{
			var l_nFlag:uint =  m_oFrontMaterial.flags;
			if( m_oFrontMaterial != m_oBackMaterial )
			{
				l_nFlag |= m_oBackMaterial.flags;
			}
			return l_nFlag;
		}
		
		/**
		 * Returns a string representation of this object.
		 *
		 * @return	The fully qualified name of this object.
		 */
		public function toString():String
		{
			return "sandy.materials.Appearance";
		}
		
		// --
		private var m_oFrontMaterial:Material;
		private var m_oBackMaterial:Material;
	}
}