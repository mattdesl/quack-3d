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
	import sandy.core.data.Point3D;
	import sandy.core.data.Vertex;
	import sandy.materials.Material;
	
	/**
	 * Display the vertex normals of a given object.
	 *
	 * <p>Developed originally for a debug purpose, this class allows you to create some
	 * special effects, displaying the normal of each vertex.</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public final class VertexNormalAttributes extends LineAttributes
	{
		private var m_nLength:Number;
		
		/**
		 * Creates a new VertexNormalAttributes object.
		 *
		 * @param p_nLength		The length of the segment.
		 * @param p_nThickness	The line thickness.
		 * @param p_nColor		The line color.
		 * @param p_nAlpha		The alpha transparency value of the material.
		 */
		public function VertexNormalAttributes( p_nLength:Number = 10, p_nThickness:uint = 1, p_nColor:uint = 0, p_nAlpha:Number = 1 )
		{
			m_nLength = p_nLength;
			// reuse LineAttributes setters
			thickness = p_nThickness;
			alpha = p_nAlpha;
			color = p_nColor;
			// --
			modified = true;
		}
		
		/**
		 * The line length.
		 */
		public function get length():Number
		{
			return m_nLength;
		}
		
		/**
		 * @private
		 */
		public function set length( p_nValue:Number ):void
		{
			m_nLength = p_nValue; 
			modified = true;
		}
		
		/**
		 * @private
		 */
		override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):void
		{
			var l_aPoints:Array = p_oPolygon.vertices;
			var l_oVertex:Vertex;
			// --
			p_oGraphics.lineStyle( thickness, color, alpha );
			p_oGraphics.beginFill(0);
			// --
			var lId:int = l_aPoints.length;
			while( l_oVertex = l_aPoints[ --lId ] )
			{
				var l_oDiff:Point3D = p_oPolygon.vertexNormals[ lId ].getPoint3D().clone();
				p_oPolygon.shape.viewMatrix.Point3DMult3x3( l_oDiff );
				// --
				l_oDiff.scale( m_nLength );
				// --
				var l_oNormal:Vertex = Vertex.createFromPoint3D( l_oDiff );
				l_oNormal.add( l_oVertex );
				// --
				p_oScene.camera.projectVertex( l_oNormal );
				// --
				p_oGraphics.moveTo( l_oVertex.sx, l_oVertex.sy );
				p_oGraphics.lineTo( l_oNormal.sx, l_oNormal.sy );
				// --
				l_oNormal = null;
				l_oDiff = null;
			}
			// --
			p_oGraphics.endFill();
		}
	
		/**
		 * @private
		 */
		override public function begin( p_oScene:Scene3D ):void
		{
			; // TODO, do the normal projection here
		}
	}
}