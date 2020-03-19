ClearResults()
ClearNotes()
//Calibration Variable
complexnumber UnitTiltX, UnitTiltY //DAC/(1/nm)
complexnumber UnitShiftX, UnitShiftY //DAC/nm
complexnumber UnitCompX, UnitCompY //DAC(1/nm)
//Control Variable
String Specimen, SavePath
number alpha, theta
number Nsteps, Binning
number scale
number CL, Exp
//GUI Component
Taggroup SpecimenNameBox,SavePathBox
Taggroup alphabox,thetabox,stepbox,binningbox,CLbox,ExpBox

class MainDialog:UIFrame
{	
	void SetParam( Object Self)
	{
		ClearResults()
		ClearNotes()
		
		//Get Control Parameters
		DLGGetValue(SpecimenNameBox, Specimen)
		DLGGetValue(SavePathBox, SavePath)
		DLGGetValue(alphabox,Alpha)
		DLGGetValue(thetabox,Theta)
		DLGGetValue(stepbox,Nsteps)
		DLGGetValue(binningbox,binning)
		DLGGetValue(CLbox,CL)
		DLGGetValue(ExpBox,Exp)
		
		//Summarize Session and Output
		Notes("\n===============Session Summary===============\n")
		Notes("Specimen Name: " + Specimen + "\n")
		Notes("Save Path: " + SavePath+ "\n")
		Notes("Alpha(degree): " + Alpha+ "\n")
		Notes("Theta(1/nm): " + Theta + "\n")
		Notes("Steps: " + Nsteps+ "\n")
		Notes("Binning: " + binning + "\n")
		Notes("Camera Length(cm): " + CL + "\n")
		Notes("Exposure Time(s): " + Exp + "\n")
		
		SaveNotesToFile(SavePath+"\\"+Specimen+"_Parameter.txt") 		
	}

