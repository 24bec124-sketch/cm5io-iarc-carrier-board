{ ================================================================
  CM5IO DRC Rules Setup - LionCircuits Manufacturing Constraints
  Altium Designer DelphiScript
  HOW TO RUN:
    1. Click on CMSIO_IARC.PcbDoc tab (must be active)
    2. In script editor: Run > Run Script > select RunAll
  ================================================================ }

procedure AddWidthRule(Board, AName, AComment, AMinMM, APrefMM, AMaxMM);
var Rule;
begin
  Rule := PCBServer.PCBRuleFactory(eWidthConstraint);
  Rule.Name      := AName;
  Rule.Comment   := AComment;
  Rule.MinWidth  := MMsToCoord(AMinMM);
  Rule.PrefWidth := MMsToCoord(APrefMM);
  Rule.MaxWidth  := MMsToCoord(AMaxMM);
  Rule.Scope1Expression := 'All';
  Rule.Scope2Expression := 'All';
  Board.AddPCBObject(Rule);
  PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Rule.I_ObjectAddress);
end;

procedure AddClearanceRule(Board, AName, AComment, AMinMM);
var Rule;
begin
  Rule := PCBServer.PCBRuleFactory(eClearanceConstraint);
  Rule.Name           := AName;
  Rule.Comment        := AComment;
  Rule.MinClearance   := MMsToCoord(AMinMM);
  Rule.Scope1Expression := 'All';
  Rule.Scope2Expression := 'All';
  Board.AddPCBObject(Rule);
  PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Rule.I_ObjectAddress);
end;

procedure AddHoleRule(Board, AName, AComment, AMinMM, AMaxMM);
var Rule;
begin
  Rule := PCBServer.PCBRuleFactory(eHoleSizeConstraint);
  Rule.Name            := AName;
  Rule.Comment         := AComment;
  Rule.MinimumHoleSize := MMsToCoord(AMinMM);
  Rule.MaximumHoleSize := MMsToCoord(AMaxMM);
  Rule.Scope1Expression := 'All';
  Board.AddPCBObject(Rule);
  PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Rule.I_ObjectAddress);
end;

procedure AddSolderMaskRule(Board, AName, AComment, AExpMM);
var Rule;
begin
  Rule := PCBServer.PCBRuleFactory(eSolderMaskExpansion);
  Rule.Name       := AName;
  Rule.Comment    := AComment;
  Rule.Expansion  := MMsToCoord(AExpMM);
  Rule.Scope1Expression := 'All';
  Board.AddPCBObject(Rule);
  PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Rule.I_ObjectAddress);
end;

procedure AddDiffPairRule(Board, AName, AComment, AMinWmm, APrefWmm, AMaxWmm, AMinGmm, APrefGmm, AMaxGmm);
var Rule;
begin
  Rule := PCBServer.PCBRuleFactory(eDiffPairsRoutingConstraint);
  Rule.Name      := AName;
  Rule.Comment   := AComment;
  Rule.MinWidth  := MMsToCoord(AMinWmm);
  Rule.PrefWidth := MMsToCoord(APrefWmm);
  Rule.MaxWidth  := MMsToCoord(AMaxWmm);
  Rule.MinGap    := MMsToCoord(AMinGmm);
  Rule.PrefGap   := MMsToCoord(APrefGmm);
  Rule.MaxGap    := MMsToCoord(AMaxGmm);
  Rule.Scope1Expression := 'All';
  Rule.Scope2Expression := 'All';
  Board.AddPCBObject(Rule);
  PCBServer.SendMessageToRobots(Board.I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, Rule.I_ObjectAddress);
end;

