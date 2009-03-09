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
package sandy.materials.attributes
{
	import flash.display.Graphics;

	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.scenegraph.Sprite2D;
	import sandy.materials.Material;

	/**
	 * ABSTRACT CLASS - super class for attributes that do not need to implement all manager hooks.
	 *
	 * <p>This purpose of this class is to save some code. Hooks are still available using "override" keyword.</p>
	 *
	 * @author		makc
	 * @version		3.0.2
	 * @date 		18.01.2008
	 **/
	public class AAttributes implements IAttributes
	{
		/**
		* Draws attribute to the graphics object.
		*
		* @param p_oGraphics	The Graphics object to draw attributes to.
		* @param p_oPolygon		The polygon which is going to be drawn.
		* @param p_oMaterial	The refering material.
		* @param p_oScene		The scene.
		*
		* @see sandy.core.data.Polygon
		* @see sandy.materials.Material
		* @see sandy.core.Scene3D
		*/
		public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			;
		}

		/**
		* Applies attribute to a sprite.
		*
		* @param p_oSprite		The Sprite2D object to draw attributes to.
		* @param p_oMaterial	The refering material.
		* @param p_oScene		The scene.
		*
		* @see sandy.core.scenegraph.Sprite2D
		* @see sandy.materials.Material
		* @see sandy.core.Scene3D
		*/
		public function drawOnSprite( p_oSprite:Sprite2D, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			;
		}

		/**
		* Method called before the display list rendering. This is the common place for this attribute to precompute things.
		*
		* @param p_oScene	The scene.
		*
		* @see #finish()
		* @see sandy.core.Scene3D
		*/
		public function begin( p_oScene:Scene3D ):void
		{
			;
		}

		/**
		* Method called right after the display list rendering. This is the place to remove and dispose memory if necessary.
		*
		* @param p_oScene	The scene.
		*
		* @see #begin()
		* @see sandy.core.Scene3D
		*/
		public function finish( p_oScene:Scene3D ):void
		{
			;
		}

		/**
		* Allows to proceed to an initialization to know when the polyon isn't lined to the material.
		*
		* @param p_oPolygon	The polygon.
		*
		* @see #unlink()
		* @see sandy.core.data.Polygon
		*/
		public function init( p_oPolygon:Polygon ):void
		{
			;// to keep reference to the shapes/polygons that use this attribute
		}

		/**
		* Remove all the initialization (opposite of init).
		*
		* @param p_oPolygon	The polygon.
		*
		* @see #init()
		* @see sandy.core.data.Polygon
		*/
		public function unlink( p_oPolygon:Polygon ):void
		{
			;// to remove reference to the shapes/polygons that use this attribute
		}

		/**
		* Returns the specific flags of this attribute.
		*
		* @see sandy.core.SandyFlags
		*/
		public function get flags():uint
		{
			return m_nFlags;
		}

		/**
		* @private
		*/
		protected var m_nFlags:uint = 0;
	}
}