﻿/*# ***** BEGIN LICENSE BLOCK *****Copyright the original author or authors.Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");you may not use this file except in compliance with the License.You may obtain a copy of the License at	http://www.mozilla.org/MPL/MPL-1.1.htmlUnless required by applicable law or agreed to in writing, softwaredistributed under the License is distributed on an "AS IS" BASIS,WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.See the License for the specific language governing permissions andlimitations under the License.# ***** END LICENSE BLOCK ******/package sandy.core.scenegraph {	import flash.geom.Rectangle;		import sandy.core.Scene3D;	import sandy.core.data.Matrix4;	import sandy.core.data.Vertex;	import sandy.util.NumberUtil;	import sandy.view.Frustum;	import sandy.view.ViewPort;		/**	 * The Camera3D class is used to create a camera for the Sandy world.	 *	 * <p>As of this version of Sandy, the camera is added to the object tree,	 * which means it is transformed in the same manner as any other object.</p>	 * 	 * @author		Thomas Pfeiffer - kiroukou	 * @version		3.0	 * @date 		26.07.2007	 */	public class Camera3D extends ATransformable	{		/**		 * The camera viewport		 */		public var viewport:ViewPort = new ViewPort(640,480);				/**		 * The frustum of the camera.		 */		public var frustrum:Frustum = new Frustum();		/**		 * Creates a camera for projecting visible objects in the world.		 *		 * <p>By default the camera shows a perspective projection. <br />		 * The camera is at -300 in z axis and look at the world 0,0,0 point.</p>		 * 		 * @param p_nWidth	Width of the camera viewport in pixels		 * @param p_nHeight	Height of the camera viewport in pixels		 * @param p_nFov	The vertical angle of view in degrees - Default 45		 * @param p_nNear	The distance from the camera to the near clipping plane - Default 50		 * @param p_nFar	The distance from the camera to the far clipping plane - Default 10000		 */		public function Camera3D( p_nWidth:Number = 550, p_nHeight:Number = 400, p_nFov:Number = 45, p_nNear:Number = 50, p_nFar:Number = 10000 )		{			super( null );			viewport.width = p_nWidth;			viewport.height = p_nHeight;			// --						_nFov = p_nFov;			_nFar = p_nFar;			_nNear = p_nNear;			// --			setPerspectiveProjection( _nFov, viewport.ratio, _nNear, _nFar );			m_nOffx = viewport.width2; 			m_nOffy = viewport.height2;			// It's a non visible node			visible = false;			z = -300;			lookAt( 0,0,0 );		}								/**		 * The angle of view of this camera in degrees.		 */		public function set fov( p_nFov:Number ):void		{			_nFov = p_nFov;			_perspectiveChanged = true;		}				/**		 * @private		 */		public function get fov():Number		{return _nFov;}				/**		 * Near plane distance for culling/clipping.		 */		public function set near( pNear:Number ):void		{_nNear = pNear; _perspectiveChanged = true;}				/**		 * @private		 */		public function get near():Number		{return _nNear;}						/**		 * Far plane distance for culling/clipping.		 */		public function set far( pFar:Number ):void		{_nFar = pFar;_perspectiveChanged = true;}				/**		 * @private		 */		public function get far():Number		{return _nFar;}			///////////////////////////////////////		//// GRAPHICAL ELEMENTS MANAGMENT /////		///////////////////////////////////////	        		/**		 * <p>Project the vertices list given in parameter.		 * The vertices are projected to the screen, as a 2D position.		 * A cache system is used here to prevent multiple projection of the same vertex.		 * In case you want to redo a projection, prefer projectVertex method which doesn't use a cache system.		 * </p>		 */		public function projectArray( p_oList:Array ):void		{			const l_nX:Number = viewport.offset.x + m_nOffx;			const l_nY:Number = viewport.offset.y + m_nOffy;			var l_nCste:Number;			var l_mp11_offx:Number = mp11 * m_nOffx;			var l_mp22_offy:Number = mp22 * m_nOffy;			for each( var l_oVertex:Vertex in p_oList )			{				if( l_oVertex.projected == false )//(l_oVertex.flags & SandyFlags.VERTEX_PROJECTED) == 0)				{					l_nCste = 	1 / l_oVertex.wz;					l_oVertex.sx =  l_nCste * l_oVertex.wx * l_mp11_offx + l_nX;					l_oVertex.sy = -l_nCste * l_oVertex.wy * l_mp22_offy + l_nY;					//l_oVertex.flags |= SandyFlags.VERTEX_PROJECTED;					l_oVertex.projected = true;				}			}		}					/**		 * <p>Project the vertex passed as parameter.		 * The vertices are projected to the screen, as a 2D position.		 * </p>		 */		public function projectVertex( p_oVertex:Vertex ):void		{			const l_nX:Number = (viewport.offset.x + m_nOffx);			const l_nY:Number = (viewport.offset.y + m_nOffy);			const l_nCste:Number = 	1 / p_oVertex.wz;			p_oVertex.sx =  l_nCste * p_oVertex.wx * mp11 * m_nOffx + l_nX;			p_oVertex.sy = -l_nCste * p_oVertex.wy * mp22 * m_nOffy + l_nY;			//p_oVertex.flags |= SandyFlags.VERTEX_PROJECTED;			//p_oVertex.projected = true;		}				/**		 * Updates the state of the camera transformation.		 *		 * @param p_oScene			The current scene		 * @param p_oModelMatrix The matrix which represents the parent model matrix. Basically it stores the rotation/translation/scale of all the nodes above the current one.		 * @param p_bChanged	A boolean value which specify if the state has changed since the previous rendering. If false, we save some matrix multiplication process.		 */		public override function update( p_oModelMatrix:Matrix4, p_bChanged:Boolean ):void		{			if( viewport.hasChanged )			{				_perspectiveChanged = true;				// -- update the local values				m_nOffx = viewport.width2; 				m_nOffy = viewport.height2;				// -- Apply a scrollRect to the container at the viewport dimension				if( scene.rectClipping ) 					scene.container.scrollRect = new Rectangle( 0, 0, viewport.width, viewport.height );				else					scene.container.scrollRect = null;				// -- we warn the the modification has been taken under account				viewport.hasChanged = false;			}			// --			if( _perspectiveChanged ) updatePerspective();			super.update( p_oModelMatrix, p_bChanged );		}		/**		 * Nothing to do - the camera can't be culled		 */		public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void		{			return;		}				/**		* Returns the projection matrix of this camera. 		* 		* @return 	The projection matrix		*/		public function get projectionMatrix():Matrix4		{			return _mp;		}				/**		 * Returns the inverse of the projection matrix of this camera.		 *		 * @return 	The inverted projection matrix		 */		public function get invProjectionMatrix():Matrix4		{			_mpInv.copy( _mp );			_mpInv.inverse();			return _mpInv;		}				/**		* Sets a projection matrix with perspective. 		*		* <p>This projection allows a natural visual presentation of objects, mimicking 3D perspective.</p>		*		* @param p_nFovY 	The angle of view in degrees - Default 45.		* @param p_nAspectRatio The ratio between vertical and horizontal dimension - Default the viewport ratio (width/height)		* @param p_nZNear 	The distance betweeen the camera and the near plane - Default 10.		* @param p_nZFar 	The distance betweeen the camera position and the far plane. Default 10 000.		*/		protected function setPerspectiveProjection(p_nFovY:Number, p_nAspectRatio:Number, p_nZNear:Number, p_nZFar:Number):void		{			var cotan:Number, Q:Number;			// --			frustrum.computePlanes(p_nAspectRatio, p_nZNear, p_nZFar, p_nFovY );			// --			p_nFovY = NumberUtil.toRadian( p_nFovY );			cotan = 1 / Math.tan(p_nFovY / 2);			Q = p_nZFar/(p_nZFar - p_nZNear);						_mp.zero();				_mp.n11 = cotan / p_nAspectRatio;			_mp.n22 = cotan;			_mp.n33 = Q;			_mp.n34 = -Q*p_nZNear;			_mp.n43 = 1;			// to optimize later			mp11 = _mp.n11; mp21 = _mp.n21; mp31 = _mp.n31; mp41 = _mp.n41;			mp12 = _mp.n12; mp22 = _mp.n22; mp32 = _mp.n32; mp42 = _mp.n42;			mp13 = _mp.n13; mp23 = _mp.n23; mp33 = _mp.n33; mp43 = _mp.n43;			mp14 = _mp.n14; mp24 = _mp.n24; mp34 = _mp.n34; mp44 = _mp.n44;									changed = true;			}					/**		 * Updates the perspective projection.		 */		protected function updatePerspective():void		{			setPerspectiveProjection( _nFov, viewport.ratio, _nNear, _nFar );			_perspectiveChanged = false;		}		/**		 * Delete the camera node and clear its displaylist.		 *  		 */		public override function destroy():void		{			viewport = null;			// --			super.destroy();		}				public override function toString():String		{			return "sandy.core.scenegraph.Camera3D";		}					//////////////////////////		/// PRIVATE PROPERTIES ///		//////////////////////////		private var _perspectiveChanged:Boolean = false;		private var _mp:Matrix4 = new Matrix4(); // projection Matrix4		private var _mpInv:Matrix4 = new Matrix4(); // Inverse of the projection matrix 		private var _nFov:Number;		private var _nFar:Number;		private var _nNear:Number;		private var mp11:Number, mp21:Number,mp31:Number,mp41:Number,					mp12:Number,mp22:Number,mp32:Number,mp42:Number,					mp13:Number,mp23:Number,mp33:Number,mp43:Number,					mp14:Number,mp24:Number,mp34:Number,mp44:Number,									m_nOffx:int, m_nOffy:int;	}}