	void Tcal(Object Self)//Problem, Software not responding to OK/Cancel
	{
		IF(!OkCancelDialog("Set TEM in DIFFRACTION Mode\n Set CCD in SEARCH Mode")) 
			exit(0)
			
		image img= GetFrontImage()
		imagedisplay imgDisp = img.ImageGetImageDisplay(0)	
		number height = img.ImageGetDimensionSize( 1 )
		number width  = img.ImageGetDimensionSize( 0 )
		number scale = img.ImageGetDimensionScale(0)
		string units = img.ImageGetDimensionUnitString(0)
		
		number DefTiltX0, DefTiltY0
		EMGetBeamTilt(DefTiltX0,DefTiltY0)
		result(DefTiltX0 + DefTiltY0)
		ROI ROI1 = NewROI()
		number top,left,bottom,right,diameter
		top=height*0.2
		left=width*0.2
		bottom=height*0.8
		right=width*0.8
		ROI1.ROISetRectangle(top, left, bottom, right) 
		ROI1.ROISetVolatile(0)
		ROI1.ROISetMoveable(0)
		imgDisp.ImageDisplayAddROI( ROI1 )
		number r_width = 0.6*width*scale
		number r_height = 0.6*height*scale
		
		if (!GetNumber("Plase Enter Disc diameter [pixels]", 0, diameter))
			exit(0)
		
		ROI ROI2=NewROI()
		number ROI2_top=top-diameter/2
		number ROI2_left=left-diameter/2
		number ROI2_bottom=top+diameter/2
		number ROI2_right=left+diameter/2
		ROI2.ROISetRectangle (ROI2_top, ROI2_left, ROI2_bottom, ROI2_right)
		ROI2.ROISetVolatile(0)
		ROI2.ROISetMoveable(0)
		ROI2.ROISetColor(0,0,1)

		String Label_ROI2="Locate a diffraction disk center on this box"
		ROI2.ROISetLabel(label_ROI2)
		imgDisp.ImageDisplayAddROI( ROI2 ) 
		
		
		number DefX_1, DefY_1
		if(!OKCancelDialog("Use a beam tilt knob to locate in the blue box.\nPress 'OK' when you are done."))
			exit(0)
		EMGetBeamTilt(DefX_1, DefY_1)
		OKDialog ("Click to continue")
		imgDisp.ImageDisplayDeleteROI(ROI2)
		
		
		//Beam box 2
		ROI2_top=top+diameter/2
		ROI2_left=right-diameter/2
		ROI2_bottom=top-diameter/2
		ROI2_right=right+diameter/2
		ROI2.ROISetRectangle (ROI2_top, ROI2_left, ROI2_bottom, ROI2_right)
		ROI2.ROISetVolatile(0)
		ROI2.ROISetMoveable(0)
		ROI2.ROISetColor(0,0,1)

		ROI2.ROISetLabel(label_ROI2)
		imgDisp.ImageDisplayAddROI( ROI2 ) 

		//Get deflector's current - 2
		number DefX_2, DefY_2
		if(!OKCancelDialog("Use a beam tilt knob to locate in the blue box.\nPress 'OK' when you are done."))
			exit(0)
		EMGetBeamTilt(DefX_2, DefY_2)
		OKDialog ("Click to continue")

		//Beam box 3
		ROI2_top=bottom+diameter/2
		ROI2_left=right-diameter/2
		ROI2_bottom=bottom-diameter/2
		ROI2_right=right+diameter/2
		ROI2.ROISetRectangle (ROI2_top, ROI2_left, ROI2_bottom, ROI2_right)
		ROI2.ROISetVolatile(0)
		ROI2.ROISetMoveable(0)
		ROI2.ROISetColor(0,0,1)

		ROI2.ROISetLabel(label_ROI2)
		imgDisp.ImageDisplayAddROI( ROI2 )
				
		//Get deflector's current - 3
		number DefX_3, DefY_3
		if(!OKCancelDialog("Use a beam tilt knob to locate in the blue box.\nPress 'OK' when you are done."))
			exit(0)
		EMGetBeamTilt(DefX_3, DefY_3)
		OKDialog ("Click to continue")
		imgDisp.ImageDisplayDeleteROI(ROI1)
		imgDisp.ImageDisplayDeleteROI(ROI2)
		
		//Calculate Tilt Deflector Current change along each direction
		UnitTiltX = complex(DefX_2-DefX_1,DefY_2-DefY_1)/r_width//DAC/(1/nm)
		UnitTiltY = complex(DefX_3-DefX_2,DefY_3-DefY_2)/r_height//DAC/(1/nm)
		
		Result("Unit Vector of Tilt along X: " + UnitTiltX + "\n")
		Result("Unit Vector of Tilt along Y: " + UnitTiltY + "\n")
		Result("Scale: "+ scale + "\n" )
		Result("Unit:" + units + "\n")
		
		Notes("\n===============Tilt Calibration Result===============\n")
		Notes("UnitTiltX: " + UnitTiltX + "\n")
		Notes("UnitTiltY: " + UnitTiltY + "\n")
		Notes("Scale: "+ scale + "\n" )
		Notes("Unit:" + units + "\n")
		EMSetBeamTilt(DefTiltX0,DefTiltY0)
		
	}
	
