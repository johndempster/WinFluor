unit SetLasersUnit;
// ---------------------------------------------------------
// Set intensity of lasers (Optoscan + Lasers light source
// ---------------------------------------------------------
// 10.03.09 Laser intensity can now be set from live image window
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ValidatedEdit;

type
  TSetLasersFrm = class(TForm)
    LasersGrp: TGroupBox;
    edLaser1Intensity: TValidatedEdit;
    Label31: TLabel;
    Label1: TLabel;
    edLaser2Intensity: TValidatedEdit;
    Label2: TLabel;
    edLaser3Intensity: TValidatedEdit;
    sbLaser1: TScrollBar;
    sbLaser2: TScrollBar;
    sbLaser3: TScrollBar;
    bOK: TButton;
    bCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure bOKClick(Sender: TObject);
    procedure sbLaser1Change(Sender: TObject);
    procedure sbLaser2Change(Sender: TObject);
    procedure sbLaser3Change(Sender: TObject);
    procedure edLaser1IntensityKeyPress(Sender: TObject; var Key: Char);
    procedure edLaser2IntensityKeyPress(Sender: TObject; var Key: Char);
    procedure edLaser3IntensityKeyPress(Sender: TObject; var Key: Char);
    procedure bCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SetLasersFrm: TSetLasersFrm;

implementation

uses LightSourceUnit, Main, RecUnit, SnapUnit;

{$R *.dfm}

procedure TSetLasersFrm.FormShow(Sender: TObject);
begin
     sbLaser1.Position := Round(LightSource.LaserIntensity[1]) ;
     edLaser1Intensity.Value := sbLaser1.Position ;
     sbLaser2.Position := Round(LightSource.LaserIntensity[2]) ;
     edLaser2Intensity.Value := sbLaser2.Position ;
     sbLaser3.Position := Round(LightSource.LaserIntensity[3]) ;
     edLaser3Intensity.Value := sbLaser3.Position ;

     ClientWidth := LasersGrp.Left + LasersGrp.Width + 5 ;
     ClientHeight := bOK.Top + bOK.Height + 5 ;

     end;

procedure TSetLasersFrm.bOKClick(Sender: TObject);
// -----------------
// OK button pressed
// -----------------
begin

     LightSource.LaserIntensity[1] := edLaser1Intensity.Value ;
     LightSource.LaserIntensity[2] := edLaser2Intensity.Value ;
     LightSource.LaserIntensity[3] := edLaser3Intensity.Value ;

     if Mainfrm.FormExists('RecordFrm') then begin
        // Restart recording
        if RecordFrm.CameraRunning then begin
           RecordFrm.StopCamera ;
           RecordFrm.StartCamera ;
           end ;
        end ;

     if Mainfrm.FormExists('SnapFrm') then begin
        // Restart recording
        if SnapFrm.CameraRunning then begin
           SnapFrm.StopCamera ;
           SnapFrm.StartCamera ;
           end ;
        end ;

     Hide ;

     end;

     
procedure TSetLasersFrm.sbLaser1Change(Sender: TObject);
begin
     edLaser1Intensity.Value := sbLaser1.Position ;
     end;

procedure TSetLasersFrm.sbLaser2Change(Sender: TObject);
begin
     edLaser2Intensity.Value := sbLaser2.Position ;
     end;


procedure TSetLasersFrm.sbLaser3Change(Sender: TObject);
begin
     edLaser3Intensity.Value := sbLaser3.Position ;
     end;


procedure TSetLasersFrm.edLaser1IntensityKeyPress(Sender: TObject;
  var Key: Char);
begin
     if Key = #13 then begin
        sbLaser1.Position := Round(edLaser1Intensity.Value) ;
        end ;
     end;

procedure TSetLasersFrm.edLaser2IntensityKeyPress(Sender: TObject;
  var Key: Char);
begin
     if Key = #13 then begin
        sbLaser2.Position := Round(edLaser2Intensity.Value) ;
        end ;
     end;


procedure TSetLasersFrm.edLaser3IntensityKeyPress(Sender: TObject;
  var Key: Char);
begin
     if Key = #13 then begin
        sbLaser3.Position := Round(edLaser3Intensity.Value) ;
        end ;
     end;


procedure TSetLasersFrm.bCancelClick(Sender: TObject);
// ---------------------
// Cancel button pressed
// ---------------------
begin
     Hide ;
     end;

end.
