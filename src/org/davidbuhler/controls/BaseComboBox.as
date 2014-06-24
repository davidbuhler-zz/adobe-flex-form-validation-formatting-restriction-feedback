/*
 * #%L
 * GwtBootstrap3
 * %%
 * Copyright (C) 2013 FormFunction
 * %%
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * #L%
 */
package org.davidbuhler.controls
{
	import mx.controls.ComboBox;
	import mx.rpc.Fault;

	public class BaseComboBox extends ComboBox
	{

		public function BaseComboBox()
		{
			super();
			this.labelField='@label';
		}
		private var _dataType:*;
		private var _lastDataType:*;
		private var _lastObject:*;
		private var _lastSelectedValue:*;
		private var _selectedValue:*;

		public function get dataType():*
		{
			return _dataType;
		}

		public function set dataType(dataType:*):void
		{
			_dataType=dataType;
			invalidateProperties();
		}

		public function set populate(dp:Object):void
		{
			this.dataProvider=dp;
		}

		public function get selectedValue():*
		{
			return _selectedValue;
		}

		public function set selectedValue(selectedValue:*):void
		{
			if (!_dataType)
			{
				throw new Fault("Error", "dataType property is required");
			}
			_selectedValue=selectedValue;
			invalidateProperties();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			var lDataType:*=this.dataType;
			var lSelectedValue:*=this.selectedValue;
			this.selectedIndex=-1;
			if (!lSelectedValue || !lDataType)
			{
				return;
			}
			if (!hasDataChanged(this.dataProvider, lSelectedValue, lDataType))
			{
				return;
			}
			for (var i:int=0; i < this.dataProvider.length; i++)
			{
				//in case there is an empty null element in the dataProvider
				if (this.dataProvider[i] != null)
				{
					var item:*=this.dataProvider[i][lDataType];
					if (item == lSelectedValue)
					{
						this.selectedIndex=i;
						break;
					}
				}
			}
		}

		private function hasDataChanged(pDataProvider:Object, pSelectdValue:*, pDataType:*):Boolean
		{
			if ((pDataProvider == lastObject) && (lastSelectedValue == pSelectdValue) && (lastDataType == pDataType))
			{
				return false;
			}
			this.lastDataType=pDataType;
			this.lastSelectedValue=pSelectdValue;
			this.lastObject=pDataProvider;
			return true;
		}

		private function get lastDataType():*
		{
			return _lastDataType;
		}

		private function set lastDataType(value:*):void
		{
			this._lastDataType=value;
		}

		private function get lastObject():*
		{
			return _lastObject;
		}

		private function set lastObject(value:*):void
		{
			this._lastObject=value;
		}

		private function get lastSelectedValue():*
		{
			return _lastSelectedValue;
		}

		private function set lastSelectedValue(value:*):void
		{
			this._lastSelectedValue=value;
		}
	}
}

