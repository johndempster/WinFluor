unit AndorUnit;
// -----------------------------------------------
// Andor cameras
// -----------------------------------------------
// 19-10-04 Started
// 27-6-05 SetBaselineClamp added. Fixes initial baseline drift problem (Mill Hill)
// 20-7-05 Internal frame interval timing now accurate (takes into account frame transfer time)
// 04-9-06 Exposure time now automaticallty corrected for frame transfer time when using internal timing

interface

uses WinTypes,sysutils, classes, dialogs, mmsystem, messages, controls, math ;

const
    AndorCameraWorkingTemperature = -70 ;

type

TAndorSession = record
     NumBytesPerFrame : Integer ;     // No. of bytes in image
     NumPixelsPerFrame : Integer ;    // No. of pixels in image
     NumFrames : Integer ;            // No. of images in circular transfer buffer
     FrameNum : Integer ;             // Current frame no.
     PFrameBuffer : Pointer ;         // Frame buffer pointer
     ImageBufferSize : Integer ;           // No. images in Andor image buffer
     PImageBuffer : PIntegerArray ;        // Local Andor image buffer
     NumFramesAcquired : Integer ;
     NumFramesCopied : Integer ;
     GetImageInUse : Boolean ;       // GetImage procedure running
     CapturingImages : Boolean ;     // Image capture in progress
     CameraOpen : Boolean ;          // Camera open for use
     TimeStart : single ;
     Temperature : Integer ;
     WorkingTemperature : Integer ;
     FrameTransferTime : Single ;    // Frame transfer time (s)
     end ;

PAndorSession = ^TAndorSession ;

TAndorCapabilities = record
	Size : Cardinal ;
	AcqModes : Cardinal ;
	ReadModes : Cardinal ;
	TriggerModes : Cardinal ;
	CameraType : Cardinal ;
  PixelMode : Cardinal ;
  SetFunctions : Cardinal ;
  GetFunctions : Cardinal ;
  Features : Cardinal ;
  end ;

TSetADChannel = function(
                Channel : Integer
                 ) : Integer ; stdcall ;

TSetExposureTime = function(
                   time : Single
                   ) : Integer ; stdcall ;

TSetNumberAccumulations = function(
                          number : Integer
                          ) : Integer ; stdcall ;

TSetAccumulationCycleTime = function(
                            time  : Single
                            ) : Integer ; stdcall ;

TSetNumberKinetics = function(
                     number : Integer
                     ) : Integer ; stdcall ;

TSetKineticCycleTime = function(
                       time : Single
                       ) : Integer ; stdcall ;

TSetAcquisitionMode = function(
                      mode : Integer
                      ) : Integer ; stdcall ;

TSetHorizontalSpeed = function(
                      index : Integer
                      ) : Integer ; stdcall ;

TSetVerticalSpeed = function(
                    index : Integer
                    ) : Integer ; stdcall ;

TSetReadMode = function(
               mode : Integer
               ) : Integer ; stdcall ;

TSetSingleTrack = function(
                  centre : Integer ;
                  height : Integer
                  ) : Integer ; stdcall ;

TSetFullImage = function(
                hbin : Integer ;
                vbin : Integer
                ): Integer ; stdcall ;

TGetAcquisitionTimings = function(
                         var exposure : Single ;
                         var accumulate : Single ;
                         var kinetic : Single
                         ) : Integer ; stdcall ;

TStartAcquisition = function : Integer ; stdcall ;

TAbortAcquisition = function : Integer ; stdcall ;

TGetAcquiredData = function(
                   var Buffer : Array of Integer ;
                   Size : Cardinal
                   ) : Integer ; stdcall ;

TGetStatus = function(
             var status : Integer
             ) : Integer ; stdcall ;

TSetTriggerMode = function(
                  mode : Integer
                  ) : Integer ; stdcall ;

TInitialize = function(
              Dir : PChar
              ) : SmallInt ; stdcall ;	 //	read ini file to get head and card

TShutDown = function : Integer ; stdcall ;

TSetTemperature = function(
                  temperature: Integer
                  ) : Integer ; stdcall ;

TGetTemperature = function(
                  var temperature : Integer
                  ) : Integer ; stdcall ;

TGetTemperatureRange = function(
                       var mintemp : Integer ;
                       var maxtemp : Integer
                       ) : Integer ; stdcall ;

TCoolerON = function : Integer ; stdcall ;

TCoolerOFF = function : Integer ; stdcall ;

TSetShutter = function(
              ShutterType : Integer ;
              mode : Integer ;
              closingtime : Integer ;
              openingtime : Integer
              ) : Integer ; stdcall ;

TGetNumberHorizontalSpeeds = function(
                             var number : Integer
                             ) : Integer ; stdcall ;

TGetHorizontalSpeed = function(
                      index : Integer ;
                      var speed : Integer
                      ) : Integer ; stdcall ;

TGetNumberVerticalSpeeds = function(
                           var number : Integer
                           ) : Integer ; stdcall ;

TGetVerticalSpeed = function(
                    index : Integer ;
                    var speed : Integer
                    ) : Integer ; stdcall ;



TGetDetector = function(
               var xpixels : Integer ;
               var ypixels : Integer
               ) : Integer ; stdcall ;

TGetSoftwareVersion = function(
                      var eprom : Cardinal ;
                      var coffile : Cardinal ;
                      var vxdrev : Cardinal ;
                      var vxdver : Cardinal ;
                      var dllrev : Cardinal ;
                      var dllver : Cardinal
                      ) : Integer ; stdcall ;

TGetHardwareVersion = function(
                      var PCB : Cardinal ;
                      var Decode : Cardinal ;
                      var SerPar : Cardinal ;
                      var Clocks : Cardinal ;
                      var dummy1 : Cardinal ;
                      var dummy2 : Cardinal
                      ) : Integer ; stdcall ;

TSetImage = function(
            hbin : Integer ;
            vbin : Integer ;
            hstart : Integer ;
            hend : Integer ;
            vstart : Integer ;
            vend  : Integer
            ) : Integer ; stdcall ;

TSetFastKinetics = function(
                   exposedRows : Integer ;
                   seriesLength : Integer ;
                   Time : Single ;
                   mode : Integer ;
                   hbin : Integer ;
                   vbin  : Integer
                   ) : Integer ; stdcall ;

TSetFrameTransferMode = function(
                        Mode : Integer
                        ) : Integer ; stdcall ;

TGetFKExposureTime = function(
                     var time  : Single
                     ) : Integer ; stdcall ;

TGetNumberFKVShiftSpeeds = function(
                           number : Integer ) : Integer ; stdcall ;

TSetFKVShiftSpeed = function(
                    index  : Integer
                    ) : Integer ; stdcall ;

TGetFKVShiftSpeed = function(
                    index  : Integer ;
                    var speed   : Integer
                    ) : Integer ; stdcall ;

TGetSpoolProgress = function(
                    var index  : Integer
                    ) : Integer ; stdcall ;

TGetSizeOfCircularBuffer = function(
                            var index  : Integer
                           ) : Integer ; stdcall ;

TGetMostRecentImage = function(
                      Buf : PIntegerArray ;
                      Size : Cardinal
                      ) : Integer ; stdcall ;

TGetOldestImage = function(
                  Buf : PIntegerArray ;
                  Size : Cardinal
                  ) : Integer ; stdcall ;

TGetNumberNewImages = function(
                      var First : Integer ;
                      var Last : Integer
                      ) : Integer ; stdcall ;

TGetImages = function(
             First : Integer ;
             Last : Integer ;
             Buf : PIntegerArray ;
             Size : Cardinal ;
             var ValidFirst : Integer ;
             var ValidLast : Integer
              ) : Integer ; stdcall ;

TGetTotalNumberImagesAcquired = function(
                                var index : Integer
                                 ) : Integer ; stdcall ;

TSetComplexImage = function(
                   numAreas : Integer ;
                   var areas : Integer
                   ) : Integer ; stdcall ;

TSetRandomTracks = function(
                   numTracks : Integer ;
                   var areas : Integer
                   ) : Integer ; stdcall ;

TSetDriverEvent = function(
                  event : THandle
                  ) : Integer ; stdcall ;

