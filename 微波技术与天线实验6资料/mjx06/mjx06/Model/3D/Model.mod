'# MWS Version: Version 2022.4 - Apr 26 2022 - ACIS 31.0.1 -

'# length = mm
'# frequency = GHz
'# time = ns
'# frequency range: fmin = 1 fmax = 3
'# created = '[VERSION]2022.4|31.0.1|20220426[/VERSION]


'@ use template: Antenna - Planar_3.cfg

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
'set the units
With Units
    .Geometry "mm"
    .Frequency "GHz"
    .Voltage "V"
    .Resistance "Ohm"
    .Inductance "H"
    .TemperatureUnit  "Kelvin"
    .Time "ns"
    .Current "A"
    .Conductance "Siemens"
    .Capacitance "F"
End With

'----------------------------------------------------------------------------

'set the frequency range
Solver.FrequencyRange "1", "3"

'----------------------------------------------------------------------------

Plot.DrawBox True

With Background
     .Type "Normal"
     .Epsilon "1.0"
     .Mu "1.0"
     .XminSpace "0.0"
     .XmaxSpace "0.0"
     .YminSpace "0.0"
     .YmaxSpace "0.0"
     .ZminSpace "0.0"
     .ZmaxSpace "0.0"
End With

With Boundary
     .Xmin "expanded open"
     .Xmax "expanded open"
     .Ymin "expanded open"
     .Ymax "expanded open"
     .Zmin "expanded open"
     .Zmax "expanded open"
     .Xsymmetry "none"
     .Ysymmetry "none"
     .Zsymmetry "none"
End With

' optimize mesh settings for planar structures

With Mesh
     .MergeThinPECLayerFixpoints "True"
     .RatioLimit "20"
     .AutomeshRefineAtPecLines "True", "6"
     .FPBAAvoidNonRegUnite "True"
     .ConsiderSpaceForLowerMeshLimit "False"
     .MinimumStepNumber "5"
     .AnisotropicCurvatureRefinement "True"
     .AnisotropicCurvatureRefinementFSM "True"
End With

With MeshSettings
     .SetMeshType "Hex"
     .Set "RatioLimitGeometry", "20"
     .Set "EdgeRefinementOn", "1"
     .Set "EdgeRefinementRatio", "6"
End With

With MeshSettings
     .SetMeshType "HexTLM"
     .Set "RatioLimitGeometry", "20"
End With

With MeshSettings
     .SetMeshType "Tet"
     .Set "VolMeshGradation", "1.5"
     .Set "SrfMeshGradation", "1.5"
End With

' change mesh adaption scheme to energy
' 		(planar structures tend to store high energy
'     	 locally at edges rather than globally in volume)

MeshAdaption3D.SetAdaptionStrategy "Energy"

' switch on FD-TET setting for accurate farfields

FDSolver.ExtrudeOpenBC "True"

PostProcess1D.ActivateOperation "vswr", "true"
PostProcess1D.ActivateOperation "yz-matrices", "true"

With FarfieldPlot
	.ClearCuts ' lateral=phi, polar=theta
	.AddCut "lateral", "0", "1"
	.AddCut "lateral", "90", "1"
	.AddCut "polar", "90", "1"
End With

'----------------------------------------------------------------------------

Dim sDefineAt As String
sDefineAt = "2.45"
Dim sDefineAtName As String
sDefineAtName = "2.45"
Dim sDefineAtToken As String
sDefineAtToken = "f="
Dim aFreq() As String
aFreq = Split(sDefineAt, ";")
Dim aNames() As String
aNames = Split(sDefineAtName, ";")

Dim nIndex As Integer
For nIndex = LBound(aFreq) To UBound(aFreq)

Dim zz_val As String
zz_val = aFreq (nIndex)
Dim zz_name As String
zz_name = sDefineAtToken & aNames (nIndex)

' Define E-Field Monitors
With Monitor
    .Reset
    .Name "e-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Efield"
    .MonitorValue  zz_val
    .Create
End With

' Define Farfield Monitors
With Monitor
    .Reset
    .Name "farfield ("& zz_name &")"
    .Domain "Frequency"
    .FieldType "Farfield"
    .MonitorValue  zz_val
    .ExportFarfieldSource "False"
    .Create
End With

Next

'----------------------------------------------------------------------------

With MeshSettings
     .SetMeshType "Hex"
     .Set "Version", 1%
End With

With Mesh
     .MeshType "PBA"
End With

'set the solver type
ChangeSolverType("HF Time Domain")

'----------------------------------------------------------------------------

'@ define material: Rogers RT5880 (lossy)

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
With Material
     .Reset
     .Name "Rogers RT5880 (lossy)"
     .Folder ""
.FrqType "all"
.Type "Normal"
.SetMaterialUnit "GHz", "mm"
.Epsilon "2.2"
.Mu "1.0"
.Kappa "0.0"
.TanD "0.0009"
.TanDFreq "10.0"
.TanDGiven "True"
.TanDModel "ConstTanD"
.KappaM "0.0"
.TanDM "0.0"
.TanDMFreq "0.0"
.TanDMGiven "False"
.TanDMModel "ConstKappa"
.DispModelEps "None"
.DispModelMu "None"
.DispersiveFittingSchemeEps "General 1st"
.DispersiveFittingSchemeMu "General 1st"
.UseGeneralDispersionEps "False"
.UseGeneralDispersionMu "False"
.Rho "0.0"
.ThermalType "Normal"
.ThermalConductivity "0.20"
.SetActiveMaterial "all"
.Colour "0.94", "0.82", "0.76"
.Wireframe "False"
.Transparency "0"
.Create
End With

