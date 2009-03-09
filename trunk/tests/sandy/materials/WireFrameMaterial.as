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
	import flash.display.Sprite;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.materials.attributes.LineAttributes;
	import sandy.materials.attributes.MaterialAttributes;
	/**
	 * Displays the faces of a 3D shape as a wire frame.
	 *
	 * <p>This material is used to represent a kind a naked view of a Shape3D. It shows all the edges
	 * with a certain thickness, color and alpha that you can specify inside the constructor</p>
	 *
	 * @author		Thomas PFEIFFER - kiroukou
	 * @version		3.0
	 * @date 		26.06.2007
	 */
	public final class WireFrameMaterial extends Material
	{
		/**
		 * Creates a new WireFrameMaterial.
		 *
		 * @param p_nThickness	The thickness of the lines.
		 * @param p_nColor		The color of the lines.
		 * @param p_nAlpha		The alpha transparency value of the material.
		 * @param p_oAttr		The attributes for this material.
		 *
		 * @see sandy.materials.attributes.MaterialAttributes
		 */
		public function WireFrameMaterial( p_nThickness:uint=1, p_nColor:uint = 0, p_nAlpha: Number = 1, p_oAttr:MaterialAttributes=null )
		{
			super( p_oAttr );
			// --
			m_oType = MaterialType.WIREFRAME;
			// --
			attributes.attributes.push( new LineAttributes( p_nThickness, p_nColor,p_nAlpha ) ) ;

		}

		/**
		 * @private
		 */		
		public override function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ):void 
		{
			attributes.draw( p_mcContainer.graphics, p_oPolygon, this, p_oScene );
		}

	}
}