	void Scal(Object Self)
	{
		IF(!OkCancelDialog("Set TEM in IMAGING Mode\nSet CCD in SEARCH Mode")) 
			exit(0)
		
		image img:= GetFrontImage()
		imagedisplay imgDisp = img.ImageGetImageDisplay(0)	
		number height = img.ImageGetDimensionSize( 1 )
		number width  = img.ImageGetDimensionSize( 0 )
		number scale = img.ImageGetDimensionScale(0)
		string units = img.ImageGetDimensionUnitString(0)
		
		//Set Initial Beam Tilt
		number DefShiftX0, DefShiftY0
		EMGetBeamShift(DefShiftX0, DefShiftY0)
		
		//Set Calibration Region
		ROI ROI1 = NewROI()
		number top,left,bottom,right,diameter
		top=height*0.35
		left=width*0.35
		bottom=height*0.65
		right=width*0.65
		ROI1.ROISetRectangle(top, left, bottom, right) 
		ROI1.ROISetVolatile(0)
		ROI1.ROISetMoveable(0)
		imgDisp.ImageDisplayAddROI( ROI1 )
		number r_width = 0.3*width*scale
		number r_height = 0.3*height*scale
		
		//Set Beam Region
		ROI ROI2 = newROI()
		number ROI2_top = top+50
		number ROI2_left = left-50
		number ROI2_bottom = top-50
		number ROI2_right = left+50
		ROI2.ROISetRectangle(ROI2_top,ROI2_left,ROI2_bottom,ROI2_right)
		ROI2.ROISetVolatile(0)
		ROI2.ROISetMoveable(0)
		imgDisp.ImageDisplayAddROI( ROI2 )
		ROI2.ROISetColor(0,0,1)
		
		String Label_ROI2="Locate a beam center on this box"
		ROI2.ROISetLabel(label_ROI2)
		imgDisp.ImageDisplayAddROI( ROI2 )
		
		number DefX1,DefY1
		if(!OKCancelDialog("Use a beam shift knob to locate in the blue box.\nPress 'OK' when you are done."))
			exit(0)
		EMGetBeamShift(DefX1,DefY1)
		OKDialog ("Click to continue")
		imgDisp.ImageDisplayDeleteROI(ROI2)
		
		
		//Beam Box 2
		ROI2_top = top+50
		ROI2_left = right-50
		ROI2_bottom = top-50
		ROi2_right = right+50
		ROI2.ROISetRectangle(ROI2_top,ROI2_left,ROI2_bottom,ROI2_right)
		ROI2.ROISetVolatile(0)
		ROI2.ROISetMoveable(0)
		imgDisp.ImageDisplayAddROI( ROI2 )
		ROI2.ROISetColor(0,0,1)
		
		Label_ROI2="Locate a beam center on this box"
		ROI2.ROISetLabel(label_ROI2)
		imgDisp.ImageDisplayAddROI( ROI2 )
		
		number DefX2,DefY2
		if(!OKCancelDialog("Use a beam shift knob to locate in the blue box.\nPress 'OK' when you are done."))
			exit(0)
		EMGetBeamShift(DefX2,DefY2)
		OKDialog ("Click to continue")
		imgDisp.ImageDisplayDeleteROI(ROI2)
		
		//Beam Box 3
		ROI2_top = bottom+50
		ROI2_left = right-50
		ROI2_bottom = bottom-50
		ROI2_right = right+50
		ROI2.ROISetRectangle(ROI2_top,ROI2_left,ROI2_bottom,ROI2_right)
		ROI2.ROISetVolatile(0)
		ROI2.ROISetMoveable(0)
		imgDisp.ImageDisplayAddROI( ROI2 )
		ROI2.ROISetColor(0,0,1)
		
		Label_ROI2="Locate a beam center on this box"
		ROI2.ROISetLabel(label_ROI2)
		imgDisp.ImageDisplayAddROI( ROI2 )
		
		number DefX3,DefY3
		if(!OKCancelDialog("Use a beam shift knob to locate in the blue box.\nPress 'OK' when you are done."))
			exit(0)
		EMGetBeamShift(DefX3,DefY3)
		OKDialog ("Click to continue")
		imgDisp.ImageDisplayDeleteROI(ROI2)
		
		UnitShiftX = complex(DefX2-DefX1,DefY2-DefY1)/r_width
		UnitShiftY = complex(DefX3-DefX2,DefY3-DefY2)/r_height
		
		Result("Unit Vector of Shift along X: " + UnitShiftX + "\n")
		Result("Unit Vector of Tilt along Y: " + UnitShiftY + "\n")
		Result("Scale: "+ scale + "\n" )
		Result("Unit:" + units + "\n")
		
		Notes("\n===============Shift Calibration Result===============\n")
		Notes("UnitShiftX: " + UnitShiftX + "\n")
		Notes("UnitShiftY: " + UnitShiftY + "\n")
		Notes("Scale: "+ scale + "\n" )
		Notes("Unit:" + units + "\n")
		EMSetBeamShift(DefShiftX0, DefShiftY0)
	}
	