procedure SetupDRCRules;
var Board;
begin
  Board := PCBServer.GetCurrentPCBBoard;
  if Board = nil then
  begin
    ShowMessage('ERROR: Make CMSIO_IARC.PcbDoc the active tab first, then run.');
    Exit;
  end;

  PCBServer.PreProcess;

  { 1. MIN TRACE WIDTH: 6mil = 0.1524mm }
  AddWidthRule(Board, 'MinTraceWidth_6mil',
    'LionCircuits 1oz: min 6mil', 0.1524, 0.1524, 5.0);

  { 2. MIN CLEARANCE trace-trace: 6mil = 0.1524mm }
  AddClearanceRule(Board, 'MinClearance_6mil',
    'LionCircuits: trace-trace min 6mil', 0.1524);

  { 3. TRACE TO COPPER POUR: 6mil }
  AddClearanceRule(Board, 'TraceToPour_6mil',
    'LionCircuits: trace to copper pour 6mil', 0.1524);

  { 4. VIA TO VIA: 12mil = 0.3048mm }
  AddClearanceRule(Board, 'ViaToVia_12mil',
    'LionCircuits: via-via min 12mil', 0.3048);

  { 5. VIA TO TRACE: 12mil }
  AddClearanceRule(Board, 'ViaToTrace_12mil',
    'LionCircuits: via-trace min 12mil', 0.3048);

  { 6. BOARD EDGE: 12mil = 0.3mm }
  AddClearanceRule(Board, 'BoardEdge_12mil',
    'LionCircuits: circuit to board edge 0.3mm', 0.3);

  { 7. SILK TO PAD: 6mil }
  AddClearanceRule(Board, 'SilkToPad_6mil',
    'LionCircuits: silkscreen to pad 6mil', 0.1524);

  { 8. SOLDER MASK EXPANSION: 0.076mm (3mil) per side ? 6mil dam }
  AddSolderMaskRule(Board, 'SolderMask_3mil_expansion',
    'LionCircuits: solder mask dam 6mil total', 0.076);

  { 9. DRILL HOLE: 0.35mm min, 6.3mm max }
  AddHoleRule(Board, 'DrillHole_0p35_6p3mm',
    'LionCircuits: drill 0.35-6.3mm', 0.35, 6.3);

  { 10. DIFF PAIR 100 OHM
        PCIe / HDMI / MIPI DSI+CSI / USB3 SuperSpeed
        Calculated: W=0.18mm, S=0.20mm ? Zdiff=101.7O
        Stackup: H=0.12mm prepreg, Er=4.2, T=0.035mm copper }
  AddDiffPairRule(Board, 'DiffPair_100R',
    '100R: PCIe/HDMI/MIPI/USB3SS | W=0.18mm G=0.20mm ? 101.7ohm',
    0.16, 0.18, 0.20,   { width min/pref/max }
    0.18, 0.20, 0.22);  { gap   min/pref/max }

  { 11. DIFF PAIR 90 OHM
        USB 2.0 High Speed / USB OTG
        Calculated: W=0.20mm, S=0.20mm ? Zdiff=95.5O (within ±10% of 90R)
        Stackup: H=0.12mm prepreg, Er=4.2, T=0.035mm copper }
  AddDiffPairRule(Board, 'DiffPair_90R_USB',
    '90R: USB2.0/OTG | W=0.20mm G=0.20mm ? 95.5ohm',
    0.18, 0.20, 0.22,   { width min/pref/max }
    0.18, 0.20, 0.22);  { gap   min/pref/max }

  PCBServer.PostProcess;
  Board.GraphicallyInvalidate;

  ShowMessage(
    'SUCCESS - All DRC Rules Applied!' + #13#10 +
    '==================================' + #13#10 +
    'Min Trace Width      : 6mil (0.1524mm)' + #13#10 +
    'Min Clearance        : 6mil' + #13#10 +
    'Trace to Pour        : 6mil' + #13#10 +
    'Via to Via           : 12mil (0.3048mm)' + #13#10 +
    'Via to Trace         : 12mil' + #13#10 +
    'Board Edge           : 12mil (0.3mm)' + #13#10 +
    'Silk to Pad          : 6mil' + #13#10 +
    'Solder Mask Exp      : 3mil/side (6mil dam)' + #13#10 +
    'Drill Hole           : 0.35 - 6.3mm' + #13#10 +
    '100R Diff (PCIe/HDMI/MIPI/USB3): W=0.18 G=0.20mm' + #13#10 +
    '90R  Diff (USB2/OTG):            W=0.20 G=0.20mm' + #13#10 +
    #13#10 +
    'NEXT: Design > Rules > High Speed > Diff Pairs' + #13#10 +
    'Set net scope for each diff pair rule.'
  );
end;

procedure RunAll;
begin
  SetupDRCRules;
end;
