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
	import sandy.bounds.BBox;
	import sandy.bounds.BSphere;
	import sandy.core.data.Plane;
	import sandy.core.data.Pool;
	import sandy.core.data.UVCoord;
	import sandy.core.data.Point3D;
	import sandy.core.data.Vertex;
	import sandy.math.PlaneMath;
	import sandy.util.NumberUtil;	

	/**
	 * Used to create the frustum of the camera.
	 * 
	 * <p>The frustum is volume used to control a geometrical object, such as a box, a sphere, or a point
	 * can be seen by the camera, and thus should be rendered.</p> 
	 * <p>Clipping of objects and polygons is performed against the frustum surfaces, as well as the near and far planes.</p>
	 * 
	 * @author		Thomas Pfeiffer - kiroukou
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public class Frustum 
	{
		/**
		* An array of planes representing the frustum.
		*/
		public var aPlanes:Array;
		//  0-> +
		//  |
		//  V     5---4
		//  -    /|  /|
		//      / 6-/-7
		//     / / / /
		//    1---0 /   
		//    |/  |/
		//    2---3 	

		/**
		* An array of points representing the frustum.
		*/
		public var aPoints:Array;
		public var aNormals:Array;
		public var aConstants:Array;
		private const m_aBoxEdges:Array = new Array(8);
		private var pool:Pool = new Pool();
		/**
		* Specifies the index of the far plane of the frustum in the aPlanes array.
		*/
		public static const FAR:uint 	= 0;
		
		/**
		* Specifies the index of the near plane of the frustum in the aPlanes array.
		*/
		public static const NEAR:uint 	= 1;
		
		/**
		* Specifies the index of the right plane of the frustum in the aPlanes array.
		*/
		public static const RIGHT:uint 	= 2;
		
		/**
		* Specifies the index of the left plane of the frustum in the aPlanes array.
		*/
		public static const LEFT:uint	= 3;
		
		/**
		* Specifies the index of the top plane of the frustum in the aPlanes array.
		*/
	    public static const TOP:uint 	= 4;
		
		/**
		* Specifies the index of the bottom plane of the frustum in the aPlanes array.
		*/
		public static const BOTTOM:uint = 5; 
		
		/**
		* Alias of CullingState.INSIDE.
		*/
		public static const INSIDE:CullingState = CullingState.INSIDE;
		
		/**
		* Alias of CullingState.OUTSIDE.
		*/
		public static const OUTSIDE:CullingState = CullingState.OUTSIDE;
		
		/**
		* Alias of CullingState.INTERSECT.
		*/
		public static const INTERSECT:CullingState = CullingState.INTERSECT;
		public static const EPSILON:Number = 0.005;
	
		/**
		 * Creates a frustum for the camera.
		 *
		 * <p>This constructor only creates the necessay data structures</p>
		 */
		public function Frustum() 
		{
			aPlanes = new Array(6);
			aPoints = new Array(8);
			aNormals = new Array(6);
			aConstants = new Array(6);
			for( var i:int = 0; i < 8; i++ )
				m_aBoxEdges[int(i)] = new Point3D();
			
		}
		
		/**
		 * Computes the frustum planes.
		 * 
		 * @param p_nAspect	Aspect ration of the camera.
		 * @param p_nNear	The distance from the camera to the near clipping plane.
		 * @param p_nFar	The distance from the camera to the far clipping plane.
		 * @param p_nFov	Vertical field of view of the camera.
		 */
		public function computePlanes( p_nAspect:Number, p_nNear:Number, p_nFar:Number, p_nFov:Number ):void
		{
			// store the information
			var lRadAngle:Number = NumberUtil.toRadian( p_nFov );
			// compute width and height of the near and far plane sections
			var tang:Number = Math.tan(lRadAngle * 0.5) ;
			
			// we inverse the vertical axis as Flash as a vertical axis inversed by our 3D one. VERY IMPORTANT
			var yNear:Number = -tang * p_nNear;			
			var xNear:Number = yNear * p_nAspect;
			var yFar:Number = yNear * p_nFar / p_nNear;
			var xFar:Number = xNear * p_nFar / p_nNear;
			p_nNear = -p_nNear;
			p_nFar = -p_nFar;
			var p:Array = aPoints;
			p[0] = new Point3D( xNear, yNear, p_nNear); // Near, right, top
			p[1] = new Point3D( xNear,-yNear, p_nNear); // Near, right, bottom
			p[2] = new Point3D(-xNear,-yNear, p_nNear); // Near, left, bottom
			p[3] = new Point3D(-xNear, yNear, p_nNear); // Near, left, top
			p[4] = new Point3D( xFar,  yFar,  p_nFar);  // Far, right, top
			p[5] = new Point3D( xFar, -yFar,  p_nFar);  // Far, right, bottom
			p[6] = new Point3D(-xFar, -yFar,  p_nFar);  // Far, left, bottom
			p[7] = new Point3D(-xFar,  yFar,  p_nFar);  // Far, left, top
			
			aPlanes[LEFT] 	= PlaneMath.computePlaneFromPoints( p[2], p[3], p[6] ); // Left
			aPlanes[RIGHT] 	= PlaneMath.computePlaneFromPoints( p[0], p[1], p[4] ); // right
			aPlanes[TOP] 	= PlaneMath.computePlaneFromPoints( p[0], p[7], p[3] ); // Top
			aPlanes[BOTTOM] = PlaneMath.computePlaneFromPoints( p[1], p[2], p[5] ); // Bottom
			aPlanes[NEAR] 	= PlaneMath.computePlaneFromPoints( p[0], p[2], p[1] ); // Near
			aPlanes[FAR] 	= PlaneMath.computePlaneFromPoints( p[4], p[5], p[6] ); // Far
			
			for( var i:int = 0; i < 6; i++ )
			{
				PlaneMath.normalizePlane( aPlanes[int(i)] );
			}
		}
		
		/**
		 * Returns the culling state for the passed point.
		 * 
		 * <p>The method tests if the passed point is within the frustum volume or not.
		 * The returned culling state is either Frustum.INSIDE or Frustum.OUTSIDE.</p>
		 *
		 * @param p_oPoint	The point to test.
		 *
		 * @return The culling state of the point.
		 */
		public function pointInFrustum( p_oPoint:Point3D ):CullingState
		{
	        for each( var plane:Plane in aPlanes ) 
			{
				if ( PlaneMath.classifyPoint( plane, p_oPoint) == PlaneMath.NEGATIVE )
				{
					return Frustum.OUTSIDE;
				}
			}
			return Frustum.INSIDE ;
		}
		
		/**
		 * Returns the culling state for the passed bounding sphere.
		 * 
		 * <p>The method tests if the bounding sphere is within the frustum volume or not.
		 * The returned culling state is either Frustum.INSIDE, Frustum.OUTSIDE or Frustum.INTERSECT</p>
		 *
		 * @param p_oSphere	The sphere to test.
		 *
		 * @return The culling state of the sphere.
		 */
		public function sphereInFrustum( p_oSphere:BSphere ):CullingState
		{
	        var d:Number = 0, c:int=0;
	        const 	x:Number = p_oSphere.position.x, 
	        		y:Number = p_oSphere.position.y, 
	        		z:Number = p_oSphere.position.z, 
	        		radius:Number = p_oSphere.radius;
	        // --
	        for each( var plane:Plane in aPlanes ) 
	        { 
	            d = plane.a * x + plane.b * y + plane.c * z + plane.d; 
	            if( d <= -radius )
	            {
	                return Frustum.OUTSIDE;
	            }
	            if( d > radius )
	            { 
	                c++;
	            }
	        } 
	        // --
	        return (c == 6) ? Frustum.INSIDE : Frustum.INTERSECT;
		}
	
		/**
		 * Returns the culling state for the passed bounding box.
		 * 
		 * <p>The method tests if the bounding box is within the frustum volume or not.
		 * The returned culling state is either Frustum.INSIDE, Frustum.OUTSIDE or Frustum.INTERSECT</p>
		 *
		 * @param p_oS	The box to test.
		 *
		 * @return The culling state of the box.
		 */		
		public function boxInFrustum( p_oBox:BBox ):CullingState
		{
			var result:CullingState = Frustum.INSIDE, out:Number, iin:Number, lDist:Number;
			// --
			p_oBox.getEdges(m_aBoxEdges);
			// for each plane do the test
			for each( var plane:Plane in aPlanes )
			{
				// reset counters for corners in and out
				out = 0; iin = 0;
				// for each corner of the box do ...
				// get out of the cycle as soon as a box as corners
				// both inside and out of the frustum
				for each( var v:Point3D in m_aBoxEdges )
				{
					lDist = plane.a * v.x + plane.b * v.y + plane.c * v.z + plane.d;
					// is the corner outside or inside
					if ( lDist < 0 )
					{
						out++;
					}
					else
					{
						iin++;
					}
					// -- 
					if( iin > 0 && out > 0 )
					{
						break;
					}
				}
				// if all corners are out
				if ( iin == 0 )
				{
					return Frustum.OUTSIDE;
				}
				// if some corners are out and others are in	
				else if ( out > 0 )
				{
					return Frustum.INTERSECT;
				}
			}
			return result;
		}
	
		/**
		 * Clips a polygon against the frustum planes.
		 *
		 * @param p_aCvert		Vertices of the polygon.
		 * @param p_aUVCoords	UV coordiantes of the polygon.
		 */
		public function clipFrustum( p_aCvert: Array, p_aUVCoords:Array ):Boolean
		{
	        if ( p_aCvert.length <= 2 )
			{
				return true;
			}
			var l_bResult:Boolean, l_bClipped:Boolean;
			l_bResult = clipPolygon( aPlanes[NEAR], p_aCvert, p_aUVCoords ); // near
			l_bClipped = clipPolygon( aPlanes[LEFT], p_aCvert, p_aUVCoords ); // left
			l_bResult ||= l_bClipped;
			l_bClipped = clipPolygon( aPlanes[RIGHT], p_aCvert, p_aUVCoords ); // right
			l_bResult ||= l_bClipped;
	        l_bClipped = clipPolygon( aPlanes[BOTTOM], p_aCvert, p_aUVCoords ); // top
	        l_bResult ||= l_bClipped;
		    l_bClipped = clipPolygon( aPlanes[TOP], p_aCvert, p_aUVCoords ); // bottom	
		    l_bResult ||= l_bClipped;

			return l_bResult;
		}
	
	
		/**
		 * Clips a polygon against the front frustum plane.
		 *
		 * @param p_aCvert		Vertices of the polygon.
		 * @param p_aUVCoords	UV coordiantes of the polygon.
		 */
		public function clipFrontPlane( p_aCvert: Array, p_aUVCoords:Array ):Boolean
		{
			if ( p_aCvert.length <= 2 )
			{
				return true;
			}
			return clipPolygon( aPlanes[NEAR], p_aCvert, p_aUVCoords ); // near;
		}
		

		/**
		 * Clip the given vertex and UVCoords arrays against the frustum front plane.
		 *
		 * @param p_aCvert	Vertices of the line.
		 */
		public function clipLineFrontPlane( p_aCvert: Array ):Boolean
		{
			var l_oPlane:Plane = aPlanes[NEAR];
			var tmp:Array = p_aCvert.splice(0);
			// --
			var v0:Vertex = tmp[0];
			var v1:Vertex = tmp[1];
			// --		
			var l_nDist0:Number = l_oPlane.a * v0.wx + l_oPlane.b * v0.wy + l_oPlane.c * v0.wz + l_oPlane.d; 
			var l_nDist1:Number = l_oPlane.a * v1.wx + l_oPlane.b * v1.wy + l_oPlane.c * v1.wz + l_oPlane.d;
			// --
			var d:Number = 0;
			var t:Vertex = pool.nextVertex;
			// --
			if ( l_nDist0 < 0 && l_nDist1 >=0 )	// Coming in
			{	 
				d = l_nDist0/(l_nDist0-l_nDist1);
				t.wx = (v0.wx+(v1.wx-v0.wx)*d);
				t.wy = (v0.wy+(v1.wy-v0.wy)*d);
				t.wz = (v0.wz+(v1.wz-v0.wz)*d);
				//
				p_aCvert[p_aCvert.length] = ( t );
				p_aCvert[p_aCvert.length] = ( v1 );
				return true;
			} 
			else if ( l_nDist1 < 0 && l_nDist0 >=0 ) // Going out
			{	
				d = l_nDist0/(l_nDist0-l_nDist1);
				//
				t.wx = (v0.wx+(v1.wx-v0.wx)*d);
				t.wy = (v0.wy+(v1.wy-v0.wy)*d);
				t.wz = (v0.wz+(v1.wz-v0.wz)*d);
				
				p_aCvert[p_aCvert.length] = ( v0 );
				p_aCvert[p_aCvert.length] = ( t );
				return true;
			} 
			else if( l_nDist1 < 0 && l_nDist0 < 0 ) // ALL OUT
			{
				p_aCvert = null;
				return true;
			}
			else if( l_nDist1 > 0 && l_nDist0 > 0 ) // ALL IN
			{
				p_aCvert[p_aCvert.length] = ( v0 );
				p_aCvert[p_aCvert.length] = ( v1 );
				return false;
			}
			return true;
		}
		
   
		/**
		 * Clips a polygon against one the frustum planes.
		 *
		 * @param p_oPlane	The plane to clip against.
		 * @param p_aCvert	Vertices of the polygon. 
		 * @param p_aUVCoords	UV coordiantes of the polygon.
		 */
		private const aDist:Array = new Array();
		public function clipPolygon( p_oPlane:Plane, p_aCvert:Array, p_aUVCoords:Array ):Boolean
		{	
			var allin:Boolean = true, allout:Boolean = true;
			var v:Vertex;
			var i:Number, l:Number = p_aCvert.length, lDist:Number;
			// -- If no points, we return null
			aDist.length = 0;
			// -- otherwise we compute the distances to frustum plane
			for each( v in p_aCvert )
			{
				lDist = p_oPlane.a * v.wx + p_oPlane.b * v.wy + p_oPlane.c * v.wz + p_oPlane.d;
				if (lDist < 0) allin = false;
				if (lDist >= 0) allout = false;
				aDist[int(aDist.length)] = ( lDist );		
			}
			
			if (allin)
			{
				return false;
			}
			else if (allout)
			{
				// we return an empty array
				p_aCvert.splice(0);
				p_aUVCoords.splice(0);
				return true;
			}
			// Clip a polygon against a plane
			var tmp:Array = p_aCvert.splice(0);
			var l_aTmpUv:Array = p_aUVCoords.splice(0);
			var l_oUV1:UVCoord = l_aTmpUv[0], l_oUV2:UVCoord = null, l_oUVTmp:UVCoord = null;
			var v1:Vertex = tmp[0], v2:Vertex = null,  t:Vertex = null;
			//
			var d:Number, dist2:Number, dist1:Number = aDist[0];
			var clipped:Boolean = false, inside:Boolean = (dist1 >= 0);
			for (i=1; i <= l; i++)
			{	 
				v2 = tmp[int(i%l)];
				l_oUV2 = l_aTmpUv[int(i%l)];
				//
				dist2= aDist[int(i%l)];
				// Sutherland-hodgeman clipping
				if ( inside && (dist2 >= 0) ) 
				{
					p_aCvert[p_aCvert.length] = (v2);	// Both in
					p_aUVCoords[p_aUVCoords.length] = (l_oUV2);
				}
				else if ( (!inside) && (dist2>=0) )		// Coming in
				{	 
					clipped = inside = true;
					//
					t = pool.nextVertex;
					d = dist1/(dist1-dist2);
					t.wx = (v1.wx+(v2.wx-v1.wx)*d);
					t.wy = (v1.wy+(v2.wy-v1.wy)*d);
					t.wz = (v1.wz+(v2.wz-v1.wz)*d);
					//
					p_aCvert[p_aCvert.length] = ( t );
					p_aCvert[p_aCvert.length] = ( v2 );
					//
					l_oUVTmp = pool.nextUV;
					l_oUVTmp.u = (l_oUV1.u+(l_oUV2.u-l_oUV1.u)*d);
					l_oUVTmp.v = (l_oUV1.v+(l_oUV2.v-l_oUV1.v)*d);
					//
					p_aUVCoords[int(p_aUVCoords.length)] = (l_oUVTmp);
					p_aUVCoords[int(p_aUVCoords.length)] = (l_oUV2);
				} 
				else if ( inside && (dist2<0) )		// Going out
				{	 
					clipped=true;
					inside=false;
					t = pool.nextVertex;
					d = dist1/(dist1-dist2);
					//
					t.wx = (v1.wx+(v2.wx-v1.wx)*d);
					t.wy = (v1.wy+(v2.wy-v1.wy)*d);
					t.wz = (v1.wz+(v2.wz-v1.wz)*d);
					//
					l_oUVTmp = pool.nextUV;
					l_oUVTmp.u = (l_oUV1.u+(l_oUV2.u-l_oUV1.u)*d);
					l_oUVTmp.v = (l_oUV1.v+(l_oUV2.v-l_oUV1.v)*d);
					//
					p_aUVCoords[int(p_aUVCoords.length)] = (l_oUVTmp);
					p_aCvert[int(p_aCvert.length)] = ( t );
				} 
				else
				{
					clipped = true;		// Both out
				}
				
				v1 = v2;
				dist1 = dist2;
				l_oUV1 = l_oUV2;
			}
			// we free the distance array
			return true;
		}
	}
}