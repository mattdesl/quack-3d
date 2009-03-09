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

package sandy.core.scenegraph 
{
	/**
	 * Interface for node operations.
	 *
	 * <p>Implements the visitor design pattern: 
	 * Using the visitor design pattern, you can define a new operation on Node
	 * and its subclasses without having to change the classes and without having
	 * to take care of traversing the node tree.</p>
	 * 
	 * @example
	 * <listing version="3.0">
	 *     var mySpecialOperation:SpecialOperation = new SpecialOperation;
	 * 
	 *     mySpecialOperation.someParameter = 0.8;
	 *     someTreeNode.perform(mySpecialOperation);
	 *     trace(mySpecialOperation.someResult);
	 * 
	 *     mySpecialOperation.someParameter = 0.2;
	 *     someOtherTreeNode.perform(mySpecialOperation);
	 *     trace(mySpecialOperation.someResult);
	 * </listing>
	 * 
	 * @author		flexrails
	 * @version		3.0
	 * @date 		22.03.2008
	 **/
	public interface INodeOperation 
	{
		/**
		 * Operation to be performed on node entry
		 * 
		 * @param  p_oNode	The node the entry operation is to be performed on
		 */ 
		function performOnEntry(p_oNode:Node):void;

		/**
		 * Operation to be performed on node exit
		 * 
		 * @param  p_oNode	The node the exit operation is to be performed on
		 */ 
		function performOnExit(p_oNode:Node):void;
	}
}