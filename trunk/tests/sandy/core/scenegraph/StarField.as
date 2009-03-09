﻿/*
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

package sandy.core.scenegraph 
{	import flash.display.*;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Matrix4;
	import sandy.core.data.Vertex;
	import sandy.events.StarFieldRenderEvent;
	import sandy.view.Frustum;	
	/**
	* Dispatched when after BitmapData object is locked and normally about to be cleared.
	*
	* @eventType sandy.events.StarFieldRenderEvent.BEFORE_RENDER
	*/
	[Event(name="beforeRender", type="sandy.events.StarFieldRenderEvent")]
	
	/**
	* Dispatched when after BitmapData object is unlocked.
	*
	* @eventType sandy.events.StarFieldRenderEvent.AFTER_RENDER
	*/
	[Event(name="afterRender", type="sandy.events.StarFieldRenderEvent")]

	/**
	 * The StarField class renders dense star field at reasonable FPS.
	 *
	 * @author		makc
	 * @version		3.0.3
	 * @date 		03.03.2008
	 */
	public class StarField extends ATransformable implements IDisplayable, Renderable
	{
		/**
		 * Distance from screen where stars start to fade out
		 */
		public var fadeFrom:Number = 0;

		/**
		 * Distance from fadeFrom to the point where stars fade out completely
		 */
		public var fadeTo:Number = 1000;

		/**
		 * Array of Vertex - star coordinates data.
		 */
		public var stars:Array = [];
		
		/**
		 * Array of star colors (if not specified, white is used).
		 */
		public var starColors:Array = [];

		/**
		 * Array of star sprites (any IBitmapDrawable-s; if not specified, StarField uses setPixel to draw a star).
		 *
		 * <p>Star sprites are affected by corresponding starColors value; for DisplayObject-s, StarField will use
		 * their blendMode to draw them.</p>
		 */
		public var starSprites:Array = [];

		/**
		 * Creates a StarField.
		 *
		 * @param p_sName	A string identifier for this object
		 */	
		public function StarField( p_sName:String = "") 
		{
			super(p_sName);
			// create something
			m_oContainer = new Sprite ();
			m_oBitmapData = new BitmapData (1, 1, true, 0); makeEvents ();
			m_oBitmap = new Bitmap (m_oBitmapData);
			m_oContainer.addChild (m_oBitmap);
			_vx = new Vertex(); _vy = new Vertex();
		}

		/**
		 * The container of this object
		 */
		public function get container():Sprite
		{
			return m_oContainer;
		}


		/**
		 * An index in stars array; if set to valid value, depth returns distance to that star.
		 */
		public var depthIndex:int = -1;

		/**
		 * The depth to draw the starfield at. If depthIndex is set to valid value,
		 * depth returns distance to that star, otherwise value set by user (default: 1e10).
		 */
		public function get depth ():Number
		{
			var v:Vertex = stars [depthIndex] as Vertex;
			if (v != null)
				return v.wz;

			return m_nDepth;
		}

		/**
		 * @private
		 */
		public function set depth (p_nDepth:Number):void
		{
			m_nDepth = p_nDepth;
		}
		  
		/**
		 * This tests for stars visibility.
		 *
		 * @param p_oScene The current scene
		 * @param p_oFrustum	The frustum of the current camera
		 * @param p_oViewMatrix	The view martix of the curren camera
		 * @param p_bChanged
		 */
		public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Boolean ):void
		{
			super.cull( p_oFrustum, p_oViewMatrix, p_bChanged );
			// check if we need to resize our canvas
			if ((m_oBitmapData.width  != scene.camera.viewport.width)
			 || (m_oBitmapData.height != scene.camera.viewport.height))
			{
				m_oBitmap.bitmapData.dispose ();
				m_oBitmapData = new BitmapData (scene.camera.viewport.width, scene.camera.viewport.height, true, 0); 
				makeEvents ();
				m_oBitmap.bitmapData = m_oBitmapData;
			}
			// --
			scene.renderer.addToDisplayList( this ); 
		}
		
		/**
		 * Renders the starfield
		 *
		 * @param p_oScene The current scene
		 * @param p_oCamera	The current camera
		 */
		public function render( p_oCamera:Camera3D ):void
		{
			resetEvents ();
			m_oBitmapData.lock();
			m_oEB.dispatchEvent (m_oEventBefore);
			if (m_oEventBefore.clear) 
				m_oBitmapData.fillRect (m_oBitmapData.rect, 0);
			// --			
			var i:int = 0;
			var c32:Number, a:Number, c:Number, r:Number, rgb_r:Number, rgb_g:Number, rgb_b:Number, bY:Number;
			for (i = 0; i < stars.length; i++)
			{
				var _v:Vertex = stars [i];
				_v.wx = _v.x * viewMatrix.n11 + _v.y * viewMatrix.n12 + _v.z * viewMatrix.n13 + viewMatrix.n14;
				_v.wy = _v.x * viewMatrix.n21 + _v.y * viewMatrix.n22 + _v.z * viewMatrix.n23 + viewMatrix.n24;
				_v.wz = _v.x * viewMatrix.n31 + _v.y * viewMatrix.n32 + _v.z * viewMatrix.n33 + viewMatrix.n34;
				
				if (_v.wz >= p_oCamera.near)
				{
					r = Math.min(1, Math.max (0, (_v.wz - fadeFrom) / fadeTo));
					if (r < 1)
					{
						// will uint and bit shift really make a difference?
						c32 = (i < starColors.length) ? Number (starColors [i]) : 0xFFFFFFFF;
						a = c32 / 0x1000000 * (1 - r); 
						c = c32 & 0xFFFFFF;
						p_oCamera.projectVertex (_v);
						if ((i < starSprites.length /* avoid array access */) && (starSprites [i] is IBitmapDrawable))
						{
							_vx.copy (_v); _vx.wx++; p_oCamera.projectVertex (_vx);
							_vy.copy (_v); _vy.wy++; p_oCamera.projectVertex (_vy);
							m_oMatrix.tx = _v.sx; m_oMatrix.a = (_vx.sx - _v.sx);
							m_oMatrix.ty = _v.sy; m_oMatrix.d = (_v.sy - _vy.sy);

							if (c != 0xFFFFFF)
							{
								rgb_r = (0xFF0000 & c) >> 16;
								rgb_g = (0x00FF00 & c) >> 8;
								rgb_b = (0x0000FF & c);
								bY = /* a * */ 1.7321 /*Math.sqrt (3)*/ / Math.sqrt (rgb_r * rgb_r + rgb_g * rgb_g + rgb_b * rgb_b);
								rgb_r *= bY; rgb_g *= bY; rgb_b *= bY;
							}
							else
							{
								rgb_r = rgb_g = rgb_b = 1;
							}

							m_oColorTransform.redMultiplier = rgb_r;
							m_oColorTransform.greenMultiplier = rgb_g;
							m_oColorTransform.blueMultiplier = rgb_b;

							// TODO think about support for fade-to-black along with fade-to-transparent?
							m_oColorTransform.alphaMultiplier = a / 255.0;

							var star:IBitmapDrawable = starSprites [i];
							m_sBlendMode = (star as DisplayObject == null) ? "normal" : DisplayObject(star).blendMode;
							m_oBitmapData.draw (star, m_oMatrix, m_oColorTransform, m_sBlendMode);
						}
						else
						{
							m_oBitmapData.setPixel32 (_v.sx, _v.sy, c + int (a) * 0x1000000);
						}
					}
				}
			}
			m_oEB.dispatchEvent (m_oEventAfter);
			if (m_oEventAfter.clear) 
				m_oBitmapData.fillRect (m_oBitmapData.rect, 0);
			m_oBitmapData.unlock();
		}

		/**
		 * Clearing is done in render() method.
		 */	
		public function clear():void
		{
			;
		}

		/**
		 * Provide the classical remove behaviour, plus remove the container to the display list.
		 */
		public override function remove():void
		{
			m_oBitmap.bitmapData.dispose ();
			if( m_oContainer.parent )
				m_oContainer.parent.removeChild( m_oContainer );
			super.remove();
		}

		/**
		 * @inheritDoc
		 */
		public override function destroy():void
		{
			remove (); 
			super.destroy ();
		}
		
		/**
		 * Displays the starfield.
		 *
		 * @param p_oScene The current scene
		 * @param p_oContainer	The container to draw on
		 */
		public function display( p_oContainer:Sprite = null  ):void
		{
			// viewport upper left?
			m_oContainer.x = 0;
			m_oContainer.y = 0;
		}
		
		private var m_nDepth:Number = 1e10;
		private var m_oContainer:Sprite;
		private var m_oBitmap:Bitmap;
		private var m_oBitmapData:BitmapData;
		private var m_oMatrix:Matrix = new Matrix ();
		private var m_oColorTransform:ColorTransform = new ColorTransform ();
		private var m_sBlendMode:String = "";
		private var _vx:Vertex, _vy:Vertex;
		private var m_oEventBefore:StarFieldRenderEvent;
		private var m_oEventAfter:StarFieldRenderEvent;

		private function makeEvents ():void
		{
			m_oEventBefore = new StarFieldRenderEvent (StarFieldRenderEvent.BEFORE_RENDER, this, m_oBitmapData, true);
			m_oEventAfter  = new StarFieldRenderEvent (StarFieldRenderEvent.AFTER_RENDER,  this, m_oBitmapData, false);
		}

		private function resetEvents ():void
		{
			// reset whatever could have been changed by listener
			m_oEventBefore.clear = true;
			m_oEventAfter.clear = false;
		}
	}
}