TSetGain = function(
           gain : Integer
           ) : Integer ; stdcall ;

TSetSingleTrackHBin = function(
                      bin : Integer
                      ) : Integer ; stdcall ;

TSetMultiTrackHBin = function(
                     bin : Integer
                     ) : Integer ; stdcall ;

TSetFVBHBin = function(
              bin : Integer
              ) : Integer ; stdcall ;

TSetCustomTrackHBin = function(
                      bin : Integer
                      ) : Integer ; stdcall ;

TGetNewData = function(
              var Buffer : Array of Cardinal ;
              Size : Cardinal
              ) : Integer ; stdcall ;

TSetEMCCDGain = function(
                Gain : Integer
                ) : Integer ; stdcall ;

TSaveAsBmp = function(
             Path : PChar ;
             palette : PChar ;
             ymin : Integer ;
             ymax : Integer
             ) : Integer ; stdcall ;

TSetSpool = function(
            Active : Integer ;
            Method : Integer ;
            Path : PChar ;
            Framebuffersize : Integer
            ) : Integer ; stdcall ;

TSetFastExtTrigger = function(
                     Mode : Integer
                     ) : Integer ; stdcall ;

TGetAcquisitionProgress = function(
                          var acc : Integer ;
                          var series : Integer
                          ) : Integer ; stdcall ;

TGetNumberHSSpeeds = function(
                     channel : Integer ;
                     itype : Integer ;
                     var NumSpeeds : Integer
                     ) : Integer ; stdcall ;

TGetHSSpeed = function(
              channel : Integer ;
              itype : Integer ;
              index : Integer ;
              var Speed : Single
              ) : Integer ; stdcall ;

TSetHSSpeed = function(
              Channel : Integer ;
              itype : Integer
              ) : Integer ; stdcall ;

TGetNumberVSSpeeds = function(
                     var NumSpeeds : Integer
                     ) : Integer ; stdcall ;

TGetVSSpeed = function(
              Index : Integer ;
              var Speed : Single
              ) : Integer ; stdcall ;

TGetFastestRecommendedVSSpeed = function(
              var Index : Integer ;
              var Speed : Single
              ) : Integer ; stdcall ;


TSetVSSpeed = function(
              Index : Integer
              ) : Integer ; stdcall ;

TSetVSAmplitude = function(
                  Index : Integer
                  ) : Integer ; stdcall ;

TGetNumberAmp = function(
                Amp : Integer
                ) : Integer ; stdcall ;

TGetAmpMaxSpeed = function(
                  Index : Integer ;
                  var Speed : Single
                  ) : Integer ; stdcall ;

TGetAmpDesc = function(
              Index : Integer ;
              Name : PChar ;
              Len : Integer
              ) : Integer ; stdcall ;

TSetVerticalRowBuffer = function(
                        Rows : Integer
                        ) : Integer ; stdcall ;

TGetRegisterDump = function(
                   var Mode : Integer
                   ) : Integer ; stdcall ;

TSetRegisterDump = function(
                   Mode : Integer
                   ) : Integer ; stdcall ;

TGetCameraSerialNumber = function(
                         var Number : SmallInt
                         ) : Integer ; stdcall ;

TGetPixelSize = function(
                var xSize : Single ;
                var ySize : Single
                ) : Integer ; stdcall ;

TGetBitDepth = function(
                Channel : Integer ;
                var Depth : Integer
                ) : Integer ; stdcall ;

TGetHeadModel = function(
                Name : PChar
                ) : SmallInt ; stdcall ;

TGetNewData16 = function(
                Buf : PWordArray ;
                Size : Cardinal
                ) : Integer ; stdcall ;

TGetAcquiredData16 = function(
                     Buf : PWordArray ;
                     Size : Cardinal
                     ) : Integer ; stdcall ;

TGetCapabilities = function(
                   var caps : TAndorCapabilities
                   ) : Integer ; stdcall ;

TSetMessageWindow = function(
                    wnd : THandle
                    ) : Integer ; stdcall ;

TSelectDevice = function(
                DevNum : Integer
                ) : Integer ; stdcall ;
TGetNumberDevices = function(
                    NumDevs : Integer
                    ) : Integer ; stdcall ;

TGetID = function(
         DevNum : Integer ;
         var ID : Integer
         ) : Integer ; stdcall ;

TSetPixelMode = function(
                Bitdepth : Integer ;
                Colormode : Integer
                ) : Integer ; stdcall ;

TIdAndorDll = function() : Integer ; stdcall ;

TSetBaselineClamp = function(
                    Active : Integer
                     ) : Integer ; stdcall ;

function Andor_GetDLLAddress(
         Handle : Integer ;
         const ProcName : string ) : Pointer ;

procedure Andor_LoadLibrary  ;

function Andor_OpenCamera(
          var Session : TAndorSession ;   // Camera session record
          var FrameWidthMax : Integer ;      // Returns camera frame width
          var FrameHeightMax : Integer ;     // Returns camera frame width
          var NumBytesPerPixel : Integer ;   // Returns bytes/pixel
          var PixelDepth : Integer ;         // Returns no. bits/pixel
          var PixelWidth : Single ;          // Returns pixel size (um)
          CameraInfo : TStringList         // Returns Camera details
          ) : Boolean ;

procedure Andor_CloseCamera(
          var Session : TAndorSession // Session record
          ) ;

procedure Andor_GetCameraGainList(
          CameraGainList : TStringList
          ) ;

procedure Andor_GetCameraReadoutSpeedList(
          CameraReadoutSpeedList : TStringList
          ) ;

function Andor_StartCapture(
         var Session : TAndorSession ;   // Camera session record
         var InterFrameTimeInterval : Double ;      // Frame exposure time
         AmpGain : Integer ;              // Camera amplifier gain index
         ReadoutSpeed : Integer ;         // Camera Read speed index number
         ExternalTrigger : Integer ;      // Trigger mode
         FrameLeft : Integer ;            // Left pixel in CCD readout area
         FrameTop : Integer ;             // Top pixel in CCD eadout area
         FrameWidth : Integer ;           // Width of CCD readout area
         FrameHeight : Integer ;          // Width of CCD readout area
         BinFactor : Integer ;             // Binning factor (1,2,4,8,16)
         PFrameBuffer : Pointer ;         // Pointer to start of ring buffer
         NumFramesInBuffer : Integer ;    // No. of frames in ring buffer
         NumBytesPerFrame : Integer       // No. of bytes/frame
         ) : Boolean ;

function Andor_CheckFrameInterval(
          var Session : TAndorSession ;   // Camera session record
          FrameLeft : Integer ;   // Left edge of capture region (In)
          FrameRight : Integer ;  // Right edge of capture region( In)
          FrameTop : Integer ;    // Top edge of capture region( In)
          FrameBottom : Integer ; // Bottom edge of capture region (In)
          BinFactor : Integer ;   // Pixel binning factor (In)
          Var FrameInterval : Double ;
          Var ReadoutTime : Double) : Boolean ;


procedure Andor_Wait( Delay : Single ) ;

procedure Andor_GetImage(
          var Session : TAndorSession  // Camera session record
          ) ;

procedure Andor_StopCapture(
          var Session : TandorSession   // Camera session record
          ) ;

procedure Andor_CheckError(
          FuncName : String ;   // Name of function called
          ErrNum : Integer      // Error # returned by function
          ) ;

implementation

uses SESCam ;