'@ new component: component1

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
Component.New "component1"

'@ define brick: component1:SUB

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
With Brick
     .Reset 
     .Name "SUB" 
     .Component "component1" 
     .Material "Rogers RT5880 (lossy)" 
     .Xrange "-L", "1.5*L" 
     .Yrange "-W", "W" 
     .Zrange "0", "H" 
     .Create
End With

'@ define material: Copper (annealed)

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
With Material
     .Reset
     .Name "Copper (annealed)"
     .Folder ""
.FrqType "static"
.Type "Normal"
.SetMaterialUnit "Hz", "mm"
.Epsilon "1"
.Mu "1.0"
.Kappa "5.8e+007"
.TanD "0.0"
.TanDFreq "0.0"
.TanDGiven "False"
.TanDModel "ConstTanD"
.KappaM "0"
.TanDM "0.0"
.TanDMFreq "0.0"
.TanDMGiven "False"
.TanDMModel "ConstTanD"
.DispModelEps "None"
.DispModelMu "None"
.DispersiveFittingSchemeEps "Nth Order"
.DispersiveFittingSchemeMu "Nth Order"
.UseGeneralDispersionEps "False"
.UseGeneralDispersionMu "False"
.FrqType "all"
.Type "Lossy metal"
.SetMaterialUnit "GHz", "mm"
.Mu "1.0"
.Kappa "5.8e+007"
.Rho "8930.0"
.ThermalType "Normal"
.ThermalConductivity "401.0"
.SpecificHeat "390", "J/K/kg"
.MetabolicRate "0"
.BloodFlow "0"
.VoxelConvection "0"
.MechanicsType "Isotropic"
.YoungsModulus "120"
.PoissonsRatio "0.33"
.ThermalExpansionRate "17"
.Colour "1", "1", "0"
.Wireframe "False"
.Reflection "False"
.Allowoutline "True"
.Transparentoutline "False"
.Transparency "0"
.Create
End With

'@ define brick: component1:PATCH

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
With Brick
     .Reset 
     .Name "PATCH" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "-L/2", "L/2" 
     .Yrange "-W/2", "W/2" 
     .Zrange "H", "H+T" 
     .Create
End With

'@ define brick: component1:FEEDLINE

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
With Brick
     .Reset 
     .Name "FEEDLINE" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "L/2", "L/2+22.882169004892464" 
     .Yrange "-1.93463134765625/2", "1.93463134765625/2" 
     .Zrange "H", "H+T" 
     .Create
End With

'@ pick face

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
Pick.PickFaceFromId "component1:SUB", "2"

'@ define extrude: component1:GND

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
With Extrude 
     .Reset 
     .Name "GND" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Mode "Picks" 
     .Height "T" 
     .Twist "0.0" 
     .Taper "0.0" 
     .UsePicksForHeight "False" 
     .DeleteBaseFaceSolid "False" 
     .KeepMaterials "False" 
     .ClearPickedFace "True" 
     .Create 
End With

'@ pick face

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
Pick.PickFaceFromId "component1:FEEDLINE", "6"

'@ define port:1

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
' Port constructed by macro Solver -> Ports -> Calculate port extension coefficient


With Port
  .Reset
  .PortNumber "1"
  .NumberOfModes "1"
  .AdjustPolarization False
  .PolarizationAngle "0.0"
  .ReferencePlaneDistance "0"
  .TextSize "50"
  .Coordinates "Picks"
  .Orientation "Positive"
  .PortOnBound "True"
  .ClipPickedPortToBound "False"
  .XrangeAdd "0", "0"
  .YrangeAdd "1.575*8.37", "1.575*8.37"
  .ZrangeAdd "1.575", "1.575*8.37"
  .Shield "PEC"
  .SingleEnded "False"
  .Create
End With

'@ define time domain solver parameters

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ set PBA version

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
Discretizer.PBAVersion "2022042622"

'@ rename block: component1:FEEDLINE to: component1:FEEDLINE1

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
Solid.Rename "component1:FEEDLINE", "FEEDLINE1"

'@ define brick: component1:FEEDLINE2

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
With Brick
     .Reset 
     .Name "FEEDLINE2" 
     .Component "component1" 
     .Material "Copper (annealed)" 
     .Xrange "L/2+22.882169004892464", "1.5*L" 
     .Yrange "-4.74365234375/2", "4.74365234375/2" 
     .Zrange "H", "H+T" 
     .Create
End With

'@ delete port: port1

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
Port.Delete "1"

'@ pick face

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
Pick.PickFaceFromId "component1:FEEDLINE2", "6"

'@ define port:1

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
' Port constructed by macro Solver -> Ports -> Calculate port extension coefficient


With Port
  .Reset
  .PortNumber "1"
  .NumberOfModes "1"
  .AdjustPolarization False
  .PolarizationAngle "0.0"
  .ReferencePlaneDistance "0"
  .TextSize "50"
  .Coordinates "Picks"
  .Orientation "Positive"
  .PortOnBound "True"
  .ClipPickedPortToBound "False"
  .XrangeAdd "0", "0"
  .YrangeAdd "1.575*8.37", "1.575*8.37"
  .ZrangeAdd "1.575", "1.575*8.37"
  .Shield "PEC"
  .SingleEnded "False"
  .Create
End With

'@ farfield plot options

'[VERSION]2022.4|31.0.1|20220426[/VERSION]
With FarfieldPlot 
     .Plottype "3D" 
     .Vary "angle2" 
     .Theta "90" 
     .Phi "90" 
     .Step "5" 
     .Step2 "5" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Directivity" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "True" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

