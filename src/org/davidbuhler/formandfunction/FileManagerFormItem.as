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
package org.davidbuhler.formandfunction
{
	import org.davidbuhler.containers.BaseBox;
	import org.davidbuhler.formandfunction.common.ControlSizes;
	import org.davidbuhler.formandfunction.containers.BaseControlBar;
	import org.davidbuhler.formandfunction.controls.FileList;

	import flash.events.*;
	import flash.media.SoundChannel;
	import flash.net.*;

	import mx.collections.*;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.controls.*;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.IFlexDisplayObject;
	import mx.core.SoundAsset;
	import mx.events.*;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	import mx.managers.PopUpManager;
	import mx.styles.StyleManager;
	import mx.utils.UIDUtil;

	public class FileManagerFormItem extends BaseBox
	{
		public static const DELETE_FILE_EVENT:String="deleteFileEvent";

		public static const SAVE_EVENT_COMPLETE:String="saveEventComplete";

		public var useCursorManger:Boolean=true;

		private static const BROWSE_LABEL:String="Browse";

		private static const DELETE_LABEL:String="Delete";

		private static const FILE_ERROR:String="File Error";

		private static const REMOVE_LABEL:String="Remove";

		private static const UPLOAD_LABEL:String="Upload";

		private static const VIEW_FILE_LABEL:String="View";

		public function FileManagerFormItem()
		{
			this.percentWidth=100;
			this.height=formHeight;
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			this.savedFilesCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleSavedFilesChanged);
			this.cuedFilesCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, populateList);
			this.cuedFilesCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleCuedFilesChanged);
			this.fileReferenceList.addEventListener(Event.SELECT, selectHandler);
		}

		public var allowedFileTypes:FileFilter=new FileFilter("Images (*.jpg; *.jpeg)", "*.jpg; *.jpeg");

		public var contentType:String="multipart/form-data";

		[Bindable]
		public var cuedFilesCollection:ArrayCollection=new ArrayCollection();

		public var cuedFilesMax:int=5;

		public var formHeight:uint=150;

		public var maxFileSize:Number=3000000; //bytes


		public var previewFilePath:String='http://uploads/';

		[Bindable]
		public var savedFilesCollection:ArrayCollection=new ArrayCollection();

		public var savedFilesMax:int=20;

		public var uploadMethod:String='POST';

		public var uploadURL:String='/Upload.cfm';

		public var uploadsCompleteLabel:String='Upload Complete';

		private var browseButton:Button=new Button();

		private var commitButton:Button=new Button();

		private var cuedDataGrid:FileList=new FileList();

		private var cursorID:Number=0;

		private var dataGridColumn:DataGridColumn=new DataGridColumn();

		private var deleteButton:Button=new Button();

		private var fileReference:FileReference=new FileReference;

		private var fileReferenceList:FileReferenceList=new FileReferenceList;

		private var filesToFilter:Array=new Array(allowedFileTypes);

		private var flashUUID:String;

		private var isCursorActive:Boolean=false;

		private var padding:uint=5;

		private var persistedDataGrid:FileList=new FileList();

		private var previewImage:Image=new Image();

		private var progressBar:ProgressBar=new ProgressBar();

		private var removeFileButton:Button=new Button();

		private var soundAsset:SoundAsset=new SoundAsset();

		private var soundChannel:SoundChannel=new SoundChannel;

		//[Embed(source="/assets/audio/Ding.mp3")]
		private var soundClass:Class;

		private var titleWindow:TitleWindow;

		private var totalbytes:Number=0;

		private var variables:URLVariables;

		private var viewFileButton:Button=new Button();


		override protected function createChildren():void
		{
			commitButton.label=UPLOAD_LABEL;
			browseButton.label=BROWSE_LABEL;
			deleteButton.label=DELETE_LABEL;
			removeFileButton.label=REMOVE_LABEL;
			viewFileButton.label=VIEW_FILE_LABEL;
			commitButton.styleName='smallButton';
			browseButton.styleName='smallButton';
			deleteButton.styleName='smallButton';
			removeFileButton.styleName='smallButton';
			viewFileButton.styleName='smallButton';
			var vBox1:VBox=new VBox();
			var vBox2:VBox=new VBox();
			var hbox:BaseHBox=new BaseHBox();
			var controlBar1:BaseControlBar=new BaseControlBar();
			var controlBar2:BaseControlBar=new BaseControlBar();
			controlBar1.width=ControlSizes.MIN_WIDTH;
			controlBar2.width=ControlSizes.MIN_WIDTH;
			controlBar1.height=30;
			controlBar2.height=30;
			cuedDataGrid.width=ControlSizes.MIN_WIDTH;
			cuedDataGrid.rowCount=3;
			persistedDataGrid.rowCount=3;
			cuedDataGrid.height=100;
			persistedDataGrid.width=ControlSizes.MIN_WIDTH;
			persistedDataGrid.height=100;
			progressBar.width=ControlSizes.MIN_WIDTH;
			progressBar.height=10;
			controlBar1.addChild(browseButton);
			controlBar1.addChild(removeFileButton);
			controlBar1.addChild(commitButton);
			controlBar2.addChild(viewFileButton);
			controlBar2.addChild(deleteButton);
			vBox1.addChild(cuedDataGrid);
			vBox1.addChild(controlBar1);
			vBox1.addChild(progressBar);
			vBox2.addChild(persistedDataGrid);
			vBox2.addChild(controlBar2);
			hbox.percentWidth=100;
			hbox.percentHeight=100;
			hbox.addChild(vBox1);
			hbox.addChild(vBox2);
			this.browseButton.addEventListener(MouseEvent.CLICK, handleBrowseFiles);
			this.commitButton.addEventListener(MouseEvent.CLICK, handleCommitFilesClick);
			this.deleteButton.addEventListener(MouseEvent.CLICK, handleDeleteFile);
			this.removeFileButton.addEventListener(MouseEvent.CLICK, handleRemoveFile);
			this.viewFileButton.addEventListener(MouseEvent.CLICK, handleViewFile);
			this.addChild(hbox);
			this.handleSavedFilesChanged(null);
			this.handleCuedFilesChanged(null);
			super.createChildren();
			invalidateDisplayList();
		}


		protected function onCreationComplete(event:FlexEvent):void
		{
			resetUploadForm();
			persistedDataGrid.dataProvider=savedFilesCollection;
			cuedDataGrid.dataProvider=cuedFilesCollection;
		}


		private function cancelFileIO(event:Event):void
		{
			fileReference.cancel();
			setupCancelButton(false);
			checkCue();
			removeCursor();
		}


		private function checkCue():void
		{
			if (cuedFilesCollection.length > 0)
			{
				commitButton.enabled=true;
			}
			else
			{
				resetProgressBar();
				commitButton.enabled=false;
			}
		}


		private function checkFileSize(filesize:Number):Boolean
		{
			var isSizeOkay:Boolean=false;
			if ((filesize <= maxFileSize) || (maxFileSize == 0))
			{
				isSizeOkay=true;
			}
			return isSizeOkay;
		}


		private function collectionEventHandler(event:CollectionEvent):void
		{
			switch (event.kind)
			{
				case CollectionEventKind.ADD:
					break;
				case CollectionEventKind.REMOVE:
					break;
				case CollectionEventKind.REPLACE:
					break;
				case CollectionEventKind.UPDATE:
					break;
			}
		}


		private function completeHandler(event:Event):void
		{
			savedFilesCollection.addItemAt({'name': cuedFilesCollection.getItemAt(0).name, 'fileId': flashUUID}, 0);
			cuedFilesCollection.removeItemAt(0);
			if (cuedFilesCollection.length > 0 && savedFilesCollection.length < savedFilesMax)
			{
				totalbytes=0;
				handleCommitFiles(event);
			}
			else
			{
				setupCancelButton(false);
				progressBar.label=uploadsCompleteLabel;
				uploadFinished(event);
			}
		}


		private function createTitleWindow(src:String):IFlexDisplayObject
		{
			titleWindow=new TitleWindow();
			titleWindow.width=400;
			titleWindow.height=400;
			titleWindow.title="Viewer";
			var image:Image=new Image();
			image.maintainAspectRatio=true;
			image.source=src;
			titleWindow.addChild(image);
			return titleWindow;
		}


		private function handleBrowseFiles(event:Event):void
		{
			fileReferenceList.browse(filesToFilter);
		}


		private function handleCommitFiles(event:Event):void
		{
			var urlRequest:URLRequest=new URLRequest;
			urlRequest.url=uploadURL;
			urlRequest.method=uploadMethod;
			var params:URLVariables=new URLVariables();
			flashUUID=UIDUtil.createUID();
			params.fileId=flashUUID;
			urlRequest.data=params;
			urlRequest.contentType=contentType;
			fileReference=FileReference(cuedFilesCollection.getItemAt(0));
			fileReference.addEventListener(Event.OPEN, openHandler);
			fileReference.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			fileReference.addEventListener(Event.COMPLETE, completeHandler);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			fileReference.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			fileReference.upload(urlRequest);
			setupCancelButton(true);
		}


		private function handleCommitFilesClick(event:MouseEvent):void
		{
			this.showBusyCursor(null);
			this.handleCommitFiles(null);
		}


		private function handleCuedFilesChanged(event:CollectionEvent):void
		{
			var hasCuedFiled:Boolean=this.cuedFilesCollection.length > 0;
			removeFileButton.enabled=(hasCuedFiled) && (this.cuedDataGrid.selectedItem != null);
			removeFileButton.enabled=(hasCuedFiled) && (this.cuedDataGrid.selectedItem != null);
		}


		private function handleDeleteFile(event:MouseEvent):void
		{
			dispatchEvent(new Event(DELETE_FILE_EVENT));
		}


		private function handleRemoveFile(event:MouseEvent):void
		{
			if (cuedFilesCollection.length > 0)
			{
				cuedFilesCollection.removeItemAt(cuedDataGrid.selectedIndex);
			}
		}


		private function handleSavedFilesChanged(event:CollectionEvent):void
		{
			var hasSavedFiled:Boolean=this.savedFilesCollection.length > 0;
			commitButton.enabled=(hasSavedFiled) && (this.savedFilesCollection.length < savedFilesMax);
			deleteButton.enabled=(hasSavedFiled) && (this.persistedDataGrid.selectedItem != null);
			viewFileButton.enabled=hasSavedFiled;
		}


		private function handleViewFile(event:MouseEvent):void
		{
			var src:String=previewFilePath + savedFilesCollection.getItemAt(persistedDataGrid.selectedIndex).name;
			PopUpManager.addPopUp(createTitleWindow(src), this, true);
			PopUpManager.centerPopUp(titleWindow);
		}


		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			if (event.status != 200)
			{
				showError(event);
			}
		}


		private function ioErrorHandler(event:IOErrorEvent):void
		{
			showError(event);
		}


		private function openHandler(event:Event):void
		{
			handleCommitFiles(event);
		}


		private function populateList(event:CollectionEvent):void
		{
			setProgressBarByteCount();
			checkCue();
		}


		private function progressHandler(event:ProgressEvent):void
		{
			progressBar.setProgress(event.bytesLoaded, event.bytesTotal);
			progressBar.indeterminate;
			progressBar.label="Uploading " + Math.round(event.bytesLoaded / 1024) + " kb of " + Math.round(event.bytesTotal / 1024) + " kb " + (cuedFilesCollection.length - 1) + " files remaining";
		}


		private function removeCursor():void
		{
			if (!useCursorManger)
			{
				return;
			}
			isCursorActive=false;
			CursorManager.removeCursor(cursorID);
		}


		private function resetForm():void
		{
			cuedFilesCollection=new ArrayCollection();
		}


		private function resetProgressBar():void
		{
			progressBar.label="";
			progressBar.maximum=0;
			progressBar.minimum=0;
		}


		private function resetUploadForm():void
		{
			commitButton.enabled=false;
			commitButton.label=UPLOAD_LABEL;
			progressBar.maximum=0;
			totalbytes=0;
			progressBar.label="";
			browseButton.enabled=true;
			removeCursor();
		}


		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			showError(event);
		}


		private function selectHandler(event:Event):void
		{
			var i:int;
			var msg:String="";
			var dl:Array=[];
			if (savedFilesCollection.length >= savedFilesMax || cuedFilesCollection.length > cuedFilesMax)
			{
				Alert.show('You have exceeded the maximum number of uploads allowed.', 'Error');
			}
			else if (event.currentTarget.fileList.length > cuedFilesMax || cuedFilesCollection.length >= cuedFilesMax)
			{
				Alert.show('You cannot upload more than ' + cuedFilesMax + ' files at once.', 'Warning');
			}
			else
			{
				for (i=0; i < event.currentTarget.fileList.length; i++)
				{
					if (checkFileSize(event.currentTarget.fileList[i].size))
					{
						cuedFilesCollection.addItem(event.currentTarget.fileList[i]);
					}
					else
					{
						dl.push(event.currentTarget.fileList[i]);
					}
				}
				if (dl.length > 0)
				{
					for (i=0; i < dl.length; i++)
					{
						msg+=String(dl[i].name + " is too large. \n");
					}
					mx.controls.Alert.show(msg + "Max File Size is: " + Math.round(maxFileSize / 1024) + " kb", "File Too Large", 4, null).clipContent;
				}
			}
		}


		private function setProgressBarByteCount():void
		{
			var i:int;
			totalbytes=0;
			for (i=0; i < cuedFilesCollection.length; i++)
			{
				totalbytes+=cuedFilesCollection[i].size;
			}
			progressBar.label="Total Files: " + cuedFilesCollection.length + " Total Size: " + Math.round(totalbytes / 1024) + " kb"
		}


		private function setupCancelButton(value:Boolean):void
		{
			if (value == true)
			{
				commitButton.label="Cancel";
				commitButton.addEventListener(MouseEvent.CLICK, cancelFileIO);
			}
			else if (value == false)
			{
				commitButton.removeEventListener(MouseEvent.CLICK, cancelFileIO);
				resetUploadForm();
			}
		}


		private function showBusyCursor(event:Event):void
		{
			if (!useCursorManger || isCursorActive)
			{
				return;
			}
			isCursorActive=true;
			cursorID=CursorManager.setCursor(StyleManager.getStyleDeclaration("CursorManager").getStyle("busyCursor"), CursorManagerPriority.HIGH);
		}


		private function showError(event:Event):void
		{
			Alert.show("Your file upload could not be processed. Please try again later.", "ERROR", 0);
			removeCursor();
		}


		private function uploadFinished(event:Event):void
		{
			soundChannel=soundAsset.play();
			removeCursor();
			dispatchEvent(new Event(SAVE_EVENT_COMPLETE));
		}
	}
}