const


        DRV_ERROR_CODES = 20001;
        DRV_SUCCESS = 	20002 ;
        DRV_VXDNOTINSTALLED = 20003;
        DRV_ERROR_SCAN = 20004;
        DRV_ERROR_CHECK_SUM = 20005 ;
        DRV_ERROR_FILELOAD = 20006;
        DRV_UNKNOWN_FUNCTION = 20007 ;
        DRV_ERROR_VXD_INIT = 20008 ;
        DRV_ERROR_ADDRESS	= 20009 ;
        DRV_ERROR_PAGELOCK = 20010 ;
        DRV_ERROR_PAGEUNLOCK =	20011;
        DRV_ERROR_BOARDTEST	= 20012 ;
        DRV_ERROR_ACK	= 20013 ;
        DRV_ERROR_UP_FIFO	= 20014  ;
        DRV_ERROR_PATTERN	= 20015 ;

        DRV_ACQUISITION_ERRORS =	20017;
        DRV_ACQ_BUFFER =	20018 ;
        DRV_ACQ_DOWNFIFO_FULL	= 20019 ;
        DRV_PROC_UNKONWN_INSTRUCTION =	20020 ;
        DRV_ILLEGAL_OP_CODE	= 20021 ;
        DRV_KINETIC_TIME_NOT_MET =	20022 ;
        DRV_ACCUM_TIME_NOT_MET = 20023 ;
        DRV_NO_NEW_DATA	= 20024 ;
        DRV_SPOOLERROR = 20026 ;

        DRV_TEMPERATURE_CODES	= 20033 ;
        DRV_TEMPERATURE_OFF	= 20034 ;
        DRV_TEMPERATURE_NOT_STABILIZED =	20035 ;
        DRV_TEMPERATURE_STABILIZED =	20036 ;
        DRV_TEMPERATURE_NOT_REACHED	= 20037 ;
        DRV_TEMPERATURE_OUT_RANGE	= 20038 ;
        DRV_TEMPERATURE_NOT_SUPPORTED	= 20039 ;
        DRV_TEMPERATURE_DRIFT	= 20040 ;


        DRV_TEMP_CODES =	20033;
        DRV_TEMP_OFF =	20034 ;
        DRV_TEMP_NOT_STABILIZED	= 20035;
        DRV_TEMP_STABILIZED	= 20036 ;
        DRV_TEMP_NOT_REACHED = 20037 ;
        DRV_TEMP_OUT_RANGE =	20038 ;
        DRV_TEMP_NOT_SUPPORTED =	20039 ;
        DRV_TEMP_DRIFT =	20040 ;


        DRV_GENERAL_ERRORS =	20049 ;
        DRV_INVALID_AUX	=20050 ;
        DRV_COF_NOTLOADED	=20051 ;
        DRV_FPGAPROG = 20052 ;
        DRV_FLEXERROR = 20053 ;
        DRV_GPIBERROR = 20054 ;

        DRV_DRIVER_ERRORS	=20065;
        DRV_P1INVALID	=20066 ;
        DRV_P2INVALID	=20067 ;
        DRV_P3INVALID	=20068  ;
        DRV_P4INVALID	=20069 ;
        DRV_INIERROR	=20070 ;
        DRV_COFERROR	=20071 ;
        DRV_ACQUIRING	=20072 ;
        DRV_IDLE	=20073 ;
        DRV_TEMPCYCLE	=20074 ;
        DRV_NOT_INITIALIZED = 20075;
        DRV_P5INVALID	=20076 ;
        DRV_P6INVALID	=20077 ;
        DRV_INVALID_MODE	=20078 ;
        DRV_INVALID_FILTER = 20079 ;

        DRV_I2CERRORS	=20080 ;
        DRV_I2CDEVNOTFOUND =	20081 ;
        DRV_I2CTIMEOUT =	20082 ;

        DRV_IOCERROR = 20090 ;
        DRV_VRMVERSIONERROR = 20091 ;

        DRV_ERROR_NOCAMERA =20990 ;
        DRV_NOT_SUPPORTED =20991 ;

        AC_ACQMODE_SINGLE =1;
        AC_ACQMODE_VIDEO =2 ;
        AC_ACQMODE_ACCUMULATE =4 ;
        AC_ACQMODE_KINETIC =8 ;
        AC_ACQMODE_FRAMETRANSFER =16 ;
        AC_ACQMODE_FASTKINETICS =32 ;

        AC_READMODE_FULLIMAGE =1 ;
        AC_READMODE_SUBIMAGE =2 ;
        AC_READMODE_SINGLETRACK =4 ;
        AC_READMODE_FVB =8 ;
        AC_READMODE_MULTITRACK =16 ;
        AC_READMODE_RANDOMTRACK =32 ;

        AC_TRIGGERMODE_INTERNAL =1 ;
        AC_TRIGGERMODE_EXTERNAL =2 ;

        AC_CAMERATYPE_PDA =0 ;
        AC_CAMERATYPE_IXON =1 ;
        AC_CAMERATYPE_ICCD =2 ;
        AC_CAMERATYPE_EMCCD =3 ;
        AC_CAMERATYPE_CCD =4  ;
        AC_CAMERATYPE_ISTAR=5  ;
        AC_CAMERATYPE_VIDEO =6   ;

        AC_PIXELMODE_8BIT  =1;
        AC_PIXELMODE_14BIT =2 ;
        AC_PIXELMODE_16BIT =4 ;
        AC_PIXELMODE_32BIT =8 ;

        AC_PIXELMODE_MONO =0 ;
        AC_PIXELMODE_RGB = $10 ;
        AC_PIXELMODE_CMY = $20 ;

        AC_SETFUNCTION_VREADOUT =1 ;
        AC_SETFUNCTION_HREADOUT =2 ;
        AC_SETFUNCTION_TEMPERATURE =4 ;
        AC_SETFUNCTION_GAIN = 8 ;
        AC_SETFUNCTION_EMCCDGAIN =16 ;

        AC_GETFUNCTION_TEMPERATURE =1 ;
        AC_GETFUNCTION_TARGETTEMPERATURE =2 ;
        AC_GETFUNCTION_TEMPERATURERANGE =4 ;
        AC_GETFUNCTION_DETECTORSIZE= 8 ;
        AC_GETFUNCTION_GAIN =16 ;
        AC_GETFUNCTION_EMCCDGAIN =32 ;

        AC_FEATURES_POLLING =1 ;
        AC_FEATURES_EVENTS =2 ;
        AC_FEATURES_SPOOLING =4 ;
        AC_FEATURES_SHUTTER =8 ;


