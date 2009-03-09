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

package sandy.core.data
{
	/**
	 * The Quaternion class is experimental and not used in this version.
	 *
	 * <p>It is not used at the moment in the library, but should becomes very usefull soon.<br />
	 * It should be stable but any kind of comments/note about it will be appreciated.</p>
	 *
	 * <p>[<strong>ToDo</strong>: Check the use of and comment this class ]</p>
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		0.3
	 * @version		3.0
	 * @date 		24.08.2007
	 **/
	public class Quaternion
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var w:Number;

		/**
		 * Creates a quaternion.
		 *
		 * <p>[<strong>ToDo</strong>: What's all this here? ]</p>
		 */
		public function Quaternion( px : Number = 0, py : Number = 0, pz : Number = 0, pw:Number = 0 )
		{
			x = px;
			y = py;
			z = pz;
			w = pw;
		}

		/**
		 * Returns a string representing this quaternion.
		 *
		 * @return	The string representatation
		 */
		public function toString():String
		{
			var s:String = "sandy.core.data.Quaternion";
			s += "(x:"+x+" , y:"+y+", z:"+z+" w:"+w + ")";
			return s;
		}
	}
}