	/*
	void CCal(Object Self)
	{
		IF(!OkCancelDialog("Set TEM in IMAGING Mode\nSet CCD in SEARCH Mode")) 
			exit(0)
		
		image img:=getfrontimage()
		number scale = img.ImageGetDimensionScale(0)
		string units = img.ImageGetDimensionUnitString(0)
		
		object currentCam = CM_GetCurrentCamera()
		number ccdxsize, ccdysize
		CM_CCD_GetSize( CurrentCam, ccdxsize, ccdysize)
		image WorkImage:=realImage("Compensate Calibration",4,ccdxsize, ccdysize)
		WorkImage.showImage()
			
		number DefTiltX0, DefTiltY0
		EMGetBeamTilt(DefTiltX0,DefTiltY0)
		complexnumber DefTilt0 = complex(DefTiltX0,DefTiltY0)
		
		complexnumber DefTilt1 = DefTilt0 - UnitTiltX*5
		complexnumber DefTilt2 = DefTilt0 + UnitTiltX*5
		
		number Xmax1,Xmax2,Ymax1,Ymax2,DeltaX,DeltaY
		//Calibrate Compensation along X
		EMSetBeamTilt(Real(DefTilt1),Imaginary(DefTilt1))
		SSCGainNormalizedBinnedAcquireInPlace(WorkImage,0.5,1,0,0,ccdxsize,ccdysize)
		max(WorkImage,Xmax1,Ymax1)
		UpdateImage(WorkImage)

		EMSetBeamTilt(Real(DefTilt2),Imaginary(DefTilt2))
		SSCGainNormalizedBinnedAcquireInPlace(WorkImage,0.5,1,0,0,ccdxsize,ccdysize)
		max(WorkImage,Xmax2,Ymax2)
		UpdateImage(WorkImage)
		
		DeltaX = Xmax2-Xmax1
		DeltaY = Ymax2-Ymax1
		UnitCompX = -(DeltaX*UnitShiftX+DeltaY*UnitShiftY)*scale/10
		
		//Calibrate Compensation along Y
		EMSetBeamTilt(Real(DefTilt3),Imaginary(DefTilt3))
		SSCGainNormalizedBinnedAcquireInPlace(WorkImage,0.5,1,0,0,ccdxsize,ccdysize)
		max(WorkImage,Xmax1,Ymax1)
		UpdateImage(WorkImage)
		
		EMSetBeamTilt(Real(DefTilt4),Imaginary(DefTilt4))
		SSCGainNormalizedBinnedAcquireInPlace(WorkImage,0.5,1,0,0,ccdxsize,ccdysize)
		max(WorkImage,Xmax2,Ymax2)
		UpdateImage(WorkImage)
		
		DeltaX = Xmax2-Xmax1
		DeltaY = Ymax2-Ymax1
		UnitCompY = -(DeltaX*UnitShiftX+DeltaY*UnitShiftY)*scale/10
		
		Notes("\n===============Tilt vs. Shift Calibration Result===============\n")
		Notes("UnitCompX: " + UnitCompX + "\n")
		Notes("UnitCompY: " + UnitCompY + "\n")
		Notes("Scale: "+ scale + "\n" )
		Notes("Unit:" + units + "\n")
		EMSetBeamShift(DefTiltX0, DefTiltY0)
		DeleteImage(WorkImage)
		
	}
	*/
	void TiltTest(Object Self)
	{
		complexnumber DefTiltStart,DefTiltOrigin,CurrentDefTilt
		number DefTiltX0,DefTiltY0
		number alpha_rad = alpha/180*pi()
		object CurrentCam = CM_GetCurrentCamera()
		object AcParameters = CM_CreateAcquisitionParameters_FullCCD( CurrentCam, 3, 0.5, 1, 1 )
		number ccdxsize, ccdysize
		
		EMGetBeamTilt(DefTiltX0,DefTiltY0)
		DefTiltOrigin = complex(DefTiltX0,DefTiltY0)
		
		CM_CCD_GetSize( CurrentCam, ccdxsize, ccdysize)
		DefTiltStart = DefTiltOrigin+UnitTiltX*theta/2*cos(alpha_rad)+UnitTiltY*theta/2*sin(alpha_rad)
		
		image Img3D := realImage("Tilt Test", 4, ccdxsize, ccdysize,6)
		taggroup imgtaggroup = imagegettaggroup(img3D)
		image src := CM_AcquireImage( CurrentCam, AcParameters )
		taggroup srctaggroup = imagegettaggroup(src)
		
		ImageCopyCalibrationFrom(Img3D, src)
		taggroupcopytagsfrom(imgtaggroup,srctaggroup)
		Img3D.showImage()
		ImageDisplay imgDisp3D = Img3D.ImageGetImageDisplay(0)
		
		number N=5
		for(number count = 0;count<=5;count++)
		{
			CurrentDefTilt = DefTiltStart-UnitTiltX*count/5*theta*cos(alpha_rad)-UnitTiltY*count/5*theta*sin(alpha_rad)
			image WorkImage := slice2(Img3D,0,0,count,0,ccdxsize,1,1,ccdysize,1)
			EMSetBeamTilt(real(currentDefTilt),imaginary(currentDefTilt))
			WorkImage = CM_AcquireImage( CurrentCam, AcParameters)
			ImgDisp3D.ImageDisplaySetDisplayedLayers( count, count )
		}
		
		EMSetBeamTilt(DefTiltX0,DefTiltY0)
			
	}
	