var

  LibraryHnd : THandle ;         // DLL library handle
  LibraryLoaded : boolean ;      // DLL library loaded flag
  AndorCapabilities : TAndorCapabilities ;
  SetADChannel : TSetADChannel ;
  SetExposureTime : TSetExposureTime ;
  SetNumberAccumulations : TSetNumberAccumulations ;
  SetAccumulationCycleTime : TSetAccumulationCycleTime ;
  SetNumberKinetics : TSetNumberKinetics ;
  SetKineticCycleTime : TSetKineticCycleTime ;
  SetAcquisitionMode : TSetAcquisitionMode ;
  SetHorizontalSpeed : TSetHorizontalSpeed ;
  SetVerticalSpeed : TSetVerticalSpeed ;
  SetReadMode : TSetReadMode ;
  SetSingleTrack : TSetSingleTrack ;
  SetFullImage : TSetFullImage ;
  GetAcquisitionTimings : TGetAcquisitionTimings ;
  StartAcquisition : TStartAcquisition ;
  AbortAcquisition : TAbortAcquisition ;
  GetAcquiredData : TGetAcquiredData ;
  GetStatus : TGetStatus ;
  SetTriggerMode : TSetTriggerMode ;
  Initialize : TInitialize ;	 //	read ini file to get head and card
  ShutDown : TShutDown ;
  SetTemperature : TSetTemperature ;
  GetTemperature : TGetTemperature ;
  GetTemperatureRange : TGetTemperatureRange ;
  CoolerON : TCoolerON ;
  CoolerOFF : TCoolerOFF ;
  SetShutter : TSetShutter ;
  GetNumberHorizontalSpeeds : TGetNumberHorizontalSpeeds ;
  GetHorizontalSpeed : TGetHorizontalSpeed ;
  GetNumberVerticalSpeeds : TGetNumberVerticalSpeeds ;
  GetVerticalSpeed : TGetVerticalSpeed ;
  GetDetector : TGetDetector ;
  GetSoftwareVersion : TGetSoftwareVersion ;
  GetHardwareVersion : TGetHardwareVersion ;
  SetImage : TSetImage ;
  SetFastKinetics : TSetFastKinetics ;
  GetFKExposureTime : TGetFKExposureTime ;
  GetNumberFKVShiftSpeeds : TGetNumberFKVShiftSpeeds ;
  GetSpoolProgress : TGetSpoolProgress ;
  GetSizeOfCircularBuffer : TGetSizeOfCircularBuffer ;
  GetMostRecentImage : TGetMostRecentImage ;
  GetOldestImage : TGetOldestImage ;
  GetNumberNewImages : TGetNumberNewImages ;
  GetImages : TGetImages ;
  GetTotalNumberImagesAcquired : TGetTotalNumberImagesAcquired ;
  SetFrameTransferMode : TSetFrameTransferMode ;
  SetFKVShiftSpeed : TSetFKVShiftSpeed ;
  GetFKVShiftSpeed : TGetFKVShiftSpeed ;
  SetComplexImage : TSetComplexImage ;
  SetRandomTracks : TSetRandomTracks ;
  SetDriverEvent : TSetDriverEvent ;
  SetGain : TSetGain ;
  SetSingleTrackHBin : TSetSingleTrackHBin ;
  SetMultiTrackHBin : TSetMultiTrackHBin ;
  SetFVBHBin : TSetFVBHBin ;
  SetCustomTrackHBin : TSetCustomTrackHBin ;
  GetNewData : TGetNewData ;
  SetEMCCDGain : TSetEMCCDGain ;
  SaveAsBmp : TSaveAsBmp ;
  SetSpool : TSetSpool ;
  SetFastExtTrigger : TSetFastExtTrigger ;
  GetAcquisitionProgress : TGetAcquisitionProgress ;
  GetNumberHSSpeeds : TGetNumberHSSpeeds ;
  GetHSSpeed : TGetHSSpeed ;
  SetHSSpeed : TSetHSSpeed ;
  GetNumberVSSpeeds : TGetNumberVSSpeeds ;
  GetVSSpeed : TGetVSSpeed ;
  GetFastestRecommendedVSSpeed : TGetFastestRecommendedVSSpeed ;
  SetVSSpeed : TSetVSSpeed ;
  SetVSAmplitude : TSetVSAmplitude ;
  GetNumberAmp : TGetNumberAmp ;
  GetAmpMaxSpeed : TGetAmpMaxSpeed ;
  GetAmpDesc : TGetAmpDesc ;
  SetVerticalRowBuffer : TSetVerticalRowBuffer ;
  GetRegisterDump : TGetRegisterDump ;
  SetRegisterDump : TGetRegisterDump ;
  GetCameraSerialNumber : TGetCameraSerialNumber ;
  GetPixelSize : TGetPixelSize ;
  GetBitDepth : TGetBitDepth ;
  GetHeadModel : TGetHeadModel ;
  GetNewData16 : TGetNewData16 ;
  GetAcquiredData16 : TGetAcquiredData16 ;
  GetCapabilities : TGetCapabilities ;
  SetMessageWindow : TSetMessageWindow ;
  SelectDevice : TSelectDevice ;
  GetNumberDevices : TGetNumberDevices ;
  GetID : TGetID ;
  SetPixelMode : TSetPixelMode ;
  IdAndorDll : TIdAndorDll ;
  SetBaselineClamp : TSetBaselineClamp ; 


procedure Andor_LoadLibrary  ;
{ ---------------------------------------------
  Load camera interface DLL library into memory
  ---------------------------------------------}
var
    LibFileName : string ;
