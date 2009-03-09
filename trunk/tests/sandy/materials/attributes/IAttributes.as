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
	* Interface for all the elements that represent a material attribute property.
	* This interface is important to make attributes really flexible and allow users to extend it.
	*/
	public interface IAttributes
	{
		/**
		* @private
		*/
		function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void;

		/**
		* @private
		*/
		function drawOnSprite( p_oSprite:Sprite2D, p_oMaterial:Material, p_oScene:Scene3D ):void;

		/**
		* @private
		*/
		function init( p_oPolygon:Polygon ):void;

		/**
		* @private
		*/
		function unlink( p_oPolygon:Polygon ):void;

		/**
		* @private
		*/
		function begin( p_oScene:Scene3D ):void;

		/**
		* @private
		*/
		function finish( p_oScene:Scene3D ):void;

		/**
		* @private
		*/
		function get flags():uint;
	}
}