	/*
	void CompTest(Object Self)
	{
		complexnumber DefTiltStart, DefTiltOrgin, CurrentDefTilt
		complexnumber DefShiftStart, DefShiftOrigin, CurrentDefShift
		number DefTiltX0,DefTiltY0,DefShiftX0,DefShiftY0
		EMGetBeamTilt(DefTiltX0,DefTiltY0)
		EMGetBeamShift(DefShiftX0,DefShiftY0)
		DefTiltOrigin = complex(DefTiltX0,DefTiltY0)
		DefShiftOrigin = complex(DefShiftX0,DefShiftY0)
		
		number alpha_rad = alpha/180*pi()
		object CurrentCam = CM_GetCurrentCamera()
		object AcParameters = CM_CreateAcquisitionParameters_FullCCD( CurrentCam, 3, Exp, binning, binning )
		number ccdxsize, ccdysize
		
		CM_CCD_GetSize( CurrentCam, ccdxsize, ccdysize)
		DefTiltStart = DefTiltOrigin+UnitTiltX*theta/2*cos(alpha_rad)+UnitTiltY*theta/2*sin(alpha_rad)
		DefShiftStart = DefShiftOrigin+UnitCompX*theta/2*cos(alpha_rad)+UnitCompY*theta/2*sin(alpha_rad)
		
		image Img3D := realImage("Compensation Test", 4, ccdxsize, ccdysize,6)
		taggroup imgtaggroup = imagegettaggroup(img3D)
		image src := CM_AcquireImage( CurrentCam, AcParameters )
		taggroup srctaggroup = imagegettaggroup(src)
		
		ImageCopyCalibrationFrom(Img3D, src)
		taggroupcopytagsfrom(imgtaggroup,srctaggroup)
		ImageDisplay imgDisp3D = Img3D.ImageGetImageDisplay(0)
		
		number N=5
		for(number count=0;count<=5;count++)
		{
			currentDefTilt = DefTiltStart-UnitTiltX*i/5*theta*cos(alpha_rad)-UnitTiltY*i/5*theta*sin(alpha_rad)
			currentDefShift = DefShiftStart-UnitTiltX*i/5*theta*cos(alpha_rad)-UnitCompY*i/5*theta*sin(alpha_rad)
			image WorkImage := slice2(Img3D,0,0,count,0,ccdxisize,1,1,ccdysize,1)
			EMSetBeamTilt(real(CurrentDefTilt),imaginary(CurrentDefTilt))
			EMSetBeamShift(real(CurrentDefShift),imaginary(CurrentDefTilt))
			WorkImage = CM_AcquireImage( CurrentCam, AcParameters)
			ImgDisp3D.ImageDisplaySetDisplayedLayers( count, count )
		}
		EMSetBeamTilt(DefTiltX0,DefTiltY0)
		EMSetBeamShift(DefShiftX0,DefShiftY0)
	}
	*/
	void StartFunc(Object Self)
	{
		complexnumber DefTiltStart,DefTiltOrigin,CurrentDefTilt
		complexnumber DefShift0
		number DefTiltX0,DefTiltY0,DefShiftX0,DefShiftY0
		number alpha_rad = alpha/180*pi()
		object CurrentCam = CM_GetCurrentCamera()
		object AcParameters = CM_CreateAcquisitionParameters_FullCCD( CurrentCam, 3, Exp, binning, binning )
		number ccdxsize, ccdysize
		
		EMGetBeamTilt(DefTiltX0,DefTiltY0)
		EMGetBeamShift(DefShiftX0,DefshiftY0)
		DefTiltOrigin = complex(DefTiltX0,DefTiltY0)
		DefShift0=complex(DefShiftX0,DefShiftY0)
		CM_CCD_GetSize( CurrentCam, ccdxsize, ccdysize)
		DefTiltStart = DefTiltOrigin+UnitTiltX*theta/2*cos(alpha_rad)+UnitTiltY*theta/2*sin(alpha_rad)
		
		image Img3D := realImage(Specimen, 4, ccdxsize/binning, ccdysize/binning,Nsteps+1)
		taggroup imgtaggroup = imagegettaggroup(img3D)
		img3D.showimage()
		image src := CM_AcquireImage( CurrentCam, AcParameters )
		taggroup srctaggroup = imagegettaggroup(src)
		
		ImageCopyCalibrationFrom(Img3D, src)
		taggroupcopytagsfrom(imgtaggroup,srctaggroup)
		ImageDisplay imgDisp3D = Img3D.ImageGetImageDisplay(0)
		
		for(number count = 0;count<=Nsteps;count++)
		{
			currentDefTilt = DefTiltStart-UnitTiltX*count/Nsteps*theta*cos(alpha_rad)-UnitTiltY*count/Nsteps*theta*sin(alpha_rad)
			//Add Compensate
			
			image WorkImage := slice2(Img3D,0,0,count,0,ccdxsize/binning,1,1,ccdysize/binning,1)
			EMSetBeamTilt(real(currentDefTilt),imaginary(currentDefTilt))
			EMSetBeamShift(DefShiftX0,DefshiftY0)
			WorkImage = CM_AcquireImage( CurrentCam, AcParameters)
			ImgDisp3D.ImageDisplaySetDisplayedLayers( count, count )
		}
		
		EMSetBeamTilt(DefTiltX0,DefTiltY0)
		EMSetBeamShift(DefShiftX0,DefshiftY0)
	}
	