begin

     LibraryLoaded := False ;

     { Load DLL camera interface library }
     LibFileName := 'atmcd32d.dll' ;
     LibraryHnd := LoadLibrary( PChar(LibFileName));
     if LibraryHnd <= 0 then begin
        MessageDlg( 'Andor: ' + LibFileName + ' not found!', mtWarning, [mbOK], 0 ) ;
        Exit ;
        end ;

     @IdAndorDll := Andor_GetDLLAddress(LibraryHnd,'IdAndorDll') ;
     @SetPixelMode := Andor_GetDLLAddress(LibraryHnd,'SetPixelMode') ;
     @GetID := Andor_GetDLLAddress(LibraryHnd,'GetID') ;
     @GetNumberDevices := Andor_GetDLLAddress(LibraryHnd,'GetNumberDevices') ;
     @SelectDevice := Andor_GetDLLAddress(LibraryHnd,'SelectDevice') ;
     @SetMessageWindow := Andor_GetDLLAddress(LibraryHnd,'SetMessageWindow') ;
     @GetCapabilities := Andor_GetDLLAddress(LibraryHnd,'GetCapabilities') ;
     @GetAcquiredData16 := Andor_GetDLLAddress(LibraryHnd,'GetAcquiredData16') ;
     @GetNewData16 := Andor_GetDLLAddress(LibraryHnd,'GetNewData16') ;
     @GetHeadModel := Andor_GetDLLAddress(LibraryHnd,'GetHeadModel') ;
     @GetPixelSize := Andor_GetDLLAddress(LibraryHnd,'GetPixelSize') ;
     @GetBitDepth := Andor_GetDLLAddress(LibraryHnd,'GetBitDepth') ;
     @GetCameraSerialNumber := Andor_GetDLLAddress(LibraryHnd,'GetCameraSerialNumber') ;
     @GetAcquisitionProgress := Andor_GetDLLAddress(LibraryHnd,'GetAcquisitionProgress') ;
     @GetNumberHSSpeeds := Andor_GetDLLAddress(LibraryHnd,'GetNumberHSSpeeds') ;
     @GetHSSpeed := Andor_GetDLLAddress(LibraryHnd,'GetHSSpeed') ;
     @GetNumberVSSpeeds := Andor_GetDLLAddress(LibraryHnd,'GetNumberVSSpeeds') ;
     @GetVSSpeed := Andor_GetDLLAddress(LibraryHnd,'GetVSSpeed') ;
     @GetFastestRecommendedVSSpeed := Andor_GetDLLAddress(LibraryHnd,'GetFastestRecommendedVSSpeed') ;
     @SetHSSpeed := Andor_GetDLLAddress(LibraryHnd,'SetHSSpeed') ;
     @SetVSSpeed := Andor_GetDLLAddress(LibraryHnd,'SetVSSpeed') ;
     @SetVSAmplitude := Andor_GetDLLAddress(LibraryHnd,'SetVSAmplitude') ;
     @GetNumberAmp := Andor_GetDLLAddress(LibraryHnd,'GetNumberAmp') ;
     @GetAmpMaxSpeed := Andor_GetDLLAddress(LibraryHnd,'GetAmpMaxSpeed') ;
     @GetAmpDesc := Andor_GetDLLAddress(LibraryHnd,'GetAmpDesc') ;
     @SetVerticalRowBuffer := Andor_GetDLLAddress(LibraryHnd,'SetVerticalRowBuffer') ;
     @GetRegisterDump := Andor_GetDLLAddress(LibraryHnd,'GetRegisterDump') ;
     @SetRegisterDump := Andor_GetDLLAddress(LibraryHnd,'SetRegisterDump') ;
     @SetFastExtTrigger := Andor_GetDLLAddress(LibraryHnd,'SetFastExtTrigger') ;
     @SetSpool := Andor_GetDLLAddress(LibraryHnd,'SetSpool') ;
     @SaveAsBmp := Andor_GetDLLAddress(LibraryHnd,'SaveAsBmp') ;
     @SetEMCCDGain := Andor_GetDLLAddress(LibraryHnd,'SetEMCCDGain') ;
     @GetNewData := Andor_GetDLLAddress(LibraryHnd,'GetNewData') ;
     @SetCustomTrackHBin := Andor_GetDLLAddress(LibraryHnd,'SetCustomTrackHBin') ;
     @SetFVBHBin := Andor_GetDLLAddress(LibraryHnd,'SetFVBHBin') ;
     @SetMultiTrackHBin := Andor_GetDLLAddress(LibraryHnd,'SetMultiTrackHBin') ;
     @SetSingleTrackHBin := Andor_GetDLLAddress(LibraryHnd,'SetSingleTrackHBin') ;
     @SetGain := Andor_GetDLLAddress(LibraryHnd,'SetGain') ;
     @SetDriverEvent := Andor_GetDLLAddress(LibraryHnd,'SetDriverEvent') ;
     @SetRandomTracks := Andor_GetDLLAddress(LibraryHnd,'SetRandomTracks') ;
     @SetComplexImage := Andor_GetDLLAddress(LibraryHnd,'SetComplexImage') ;
     @GetFKVShiftSpeed := Andor_GetDLLAddress(LibraryHnd,'GetFKVShiftSpeed') ;
     @SetFKVShiftSpeed := Andor_GetDLLAddress(LibraryHnd,'SetFKVShiftSpeed') ;
     @GetNumberFKVShiftSpeeds := Andor_GetDLLAddress(LibraryHnd,'GetNumberFKVShiftSpeeds') ;
     @GetFKExposureTime := Andor_GetDLLAddress(LibraryHnd,'GetFKExposureTime') ;
     @SetFastKinetics := Andor_GetDLLAddress(LibraryHnd,'SetFastKinetics') ;
     @SetImage := Andor_GetDLLAddress(LibraryHnd,'SetImage') ;
     @GetHardwareVersion := Andor_GetDLLAddress(LibraryHnd,'GetHardwareVersion') ;
     @GetSoftwareVersion := Andor_GetDLLAddress(LibraryHnd,'GetSoftwareVersion') ;
     @GetDetector := Andor_GetDLLAddress(LibraryHnd,'GetDetector') ;
     @GetVerticalSpeed := Andor_GetDLLAddress(LibraryHnd,'GetVerticalSpeed') ;
     @GetNumberVerticalSpeeds := Andor_GetDLLAddress(LibraryHnd,'GetNumberVerticalSpeeds') ;
     @GetHorizontalSpeed := Andor_GetDLLAddress(LibraryHnd,'GetHorizontalSpeed') ;
     @GetNumberHorizontalSpeeds := Andor_GetDLLAddress(LibraryHnd,'GetNumberHorizontalSpeeds') ;
     @SetShutter := Andor_GetDLLAddress(LibraryHnd,'SetShutter') ;
     @CoolerOFF := Andor_GetDLLAddress(LibraryHnd,'CoolerOFF') ;
     @CoolerON := Andor_GetDLLAddress(LibraryHnd,'CoolerON') ;
     @GetTemperatureRange := Andor_GetDLLAddress(LibraryHnd,'GetTemperatureRange') ;
     @GetTemperature := Andor_GetDLLAddress(LibraryHnd,'GetTemperature') ;
     @SetTemperature := Andor_GetDLLAddress(LibraryHnd,'SetTemperature') ;
     @ShutDown := Andor_GetDLLAddress(LibraryHnd,'ShutDown') ;
     @Initialize := Andor_GetDLLAddress(LibraryHnd,'Initialize') ;
     @SetTriggerMode := Andor_GetDLLAddress(LibraryHnd,'SetTriggerMode') ;
     @GetStatus := Andor_GetDLLAddress(LibraryHnd,'GetStatus') ;
     @GetAcquiredData := Andor_GetDLLAddress(LibraryHnd,'GetAcquiredData') ;
     @AbortAcquisition := Andor_GetDLLAddress(LibraryHnd,'AbortAcquisition') ;
     @StartAcquisition := Andor_GetDLLAddress(LibraryHnd,'StartAcquisition') ;
     @GetAcquisitionTimings := Andor_GetDLLAddress(LibraryHnd,'GetAcquisitionTimings') ;
     @SetFullImage := Andor_GetDLLAddress(LibraryHnd,'SetFullImage') ;
     @SetSingleTrack := Andor_GetDLLAddress(LibraryHnd,'SetSingleTrack') ;
     @SetReadMode := Andor_GetDLLAddress(LibraryHnd,'SetReadMode') ;
     @SetVerticalSpeed := Andor_GetDLLAddress(LibraryHnd,'SetVerticalSpeed') ;
     @SetHorizontalSpeed := Andor_GetDLLAddress(LibraryHnd,'SetHorizontalSpeed') ;
     @SetAcquisitionMode := Andor_GetDLLAddress(LibraryHnd,'SetAcquisitionMode') ;
     @SetKineticCycleTime := Andor_GetDLLAddress(LibraryHnd,'SetKineticCycleTime') ;
     @SetNumberKinetics := Andor_GetDLLAddress(LibraryHnd,'SetNumberKinetics') ;
     @SetAccumulationCycleTime := Andor_GetDLLAddress(LibraryHnd,'SetAccumulationCycleTime') ;
     @SetADChannel := Andor_GetDLLAddress(LibraryHnd,'SetADChannel') ;
     @SetExposureTime := Andor_GetDLLAddress(LibraryHnd,'SetExposureTime') ;
     @SetNumberAccumulations := Andor_GetDLLAddress(LibraryHnd,'SetNumberAccumulations') ;
     @GetSpoolProgress := Andor_GetDLLAddress(LibraryHnd,'GetSpoolProgress') ;
     @GetSizeOfCircularBuffer := Andor_GetDLLAddress(LibraryHnd,'GetSizeOfCircularBuffer') ;
     @GetMostRecentImage := Andor_GetDLLAddress(LibraryHnd,'GetMostRecentImage') ;
     @GetOldestImage := Andor_GetDLLAddress(LibraryHnd,'GetOldestImage') ;
     @GetNumberNewImages := Andor_GetDLLAddress(LibraryHnd,'GetNumberNewImages') ;
     @GetImages := Andor_GetDLLAddress(LibraryHnd,'GetImages') ;
     @GetTotalNumberImagesAcquired := Andor_GetDLLAddress(LibraryHnd,'GetTotalNumberImagesAcquired') ;
     @SetFrameTransferMode := Andor_GetDLLAddress(LibraryHnd,'SetFrameTransferMode') ;
     @SetBaselineClamp := Andor_GetDLLAddress(LibraryHnd,'SetBaselineClamp') ;
     LibraryLoaded := True ;

     end ;


function Andor_GetDLLAddress(
         Handle : Integer ;
         const ProcName : string ) : Pointer ;
// -----------------------------------------
// Get address of procedure within DLL
// -----------------------------------------
begin
    Result := GetProcAddress(Handle,PChar(ProcName)) ;
    if Result = Nil then
       MessageDlg('atmcd32d.dll: ' + ProcName + ' not found',mtWarning,[mbOK],0) ;
    end ;


function Andor_OpenCamera(
          var Session : TAndorSession ;   // Camera session record
          var FrameWidthMax : Integer ;      // Returns camera frame width
          var FrameHeightMax : Integer ;     // Returns camera height width
          var NumBytesPerPixel : Integer ;   // Returns bytes/pixel
          var PixelDepth : Integer ;         // Returns no. bits/pixel
          var PixelWidth : Single ;          // Returns pixel size (um)
          CameraInfo : TStringList         // Returns Camera details
          ) : Boolean ;
// ---------------------
// Open Andor camera
// ---------------------
var
    Err : Integer ;
    cBuf : Array[0..79] of Char ;
    s : String ;
    i,j :Integer ;
    CCDTemperature : Integer ;
    CCDXSize : Integer ;
    CCDYSize : Integer ;
    ActualXSize : Integer ;
    ActualYSize : Integer ;
    c : Char ;
    SerialNumber : SmallInt ;
    NumDevices : Integer ;
    PixelHeight : Single ;
    NumVSSpeeds : Integer ;
    NumHSSpeeds : Integer ;
    ShiftTime : Single ;
    FWSmall, FHSmall : Integer ;
    ReadoutRate : Single ;
