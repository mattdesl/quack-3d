﻿/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author Thomas PFEIFFER (thomas.pfeiffer AT gmail DOT com) flashsandy.org
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

package sandy.core 
{
	import flash.display.Sprite;
	
	import sandy.core.data.Matrix4;
	import sandy.core.data.Polygon;
	import sandy.core.data.Pool;
	import sandy.core.data.Point3D;
	import sandy.core.data.Vertex;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.IDisplayable;
	import sandy.core.scenegraph.Node;
	import sandy.core.scenegraph.Renderable;
	import sandy.core.scenegraph.Shape3D;
	import sandy.core.scenegraph.Sprite2D;
	import sandy.view.CullingState;
	import sandy.view.Frustum;

	/**
	 * @author thomas
	 */
	public class Renderer 
	{
		protected const m_aDisplayList:Array = new Array();
		protected var m_nDisplayListCount:int;
		protected var m_aCamera:Camera3D;
		
		protected const m_aRenderingList:Array = new Array();
		protected var m_nRenderingListCount:int;
		private var pool:Pool = new Pool();
		
		private var m_bGlobalRedraw:Boolean;
		
		public function Renderer() 
		{
			m_nRenderingListCount = 0;
			m_nDisplayListCount = 0;
		}

		public function init():void
		{
			m_nDisplayListCount = 0;
			m_bGlobalRedraw = false;
		}
		
		/**
		 * Process the rendering of the scene.
		 * The camera has all the information needed about the objects to render.
		 * 
		 * The camera stores all the visible shape/polygons into an array, and loop through it calling their display method.
		 * Before the display call, the container graphics is cleared.
		 */
		public function renderDisplayList( p_oScene:Scene3D ):void
		{
			const l_mcContainer:Sprite = p_oScene.container;
		    // --
		    m_aRenderingList.sortOn( "depth", Array.NUMERIC | Array.DESCENDING );
		    // -- This is the new list to be displayed.
			var l_oFace:IDisplayable;
			for( var i:int = 0; i < m_nRenderingListCount; i++ )
			{
				l_oFace = m_aRenderingList[int(i)];
				if( l_oFace.changed || p_oScene.camera.changed )
				{
					l_oFace.display();
				}
				// --
				if( i < l_mcContainer.numChildren )
				{
					if( l_mcContainer.getChildAt(i) != l_oFace.container )
					{
						l_mcContainer.addChildAt( l_oFace.container, i );
					}
				}
				else
				{
					l_mcContainer.addChildAt( l_oFace.container, i );
				}
			}
		}
		
		public function addToDisplayList( p_oObject:IDisplayable ):void
		{
			m_aDisplayList[m_nDisplayListCount++] = p_oObject;
			m_bGlobalRedraw = m_bGlobalRedraw || p_oObject.changed;
		}
		
		public function render( p_oScene:Scene3D ):Boolean
		{
			var 	m11:Number, m21:Number, m31:Number,
					m12:Number, m22:Number, m32:Number,
					m13:Number, m23:Number, m33:Number,
					m14:Number, m24:Number, m34:Number,
					x:Number, y:Number, z:Number;
			var		l_oCamera:Camera3D = p_oScene.camera;		
			var  	l_nZNear:Number = l_oCamera.near, l_oCamPos:Point3D = pool.nextPoint3D, l_nPolyFlags:uint = 0,
	        		l_oMatrix:Matrix4, l_oFrustum:Frustum = l_oCamera.frustrum, 
					l_oVertex:Vertex, l_aVertices:Array, l_oFace:Polygon, l_nMinZ:Number, l_nFlags:int;
			var 	l_nVisiblePolyCount:int = 0, i:int;
		
			var l_bForceRedraw:Boolean = p_oScene.camera.changed;
			
			// -- return false because we do not even need to refresh display
			if( m_bGlobalRedraw == false && l_bForceRedraw == false )
				return false;
			
			// -- Note, this is the displayed list from the previous iteration!
			for each( var l_oObj:IDisplayable in m_aRenderingList )
			{
				if( l_oObj )
				{
					if( l_bForceRedraw == true || l_oObj.changed == true )
					{
						l_oObj.clear();
					}
				}
			}
			// --
			m_nRenderingListCount = 0;
			m_aRenderingList.length = 0;
			// --
			for( i = 0; i < m_nDisplayListCount; i ++ )
			{
				if( m_aDisplayList[int(i)] is Shape3D )
				{
					var l_oShape:Shape3D = m_aDisplayList[int(i)] as Shape3D;
					// if no change for that object, directly go to the draw level
					if( l_oShape.changed == false && l_bForceRedraw == false )
					{
						if( l_oShape.useSingleContainer )
							m_aRenderingList[int(m_nRenderingListCount++)] = l_oShape;
						else
						{
							for each( l_oFace in l_oShape.aVisiblePolygons )
								m_aRenderingList[int(m_nRenderingListCount++)] = l_oFace;
						}
						continue;
					}
					// --
					l_nFlags = l_oShape.appearance.flags;
					l_oShape.depth = 0;
					l_oShape.aVisiblePolygons.length = 0;
					l_oCamPos.reset(l_oCamera.modelMatrix.n14, l_oCamera.modelMatrix.n24, l_oCamera.modelMatrix.n34);
					l_oShape.invModelMatrix.Point3DMult( l_oCamPos );
					// --
					l_oMatrix = l_oShape.viewMatrix;
					m11 = l_oMatrix.n11; m21 = l_oMatrix.n21; m31 = l_oMatrix.n31;
					m12 = l_oMatrix.n12; m22 = l_oMatrix.n22; m32 = l_oMatrix.n32;
					m13 = l_oMatrix.n13; m23 = l_oMatrix.n23; m33 = l_oMatrix.n33;
					m14 = l_oMatrix.n14; m24 = l_oMatrix.n24; m34 = l_oMatrix.n34;
					// --
					var l_bClipped:Boolean = ((l_oShape.culled == CullingState.INTERSECT) && ( l_oShape.enableClipping || l_oShape.enableNearClipping ));
					// --
					for each( l_oVertex in l_oShape.geometry.aVertex )
					{
						l_oVertex.projected = l_oVertex.transformed = false;
					}
					// --
					for each( l_oFace in l_oShape.aPolygons )
		            {
						if( l_oShape.animated )
							l_oFace.updateNormal();
		                // -- visibility test
		                l_oVertex = l_oFace.normal;
		                x = l_oFace.a.x; y = l_oFace.a.y; z = l_oFace.a.z;
			            l_oFace.visible = (l_oVertex.x*( l_oCamPos.x - x) + l_oVertex.y*( l_oCamPos.y - y) + l_oVertex.z*( l_oCamPos.z - z)) > 0;
			            // -- 
		                if( l_oShape.enableBackFaceCulling )
		                {
			                if( l_oFace.visible == false )
			                	continue;
		                }
		                // --
		                l_oVertex = l_oFace.a;
		                if( l_oVertex.transformed == false )// (l_oVertex.flags & SandyFlags.VERTEX_CAMERA) == 0)
		                {
							l_oVertex.wx = (x) * m11 + (y) * m12 + (z) * m13 + m14;
							l_oVertex.wy = x * m21 + y * m22 + z * m23 + m24;
							l_oVertex.wz = x * m31 + y * m32 + z * m33 + m34;
							//l_oVertex.flags |= SandyFlags.VERTEX_CAMERA;
							l_oVertex.transformed = true;
						}
						
						l_oVertex = l_oFace.b;
						if( l_oVertex.transformed == false )// (l_oVertex.flags & SandyFlags.VERTEX_CAMERA) == 0)
		                {
							l_oVertex.wx = (x=l_oVertex.x) * m11 + (y=l_oVertex.y) * m12 + (z=l_oVertex.z) * m13 + m14;
							l_oVertex.wy = x * m21 + y * m22 + z * m23 + m24;
							l_oVertex.wz = x * m31 + y * m32 + z * m33 + m34;
							//l_oVertex.flags |= SandyFlags.VERTEX_CAMERA;
							l_oVertex.transformed = true;
		                }
		          						
						l_oVertex = l_oFace.c;
						if( l_oVertex )
		                {
							if( l_oVertex.transformed == false )//(l_oVertex.flags & SandyFlags.VERTEX_CAMERA) == 0)
			                {
								l_oVertex.wx = (x=l_oVertex.x) * m11 + (y=l_oVertex.y) * m12 + (z=l_oVertex.z) * m13 + m14;
								l_oVertex.wy = x * m21 + y * m22 + z * m23 + m24;
								l_oVertex.wz = x * m31 + y * m32 + z * m33 + m34;
								//l_oVertex.flags |= SandyFlags.VERTEX_CAMERA;
								l_oVertex.transformed = true;
			                }
		                }

		                l_oVertex = l_oFace.d;
						if( l_oVertex )
		                {
							if( l_oVertex.transformed == false )
							{
								l_oVertex.wx = (x=l_oVertex.x) * m11 + (y=l_oVertex.y) * m12 + (z=l_oVertex.z) * m13 + m14;
								l_oVertex.wy = x * m21 + y * m22 + z * m23 + m24;
								l_oVertex.wz = x * m31 + y * m32 + z * m33 + m34;
								l_oVertex.transformed = true;
							}
		                }

		                // --               	
						l_oFace.precompute();
		                l_nMinZ = l_oFace.minZ;
		                // -- culling/clipping phasis
		                if( l_bClipped )
		                {
		                	if( l_oShape.enableClipping ) // NEED COMPLETE CLIPPING
							{
								l_oFace.clip( l_oFrustum );
							}
							else if( l_oShape.enableNearClipping && l_nMinZ < l_nZNear ) // PARTIALLY VISIBLE
							{
								l_oFace.clipFrontPlane( l_oFrustum );
							}
							else if( l_nMinZ < l_nZNear )
							{
								continue;
							}
		                }
		  				else if( l_nMinZ < l_nZNear )
						{
							continue;
						}
						// --
						l_aVertices = l_oFace.isClipped ? l_oFace.cvertices : l_oFace.vertices;
						if( l_aVertices.length > 1 )
						{
							l_oCamera.projectArray( l_aVertices );
							if(l_oShape.enableForcedDepth)
								l_oFace.depth = l_oShape.forcedDepth;
							else
								l_oShape.depth += l_oFace.depth;    
							// --
							l_nVisiblePolyCount++;
							l_oShape.aVisiblePolygons[int(l_oShape.aVisiblePolygons.length)] = l_oFace;
							// --
							l_nPolyFlags |= l_nFlags;
							// --
							if( l_oShape.useSingleContainer == false )
								m_aRenderingList[int(m_nRenderingListCount++)] = l_oFace;
						}
					}
					// --
					if( l_oShape.aVisiblePolygons.length > 0 )
					{
						if( l_oShape.useSingleContainer == true )
						{
							if(l_oShape.enableForcedDepth) 
								l_oShape.depth = l_oShape.forcedDepth;
							else
								l_oShape.depth /= l_oShape.aVisiblePolygons.length;
							// --
							m_aRenderingList[int(m_nRenderingListCount++)] = l_oShape;
						}
						// --
						if( l_nFlags != 0 || l_nPolyFlags != 0 )
						{
							if( (l_nFlags | l_nPolyFlags) & SandyFlags.POLYGON_NORMAL_WORLD )
				            {
				            	l_oMatrix = l_oShape.modelMatrix;
				           		m11 = l_oMatrix.n11; m21 = l_oMatrix.n21; m31 = l_oMatrix.n31;
				            	m12 = l_oMatrix.n12; m22 = l_oMatrix.n22; m32 = l_oMatrix.n32;
				            	m13 = l_oMatrix.n13; m23 = l_oMatrix.n23; m33 = l_oMatrix.n33;
				                // -- Now we transform the normals.
				                for each( l_oFace in l_oShape.aVisiblePolygons )
								{
				                    l_oVertex = l_oFace.normal;
				                    l_oVertex.wx  = (x=l_oVertex.x) * m11 + (y=l_oVertex.y) * m12 + (z=l_oVertex.z) * m13;
				                    l_oVertex.wy  = x * m21 + y * m22 + z * m23;
				                    l_oVertex.wz  = x * m31 + y * m32 + z * m33;
				                }
				            }
				            if( (l_nFlags | l_nPolyFlags) & SandyFlags.VERTEX_NORMAL_WORLD )
				            {
				            	l_oMatrix = l_oShape.modelMatrix;
				           		m11 = l_oMatrix.n11; m21 = l_oMatrix.n21; m31 = l_oMatrix.n31;
				            	m12 = l_oMatrix.n12; m22 = l_oMatrix.n22; m32 = l_oMatrix.n32;
				            	m13 = l_oMatrix.n13; m23 = l_oMatrix.n23; m33 = l_oMatrix.n33;
				                // -- Now we transform the normals.
				                for each( l_oVertex in l_oShape.geometry.aVertexNormals )
				                {
				                    l_oVertex.wx  = (x=l_oVertex.x) * m11 + (y=l_oVertex.y) * m12 + (z=l_oVertex.z) * m13;
				                    l_oVertex.wy  = x * m21 + y * m22 + z * m23;
				                    l_oVertex.wz  = x * m31 + y * m32 + z * m33;
				                }
				            }
						}
					}
				}
				else if( m_aDisplayList[int(i)] is Sprite2D )
				{
					var l_oSprite2D:Sprite2D = m_aDisplayList[int(i)] as Sprite2D;
					l_oSprite2D.v.projected = false;
					l_oSprite2D.vx.projected = false;
					l_oSprite2D.vy.projected = false;
					
					l_oVertex = l_oSprite2D.v;
					l_oMatrix = l_oSprite2D.viewMatrix;
					l_oVertex.wx = l_oVertex.x * l_oMatrix.n11 + l_oVertex.y * l_oMatrix.n12 + l_oVertex.z * l_oMatrix.n13 + l_oMatrix.n14;
					l_oVertex.wy = l_oVertex.x * l_oMatrix.n21 + l_oVertex.y * l_oMatrix.n22 + l_oVertex.z * l_oMatrix.n23 + l_oMatrix.n24;
					l_oVertex.wz = l_oVertex.x * l_oMatrix.n31 + l_oVertex.y * l_oMatrix.n32 + l_oVertex.z * l_oMatrix.n33 + l_oMatrix.n34;
		
					l_oSprite2D.depth = l_oSprite2D.enableForcedDepth ? l_oSprite2D.forcedDepth : l_oVertex.wz;
		
					l_oCamera.projectVertex( l_oVertex );
					m_aRenderingList[int(m_nRenderingListCount++)] = l_oSprite2D;
		
					l_oSprite2D.vx.copy (l_oVertex); l_oSprite2D.vx.wx++; l_oCamera.projectVertex (l_oSprite2D.vx);
					l_oSprite2D.vy.copy (l_oVertex); l_oSprite2D.vy.wy++; l_oCamera.projectVertex (l_oSprite2D.vy);
				}
				else if( m_aDisplayList[int(i)] is Renderable )
				{
					(m_aDisplayList[int(i)] as Renderable).render(l_oCamera);
					m_aRenderingList[int(m_nRenderingListCount++)] = m_aDisplayList[int(i)] as Renderable;
				}
			}
			// true because need need to refresh display
			return true;
		}
	}
}