	Taggroup CreateControlBox( object self )
	{
		Taggroup ControlBox_items
		Taggroup ControlBox = DlGCreateBox("Control",ControlBox_items).DLGExternalPadding(15,0)
		
		Taggroup label
		label = DLGCreateLabel("Specimen")
		SpecimenNameBox = DLGCreateStringField(Specimen,50).DLGIdentifier("SpecimenNameBox")
		Taggroup SpecimenGroup = DLGGroupItems(label, SpecimenNameBox).DLGTableLayout(2,1,0)
		ControlBox_items.dlgaddelement(SpecimenGroup)
		
		Taggroup label1, label2
		label1 = DLGCreateLabel("Alpha(Degree)")
		label2 = DLGCreateLabel("Theta(1/nm)")
		alphabox = DLGCreateRealField(alpha, 10, 4).DLGIdentifier("alphabox")
		thetabox = DLGCreateRealField(theta, 10, 4).DLGIdentifier("thetabox")
		Taggroup ControlGroup1 = DLGGroupItems(label1,alphabox,label2,thetabox).DLGTableLayout(4,1,0)
		ControlBox_items.dlgaddelement(ControlGroup1)
		
		
		label1 = DLGCreateLabel("Steps")
		label2 = DLGCreateLabel("Binning")
		stepbox = DLGCreateRealField(Nsteps, 10, 4).DLGIdentifier("stepbox")
		binningbox = DLGCreateRealField(Binning, 10, 4).DLGIdentifier("binningbox")
		Taggroup ControlGroup2 = DLGGroupItems(label1,stepbox,label2,binningbox)
		ControlBox_items.dlgaddelement(ControlGroup2).DLGTableLayout(4,1,0)
		
		
		label1 = DLGCreateLabel("Camera Length(cm)")
		label2 = DLGCreateLabel("Exposure Time(s)")
		CLbox = DLGCreateRealField(CL,10,4).DLGIdentifier("CLbox")
		Expbox = DLGCreateRealField(Exp, 10, 4).DLGIdentifier("Expbox")
		Taggroup CameraGroup = DLGGroupItems(label1,CLbox,label2,Expbox)
		ControlBox_items.DLGAddElement(CameraGroup).DLGTableLayout(4,1,0)
		
		label = DLGCreateLabel("Save Path")
		SavePathBox = DLGCreateStringField(SavePath,50).DLGIdentifier("SavePathBox")
		Taggroup PathGroup = DLGGroupItems(label, SavePathBox).DLGTableLayout(2,1,0)
		ControlBox_items.dlgaddelement(PathGroup)
		
		Taggroup SetButton
		SetButton = DLGCreatePushButton("Set Control Parameter","SetParam")
		ControlBox_items.dlgaddelement(SetButton)
		
		Taggroup TiltTestButton,CompensateTestButton
		TiltTestButton = DLGCreatePushButton("Test Calibrated Tilt","TiltTest")
		CompensateTestButton = DLGCreatePushButton("Test Calibrated Compensate","CompTest")
		Taggroup ButtonGroup2 = DLGGroupItems(TiltTestButton,CompensateTestButton).DLGTableLayout(3,1,0)
		ControlBox_items.dlgaddelement(ButtonGroup2)
		
		Taggroup startButton
		StartButton = DLGCreatePushButton("Start Session","StartFunc")
		ControlBox_items.dlgaddelement(StartButton)
		
		
		return ControlBox
	}
	