begin

     Result := False ;

     // Load DLL libray
     if not LibraryLoaded then Andor_LoadLibrary  ;
     if not LibraryLoaded then Exit ;

     // Initialise software
     Err := Initialize(PChar('c:\Program Files\iXon\Drivers')) ;
     Andor_CheckError('Initialize',Err) ;
     if Err <> DRV_SUCCESS then Exit ;

     // Set A/D channel
     Andor_CheckError('SetADChannel',SetADChannel(0)) ;

     // Serial number
     Andor_CheckError( 'GetCameraSerialNumber',
                       GetCameraSerialNumber( SerialNumber )) ;
     CameraInfo.Add(format('Camera s/n %d',[SerialNumber])) ;

     // Head model
     Andor_CheckError( 'GetHeadModel',
                       GetHeadModel( cBuf )) ;
     CameraInfo.Add(format('Head Model: %s',[cBuf])) ;

     // Set Luca temperature to -20C, others to -70 C
     if Pos('luc',LowerCase(cBuf)) > 0 then Session.WorkingTemperature := -20
                                       else Session.WorkingTemperature := -70 ;

     Andor_CheckError( 'GetCapabilities',
                       GetCapabilities( AndorCapabilities )) ;

     if (AndorCapabilities.AcqModes or AC_ACQMODE_VIDEO) = 0 then
        CameraInfo.Add('WARNING: Run Till Abort mode not available!') ;

     if (AndorCapabilities.AcqModes or AC_ACQMODE_FRAMETRANSFER) = 0 then
        CameraInfo.Add('WARNING: Frame transfer mode not available!') ;

     // Get no. horizontal and vertical pixels in CCD
      Andor_CheckError( 'GetDetector',
                        GetDetector( FrameWidthMax, FrameHeightMax ) ) ;
     CameraInfo.Add(format('Frame: %d x %d pixels',[FrameWidthMax,FrameHeightMax])) ;

     // Get pixel size
     Andor_CheckError( 'GetPixelSize',
                       GetPixelSize( PixelWidth, PixelHeight )) ;
     CameraInfo.Add(format('Pixel width: %.3f um',[PixelWidth])) ;

     // No. of bytes per pixel
     Andor_CheckError( 'GetBitDepth',
                       GetBitDepth( 0, PixelDepth )) ;
     NumBytesPerPixel := 2 ;
     CameraInfo.Add(format('Pixel depth: %d bits',[PixelDepth])) ;

     // List horizontal pixel readout rates
     Andor_CheckError( 'GetNumberHSSpeeds',
                        GetNumberHSSpeeds( 0, 0, NumHSSpeeds )) ;
     CameraInfo.Add(' ') ;
     CameraInfo.Add(' Pixel readout rate') ;

     s := '' ;
     for i := 0 to NumHSSpeeds-1 do begin
         Andor_CheckError( 'GetHSSpeed',
                           GetHSSpeed( 0, 0, i, ReadoutRate )) ;
         if i > 0 then s := s + ', ' ;
         s := s + format('%d=%.4g MHz',[i,ReadoutRate] ) ;
         end ;
     CameraInfo.Add(s) ;
     // Set to fastest speed
     Andor_CheckError( 'SetHSSpeed', SetHSSpeed( 0, 0 )) ;
     Andor_CheckError( 'GetHSSpeed', GetHSSpeed( 0, 0, 0, ReadoutRate )) ;
     CameraInfo.Add(format('Readout rate = %.4g MHz',[ReadoutRate])) ;

     // List vertical line shift times
     Andor_CheckError( 'GetNumberVSSpeeds',
                       GetNumberVSSpeeds( NumVSSpeeds )) ;
     CameraInfo.Add(' ') ;
     CameraInfo.Add(' Vertical line shift times') ;
     s := '' ;
     for i := 0 to NumVSSpeeds-1 do begin
         Andor_CheckError( 'GetVSSpeed',GetVSSpeed( i, ShiftTime )) ;
         if i > 0 then s := s + ', ' ;
         s := s + format('%d = %.4g us',[i,ShiftTime] )
         end ;
     CameraInfo.Add(s) ;
     // Set vertical shift to fastest recommended speed
     Andor_CheckError( 'GetFastestRecommendedVSSpeed',
                        GetFastestRecommendedVSSpeed( i, ShiftTime )) ;
     Andor_CheckError( 'SetVSSpeed', SetVSSpeed( i )) ;
     Andor_CheckError( 'GetVSSpeed',GetVSSpeed( i, ShiftTime )) ;
     CameraInfo.Add(format('Vertical line shift time = %.4g us',[ShiftTime])) ;

     // Set frame transfer time
     Session.FrameTransferTime :=  ShiftTime*FrameHeightMax*1E-6 ;
     Session.FrameTransferTime := 0.0018 ;
     CameraInfo.Add(format('Frame transfer time = %.4g us',[Session.FrameTransferTime*1E6])) ;

     // Set CCD temperature and turn cooler on
     Andor_CheckError( 'SetTemperature',SetTemperature(Session.WorkingTemperature)) ;
     Andor_CheckError( 'CoolerOn', CoolerOn ) ;

     // Set baseline clamp on
     // (Prevents transient changes in background signal level at start of imaging)
     Andor_CheckError( 'SetBaselineClamp', SetBaselineClamp(1) ) ;

     Session.GetImageInUse := False ;
     Session.CapturingImages := False ;
     Session.GetImageInUse := False ;

     Session.CameraOpen := True ;
     Result := Session.CameraOpen ;

     Session.PImageBuffer := Nil ;

     end ;


procedure Andor_CloseCamera(
          var Session : TAndorSession // Session record
          ) ;
// ----------------
// Shut down camera
// ----------------
var
    Err : Integer ;
    Temperature : Integer ;
begin

    if not Session.CameraOpen then Exit ;

    // Stop camera
    Err := AbortAcquisition ;
    if Err <> DRV_IDLE then Andor_CheckError( 'AbortAcquisition', Err ) ;

    Andor_CheckError( 'CoolerOff', CoolerOff ) ;

    if MessageDlg( 'Wait for camera to return to room temperature? ', mtConfirmation,
        [mbYes,mbNo], 0 ) = mrYes then begin
        // Wait for temperature to rise above 0C
        Temperature := -100 ;
        While Temperature < 0 do begin
              GetTemperature(Temperature) ;
             end ;
        end ;

    // Close camera
    Andor_CheckError( 'ShutDown', ShutDown ) ;

    // Free image transfer buffer
    if Session.PImageBuffer <> Nil then begin
       FreeMem( Session.PImageBuffer ) ;
       Session.PImageBuffer := Nil ;
       end ;

    Session.GetImageInUse := False ;
    Session.CameraOpen := False ;
    Session.CapturingImages := False ;

    end ;


procedure Andor_GetCameraGainList(
          CameraGainList : TStringList
          ) ;
// --------------------------------------------
// Get list of available camera amplifier gains
// --------------------------------------------
var
    i : Integer ;
begin
    CameraGainList.Clear ;
    for i := 1 to 255 do CameraGainList.Add( format( '%d',[i] )) ;
    end ;

procedure Andor_GetCameraReadoutSpeedList(
          CameraReadoutSpeedList : TStringList
          ) ;
// -------------------------------
// Get camera pixel readout speeds
// -------------------------------
var
    i : Integer ;
    NumHSSpeeds : Integer ;
    ReadoutRate : Single ;
    Err : Integer ;
begin

     CameraReadoutSpeedList.Clear ;

     Err := GetNumberHSSpeeds( 0, 0, NumHSSpeeds ) ;
     if Err <> DRV_SUCCESS then Exit ;

     for i := 0 to NumHSSpeeds-1 do begin
         Andor_CheckError( 'GetHSSpeed',GetHSSpeed( 0, 0, i, ReadoutRate )) ;
         CameraReadoutSpeedList.Add(format('%.4g MHz',[ReadoutRate] )) ;
         end ;
     end ;


function Andor_StartCapture(
         var Session : TAndorSession ;   // Camera session record
         var InterFrameTimeInterval : Double ;      // Frame exposure time
         AmpGain : Integer ;              // Camera amplifier gain index
         ReadoutSpeed : Integer ;         // Camera Read speed index number
         ExternalTrigger : Integer ;      // Trigger mode
         FrameLeft : Integer ;            // Left pixel in CCD readout area
         FrameTop : Integer ;             // Top pixel in CCD eadout area
         FrameWidth : Integer ;           // Width of CCD readout area
         FrameHeight : Integer ;          // Width of CCD readout area
         BinFactor : Integer ;             // Binning factor (1,2,4,8,16)
         PFrameBuffer : Pointer ;         // Pointer to start of ring buffer
         NumFramesInBuffer : Integer ;    // No. of frames in ring buffer
         NumBytesPerFrame : Integer       // No. of bytes/frame
         ) : Boolean ;
// -------------------
// Start frame capture
// -------------------
const
     MaxExposureTimeTicks = 65535 ;
     TimerTickInterval = 20 ; // Timer tick resolution (ms)

var
    Err : Integer ;
    i : Integer ;
    Mode : Integer ;
    ReadoutTime : Double ;
    CycleTime : Single ;
    ExposureTime : Single ;
    AccumulateTime : Single ;
    TrigMode : Integer ;
