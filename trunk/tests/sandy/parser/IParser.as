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
package sandy.parser
{
	import flash.events.IEventDispatcher;

	import sandy.materials.Appearance;

	/**
	 * The IParser interface defines the interface that parser classes such as ColladaParser must implement.
	 *
	 * @author		Thomas Pfeiffer - kiroukou
	 * @since		1.0
	 * @version		3.0
	 * @date 		26.07.2007
	 */
	public interface IParser extends IEventDispatcher
	{
		/**
		 * This method starts the parsing process.
		 */
		function parse():void;

		/**
		 * Creates a transformable node in the object tree of the world.
		 *
		 * @param p_oAppearance	The default appearance that will be applied to the parsed object.
		 */
		function set standardAppearance( p_oAppearance:Appearance ):void;
	}
}