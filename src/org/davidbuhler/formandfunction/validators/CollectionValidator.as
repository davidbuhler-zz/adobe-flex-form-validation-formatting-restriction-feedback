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
package org.davidbuhler.formandfunction.validators
{
	import mx.controls.CheckBox;
	import mx.validators.NumberValidator;

	public class CollectionValidator extends NumberValidator
	{
		public function CollectionValidator():void
		{
			this.minValue=1;
			this.maxValue=2;
			this.lowerThanMinError='Additional selections are required';
			this.exceedsMaxError='Too many boxes are selected';
		}

		override protected function doValidation(value:Object):Array
		{
			var results:Array=super.doValidation(value);
			var val:String=value ? String(value) : "";
			if (results.length > 0 || ((val.length == 0) && !required))
			{
				return results;
			}
			else
			{
				for (var i:uint=0; i < value.length; i++)
				{
					var totalSelected:uint=0;
					if (CheckBox(value[i]).selected)
					{
						totalSelected++;
					}
				}
				return NumberValidator.validateNumber(this, totalSelected, null);
			}
		}
	}
}