begin

     if not Session.CameraOpen then Exit ;

     // Read camera temperature
     GetTemperature( Session.Temperature ) ;

     // Set CCD readout speed
     //ReadoutSpeed := Min(Max(ReadoutSpeed, 0),CameraReadoutSpeedList.Count-1) ;
     Andor_CheckError( 'SetHSSpeed', SetHSSpeed( 0, ReadoutSpeed )) ;

     // Check that frame interval is valid
     Andor_CheckFrameInterval( Session,
                               FrameLeft,
                               FrameLeft + FrameWidth -1,
                               FrameTop,
                               FrameTop + FrameHeight - 1,
                               BinFactor,
                               InterFrameTimeInterval,
                               ReadoutTime ) ;

     // Set camera in  run till abort non-FT mode
     Andor_CheckError( 'SetAcquisitionMode',SetAcquisitionMode(5));

     // Set EMCCD gain
     Andor_CheckError( 'SetEMCCDGain', SetEMCCDGain( AmpGain )) ;

     // Set image read mode
     Andor_CheckError( 'SetReadMode', SetReadMode(4)) ;

     // Set internal/external frame trigger mode
     if ExternalTrigger <> CamFreeRun then TrigMode := 1
                                      else TrigMode := 0 ;
     Andor_CheckError( 'SetTriggerMode', SetTriggerMode(TrigMode)) ;

     // Set number of accumulations / frame (always 1)
     Andor_CheckError( 'SetNumberAccumulations',
                       SetNumberAccumulations(1)) ;

     // set camera into frame transfer mode
     Andor_CheckError( 'SetFrameTransferMode',SetFrameTransferMode(1));

     // Set camera into fast trigger mode (no clean cycles)
     Andor_CheckError( 'SetFastExtTrigger',SetFastExtTrigger(1));

     // Set image sub-area and binning factor
     Andor_CheckError( 'SetImage',
                       SetImage( BinFactor,
                                 BinFactor,
                                 FrameLeft+1,
                                 FrameLeft + FrameWidth,
                                 FrameTop+1,
                                 FrameTop + FrameHeight )) ;

     if TrigMode = 1 then begin
        // External camera triggering -
        // (SetExposure time sets trigger delay)
        Andor_CheckError( 'SetExposureTime',SetExposureTime( 0.0 )) ;
        end
     else begin
        // Internal camera timing -
        // Set exposure time taking into account CCD readout transfer time so as
        // to preserve frame transfer time
        Andor_CheckError( 'SetExposureTime', SetExposureTime(InterFrameTimeInterval)) ;
        Andor_CheckError( 'GetAcquisitionTimings',
                       GetAcquisitionTimings( ExposureTime,
                                              AccumulateTime,
                                              CycleTime )) ;                                                                                                                                                                            
        Session.FrameTransferTime := CycleTime - InterFrameTimeInterval ;
        ExposureTime := InterFrameTimeInterval - Session.FrameTransferTime ;
        Andor_CheckError( 'SetExposureTime', SetExposureTime(ExposureTime)) ;
        Andor_CheckError( 'GetAcquisitionTimings',
                       GetAcquisitionTimings( ExposureTime,
                                              AccumulateTime,
                                              CycleTime )) ;
        InterFrameTimeInterval := CycleTime ;
        end ;

     Session.NumPixelsPerFrame := (FrameWidth*FrameHeight) div (BinFactor*BinFactor);
     Session.NumBytesPerFrame := NumBytesPerFrame ;
     Session.NumFrames := NumFramesInBuffer ;
     Session.PFrameBuffer := PFrameBuffer ;
     Session.NumFramesCopied := 0 ;
     Session.FrameNum := 0 ;

     // Get number of images within camera circular image buffer
     Andor_CheckError( 'GetSizeOfCircularBuffer',
                       GetSizeOfCircularBuffer( Session.ImageBufferSize )) ;

     // Allocate local image transfer buffer
      if Session.PImageBuffer <> Nil then FreeMem(Session.PImageBuffer) ;
     GetMem( Session.PImageBuffer, Session.ImageBufferSize*Session.NumPixelsPerFrame*4 ) ;

     if TrigMode = 1 then begin
        // In external trigger mode, start camera then wait
        Andor_CheckError( 'SetShutter',SetShutter( 1,1,20,20)) ;
        Andor_CheckError( 'StartAcquisition', StartAcquisition ) ;
        Andor_Wait(2.0) ;
        end
     else begin
        // In free run mode, wait till camera sets up then start
        Andor_Wait(2.0) ;
        Andor_CheckError( 'SetShutter',SetShutter( 1,1,20,20)) ;
        // Start camera acquisition ;
        Andor_CheckError( 'StartAcquisition', StartAcquisition ) ;
        end ;

     Session.TimeStart := TimeGetTime*0.001 ;

     // Start frame acquisition monitor procedure

     Session.CapturingImages := True ;

     Result := True ;

     end;


procedure Andor_Wait( Delay : Single ) ;
var
  T : Integer ;
  TExit : Integer ;
begin
    T := TimeGetTime ;
    TExit := T + Round(Delay*1E3) ;
    while T < TExit do begin
       T := TimeGetTime ;
       end ;
    end ;


function Andor_CheckFrameInterval(
          var Session : TAndorSession ;   // Camera session record
          FrameLeft : Integer ;   // Left edge of capture region (In)
          FrameRight : Integer ;  // Right edge of capture region( In)
          FrameTop : Integer ;    // Top edge of capture region( In)
          FrameBottom : Integer ; // Bottom edge of capture region (In)
          BinFactor : Integer ;   // Pixel binning factor (In)
          Var FrameInterval : Double ;
          Var ReadoutTime : Double) : Boolean ;
// ----------------------------------------
// Check that inter-frame interval is valid
// ----------------------------------------
var
    ExposureTime : Single ;
    AccumulateTime : Single ;
    CycleTime : Single ;
    Status : Integer ;
    Err : Integer ;
begin

     if not Session.CameraOpen then Exit ;

     // Exit if camera is acquiring
     Andor_CheckError( 'GetStatus',GetStatus( Status )) ;
     if Status = DRV_ACQUIRING then Exit ;

     // Set camera in  run till abort non-FT mode
     Andor_CheckError( 'SetAcquisitionMode',SetAcquisitionMode(5));

     // Set to "image" read mode
     Andor_CheckError( 'SetReadMode', SetReadMode(4)) ;

     Andor_CheckError( 'SetFrameTransferMode',SetFrameTransferMode(1));

     Andor_CheckError( 'SetTriggerMode', SetTriggerMode(0)) ;

     // Set image sub-area and binning factor
     Andor_CheckError( 'SetImage',
                       SetImage( BinFactor,
                                 BinFactor,
                                 FrameLeft+1,
                                 FrameRight+1 ,
                                 FrameTop+1,
                                 FrameBottom+1)) ;

     // Find readout time (shortest possible exposure time
     Andor_CheckError( 'SetExposureTime',SetExposureTime( 0.0 )) ;
     Andor_CheckError( 'GetAcquisitionTimings',
                       GetAcquisitionTimings( ExposureTime,
                                              AccumulateTime,
                                              CycleTime )) ;
     ReadoutTime := (Trunc(CycleTime*1000)+1)*0.001 ;

        // Internal camera timing -
     // (Set exposure time the frame interval - frame transfer time)
//     Andor_CheckError( 'SetExposureTime',
//                       SetExposureTime( Max(FrameInterval - Session.FrameTransferTime,0.0))) ;
//        Andor_CheckError( 'SetKineticCycleTime',
//                          SetKineticCycleTime( FrameInterval )) ;

     // Set exposure time taking into account CCD readout transfer time so as
     // to preserve frame transfer time
     Andor_CheckError( 'SetExposureTime', SetExposureTime(FrameInterval)) ;
     Andor_CheckError( 'GetAcquisitionTimings',
                       GetAcquisitionTimings( ExposureTime,
                                              AccumulateTime,
                                              CycleTime )) ;
     Session.FrameTransferTime := CycleTime - FrameInterval ;
     ExposureTime := FrameInterval - Session.FrameTransferTime ;
     Andor_CheckError( 'SetExposureTime', SetExposureTime(ExposureTime)) ;
     Andor_CheckError( 'GetAcquisitionTimings',
                       GetAcquisitionTimings( ExposureTime,
                                              AccumulateTime,
                                              CycleTime )) ;
     FrameInterval := CycleTime ;

     if FrameInterval < ReadoutTime then FrameInterval:= ReadoutTime ;

     end ;