	Taggroup CreateCalBox( object self )
	{
		Taggroup CalBox_items
		Taggroup CalBox = DlGCreateBox("Calibration",CalBox_items).DLGExternalPadding(15,0)
		
		Taggroup TCalButton, SCalButton, CompCalButton
		TCalButton = DLGCreatePushbutton("Calibrate Beam Tilt","TCal")
		SCalButton = DLGCreatePushbutton("Calibrate Beam Shift","SCal")
		CompCalButton = DLGCreatePushbutton("Calibrate Beam Tilt vs. Beam Shift","CCal")
		
		CalBox_items.DLGAddElement(TCalButton)
		CalBox_items.DLGAddElement(SCalButton)
		CalBox_items.DLGAddElement(CompCalButton)
		return CalBox
	}
	
	Taggroup CreateUI( object self )
	{
	
		TagGroup position;
		position = DLGBuildPositionFromApplication()
		position.TagGroupSetTagAsTagGroup( "Width", DLGBuildAutoSize() )
		position.TagGroupSetTagAsTagGroup( "Height", DLGBuildAutoSize() )
		position.TagGroupSetTagAsTagGroup( "X", DLGBuildRelativePosition( "Inside", 1) )
		position.TagGroupSetTagAsTagGroup( "Y", DLGBuildRelativePosition( "Inside", -1.0 ) )
		
		
		Taggroup MainDialog = DLGCreateDialog(" ").dlgposition(position)
		Taggroup ControlBox = self.CreateControlBox()
		Taggroup CalBox = self.CreateCalBox()
		MainDialog.dlgaddelement(ControlBox).DLGAnchor("West")
		MainDialog.dlgaddelement(CalBox).DLGAnchor("East")
		MainDialog.DLGTableLayout(2,1,0)
		return MainDialog
	}
	
	MainDialog( object self )
	{
		self.init( self.CreateUI() )
	}
	
	~MainDialog( object self )
	{
	}


}

void main()
{
		// Create the dialog
		
		object MainDialog = Alloc(MainDialog)
		MainDialog.Display("DLACBED_Test")
		
		Return
		
}

main()