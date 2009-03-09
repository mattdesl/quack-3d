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
package sandy.util 
{
	import sandy.core.data.Point3D;
	import sandy.core.scenegraph.ATransformable;
	import sandy.util.NumberUtil;
       	
       	/**
	 * Utility class for tweening ATransformale rotaions.
	 *
	 * @author		makc
	 * @version		3.0.1
	 * @date 		12.03.2008
	 */
	public class RotationUtil 
	{
		/**
		 * Tweening variable (tween this from 0 to 1).
		 */
		public function get t():Number { return _t; }

		/**
		 * @private
		 */
		public function set t(v:Number):void
		{
			if ((obj != null) && (_axis != null))
			{
				// rotate
				if (_axis.getNorm () > NumberUtil.TOL)
				{
					obj.rotateAxis (_axis.x, _axis.y, _axis.z, (v - _t) * 180 * _ang / Math.PI);
				}
				else
					// it's either same or the opposite point (_dot is 1 or -1)
					if (_dot < 0)
					{
						obj.rotateAxis (obj.up.x, obj.up.y, obj.up.z, (v - _t) * 180);
					}
				// store v
				_t = v;

				if (enableRoll)
				{
					// do lookAt to reset roll (this will fail on poles)
					obj.lookAt (obj.out.x + obj.x, obj.out.y + obj.y, obj.out.z + obj.z);
					// roll
					obj.roll += (1 - _t) * roll0 + _t * roll1;
				}
			}
		}

		/**
		 * Initial "out" Point3D.
		 */
		public function get out0():Point3D { return _out0; }

		/**
		 * @private
		 */
		public function set out0(v:Point3D):void
		{
			_out0 = v; preCalculate ();
		}

		/**
		 * Final "out" Point3D.
		 */
		public function get out1():Point3D { return _out1; }

		/**
		 * @private
		 */
		public function set out1(v:Point3D):void
		{
			_out1 = v; preCalculate ();
		}

		/**
		 * ATransformable object to tween.
		 */
		public var obj:ATransformable;

		/**
		 * If enabled, rolls ATransformable while tweening.
		 */
		public var enableRoll:Boolean = false;

		/**
		 * Initial roll angle.
		 */
		public var roll0:Number;

		/**
		 * Final roll angle.
		 */
		public var roll1:Number;

		/**
		 * Resets object (useful to call after tweening).
		 */
		public function reset ():void
		{
			_t = 0;
			_out0 = null;
			_out1 = null;
			_dot = 0;
			_ang = 0;
			_axis = null;
		}

		// --
		private var _t:Number = 0;
		private var _out0:Point3D;
		private var _out1:Point3D;
		private var _dot:Number;
		private var _ang:Number;
		private var _axis:Point3D;

		private function preCalculate ():void
		{
			if ((_out0 != null) && (_out1 != null))
			{
				var _out0n:Point3D = _out0.clone (); _out0n.normalize ();
				var _out1n:Point3D = _out1.clone (); _out1n.normalize ();

				_dot = _out0n.dot (_out1n);
				_ang = Math.acos (_dot);

				_axis = _out0n.cross (_out1n);
			}
		}
	}
}