procedure Andor_GetImage(
          var Session : TAndorSession  // Camera session record
          ) ;
// ------------------------------------------------------
// Transfer images from Andor driverbuffer to main buffer
// ------------------------------------------------------
var
    i, j : Integer ;
    FramePointer : Integer ;
    NumAccumulations : Integer ;
    FirstImageNum : Integer ;
    LastImageNum : Integer ;
    ImageNum : Integer ;
    NumImages : Integer ;
    FirstValidImageNum : Integer ;
    LastValidImageNum : Integer ;
    Status : Integer ;
    Err : Integer ;
    Framerate : single ;
begin

    // Get range of new images in circular buffer
    Err := GetNumberNewImages( FirstImageNum, LastImageNum ) ;
//    FrameRate := FirstImageNum / ((TimeGetTime*0.001) - Session.TimeStart);
//    outputdebugString(PChar(format('%d %.4g',[FirstImageNum, FrameRate]))) ;
    if Err = DRV_NO_NEW_DATA then Exit ;
    Andor_CheckError( 'GetNumberNewImages', Err ) ;

    // No. of images to transfer
    NumImages := LastImageNum - FirstImageNum + 1 ;
    if NumImages < 1 then NumImages := NumImages + Session.ImageBufferSize ;

    // Get latest images from camera
    Err := GetImages( FirstImageNum,
                      LastImageNum,
                      Session.PImageBuffer,
                      Session.NumPixelsPerFrame*NumImages,
                      FirstValidImageNum,
                      LastValidImageNum ) ;
    Andor_CheckError( 'GetImages', Err ) ;

    // Copy 32 bit images into 16 bit frame buffer
    j := 0 ;
    for ImageNum := 1 to NumImages do begin
       FramePointer := Session.FrameNum*Session.NumPixelsPerFrame ;
       for i := FramePointer to FramePointer + Session.NumPixelsPerFrame -1 do begin
           PWordArray(Session.PFrameBuffer)[i] := Session.PImageBuffer[j] ;
           Inc(j) ;
           end ;
       Session.FrameNum := Session.FrameNum + 1 ;
       if Session.FrameNum >= Session.NumFrames then Session.FrameNum := 0 ;
       Session.NumFramesCopied := Session.NumFramesCopied + 1 ;
       end ;

    end ;


procedure Andor_StopCapture(
          var Session : TandorSession   // Camera session record
          ) ;
// ------------------
// Stop frame capture
// ------------------
var
    Err : Integer ;
    iBuf : Integer ;
    BufStatus : Integer ;
begin

     if not Session.CapturingImages then Exit ;

     // Stop frame capture
     Andor_CheckError( 'AbortAcquisition', AbortAcquisition ) ;

     // Close camera shutter
     Andor_CheckError( 'SetShutter',SetShutter( 1,2,20,20)) ;
     // Wait till shutter closed
     Andor_Wait(0.02) ;

     // Free image transfer buffer
     if Session.PImageBuffer <> Nil then begin
        FreeMem( Session.PImageBuffer ) ;
        Session.PImageBuffer := Nil ;
        end ;

     Session.CapturingImages := False ;   

     end;


procedure Andor_CheckError(
          FuncName : String ;   // Name of function called
          ErrNum : Integer      // Error # returned by function
          ) ;
// ------------
// Report error
// ------------
var
    Report : string ;
begin

    if ErrNum = DRV_SUCCESS then Exit ;

    Case ErrNum of
        DRV_ERROR_CODES : Report := '' ;
        DRV_SUCCESS : Report := '' ;
        DRV_VXDNOTINSTALLED : Report := 'VXD not installed' ;
        DRV_ERROR_SCAN : Report := '' ;
        DRV_ERROR_CHECK_SUM : Report := '' ;
        DRV_ERROR_FILELOAD : Report := '' ;
        DRV_UNKNOWN_FUNCTION : Report := '' ;
        DRV_ERROR_VXD_INIT : Report := '' ;
        DRV_ERROR_ADDRESS : Report := '' ;
        DRV_ERROR_PAGELOCK : Report := '' ;
        DRV_ERROR_PAGEUNLOCK : Report := '' ;
        DRV_ERROR_BOARDTEST : Report := '' ;
        DRV_ERROR_ACK : Report := '' ;
        DRV_ERROR_UP_FIFO : Report := '' ;
        DRV_ERROR_PATTERN : Report := '' ;

        DRV_ACQUISITION_ERRORS : Report := '' ;
        DRV_ACQ_BUFFER : Report := '' ;
        DRV_ACQ_DOWNFIFO_FULL : Report := '' ;
        DRV_PROC_UNKONWN_INSTRUCTION : Report := '' ;
        DRV_ILLEGAL_OP_CODE : Report := '' ;
        DRV_KINETIC_TIME_NOT_MET : Report := '' ;
        DRV_ACCUM_TIME_NOT_MET : Report := '' ;
        DRV_NO_NEW_DATA : Report := '' ;
        DRV_SPOOLERROR : Report := '' ;

        DRV_TEMPERATURE_CODES : Report := '' ;
        DRV_TEMPERATURE_OFF : Report := '' ;
        DRV_TEMPERATURE_NOT_STABILIZED : Report := '' ;
        DRV_TEMPERATURE_STABILIZED : Report := '' ;
        DRV_TEMPERATURE_NOT_REACHED : Report := '' ;
        DRV_TEMPERATURE_OUT_RANGE : Report := '' ;
        DRV_TEMPERATURE_NOT_SUPPORTED : Report := '' ;
        DRV_TEMPERATURE_DRIFT : Report := '' ;

        DRV_P1INVALID : Report := 'Invalid function parameter (P1) ' ;
        DRV_P2INVALID : Report := 'Invalid function parameter (P2) ' ;
        DRV_P3INVALID : Report := 'Invalid function parameter (P3) ' ;
        DRV_P4INVALID : Report := 'Invalid function parameter (P4) ' ;

        DRV_GENERAL_ERRORS : Report := '' ;
        DRV_INVALID_AUX : Report := '' ;
        DRV_COF_NOTLOADED : Report := '' ;
        DRV_FPGAPROG : Report := '' ;
        DRV_FLEXERROR : Report := '' ;
        DRV_GPIBERROR : Report := '' ;

        DRV_DRIVER_ERRORS	 : Report := '' ;
        DRV_INIERROR : Report := 'Unable to load DETECTOR.INI' ;
        DRV_COFERROR : Report := 'Unable to load *.COF' ;
        DRV_ACQUIRING : Report := '' ;
        DRV_IDLE : Report := '' ;
        DRV_TEMPCYCLE : Report := '' ;
        DRV_NOT_INITIALIZED : Report := '' ;
        DRV_P5INVALID : Report := '' ;
        DRV_P6INVALID : Report := '' ;
        DRV_INVALID_MODE : Report := '' ;
        DRV_INVALID_FILTER : Report := '' ;

        DRV_I2CERRORS : Report := '' ;
        DRV_I2CDEVNOTFOUND : Report := '' ;
        DRV_I2CTIMEOUT : Report := '' ;

        DRV_IOCERROR : Report := '' ;
        DRV_VRMVERSIONERROR : Report := '' ;

        DRV_ERROR_NOCAMERA : Report := '' ;
        DRV_NOT_SUPPORTED : Report := '' ;

      else Report := '' ;
      end ;

//    MessageDlg( format( 'Andor:%s (%d) %s',
//                        [FuncName,ErrNum,Report] ),
//                mtWarning, [mbOK], 0 ) ;

    end ;


function Andor_CharArrayToString(
         cBuf : Array of Char
         ) : String ;
// ---------------------------------
// Convert character array to string
// ---------------------------------
var
     i : Integer ;
begin
     i := 0 ;
     Result := '' ;
     while (cBuf[i] <> #0) and (i <= High(cBuf)) do begin
         Result := Result + cBuf[i] ;
         Inc(i) ;
         end ;
     end ;


end.
