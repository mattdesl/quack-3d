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
package sandy.primitive
{
	import sandy.core.scenegraph.Geometry3D;

	/**
	* An interface implemented by all 3D primitive classes.
	*
	* <p>This is to ensure that all primitives classes implements the necessary method(s)</p>
	*
	* @author		Thomas Pfeiffer - kiroukou
	* @version		3.0
	* @date 		10/05/2007
	*/
	public interface Primitive3D
	{
		/**
		* Generates the geometry for the primitive.
		*
		* @return The geometry object for the primitive.
		*
		* @see sandy.core.scenegraph.Geometry3D
		*/
		function generate(... arguments):Geometry3D;
	}
}